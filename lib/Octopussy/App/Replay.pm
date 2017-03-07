package Octopussy::App::Replay;

=head1 NAME

Octopussy::App::Replay

=head1 DESCRIPTION

Module handling everything for octo_replay program

=head1 SYNOPSIS

octo_replay --device <device> --service <service>
--begin YYYYMMDDHHMM --end YYYYMMDDHHMM

=head1 OPTIONS

=over 8

=item B<-h,--help>

Prints this help

=item B<-v,--version>

Prints program version

=item B<--device> I<devicename>

Device you want to replay

=item B<--service> I<servicename>

Service you want to replay

=item B<--begin> YYYYMMDDHHMM

Begining datetime from when you want to replay

=item B<--end> YYYYMMDDHHMM

Ending datetime until when you want to replay

=back

=cut

use strict;
use warnings;

use FindBin;
use Getopt::Long qw(:config no_ignore_case);
use Pod::Find qw(pod_where);
use Pod::Usage;

use lib "$FindBin::Bin/../lib";

use Octopussy;
use Octopussy::Device;
use Octopussy::FS;
use Octopussy::Logs;
use Octopussy::Storage;

my $PROGRAM      = 'octo_replay';
my $OCTO_VERSION = Octopussy::Version();

=head1 SUBROUTINES/METHODS

=head2 run(@ARGV)

Runs Program with @ARGV options

=cut

sub run
{
    my $self = shift;
    local @ARGV = @_;

    my %opt  = ();
    my @options =
    ('help|h', 'version|v', 'device=s', 'service=s', 'begin=s', 'end=s');
    my $status = GetOptions(\%opt, @options);

    if ($opt{version})
    {
        printf "%s for Octopussy %s\n", $PROGRAM, $OCTO_VERSION;
        return (0);
    }

    return (usage()) if ((!$status) || ($opt{help}));

    return (usage(Octopussy::Device::String_List(undef)))
    if (!defined $opt{device});
    return (usage(Octopussy::Device::String_Services($opt{device})))
    if (!defined $opt{service});

    return (usage()) if ((!defined $opt{begin}) || (!defined $opt{end}));

    replay(\%opt);

    return ($status);
}

=head2 usage($msg)

Prints Program Usage

=cut

sub usage
{
    my $msg = shift;

    if (defined $msg)
    {
        pod2usage(
        -input    => pod_where({-inc => 1}, __PACKAGE__),
        -verbose  => 99,
        -sections => [qw(SYNOPSIS OPTIONS)],
        -message  => "\n$msg\n",
        -exitval  => 'NOEXIT'
        );
    }
    else
    {
        pod2usage(
        -input    => pod_where({-inc => 1}, __PACKAGE__),
        -verbose  => 99,
        -sections => [qw(SYNOPSIS OPTIONS)],
        -exitval  => 'NOEXIT'
        );
    }

    return (-1);
}

=head2 replay($opt)

Replays logs

=cut

sub replay
{
    my $opt = shift;

    my $count = 0;

    # 'device', 'service', 'begin' and 'end' should be defined
    return ($count)	if ((!defined $opt->{device})
    || (!defined $opt->{service})
    || (!defined $opt->{begin})
    || (!defined $opt->{end}));

    my $dir_incoming = Octopussy::Storage::Directory_Incoming($opt->{device});
    # $dir_incoming undefined => invalid device
    return ($count)	if (!defined $dir_incoming);

    $dir_incoming .= "$opt->{device}/Incoming/";

    my ($files) =
    Octopussy::Logs::Get_TimePeriod_Files($opt->{device}, $opt->{service},
    $opt->{begin}, $opt->{end});
    foreach my $min (sort keys %{$files})
    {
        my @logs = ();
        foreach my $f (@{$files->{$min}})
        {
            my $cat = ($f =~ /.+\.gz$/ ? 'zcat' : 'cat');
            if (defined open my $FILE, '-|', "$cat \"$f\"")
            {
                while (<$FILE>) { push @logs, $_; }
                close $FILE;
                unlink $f;
                $count++;
            }
        }

        if ($min =~ /^(\d{4})(\d{2})(\d{2})(\d{2})(\d{2})$/)
        {
            my $incoming = $dir_incoming . "$1/$2/$3/msg_${4}h${5}_00.log";
            if (defined open my $INCOMING, '>', $incoming)
            {
                foreach my $l (sort @logs) { print {$INCOMING} $l; }
                close $INCOMING;
                Octopussy::FS::Chown($incoming);
            }
        }

    }

    return ($count);
}

1;

=head1 AUTHOR

Sebastien Thebert <octopussy@onetool.pm>

=cut

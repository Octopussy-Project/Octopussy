#!/usr/bin/env perl

=head1 NAME

syslog2iso8601.pl - Octopussy program to convert 'syslog format' logs to 'iso8601' logs

=head1 SYNOPSIS

syslog2iso8601.pl --device <device> --service <service> 

=head1 DESCRIPTION

=cut

use strict;
use warnings;
use Readonly;

use Getopt::Long;
Getopt::Long::Configure('bundling');

use DateTime;
use DateTime::Format::Strptime;

use AAT::Utils qw( ARRAY );
use Octopussy;
use Octopussy::Logs;

Readonly my $PROG_NAME    => 'syslog2iso8601.pl';
Readonly my $PROG_VERSION => Octopussy::Version();

my $help;
my ($opt_device, $opt_service, $opt_timezone) = (undef, undef, undef);

=head1 FUNCTIONS

=head2 Help()

Prints Help

=cut

sub Help
{
    my $help_str = <<"EOF";

$PROG_NAME (version $PROG_VERSION)

 Usage: $PROG_NAME --device <device> --service <service> --timezone <+/-HH:MM>

EOF

    print $help_str;
    if (!defined $opt_device)
    {
        print ' ' . Octopussy::Device::String_List(undef) . "\n";
    }
    elsif (!defined $opt_service)
    {
        print ' '
            . Octopussy::Device::String_Services(ARRAY($opt_device)) . "\n";
    }
    print "\n";

    exit;
}

#
# MAIN
#

my $status = GetOptions(
    'h'         => \$help,
    'help'      => \$help,
    'device=s'  => \$opt_device,
    'service=s' => \$opt_service,
    'timezone=s' => \$opt_timezone,
);

Help()
    if ((!$status)
    || ($help)
    || (!defined $opt_device)
    || (!defined $opt_service)
    || (!defined $opt_timezone));

my ($files, $total) =
    Octopussy::Logs::Get_TimePeriod_Files($opt_device, $opt_service, '197001010000', '202001010000');

my $strp = new DateTime::Format::Strptime(pattern => '%Y %h %e %T');

foreach my $min (sort keys %{$files})
{
    my @logs = ();
    foreach my $f (@{$files->{$min}})
    {
    	if ($f =~ /\/(\d{4})\/\d{2}\/\d{2}\/msg_/)
    	{
            my $year = $1;
            if (defined open my $FILE, '-|', "zcat \"$f\"")
            {
                while (<$FILE>)
                { 
            	   if ($_ =~ /^(\w{3}) \s?(\d{1,2}) (\d\d:\d\d:\d\d) (.*)$/)
            	   {
            	       my $dt = $strp->parse_datetime("$year $1 $2 $3");
            	       my $str = sprintf("%sT%s.000000%s %s", $dt->ymd('-'), $dt->hms(':'), $opt_timezone, $4);  	
            	       print "$str\n";
            	       push @logs, $str;
            	   }
                }
                close $FILE;
            }
            #unlink $f;
        }
    }
=head2
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
=cut
}

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut

1;
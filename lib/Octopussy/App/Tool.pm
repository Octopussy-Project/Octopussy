package Octopussy::App::Tool;

=head1 NAME

Octopussy::App::Tool

=head1 DESCRIPTION

Module handling everything for octo_tool program

octo_tool backup - Backups Octopussy configuration
octo_tool cache_clear - Clears Cache (msgid_stats or taxonomy_stats)
octo_tool message_copy - Copies Message from a Service to another Service
octo_tool message_move - Moves Message from a Service to another Service
octo_tool service_clone - Clones a Service
octo_tool table_clone - Clones a Table

=head1 SYNOPSIS

octo_tool <task> [options]

octo_tool backup <filename>

octo_tool cache_clear msgid_stats|taxonomy_stats

octo_tool message_copy <msgid_src> <msg_dst>

octo_tool message_move <msgid_src> <msg_dst>

octo_tool service_clone <servicename> <cloned_servicename>

octo_tool table_clone <tablename> <cloned_tablename>

=head1 OPTIONS

=over 8

=item B<-h,--help>

Prints this Help

=item B<-v,--version>

Prints version

=back

=cut

use strict;
use warnings;

use FindBin;
use Getopt::Long qw(:config no_ignore_case);
use Pod::Find qw(pod_where);
use Pod::Usage;
use POSIX qw(strftime);

use lib "$FindBin::Bin/../lib";

use Octopussy;
use Octopussy::App;
use Octopussy::Cache;
use Octopussy::Configuration;
use Octopussy::Service;
use Octopussy::Table;

my $OCTO_VERSION = Octopussy::Version();
my $PROGRAM = 'octo_tool';
my $VERSION = '0.6';

my %task   = (
    backup        => \&Backup,
    cache_clear   => \&Cache_Clear,
    message_copy  => \&Message_Copy,
    message_move  => \&Message_Move,
    service_clone => \&Service_Clone,
    table_clone   => \&Table_Clone,
);

__PACKAGE__->run(@ARGV) unless caller;

=head1 SUBROUTINES/METHODS

=head2 run(@ARGV)

=cut

sub run
{
    my $self = shift;
    my %opt  = ();

    return (-1) if (!Octopussy::App::Valid_User($PROGRAM));

    local @ARGV = @_;
    my @options = ('help|h', 'version|v');
    my $status = GetOptions(\%opt, @options);

    if ($opt{version})
    {
        printf "%s %s for Octopussy %s\n", $PROGRAM, $VERSION, $OCTO_VERSION;
        return (0);
    }

  	Usage()	if ((!$status) || ($opt{help}));

	my $t = $ARGV[0];
	Usage('[ERROR] You need to specify a task')	if (!defined $t); 	
	my @args = @ARGV;
	shift @args;
	
	if (defined $task{$t})
	{
		$task{$t}(@args);
	}
	else
	{
		Usage('[ERROR] Invalid Task');
	}
	
	return ($status);
}

=head2 Usage($msg)

Prints Script Usage

=cut

sub Usage
{
    my $msg = shift;

    if (defined $msg)
    {
        pod2usage(
			-input => pod_where({-inc => 1}, __PACKAGE__),
            -verbose  => 99,
            -sections => [qw(SYNOPSIS OPTIONS)],
            -message  => "\n$msg\n"
        );
    }
    else
    {
        pod2usage(
			-input => pod_where({-inc => 1}, __PACKAGE__),
			-verbose => 99, 
			-sections => [qw(SYNOPSIS OPTIONS)]
		);
    }

    return (-1);
}

=head2 Backup($filename)

Backups Octopussy configuration

=cut

sub Backup
{
    my $filename = shift;

	Usage('[ERROR] Backup filename missing.') if (!defined $filename);

    my $timestamp = strftime("%Y%m%d%H%M%S", localtime);
    $filename .= ($filename !~ /\.tgz$/ ? "_${timestamp}.tgz" : '');
    Octopussy::Configuration::Backup($filename);

    return ($filename);
}

=head2 Cache_Clear($cache_name)

Clears Cache 'msgid_stats' or 'taxonomy_stats'

=cut

sub Cache_Clear
{
    my $cache_name = shift;

    Usage('[ERROR] Invalid number of args.') if (!defined $cache_name);

    if ($cache_name eq 'msgid_stats')
    {
        Octopussy::Cache::Clear_MsgID_Stats();
    }
    elsif ($cache_name eq 'taxonomy_stats')
    {
        Octopussy::Cache::Clear_Taxonomy_Stats();
    }
}

=head2 Message_Copy($msgid_src, $msgid_dst)

Copies Message 'msgid_src' to Message 'msgid_dst'

=cut

sub Message_Copy
{
    my ($msgid_src, $msgid_dst) = @_;

    Usage('[ERROR] Invalid number of args.') if (!defined $msgid_dst);

    Octopussy::Service::Copy_Message($msgid_src, $msgid_dst);

    return ($msgid_dst);
}

=head2 Message_Move($msgid_src, $msgid_dst)

Moves Message 'msgid_src' to Message 'msgid_dst'

=cut

sub Message_Move
{
    my ($msgid_src, $msgid_dst) = @_;

    Usage('[ERROR] Invalid number of args.') if (!defined $msgid_dst);

    my $nb_errors = Octopussy::Service::Copy_Message($msgid_src, $msgid_dst);
    if ($nb_errors == 0)
    {
        my ($serv_src) = $msgid_src =~ /^(.+):.+$/;
        Octopussy::Service::Remove_Message($serv_src, $msgid_src);
    }

    return ($msgid_dst);
}

=head2 Service_Clone($service_orig, $service_clone)

Clones Service '$service_orig' in '$service_clone'

=cut

sub Service_Clone
{
    my ($service_orig, $service_clone) = @_;

    Usage('[ERROR] Invalid number of args.') if (!defined $service_clone);

    my $service_orig_filename  = Octopussy::Service::Filename($service_orig);
    my $service_clone_filename = Octopussy::Service::Filename($service_clone);
    Usage("[ERROR] Service '$service_orig' doesn't exist !")
        if (!-f $service_orig_filename);
    Usage("[ERROR] Service '$service_clone' already exists !")
        if ((defined $service_clone_filename) && (-f $service_clone_filename));

    Octopussy::Service::Clone($service_orig, $service_clone);

    return ($service_clone);
}

=head2 Table_Clone($table_orig, $table_clone)

Clones Table '$table_orig' in '$table_clone'

=cut

sub Table_Clone
{
    my ($table_orig, $table_clone) = @_;

    Usage('[ERROR] Invalid number of args.') if (!defined $table_clone);

    my $table_orig_filename  = Octopussy::Table::Filename($table_orig);
    my $table_clone_filename = Octopussy::Table::Filename($table_clone);
    Usage("[ERROR] Table '$table_orig' doesn't exist !")
        if (!-f $table_orig_filename);
    Usage("[ERROR] Table '$table_clone' already exists !")
        if ((defined $table_clone_filename) && (-f $table_clone_filename));
    Octopussy::Table::Clone($table_orig, $table_clone);

    return ($table_clone);
}

1;

=head1 AUTHOR

Sebastien Thebert <octopussy@onetool.pm>

=cut

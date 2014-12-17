#!/usr/bin/perl

=head1 NAME

xml2json.pl - Script to migrate Octopussy XML configuration files to JSON

=head1 SYNOPSIS

xml2json.pl <filename.xml> [<filename2.xml> ... <filenameX.xml>]
find /var/lib/octopussy/conf -iname *.xml | xml2json.pl

=cut

use strict;
use warnings;

use English qw( -no_match_vars );
use File::Slurp;
use JSON;
use XML::Simple;

my %action = (
	octopussy_device => \&json_device,
	octopussy_loglevel => \&json_loglevel,
	octopussy_service => \&json_service,
	octopussy_table => \&json_table,
	octopussy_taxonomy => \&json_taxonomy,
	octopussy_timeperiods => \&json_timeperiods,
	octopussy_types => \&json_types,
	Octopussy_users => \&json_user,
	);

=head1 SUBROUTINES

=head2 json_device($conf)

=cut

sub json_device
{
	printf "Device\n";
}

=head2 json_loglevel($conf)

Converts loglevel to JSON format

=cut

sub json_loglevel
{
    my $conf = shift;

    my @loglevel = ();
    foreach my $l (reverse sort { $a->{level} <=> $b->{level} } @{$conf->{loglevel}})
    {
        push @loglevel, $l;
    }

    return (to_json(\@loglevel, {pretty => 1}));
}

=head2 json_service($conf)

Converts service to JSON format

=cut

sub json_service
{
	my $conf = shift;

	my @messages = ();
	foreach my $m (sort { $a->{rank} cmp $b->{rank} } @{$conf->{message}})
	{
		$m->{id} = (split(/:/, $m->{msg_id}))[1];
		delete $m->{msg_id};
    	delete $m->{rank};
    	push @messages, $m;
    }
    delete $conf->{message};
    delete $conf->{nb_messages};
    $conf->{messages} = \@messages;

    return (to_json($conf, {pretty => 1}));
}

=head2 json_table($conf)

Converts table to JSON format

=cut

sub json_table
{
	my $conf = shift;
	
	my @fields = ();
	foreach my $f (sort { $a->{title} cmp $b->{title} } @{$conf->{field}})
    {
    	push @fields, { name => $f->{title}, type => $f->{type} };
    }
    delete $conf->{field};
    $conf->{fields} = \@fields;

    return (to_json($conf, {pretty => 1}));
}

=head2 json_taxonomy($conf)

Converts taxonomy to JSON format

=cut

sub json_taxonomy
{
    my $conf = shift;

    my @taxonomy = ();
    foreach my $t (sort { $a->{value} cmp $b->{value} } @{$conf->{taxonomy}})
    {
        push @taxonomy, $t;
    }

    return (to_json(\@taxonomy, {pretty => 1}));
}

=head2 json_timeperiods($conf)

Converts timeperiods to JSON format

=cut

sub json_timeperiods
{
    my $conf = shift;

    my @timeperiods = ();
    foreach my $t (sort { $a->{label} cmp $b->{label} } @{$conf->{timeperiod}})
    {
        $t->{days} = $t->{dt};
        delete $t->{dt};
        push @timeperiods, $t;
    }

    return (to_json(\@timeperiods, {pretty => 1}));
}

=head2 json_types($conf)

Converts types to JSON format

=cut

sub json_types
{
    my $conf = shift;

    my @types = ();
    foreach my $t (sort { $a->{type_id} cmp $b->{type_id} } @{$conf->{type}})
    {
        $t->{id} = $t->{type_id};
        delete $t->{type_id};
        $t->{regex} = $t->{re};
        delete $t->{re};
        push @types, $t;
    }

    return (to_json(\@types, {pretty => 1}));
}

=head2 json_user($conf)

=cut

sub json_user
{
	my $conf = shift;

	my @users = ();
	foreach my $u (@{$conf->{user}})
    {
		delete $u->{menu_mode};
		delete $u->{theme};
        push @users, $u;
    }

	return (to_json({ users => \@users }, {pretty => 1}));	
}

=head2 xml_read($filename)

Read XML file '$filename'

=cut

sub xml_read
{
	my $filename = shift;
	
	my %XML_INPUT_OPTIONS = (KeepRoot => 1, KeyAttr => [], ForceArray => 1);

	if ((defined $filename) && (-f $filename))
	{
    	my $conf = eval { XMLin($filename, %XML_INPUT_OPTIONS); };
        die "[ERROR] Unable to read XML file $filename"	if ($EVAL_ERROR);

		return ($conf)
	}
	die "[ERROR] XML file $filename doesn't exist";
}

# loop on each file from command line
my @files = (@ARGV ? @ARGV : <STDIN>);
my $count = 0;
foreach my $filename (@files)
{
	chomp $filename;
	my $conf = xml_read($filename);
	my $type = (keys %{$conf})[0];
	my $str_json = $action{$type}($conf->{$type}->[0]);
	my $filename_json = $filename;
	$filename_json =~ s/\.xml$/\.json/i;
	$count++;
	printf "[%03d] %s: %s => %s\n", $count, $type, $filename, $filename_json;
	write_file($filename_json, { binmode => ':utf8' }, $str_json);
}

=head1 AUTHOR

Sebastien Thebert <octopussy@onetool.pm>

=cut

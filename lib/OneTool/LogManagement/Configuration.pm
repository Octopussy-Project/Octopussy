package OneTool::LogManagement::Configuration;

=head1 NAME

OneTool::LogManagement::Configuration - OneTool LogManagement Configuration module

=cut

use strict;
use warnings;

use File::Slurp;
use FindBin;
use JSON;

my $DIR_CONFIG = "$FindBin::Bin/../conf/logmanagement";

=head1 SUBROUTINES/METHODS

=head2 get($type, $name)

=cut

sub get 
{
	my ($type, $name) = @_;

	my $filename = filename($type, $name);
	if ((defined $filename) && (-r $filename))
	{
		my $json = read_file($filename);
		my $conf = from_json($json);

		return ($conf);
	}

	return (undef);
}


=head2 items($type)

=cut

sub items
{
	my $type = shift;

	my @items = map { ($_ =~ /^(.+)\.json$/ ? ($_ = $1) : ()) } 
		read_dir("${DIR_CONFIG}/$type/");

	return (@items);
}

=head2 directory()

=cut

sub directory
{
	my $dir_new = shift;

	$DIR_CONFIG = (defined $dir_new ? $dir_new : $DIR_CONFIG);

	return ($DIR_CONFIG);
}

=head2 filename($type, $name)

=cut

sub filename
{
	my ($type, $name) = @_;

	return ("${DIR_CONFIG}/$type/${name}.json");
}

1;

=head1 AUTHOR

Sebastien Thebert <contact@onetool.pm>

=cut

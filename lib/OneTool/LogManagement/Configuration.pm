package OneTool::LogManagement::Configuration;

=head1 NAME

OneTool::LogManagement::Configuration - OneTool LogManagement Configuration module

=cut

use strict;
use warnings;

use File::Slurp;
use FindBin;
use JSON;

my $DIR_CONFIG = $ENV{ONETOOL_DIR_CONFIG} || "$FindBin::Bin/../conf/logmanagement";

=head1 SUBROUTINES/METHODS

=head2 directory()

Gets/Sets configuration directory

=cut

sub directory
{
    my $dir_new = shift;

    $DIR_CONFIG = (defined $dir_new ? $dir_new : $DIR_CONFIG);

    return ($DIR_CONFIG);
}

=head2 filename($type, $name)

Returns filename for type '$type' and name '$name'

=cut

sub filename
{
    my ($type, $name) = @_;

    return (defined $type ? "${DIR_CONFIG}/$type/${name}.json" : "${DIR_CONFIG}/${name}.json");
}

=head2 items($type)

Returns items of type '$type'

=cut

sub items
{
    my $type = shift;

    my @items = map { ($_ =~ /^(.+)\.json$/ ? ($_ = $1) : ()) } 
        read_dir("${DIR_CONFIG}/$type/");

    return (@items);
}

=head2 load($type, $name)

Loads configuration from file type '$type' and name '$name'

=cut

sub load 
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

=head2 save($type, $name, $conf)

Saves configuration '$conf' in JSON format for type '$type' and name '$name'

=cut

sub save
{
    my ($type, $name, $conf) = @_;

    my $filename = filename($type, $name);
    my $json = to_json($conf, { pretty => 1 });
    write_file($filename, { binmode => ':utf8' }, $json);
    
    return ($filename);
}

1;

=head1 AUTHOR

Sebastien Thebert <octopussy@onetool.pm>

=cut

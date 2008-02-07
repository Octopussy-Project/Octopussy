=head1 NAME

AAT::XML - AAT XML module

=cut

package AAT::XML;

use strict;
use open ':utf8';
#use bytes;
use utf8;

use XML::Simple;
# qw(:strict);

my %XML_CACHE = ();
my %filenames = ();

=head1 FUNCTIONS

=head2 Filename($dir, $name)

Returns Filename of the XML File from Directory '$dir' 
which XML Data field 'name' is '$name'

=cut

sub Filename($$)
{
	my ($dir, $name) = @_;

	return ($filenames{$dir}{$name})	if (defined $filenames{$dir}{$name});
	my @files = AAT::FS::Directory_Files($dir, qr/.+\.xml$/);
  foreach my $f (@files)
  {
    my $conf = AAT::XML::Read("$dir/$f");
		$filenames{$dir}{$name} = "$dir/$f";
    return ("$dir/$f")	if ($conf->{name} eq $name);
  }

  return (undef);	
}

=head2 Name_List($dir)

Returns List of Names from XML Data from Directory '$dir'

=cut

sub Name_List($)
{
	my $dir = shift;
	my @list = ();
	my @files = AAT::FS::Directory_Files($dir, qr/.+\.xml$/);
  foreach my $f (@files)
  {
    my $conf = AAT::XML::Read("$dir/$f");
    push(@list, $conf->{name})  if (defined $conf->{name});
  }

  return (sort @list);
}

=head2 File_Array_Values

Returns List of Values of each Field '$field' from File '$file', Array '$array' 

=cut

sub File_Array_Values($$$)
{
	my ($file, $array, $field) = @_;
	my @list = ();

	my $conf = AAT::XML::Read($file);
	foreach my $item (AAT::ARRAY($conf->{"$array"}))
    { push(@list, $item->{"$field"}); }

	return (sort @list);
}

=head2 Read($file, $no_option)

Read XML content from file '$file' OR from XML_CACHE

=cut

sub Read
{
	my ($file, $no_option) = @_;
  my %XML_INPUT_OPTIONS = ( KeyAttr => [], ForceArray => 1 );

	if ((defined $file) && (-f $file))
  {
    my @stats = stat($file);
    if ((defined $XML_CACHE{$file})
      && ($stats[9] == $XML_CACHE{$file}{modif_time}))
    {
      return ($XML_CACHE{$file}{xml});
    }
    else
    {
      return (undef)  if ((!defined $file) || (! -f $file));
			my $xml = eval { XMLin($file, 
				(defined $no_option ? () : %XML_INPUT_OPTIONS)) };
			AAT::Syslog("AAT::XML", "XML_READ_ERROR", $@)	if ($@);
			$XML_CACHE{$file}{modif_time} = $stats[9];
      $XML_CACHE{$file}{xml} = $xml;
      return ($xml);
    }
  }

  return (undef);
}

=head2 Write($file, $data, $root_name)

Write XML content '$data' to file '$file'

=cut

sub Write
{
  my ($file, $data, $root_name) = @_;

	my %XML_OUTPUT_OPTIONS =
    ( AttrIndent => 1, KeyAttr => [], 
      XMLDecl => "<?xml version='1.0' encoding='UTF-8'?>",
      RootName => $root_name || "aat_config" );
  my $xml = XMLout($data, %XML_OUTPUT_OPTIONS);
	AAT::Syslog("AAT::XML", "XML_WRITE_ERROR", $@)	if ($@);
	my $flag = utf8::is_utf8($xml);

	if ($flag == 1)
	{
		open(FILE, ">:utf8", $file);
	}
	else
	{
		open(FILE, ">:bytes", $file);
	}
  print FILE $xml;
  close(FILE);
}

1;

=head1 SEE ALSO

AAT(3), AAT::DB(3), AAT::Syslog(3), AAT::Theme(3), AAT::Translation(3), AAT::User(3)

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut

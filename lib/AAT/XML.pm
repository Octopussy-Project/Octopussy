package AAT::XML;

=head1 NAME

AAT::XML - AAT XML module

=cut

use strict;
use warnings;
use open ':utf8';
use English qw( -no_match_vars );

use Path::Tiny;
use XML::Simple;

use AAT::Syslog;
use AAT::Utils qw( ARRAY );

my $STAT_MODIF_TIME = 9;

my %XML_CACHE = ();
my %filename  = ();

=head1 SUBROUTINES/METHODS

=head2 Filename($dir, $name)

Returns Filename of the XML File from Directory '$dir'
which XML Data field 'name' is '$name'

=cut

sub Filename
{
    my ($dir, $name) = @_;

    return ($filename{$dir}{$name}) if (defined $filename{$dir}{$name});

    return (undef) if (!-r $dir);

    my @files = path($dir)->children(qr/.+\.xml$/);
    foreach my $f (@files)
    {
        my $conf = AAT::XML::Read($f->stringify);
        $filename{$dir}{$conf->{name}} = $f->stringify;
        return ($f->stringify) if ($conf->{name} eq $name);
    }

    return (undef);
}

=head2 Name_List($dir)

Returns List of Names from XML Data from Directory '$dir'

=cut

sub Name_List
{
    my $dir  = shift;
    my @list = ();

    return () if (!-r $dir);

    my @files = path($dir)->children(qr/.+\.xml$/);
    foreach my $f (@files)
    {
        my $conf = AAT::XML::Read($f->stringify);
        push @list, $conf->{name} if (defined $conf->{name});
    }

    return (sort @list);
}

=head2 File_Array_Values

Returns List of Values of each Field '$field' from File '$file', Array '$array'

=cut

sub File_Array_Values
{
    my ($file, $array, $field) = @_;
    my @list = ();

    my $conf = AAT::XML::Read($file);
    foreach my $item (ARRAY($conf->{$array}))
    {
        push @list, $item->{$field};
    }

    return (sort @list);
}

=head2 Read($file, $no_option)

Reads XML content from file '$file' OR from XML_CACHE

=cut

sub Read
{
    my ($file, $no_option) = @_;
    my %XML_INPUT_OPTIONS = (KeyAttr => [], ForceArray => 1);

    if ((defined $file) && (-f $file))
    {
        my @stats = stat $file;
        if (   (defined $XML_CACHE{$file})
            && ($stats[$STAT_MODIF_TIME] == $XML_CACHE{$file}{modif_time}))
        {
            return ($XML_CACHE{$file}{xml});
        }
        else
        {
            return (undef) if ((!defined $file) || (!-f $file));
            my $xml = eval {
                XMLin($file, (defined $no_option ? () : %XML_INPUT_OPTIONS));
            };
            AAT::Syslog::Message('AAT_XML', 'XML_READ_ERROR', $EVAL_ERROR)
                if ($EVAL_ERROR);
            $XML_CACHE{$file}{modif_time} = $stats[$STAT_MODIF_TIME];
            $XML_CACHE{$file}{xml}        = $xml;
            return ($xml);
        }
    }

    return (undef);
}

=head2 Write($file, $data, $root_name)

Writes XML content '$data' to file '$file'

=cut

sub Write
{
    my ($file, $data, $root_name) = @_;

    my %XML_OUTPUT_OPTIONS = (
        AttrIndent => 1,
        KeyAttr    => [],
        XMLDecl    => q(<?xml version='1.0' encoding='UTF-8'?>),
        RootName   => $root_name || 'aat_config',
    );
    my $xml = XMLout($data, %XML_OUTPUT_OPTIONS);

    if (defined open my $FILE, '>', $file)
    {
        print {$FILE} $xml;
        close $FILE;
        delete $XML_CACHE{$file};
    }
    else
    {
        AAT::Syslog::Message('AAT_XML', 'XML_WRITE_ERROR', $EVAL_ERROR)
            if ($EVAL_ERROR);
        return (undef);
    }

    return ($file);
}

1;

=head1 SEE ALSO

AAT(3), AAT::DB(3), AAT::Syslog(3), AAT::Theme(3), AAT::Translation(3), AAT::User(3)

=head1 AUTHOR

Sebastien Thebert <octopussy@onetool.pm>

=cut

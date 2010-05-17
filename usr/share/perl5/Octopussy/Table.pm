# $HeadURL$
# $Revision$
# $Date$
# $Author$

=head1 NAME

Octopussy::Table - Octopussy Table module

=cut

package Octopussy::Table;

use strict;
use warnings;
use Readonly;

use List::MoreUtils qw(any);

use AAT::Download;
use AAT::Utils qw( ARRAY NOT_NULL );
use AAT::XML;
use Octopussy;
use Octopussy::Device;
use Octopussy::DeviceGroup;
use Octopussy::Service;
use Octopussy::Type;

Readonly my $DIR_TABLE => 'tables';
Readonly my $XML_ROOT  => 'octopussy_table';

my $dir_tables = undef;
my %filename;

=head1 FUNCTIONS

=head2 New(\%conf)

Creates a new Table with configuration '$conf'

Parameters:

\%conf - hashref of the new Table configuration

=cut

sub New
{
  my $conf = shift;

  if (NOT_NULL($conf->{name}))
  {
    $dir_tables ||= Octopussy::Directory($DIR_TABLE);
    $conf->{version} = Octopussy::Timestamp_Version(undef);
    AAT::XML::Write("$dir_tables/$conf->{name}.xml", $conf, $XML_ROOT);
    Add_Field($conf->{name}, 'datetime', 'DATETIME');
    Add_Field($conf->{name}, 'device',   'WORD');

    return ($conf->{name});
  }

  return (undef);
}

=head2 Remove($table)

Removes the Table '$table'

Parameters:

$service - Name of the Table to remove

=cut

sub Remove
{
  my $table = shift;

  my $nb = unlink Filename($table);
  $filename{$table} = undef;

  return ($nb);
}

=head2 List()

Get List of Tables

=cut

sub List
{
  $dir_tables ||= Octopussy::Directory($DIR_TABLE);

  return (AAT::XML::Name_List($dir_tables));
}

=head2 Filename($table)

Get the XML filename for the Table '$table'

=cut

sub Filename
{
  my $table = shift;

  return ($filename{$table}) if (defined $filename{$table});
  $dir_tables ||= Octopussy::Directory($DIR_TABLE);
  $filename{$table} = AAT::XML::Filename($dir_tables, $table);

  return ($filename{$table});
}

=head2 Configuration($table)

Get the configuration for the Table '$table'

=cut

sub Configuration
{
  my $table = shift;

  return (AAT::XML::Read(Filename($table)));
}

=head2 Configurations($sort)

Get the configuration for all Tables

=cut

sub Configurations
{
  my $sort = shift || 'name';
  my (@configurations, @sorted_configurations) = ((), ());
  my @tables = List();

  foreach my $t (@tables)
  {
    my $conf = Configuration($t);
    push @configurations, $conf;
  }
  foreach my $c (sort { $a->{$sort} cmp $b->{$sort} } @configurations)
  {
    push @sorted_configurations, $c;
  }

  return (@sorted_configurations);
}

=head2 Add_Field($table, $fieldname, $fieldtype)

Adds Field '$fieldname' of type '$fieldtype' to Table '$table'

=cut

sub Add_Field
{
  my ($table, $fieldname, $fieldtype) = @_;

  my $conf = AAT::XML::Read(Filename($table));

  if (any { $fieldname =~ /^$_->{title}$/ } ARRAY($conf->{field}))
  {
    return (undef);
  }
  push @{$conf->{field}}, {title => $fieldname, type => $fieldtype};
  AAT::XML::Write(Filename($table), $conf, $XML_ROOT);

  return ($fieldname);
}

=head2 Remove_Field($table, $fieldname)

Removes Field '$fieldname' from Table '$table'

=cut

sub Remove_Field
{
  my ($table, $fieldname) = @_;

  my $conf = AAT::XML::Read(Filename($table));
  my @fields = grep { $_->{title} ne $fieldname } ARRAY($conf->{field});
  $conf->{field} = \@fields;
  AAT::XML::Write(Filename($table), $conf, $XML_ROOT);

  return (scalar @fields);
}

=head2 Fields($table)

Gets fields from Table '$table'

=cut

sub Fields
{
  my $table = shift;

  my $conf = AAT::XML::Read(Filename($table));

  return (ARRAY($conf->{field}));
}

=head2 Fields_Configurations($table, $sort)

Gets the configuration for all Fields

=cut

sub Fields_Configurations
{
  my ($table, $sort) = @_;
  my @sorted_configurations = ();
  my @fields                = Fields($table);

  foreach my $c (sort { $a->{$sort} cmp $b->{$sort} } @fields)
  {
    push @sorted_configurations, $c;
  }

  return (@sorted_configurations);
}

=head2 SQL($table, $fields, $indexes)

Generates SQL code to create the Table '$table'

=cut

sub SQL
{
  my ($table, $fields, $indexes) = @_;
  my $real_table = $table;

  $real_table =~ s/_\d+$//;
  my $conf  = AAT::XML::Read(Filename($real_table));
  my $sql   = "CREATE TABLE `$table` (";
  my $index = '';

  foreach my $sf (ARRAY($fields))
  {

    #foreach my $ind (ARRAY($indexes))
    #	{ $index .= "INDEX ($ind), "  if ($ind eq $sf); }
    foreach my $f (ARRAY($conf->{field}))
    {
      if ( ($sf =~ /^$f->{title}$/i)
        || ($sf =~ /^Plugin_\S+__$f->{title}$/i))
      {
        $sql .= "`$sf` " . uc(Octopussy::Type::SQL_Type($f->{type})) . ', ';
      }
    }
  }

  #foreach my $f (ARRAY($conf->{field}))
  #{
  #	if (Octopussy::Type::SQL_Type($f->{type}) =~ /TEXT/)
  #		{ $sql .= "PRIMARY KEY ($f->{title}(250)), "; }
  #}
  $sql .= $index;
  $sql =~ s/, $/\)/g;

  return ($sql);
}

=head2 Field_Type_List($table, $type)

Gets field list from Table '$table' where Field type is '$type'

=cut

sub Field_Type_List
{
  my ($table, $type) = @_;
  my $conf        = Configuration($table);
  my $simple_type = Octopussy::Type::Simple_Type($type);
  my @list        = ();
  foreach my $f (ARRAY($conf->{field}))
  {
    my $f_stype = Octopussy::Type::Simple_Type($f->{type});
    push @list, $f->{title} if ($simple_type =~ /^$f_stype$/i);
  }

  return (sort @list);
}

=head2 Devices_and_Services_With($table)

Returns one arrayref of devicegroups, one of devices and one of services 
which contains messages with Table '$table'

=cut

sub Devices_and_Services_With
{
  my $table = shift;
  my (%device, %service);
  my (@devicegroups, @devices, @services) = ((), (), ());

  my @service_list = Octopussy::Service::List();
  foreach my $serv (@service_list)
  {
    my @messages = Octopussy::Service::Messages($serv);
    foreach my $m (@messages)
    {
      if ($m->{table} eq $table)
      {
        $service{$serv} = 1;
        last;
      }
    }
  }

  my @dconfs = Octopussy::Device::Configurations();
  foreach my $dc (@dconfs)
  {
    foreach my $s (ARRAY($dc->{service}))
    {
      $device{$dc->{name}} = 1 if (NOT_NULL($service{$s->{sid}}));
    }
  }
  @devices  = sort keys %device;
  @services = sort keys %service;
  foreach my $dg (Octopussy::DeviceGroup::List())
  {
    my $match = 0;
    foreach my $dgd (Octopussy::DeviceGroup::Devices($dg))
    {
      foreach my $d (sort keys %device) { $match = 1 if ($dgd eq $d); }
    }
    push @devicegroups, $dg if ($match);
  }

  return (\@devicegroups, \@devices, \@services);
}

=head2 Valid_Pattern($table, $pattern)

=cut

sub Valid_Pattern
{
  my ($table, $pattern) = @_;
  my @fields    = Fields($table);
  my %f_pattern = ();
  my @errors    = ();

  while (($pattern =~ s/<\@REGEXP\("\S+?"\):(\S+?)\@>//)
    || ($pattern =~ s/<\@\S+?:(\S+?)\@>//))
  {
    my $fieldname = $1;
    my $match     = 0;
    $f_pattern{$fieldname} = (
      NOT_NULL($f_pattern{$fieldname})
      ? $f_pattern{$fieldname} + 1
      : 1
    );
    foreach my $f (@fields)
    {
      $match = 1
        if (($f->{title} =~ /^$fieldname$/) || ($fieldname =~ /NULL/i));
    }
    push @errors, "$fieldname DONT MATCH ! \n" if (!$match);
  }

  #	foreach my $k (keys %f_pattern)
  # 	{
  #  	push @errors, "$fieldname MATCH MORE THAN ONCE ! \n"
  #    	if ($f_pattern{$k} > 1);
  # 	}

  return (@errors);
}

=head2 Updates_Installation(@tables)

=cut

sub Updates_Installation
{
  my @tables = @_;
  my $web    = Octopussy::WebSite();
  $dir_tables ||= Octopussy::Directory($DIR_TABLE);

  foreach my $t (@tables)
  {
    AAT::Download::File('Octopussy', "$web/Download/Tables/$t.xml",
      "$dir_tables/$t.xml");
  }

  return (scalar @tables);
}

=head2 Update_Get_Fields($table)

=cut

sub Update_Get_Fields
{
  my $table = shift;
  my $web   = Octopussy::WebSite();

  AAT::Download::File('Octopussy', "$web/Download/Tables/$table.xml",
    "/tmp/$table.xml");
  my $conf_new = AAT::XML::Read("/tmp/$table.xml");

  return (ARRAY($conf_new->{field}));
}

=head2 Updates_Diff($table)

=cut

sub Updates_Diff
{
  my $table      = shift;
  my $conf       = Configuration($table);
  my @fields     = ();
  my @new_fields = Update_Get_Fields($table);
  foreach my $f (ARRAY($conf->{field}))
  {
    my @list  = ();
    my $match = 0;
    foreach my $f2 (@new_fields)
    {
      if ($f2->{title} eq $f->{title})
      {
        $match = 1;
        if ($f2->{type} ne $f->{type})
        {
          $f->{type} = "$f->{type} --> $f2->{type}";
          push @fields, $f;
        }
      }
      else { push @list, $f2; }
    }
    if (!$match)
    {
      $f->{status} = 'deleted';
      push @fields, $f;
    }
    @new_fields = @list;
  }
  foreach my $f (@new_fields)
  {
    $f->{status} = 'added';
    push @fields, $f;
  }

  return (@fields);
}

1;

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut

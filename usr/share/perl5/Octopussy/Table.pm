=head1 NAME

Octopussy::Table - Octopussy Table module

=cut

package Octopussy::Table;

use strict;
no strict 'refs';

use Octopussy;
use Octopussy::Type;

my $TABLE_DIR = "tables";

my $tables_dir = undef;
my %filenames;

=head1 FUNCTIONS

=head2 New($conf)

Creates a new Table with configuration '$conf'

=cut
 
sub New($)
{
	my $conf = shift;

	$tables_dir ||= Octopussy::Directory($TABLE_DIR);
	$conf->{version} = Octopussy::Timestamp_Version(undef);
	AAT::XML::Write("$tables_dir/$conf->{name}.xml", $conf, "octopussy_table");
}

=head2 Remove($table)

Removes the Table '$table'

=cut

sub Remove($)
{
	my $table = shift;

	$filenames{$table} = undef;
	unlink(Filename($table));
}


=head2 List()

Get List of Tables

=cut

sub List()
{
	$tables_dir ||= Octopussy::Directory($TABLE_DIR);

	return (AAT::XML::Name_List($tables_dir));
}

=head2 Filename($table_name)

Get the XML filename for the Table '$table_name'

=cut

sub Filename($)
{
	my $table_name = shift;

	return ($filenames{$table_name})	if (defined $filenames{$table_name});
	$tables_dir ||= Octopussy::Directory($TABLE_DIR);
	$filenames{$table_name} = AAT::XML::Filename($tables_dir, $table_name);

	return ($filenames{$table_name});
}

=head2 Configuration($table_name)

Get the configuration for the Table '$table_name'

=cut
 
sub Configuration($)
{
	my $table_name = shift;

	my $conf = AAT::XML::Read(Filename($table_name));

	return ($conf);
}

=head2 Configurations($sort)

Get the configuration for all Tables

=cut

sub Configurations
{
  my $sort = shift || "name";
  my (@configurations, @sorted_configurations) = ((), ());
  my @tables = List();
  my %field;
  foreach my $t (@tables)
  {
    my $conf = Configuration($t);
    $field{$conf->{$sort}} = 1;
    push(@configurations, $conf);
  }
  foreach my $f (sort keys %field)
  {
    foreach my $c (@configurations)
      { push(@sorted_configurations, $c)    if ($c->{$sort} eq $f); }
  }

  return (@sorted_configurations);
}

=head2 Add_Field($table, $fieldname, $fieldtype)

Adds Field '$fieldname' of type '$fieldtype' to Table '$table'

=cut

sub Add_Field($$$)
{
	my ($table, $fieldname, $fieldtype) = @_;

	my $conf = AAT::XML::Read(Filename($table));	
	push(@{$conf->{field}}, { title => $fieldname, type => $fieldtype });
	AAT::XML::Write(Filename($table), $conf, "octopussy_table");
}

=head2 Remove_Field($table, $fieldname)

Removes Field '$fieldname' from Table '$table'

=cut

sub Remove_Field($$)
{
	my ($table, $fieldname) = @_;

	my $conf = AAT::XML::Read(Filename($table));
	my @fields = ();
	foreach my $f (AAT::ARRAY($conf->{field}))
	{
		push(@fields, $f)	if ($f->{title} ne $fieldname);
	}	
	$conf->{field} = \@fields;
	AAT::XML::Write(Filename($table), $conf, "octopussy_table");
}

=head2 Fields($table)

Gets fields from Table '$table'

=cut
 
sub Fields($)
{
	my $table = shift;

	my $conf = AAT::XML::Read(Filename($table));

	return (AAT::ARRAY($conf->{field}));
}

=head2 Fields_Configurations($table, $sort)

Gets the configuration for all Fields

=cut

sub Fields_Configurations($$)
{
	my ($table, $sort) = @_;
	my (@configurations, @sorted_configurations) = ((), ());
	my @fields = Fields($table);
	my %field;

	foreach my $conf (@fields)
	{
		$field{$conf->{$sort}} = 1;
		push(@configurations, $conf);
	}
	foreach my $f (sort keys %field)
	{
		foreach my $c (@configurations)
			{ push(@sorted_configurations, $c)    if ($c->{$sort} eq $f); }
	}

	return (@sorted_configurations);
}

=head2 SQL($table, $fields, $indexes)

Generates SQL code to create the Table '$table'

=cut

sub SQL($$$)
{
	my ($table, $fields, $indexes) = @_;
	my $real_table = $table;
	
	$real_table =~ s/_\d+$//;
	my $conf = AAT::XML::Read(Filename($real_table));
	my $sql = "CREATE TABLE `$table` (";
	my $index = "";
	
	foreach my $sf (AAT::ARRAY($fields))
  {
		#foreach my $ind (AAT::ARRAY($indexes))
		#	{ $index .= "INDEX ($ind), "  if ($ind eq $sf); }
		foreach my $f (AAT::ARRAY($conf->{field}))
  	{
			$sql .= "`$f->{title}` " .
        uc(Octopussy::Type::SQL_Type($f->{type})) . ", "
        if ($sf =~ /^$f->{title}$/i);
		}
	}
	#foreach my $f (AAT::ARRAY($conf->{field}))
	#{
	#	if (Octopussy::Type::SQL_Type($f->{type}) =~ /TEXT/)
	#	{
	#		$sql .= "PRIMARY KEY ($f->{title}(250)), ";
	#	}
	#}
	$sql .= $index;
	$sql =~ s/, $/\)/g;

	print "SQL: $sql\n";
	return ($sql);
}

=head2 Field_Type_List($table, $type)

Gets field list from Table '$table' where Field type is '$type'

=cut

sub Field_Type_List($$)
{
	my ($table, $type) = @_;
	my $conf = Configuration($table);
	my $simple_type = Octopussy::Type::Simple_Type($type);
	my @list = ();
	foreach my $f (AAT::ARRAY($conf->{field}))
 		{ push(@list, $f->{title})	if ($simple_type =~ /^$f->{type}/i); }

	return (@list);
}

=head2 Devices_and_Services_With($table)

Returns one hashref of devices and one hashref of services 
wich contains messages with table '$table'

=cut

sub Devices_and_Services_With($)
{
	my $table = shift;
	my (%device, %service);
	my (@devices, @services) = ((), ());

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
		foreach my $s (AAT::ARRAY($dc->{service}))
			{ $device{$dc->{name}} = 1	if (defined $service{$s->{sid}}); }
	}
	foreach my $d (sort keys %device)
    { push(@devices, $d); }
	foreach my $s (sort keys %service)
		{ push(@services, $s); }	

	return (\@devices, \@services);
}

=head2 Valid_Pattern($table, $pattern)

=cut

sub Valid_Pattern($$)
{
	my ($table, $pattern) = @_;
	my @fields = Fields($table); 

	while (($pattern =~ s/<\@REGEXP\("\S+?"\):(\S+?)\@>//) 
					|| ($pattern =~ s/<\@\S+?:(\S+?)\@>//))
  {
		my $fieldname = $1;
		my $match = 0;
		foreach my $f (@fields)
		{
			$match = 1	
				if (($f->{title} =~ /^$fieldname$/) || ($fieldname =~ /NULL/i));
		}
		if (!$match)
		{
			print "$fieldname DONT MATCH ! \n";
			return (0);
		}
	}	

	return (1);
}

=head2 Updates_Installation(@tables)

=cut

sub Updates_Installation
{
  my @tables = @_;
  my $web = Octopussy::WebSite();
  $tables_dir ||= Octopussy::Directory($TABLE_DIR);

  foreach my $t (@tables)
  {
		AAT::Download("$web/Download/Tables/$t.xml", "$tables_dir/$t.xml");
  }
}

=head2 Update_Get_Fields($table)

=cut

sub Update_Get_Fields($)
{
	my $table = shift;
	my $web = Octopussy::WebSite();

	AAT::Download("$web/Download/Tables/$table.xml", "/tmp/$table.xml");
	my $new_conf =  AAT::XML::Read("/tmp/$table.xml");

	return (AAT::ARRAY($new_conf->{field}));
}

=head2 Updates_Diff($table)

=cut

sub Updates_Diff($)
{
  my $table = shift;
  my $conf = Configuration($table);
  my @fields = ();
  my @new_fields = Update_Get_Fields($table);
  foreach my $f (AAT::ARRAY($conf->{field}))
  {
    my @list = ();
    my $match = 0;
    foreach my $f2 (@new_fields)
		{
      if ($f2->{title} eq $f->{title})
      {
        $match = 1;
				if ($f2->{type} ne $f->{type})
        {
          $f->{type} = "$f->{type} --> $f2->{type}";
          push(@fields, $f);
        }	
			}
			else
				{ push(@list, $f2); }
		}
		if (!$match)
		{
      $f->{status} = "deleted";
      push(@fields, $f);
    }
    @new_fields = @list;
	}
	foreach my $f (@new_fields)
  {
    $f->{status} = "added";
    push(@fields, $f);
  }

	return (@fields);
}

1;

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut

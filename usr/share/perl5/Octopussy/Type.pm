=head1 NAME

Octopussy::Type - Octopussy Type module

=cut
package Octopussy::Type;

use strict;
no strict 'refs';

use AAT;
use Octopussy;

my %MONTH = ( 
	Jan => "01", Feb => "02", Mar => "03", Apr => "04", 
	May => "05", Jun => "06", Jul => "07", Aug => "08", 
	Sep => "09", Oct => "10", Nov => "11", Dec => "12" );

my $REGEXP_COLOR = "red";
my $NUMBER_COLOR = "blue";
my $STRING_COLOR = "darkgray";
my $LONG_STRING_COLOR = "darkgray";
my $WORD_COLOR = "green";

=head2 Configurations()

Get list of type configurations

=cut

sub Configurations()
{
	my $conf = AAT::XML::Read(Octopussy::File("types"));
	my @list = ();

	foreach my $t (AAT::ARRAY($conf->{type}))
		{ push(@list, $t); }
	
	return (@list);
}

=head2 Colors()

Get an hash of Colors for each Type

=cut

sub Colors()
{
	my @types = Octopussy::Type::Configurations();
  my %color = ();
  foreach my $t (@types)
  	{ $color{"$t->{type_id}"} = $t->{color}; }
  $color{"NUMBER"} = $NUMBER_COLOR;
	$color{"BYTES"} = $NUMBER_COLOR;
	$color{"SECONDS"} = $NUMBER_COLOR;
  $color{"WORD"} = $WORD_COLOR;
  $color{"STRING"} = $STRING_COLOR;
	$color{"LONG_STRING"} = $LONG_STRING_COLOR;
	$color{"REGEXP"} = $REGEXP_COLOR;

	return (%color);
}

=head2 List()

Get list of types

=cut 

sub List()
{
 	my $conf = AAT::XML::Read(Octopussy::File("types"));
 	my @list = ();
	my %type;
	
 	foreach my $t (AAT::ARRAY($conf->{type}))
 		{ $type{"$t->{type_id}"} = 1; }
	push(@list, "NUMBER");
	push(@list, "BYTES");
	push(@list, "SECONDS");
	push(@list, "STRING");
	push(@list, "LONG_STRING");
	push(@list, "WORD");
	foreach my $k (keys %type)
		{ push(@list, $k); }
				
	return (@list);
}

=head2 Simple_List()

Get list of simple types (*_DATETIME -> DATETIME, *_STRING -> STRING...)

=cut

sub Simple_List()
{
  my $conf = AAT::XML::Read(Octopussy::File("types"));
  my @list = ();
  my %type;

	$type{"NUMBER"} = 1;
	$type{"BYTES"} = 1;
	$type{"SECONDS"} = 1;
	$type{"STRING"} = 1;
	$type{"LONG_STRING"} = 1;
	$type{"WORD"} = 1;
  foreach my $t (AAT::ARRAY($conf->{type}))
    { $type{"$t->{simple_type}"} = 1; }
  foreach my $k (sort keys %type)
    { push(@list, $k); }

  return (@list);
}

=head2 SQL_List()

Get list of SQL types

=cut

sub SQL_List()
{
	my $conf = AAT::XML::Read(Octopussy::File("types"));
	my @list = ();
	my %type;
	
	foreach my $t (AAT::ARRAY($conf->{type}))
		{ $type{"$t->{sql_type}"} = 1; }
	push(@list, "BIGINT");
	
	foreach my $k (keys %type)
		{ push(@list, $k); }

	return (sort (@list));
}

=head2 Regexp($type)

Get regexp from type '$type'

=cut 

sub Regexp($)
{
	my $type = shift;

	my @list = Configurations();
	foreach my $t (@list)
	{
		return ($t->{re})	if ($t->{type_id} eq $type);	
	}
	
	return (undef);
}

=head2 Regexps()

Get regexps from all types

=cut

sub Regexps()
{
	my %re_types = ();
	
	my @list = Configurations();
	$re_types{"NUMBER"} = "[-+]?\\d+";
	$re_types{"BYTES"} = "[-+]?\\d+";
	$re_types{"SECONDS"} = "[-+]?\\d+";
	$re_types{"WORD"} = "\\S+";
	$re_types{"STRING"} = ".+";
	$re_types{"LONG_STRING"} = ".+";
	foreach my $t (@list)
		{ $re_types{"$t->{type_id}"} = $t->{re}; }
	
	return (%re_types);
}

=head2 Simple_Type(type)

Get Simple type from type '$type'

=cut 

sub Simple_Type($)
{
	my $type = shift;

  my @list = Configurations();
  foreach my $t (@list)
    { return ($t->{simple_type}) if ($t->{type_id} =~ /^$type/); }

  return ($type);
}

=head2 SQL_Type(type)

Get SQL type from type '$type'

=cut

sub SQL_Type($)
{
	my $type = shift;

	my @list = Configurations();
	foreach my $t (@list)
		{ return ($t->{sql_type}) if ($t->{simple_type} =~ /^$type/); }
	if ($type eq "NUMBER" || $type eq "BYTES" || $type eq "SECONDS") 
		{ return ("BIGINT"); }
	elsif ($type eq "STRING" || $type eq "WORD")
		{ return ("VARCHAR(250)"); }
	elsif ($type eq "LONG_STRING")
		{ return ("TEXT"); }

	return (undef);
}

=head2 SQL_Datetime($dt)

Convert '$dt' to SQL datetime

=cut

sub SQL_Datetime($)
{
	my $dt = shift;

	if ($dt =~ /(\d{2})\/(\w{3})\/(\d{4}):(\d{2}):(\d{2}):(\d{2}) .\d{4}/)
		{ return ("$3-$MONTH{$2}-$1 $4:$5:$6"); }
	elsif ($dt =~ /\w{3} (\w{3}) \s?(\d{1,2}) (\d{2}):(\d{2}):(\d{2}) (\d{4})/)
		{ return ("$6-$MONTH{$1}-$2 $3:$4:$5"); }
	elsif ($dt =~ /(\d{4})\/(\d{2})\/(\d{2}) (\d{2}):(\d{2}):(\d{2})/)
		{ return ("$1-$2-$3 $4:$5:$6"); }	
	elsif ($dt =~ /(\w{3}) \s?(\d{1,2}) (\d{2}):(\d{2}):(\d{2})/)
	{
		my ($year, $mon, $mday) = AAT::Datetime::Now();	
		return ("$year-$MONTH{$1}-$2 $3:$4:$5");
	}

	return ($dt);
}

1;

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut

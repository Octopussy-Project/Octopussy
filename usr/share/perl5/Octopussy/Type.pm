# $HeadURL$
# $Revision$
# $Date$
# $Author$

=head1 NAME

Octopussy::Type - Octopussy Type module

=cut

package Octopussy::Type;

use strict;
use warnings;
use Readonly;

use AAT::Utils qw( ARRAY );
use AAT::XML;

use Octopussy::FS;

Readonly my $FILE_TYPES        => 'types';
Readonly my $REGEXP_COLOR      => 'red';
Readonly my $NUMBER_COLOR      => 'blue';
Readonly my $STRING_COLOR      => 'darkgray';
Readonly my $LONG_STRING_COLOR => 'darkgray';
Readonly my $WORD_COLOR        => 'green';

Readonly my %MONTH => (
  Jan => '01',
  Feb => '02',
  Mar => '03',
  Apr => '04',
  May => '05',
  Jun => '06',
  Jul => '07',
  Aug => '08',
  Sep => '09',
  Oct => '10',
  Nov => '11',
  Dec => '12',
);

my $QR_DT1 = qr/^(\w{3}) \s?(\d{1,2}) (\d{2}):(\d{2}):(\d{2})/m;
my $QR_DT2 = qr/^\w{3} (\w{3}) \s?(\d{1,2}) (\d{2}):(\d{2}):(\d{2}) (\d{4})/m;
my $QR_DT3 = qr/^(\d{4})\/(\d{2})\/(\d{2}) (\d{2}):(\d{2}):(\d{2})/m;
my $QR_DT4 = qr/^(\d{2})\/(\w{3})\/(\d{4}):(\d{2}):(\d{2}):(\d{2}) .\d{4}/m;
my $QR_DT5 = qr/^(\d{4}-\d{2}-\d{2})T(\d{2}:\d{2}:\d{2})(?:\.\d{1,6})?.\d{2}:\d{2}/m;

=head2 Configurations()

Get list of type configurations

=cut

sub Configurations
{
  my $conf = AAT::XML::Read(Octopussy::FS::File($FILE_TYPES));

  return (ARRAY($conf->{type}));
}

=head2 Colors()

Get an hash of Colors for each Type

=cut

sub Colors
{
  my @types = Octopussy::Type::Configurations();
  my %color = ();
  foreach my $t (@types) { $color{"$t->{type_id}"} = $t->{color}; }
  $color{'NUMBER'}      = $NUMBER_COLOR;
  $color{'BYTES'}       = $NUMBER_COLOR;
  $color{'SECONDS'}     = $NUMBER_COLOR;
  $color{'PID'}         = $NUMBER_COLOR;
  $color{'WORD'}        = $WORD_COLOR;
  $color{'EMAIL'}       = $WORD_COLOR;
  $color{'USER_AGENT'}  = $WORD_COLOR;
  $color{'STRING'}      = $STRING_COLOR;
  $color{'LONG_STRING'} = $LONG_STRING_COLOR;
  $color{'REGEXP'}      = $REGEXP_COLOR;

  return (%color);
}

=head2 List()

Get list of types

=cut 

sub List
{
  my $conf = AAT::XML::Read(Octopussy::FS::File($FILE_TYPES));
  my @list = ();
  my %type;

  foreach my $t (ARRAY($conf->{type})) { $type{"$t->{type_id}"} = 1; }
  push @list, 'NUMBER';
  push @list, 'BYTES';
  push @list, 'SECONDS';
  push @list, 'PID';
  push @list, 'STRING';
  push @list, 'LONG_STRING';
  push @list, 'WORD';
  push @list, 'EMAIL';
  push @list, 'USER_AGENT';
  push @list, keys %type;

  return (@list);
}

=head2 Simple_List()

Get list of simple types (*_DATETIME -> DATETIME, *_STRING -> STRING...)

=cut

sub Simple_List
{
  my $conf = AAT::XML::Read(Octopussy::FS::File($FILE_TYPES));
  my @list = ();
  my %type;

  $type{'NUMBER'}      = 1;
  $type{'BYTES'}       = 1;
  $type{'SECONDS'}     = 1;
  $type{'PID'}         = 1;
  $type{'STRING'}      = 1;
  $type{'LONG_STRING'} = 1;
  $type{'WORD'}        = 1;
  $type{'EMAIL'}       = 1;
  $type{'USER_AGENT'}  = 1;
  foreach my $t (ARRAY($conf->{type}))
  {
    $type{"$t->{simple_type}"} = 1;
  }
  @list = sort keys %type;

  return (@list);
}

=head2 SQL_List()

Get list of SQL types

=cut

sub SQL_List
{
  my $conf = AAT::XML::Read(Octopussy::FS::File($FILE_TYPES));
  my @list = ();
  my %type;

  foreach my $t (ARRAY($conf->{type})) { $type{"$t->{sql_type}"} = 1; }
  push @list, 'BIGINT';

  foreach my $k (keys %type) { push @list, $k; }

  return (sort @list);
}

=head2 Regexp($type)

Get regexp from type '$type'

=cut 

sub Regexp
{
  my $type = shift;

  my @list = Configurations();
  foreach my $t (@list)
  {
    return ($t->{re}) if ($t->{type_id} eq $type);
  }

  return (undef);
}

=head2 Regexps()

Get regexps from all types

=cut

sub Regexps
{
  my %re_types = ();

  my @list = Configurations();
  $re_types{'NUMBER'}      = '[-+]?\d+';
  $re_types{'BYTES'}       = '[-+]?\d+';
  $re_types{'SECONDS'}     = '[-+]?\d+';
  $re_types{'PID'}         = '\d+';
  $re_types{'WORD'}        = '\S+';
  $re_types{'EMAIL'}       = '.+@.+\..+';    ## no critic
  $re_types{'USER_AGENT'}  = '.+';
  $re_types{'STRING'}      = '.+';
  $re_types{'LONG_STRING'} = '.+';
  foreach my $t (@list) { $re_types{"$t->{type_id}"} = $t->{re}; }

  return (%re_types);
}

=head2 Simple_Type(type)

Get Simple type from type '$type'

=cut 

sub Simple_Type
{
  my $type = shift;

  my @list = Configurations();
  foreach my $t (@list)
  {
    return ($t->{simple_type}) if ($t->{type_id} =~ /^$type/m);
  }
  return ('NUMBER') if ($type =~ /^(BYTES|SECONDS|PID)$/m);
  return ('STRING') if ($type =~ /^(EMAIL|USER_AGENT)$/m);

  return ($type);
}

=head2 SQL_Type(type)

Get SQL type from type '$type'

=cut

sub SQL_Type
{
  my $type = shift;

  my @list = Configurations();
  foreach my $t (@list)
  {
    return ($t->{sql_type}) if ($t->{simple_type} =~ /^$type/m);
  }
  if ( $type eq 'NUMBER'
    || $type eq 'BYTES'
    || $type eq 'SECONDS'
    || $type eq 'PID')
  {
    return ('BIGINT');
  }
  elsif (($type eq 'STRING')
    || ($type eq 'WORD')
    || ($type eq 'EMAIL')
    || ($type eq 'USER_AGENT'))
  {
    return ('VARCHAR(250)');
  }
  elsif ($type eq 'LONG_STRING') { return ('TEXT'); }

  return (undef);
}

=head2 SQL_Datetime($dt)

Convert '$dt' to SQL datetime

=cut

sub SQL_Datetime
{
  my $dt = shift;

  if ($dt =~ $QR_DT1)
  {
    my ($year, $mon, $mday) = AAT::Utils::Now();
    return ("$year-$MONTH{$1}-$2 $3:$4:$5");
  }
  elsif ($dt =~ $QR_DT2) { return ("$6-$MONTH{$1}-$2 $3:$4:$5"); }
  elsif ($dt =~ $QR_DT3) { return ("$1-$2-$3 $4:$5:$6"); }
  elsif ($dt =~ $QR_DT4) { return ("$3-$MONTH{$2}-$1 $4:$5:$6"); }
  elsif ($dt =~ $QR_DT5) { return ("$1 $2"); }	
	
  return ($dt);
}

1;

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut

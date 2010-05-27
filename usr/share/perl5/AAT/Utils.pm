# $HeadURL$
# $Revision$
# $Date$
# $Author$

=head1 NAME

AAT::Utils - AAT Utils module

=cut

package AAT::Utils;

use strict;
use warnings;
use Readonly;

use Exporter 'import';

our @EXPORT_OK = qw( ARRAY HASH HASH_KEYS NOT_NULL NULL );

Readonly my $START_YEAR   => 1900;

=head1 FUNCTIONS

=head2 ARRAY($value)

Converts $value to an array ( @{$value) )

=cut

sub ARRAY
{
  my $value = shift;

  return (
    (
      NOT_NULL($value)
      ? ((ref $value eq 'ARRAY') ? @{$value} : ("$value"))
      : ()
    )
  );
}

=head2 ARRAY_REF($value)

Converts $value to an array reference ( \@{$value} )

=cut

sub ARRAY_REF
{
  my $value = shift;

  return (
    (
      NOT_NULL($value)
      ? ((ref $value eq 'ARRAY') ? \@{$value} : ["$value"])
      : []
    )
  );
}

=head2 HASH($value)

Converts $value to an hash ( %{$value} )

=cut

sub HASH
{
  my $value = shift;

  return ((NOT_NULL($value)) ? %{$value} : ());
}

=head2 HASH_KEYS($value)

Returns keys for the converted hash $value ( keys %{$value} )

=cut

sub HASH_KEYS
{
  my $value = shift;

  return ((NOT_NULL($value)) ? keys %{$value} : ());
}

=head2 NOT_NULL($value)

Checks that value '$value' is not null (undef or '')

=cut

sub NOT_NULL
{
  my $value = shift;

  if (ref $value eq 'ARRAY')
  {
    return (
      scalar(@{$value}) > 1
      ? 1
      : (((scalar(@{$value}) == 1) && (NOT_NULL(${$value}[0]))) ? 1 : 0)
    );
  }

  return (((defined $value) && ($value ne '')) ? 1 : 0);
}

=head2 NULL($value)

Checks that value '$value' is null (undef or '')

=cut

sub NULL
{
  my $value = shift;

  if (ref $value eq 'ARRAY')
  {
    return (
      scalar(@{$value}) > 1
      ? 0
      : (((scalar(@{$value}) == 1) && (NOT_NULL(${$value}[0]))) ? 0 : 1)
    );
  }

  return (((defined $value) && ($value ne '')) ? 0 : 1);
}


=head2 Now()

Returns current date (now!) in an Array (YYYY, MM, DD, HH, MM, SS)

=cut

sub Now
{
	my ($sec, $min, $hour, $mday, $mon, $year) = localtime time;
	
  $year += $START_YEAR;
  $mon++;
  $mon  = ($mon < 10  ? '0' . $mon  : $mon);
  $mday = ($mday < 10 ? '0' . $mday : $mday);
  $hour = ($hour < 10 ? '0' . $hour : $hour);
  $min  = ($min < 10  ? '0' . $min  : $min);
  $sec  = ($sec < 10  ? '0' . $sec  : $sec);

  return ($year, $mon, $mday, $hour, $min, $sec);
}


=head2 Now_String()

Get te actual time in "YYYY/MM/DD HH:MM" format

Returns:
 $now_string - string "YYYY/MM/DD HH:MM" formated

=cut

sub Now_String
{
  my ($year, $month, $mday, $hour, $min) = Now();

  return ("$year/$month/$mday $hour:$min");
}


1;

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut

# $HeadURL$
# $Revision$
# $Date$
# $Author$

=head1 NAME

Octopussy::DB - Octopussy Database module

=cut

package Octopussy::DB;

use strict;
use warnings;

use DBI;
use Octopussy;

my @sql_substitutions = (
  {
    regexp       => '^(COUNT\(DISTINCT\((.+?)\)\))',
    substitution => 'COUNT_DISTINCT_',
    value        => 'COUNT_DISTINCT_'
  },
  {
    regexp       => '^(COUNT\((.+?)\))',
    substitution => 'COUNT_',
    value        => 'COUNT_'
  },
  {
    regexp       => '^(SUM\((.+?)\))',
    substitution => 'SUM_',
    value        => 'SUM_'
  },
  {
    regexp       => '^(AVG\((.+)?\))',
    substitution => 'AVG_',
    value        => 'AVG_'
  },
  {
    regexp       => '^(MIN\((.+)?\))',
    substitution => 'MIN_',
    value        => 'MIN_'
  },
  {
    regexp       => '^(MAX\((.+)?\))',
    substitution => 'MAX_',
    value        => 'MAX_'
  },
  {
    regexp       => '^(DAY\((.+?)\))',
    substitution => '\'\%d/\%m/\%Y\') as D_',
    value        => 'D_'
  },
  {
    regexp       => '^(DAY_HOUR\((.+?)\))',
    substitution => '\'\%d/\%m/\%Y \%Hh\') as DH_',
    value        => 'DH_'
  },
  {
    regexp       => '^(DAY_HOUR_MIN\((.+?)\))',
    substitution => '\'\%d/\%m/\%Y \%Hh\%i\') as DHM_',
    value        => 'DHM_'
  },
  {
    regexp       => '^(UNIX_TIMESTAMP\((.+?)\))',
    substitution => '\'\%Y-\%m-\%d \%H:\%i:00\')) as UT_',
    value        => 'UT_'
  },
);

=head1 FUNCTIONS

=head2 Connect()

Connects to the Octopussy Database

=cut 

sub Connect
{
  my $error = AAT::DB::Connect('Octopussy');

  AAT::Syslog('Octopussy_DB', $error) if (defined $error);

  return ($error);
}

=head2 Table_Creation($tablename, \@fields, \@indexes)

Creates Table '$tablename' with fields '\@fields'

=cut

sub Table_Creation
{
  my ($tablename, $fields, $indexes) = @_;

  my $sql = Octopussy::Table::SQL($tablename, $fields, $indexes);
  AAT::DB::Do('Octopussy', $sql);

  return ($sql);
}

=head2 SQL_As_Substitution($field)

=cut

sub SQL_As_Substitution
{
  my $field = shift;

  foreach my $s (@sql_substitutions)
  {
    if    ($field =~ /^(\S+::\S+?)\((\S+)\)/) { $field = $2; }
    elsif ($field =~ /$s->{regexp}/)          { $field = "$s->{value}$2"; }
  }

  return ($field);
}

=head2 SQL_Select_Function(@fields)

=cut

sub SQL_Select_Function
{
  my @fields     = @_;
  my @new_fields = ();

  my $query = 'SELECT ';
  foreach my $field (@fields)
  {
    my ($func, $func_field) = (undef, undef);
    if ($field =~ /^(\S+::\S+?)\((\S+)\)/)
    {
      ($func, $func_field) = ($1, $2);
      if (Octopussy::Plugin::Function_Source($func) eq 'INPUT')
      {
        my $func_bis = $func;
        $func_bis =~ s/^Octopussy:://;
        $func_bis =~ s/::/_/g;
        $field = $func_bis . "__$func_field";
      }
      else
      {
        $field = $2;
      }
    }
    my $match = 0;
    foreach my $s (@sql_substitutions)
    {
      if ($field =~ /$s->{regexp}/)
      {
        my ($fct, $param) = ($1, $2);
        $field = (
          (($field !~ /^DAY/) && ($field !~ /^UNIX/))
          ? "$fct as $s->{substitution}$param"
          : (
            ($field =~ /^UNIX/)
            ? "UNIX_TIMESTAMP(DATE_FORMAT($param,$s->{substitution}$param"
            : "DATE_FORMAT($param,$s->{substitution}$param"
          )
        );
        my $cfield =
          (defined $func ? "$func($s->{value}$param)" : "$s->{value}$param");
        push @new_fields, $cfield;
        $match = 1;
        last;
      }
    }
    my $complete_field = (defined $func ? "$func($func_field)" : $field);
    push @new_fields, $complete_field if (!$match);
    $query .= "$field, ";
  }
  $query =~ s/, $/ /;

  return ($query, \@new_fields);
}

=head2 Column_Names($query)

Returns list of Column names from an SQL query

=cut

sub Column_Names
{
  my $query        = shift;
  my %hash_columns = ();
  my @columns      = ();

  if ($query =~ /SELECT (.+) FROM/i)
  {
    my @data = split /, /, $1;
    foreach my $f (@data)
    {
      $f =~ s/\S+ AS (.+)$/$1/i;
      $f =~ s/^\s*\(?COUNT\(//gi;
      $f =~ s/^\s*\(?DISTINCT\(//gi;
      $f =~ s/^\s*\(?SUM\(//gi;
      $f =~ s/^\s*\(?AVG\(//gi;
      $f =~ s/^\s*\(?UNIX_TIMESTAMP\(//gi;
      $f =~ s/^\s*DATE_FORMAT\((\S+),\'(.+)?\'\)/$1/gi;
      $f =~ s/[\(,\)]//gi;
      $f =~ s/^\s*//i;
      $f =~ s/\s*$//i;
      $hash_columns{$f} = 1;
    }
  }
  foreach my $k (keys %hash_columns) { push @columns, $k; }

  return (@columns);
}

1;

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut

#!/usr/bin/perl

=head1 NAME

tables_integrity.t - Octopussy Tables integrity Test

=head1 DESCRIPTION

It checks:
  - that fields 'datetime' & 'device' are defined in any Table
  - any field is defined only one time

=cut

use strict;
use warnings;

use Test::More tests => 1;

use FindBin;

use lib "$FindBin::Bin/../lib";

use Octopussy::Table;

my $str_error = '';

=head1 SUBROUTINES/METHODS

=head2 Error

=cut

sub Error
{
  my ($str, @args) = @_;

  $str_error .= sprintf("[ERROR] $str\n", @args);

  return (undef);
}

=head2 MAIN

=cut

my @tables = Octopussy::Table::List();

foreach my $table (@tables)
{
  my $conf        = Octopussy::Table::Configuration($table);
  my %field_count = ();
  foreach my $f (@{$conf->{field}})
  {
    $field_count{$f->{title}} =
      (defined $field_count{$f->{title}}) ? $field_count{$f->{title}} + 1 : 1;
  }
  Error("Need to define 'datetime' Field in Table '%s'", $table)
    if (!defined $field_count{datetime});
  Error("Need to define 'device' Field in Table '%s'", $table)
    if (!defined $field_count{device});
  foreach my $k (keys %field_count)
  {
    Error("\tField '%s' in Table '%s' defined more than one time !", $k, $table)
      if ($field_count{$k} > 1);
  }
}

ok($str_error eq '', 'Tables Integrity') or diag($str_error);

=head1 AUTHOR

Sebastien Thebert <octopussy@onetool.pm>

=cut

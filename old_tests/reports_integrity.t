#!/usr/bin/perl -w

=head1 NAME

reports_integrity.t - Octopussy Reports integrity Test

=head1 DESCRIPTION

It checks that:
  - selected Table is correct
  - selected Taxonomy is correct
  - Services with selected Table have messages with selected Taxonomy

=cut

use strict;
use warnings;

use List::MoreUtils qw(any none);
use Test::More tests => 1;

use FindBin;

use lib "$FindBin::Bin/../lib";

use AAT::Application;

AAT::Application::Set_Config_File("$FindBin::Bin/data/etc/aat/aat.xml");

use Octopussy::Report;
use Octopussy::Service;
use Octopussy::Table;
use Octopussy::Taxonomy;

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

my @reports = Octopussy::Report::List();
my @tables  = Octopussy::Table::List();
my @taxos   = Octopussy::Taxonomy::List();

foreach my $report (@reports)
{
  my $conf = Octopussy::Report::Configuration($report);
  my ($table, $taxo) = ($conf->{table}, $conf->{taxonomy});

  Error("Unknown Table '%s' in Report '%s'", $table, $report)
    if (none { $table eq $_ } @tables);

  if ((defined $taxo) && ($taxo ne '-ANY-'))
  {
    Error("Unknown Taxonomy '%s' in Report '%s'", $taxo, $report)
      if (none { $taxo eq $_->{value} } @taxos);

    my ($dgs, $devs, $servs) =
      Octopussy::Table::Devices_and_Services_With($table);
    my $match = 0;
    foreach my $serv (@{$servs})
    {
      my $s_conf = Octopussy::Service::Configuration($serv);
      my @msgs   = @{$s_conf->{message}};
      if (any { $table eq $_->{table} && $taxo eq $_->{taxonomy}; } @msgs)
      {
        $match = 1;
        last;
      }
    }
    Error("No Message with Taxonomy '%s' in Report '%s'", $taxo, $report)
      if (!$match);
  }
}

ok($str_error eq '', 'Reports Integrity') or diag($str_error);

=head1 AUTHOR

Sebastien Thebert <octopussy@onetool.pm>

=cut

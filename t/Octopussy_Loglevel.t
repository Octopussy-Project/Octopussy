#!/usr/bin/perl
# $HeadURL$
# $Revision$
# $Date$
# $Author$

=head1 NAME

Octopussy_Loglevel.t - Octopussy Source Code Checker for Octopussy::Loglevel

=cut

use strict;
use warnings;
use Readonly;

use Test::More tests => 2;

use Octopussy::Loglevel;

Readonly my $NB_LOGLEVELS => 7;

#
# check Loglevel.pm (2 tests)
#
my %color = Octopussy::Loglevel::Colors();
ok((((scalar keys %color) == $NB_LOGLEVELS) && ($color{'Debug'} eq 'gray')),
  'Octopussy::Loglevel::Colors()');

my %level = Octopussy::Loglevel::Levels();
ok((((scalar keys %level) == $NB_LOGLEVELS) && ($level{'Debug'} == 1)),
  'Octopussy::Loglevel::Levels()');

1;

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut

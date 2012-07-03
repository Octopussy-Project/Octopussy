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

use Test::More tests => 7;

use FindBin;
use lib "$FindBin::Bin/../usr/share/perl5";

use AAT::Application;
use Octopussy::Loglevel;

Readonly my $AAT_CONFIG_FILE_TEST => 't/data/etc/aat/aat.xml';
Readonly my $COLOR_DEBUG => 'gray';
Readonly my $NB_LOGLEVELS => 7;

AAT::Application::Set_Config_File($AAT_CONFIG_FILE_TEST);

my %color = Octopussy::Loglevel::Colors();
ok((((scalar keys %color) == $NB_LOGLEVELS) && ($color{'Debug'} eq $COLOR_DEBUG)),
  'Octopussy::Loglevel::Colors()');

my %level = Octopussy::Loglevel::Levels();
ok((((scalar keys %level) == $NB_LOGLEVELS) && ($level{'Debug'} == 1)),
  'Octopussy::Loglevel::Levels()');

my @unknowns = Octopussy::Loglevel::Unknowns();
ok(scalar @unknowns == 0, 'Octopussy::Loglevel::Unknowns()');

@unknowns = Octopussy::Loglevel::Unknowns('-ANY-', 'false_loglevel');
ok(scalar @unknowns == 1, "Octopussy::Loglevel::Unknowns('-ANY-', 'false_loglevel')");

my $is_valid = Octopussy::Loglevel::Valid_Name(undef);
ok(!$is_valid, 'Octopussy::Loglevel::Valid_Name(undef)');

$is_valid = Octopussy::Loglevel::Valid_Name('invalid_loglevel');
ok(!$is_valid, "Octopussy::Loglevel::Valid_Name('invalid_loglevel')");

$is_valid = Octopussy::Loglevel::Valid_Name('Warning');
ok($is_valid, "Octopussy::Loglevel::Valid_Name('Warning')");

1;

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut

#!/usr/bin/perl

=head1 NAME

t/Octopussy/Plugin.t - Test Suite for Octopussy::Plugin module

=cut

use strict;
use warnings;

use FindBin;
use List::MoreUtils qw(any);
use Test::More;

use lib "$FindBin::Bin/../../lib";

use AAT::Application;

AAT::Application::Set_Config_File("$FindBin::Bin/../data/etc/aat/aat.xml");

my $LANG = 'FR';
my $REQUIRED_NB_PLUGINS = 3;

my $TEST_MAIL        = 'octo.devel@gmail.com';
my $TEST_MAIL_DOMAIN = 'gmail.com';
my $TEST_MAIL_USER   = 'octo.devel';

my $TEST_NETWORK        = '10.20.30.40';
my $TEST_NETWORK_MASK8  = '10.XXX.XXX.XXX';
my $TEST_NETWORK_MASK16 = '10.20.XXX.XXX';
my $TEST_NETWORK_MASK24 = '10.20.30.XXX';

my $TEST_BYTES      = 32_000_000;
my $TEST_BYTES_K_FR = '31250.0 Koctets';
my $TEST_BYTES_M_FR = '30.5 Moctets';

my @plugins = qw(
  Octopussy::Plugin::Email
  Octopussy::Plugin::Network
  Octopussy::Plugin::Proxy
  Octopussy::Plugin::SMTP
  Octopussy::Plugin::Unit
  Octopussy::Plugin::Web
  );

my @functions = qw(
  Octopussy::Plugin::Email::Domain
  Octopussy::Plugin::Email::User
  Octopussy::Plugin::Network::Mask_8
  Octopussy::Plugin::Network::Mask_16
  Octopussy::Plugin::Network::Mask_24
  Octopussy::Plugin::Unit::KiloBytes
  Octopussy::Plugin::Unit::MegaBytes
  );

require_ok('Octopussy::Plugin');

my @list = Octopussy::Plugin::List();
cmp_ok(scalar @plugins, '>=', $REQUIRED_NB_PLUGINS, 'Octopussy::Plugin::List()');

my $nb_plugins_init = Octopussy::Plugin::Init({lang => $LANG}, @functions);
cmp_ok($nb_plugins_init, '==', $REQUIRED_NB_PLUGINS, 'Octopussy::Plugin::Init()');

my @p_functions = Octopussy::Plugin::Functions();
my $match       = 0;
foreach my $pf (@p_functions)
{
  foreach my $f (@{$pf->{functions}})
  {
    $match++ if (any { $f->{perl} eq $_ } @functions);
  }
}
cmp_ok($match, '==', scalar @functions, 'Octopussy::Plugin::Functions()');

my $mail_domain = Octopussy::Plugin::Email::Domain($TEST_MAIL);
cmp_ok($mail_domain, 'eq', $TEST_MAIL_DOMAIN,
	"Octopussy::Plugin::Email::Domain('$TEST_MAIL') => $mail_domain");
my $mail_user = Octopussy::Plugin::Email::User($TEST_MAIL);
cmp_ok($mail_user, 'eq', $TEST_MAIL_USER,
	"Octopussy::Plugin::Email::User('$TEST_MAIL') => $mail_user");

my $mask8 = Octopussy::Plugin::Network::Mask_8($TEST_NETWORK);
cmp_ok($mask8, 'eq', $TEST_NETWORK_MASK8,
	"Octopussy::Plugin::Network::Mask_8('$TEST_NETWORK') => $mask8");
my $mask16 = Octopussy::Plugin::Network::Mask_16($TEST_NETWORK);
cmp_ok($mask16, 'eq', $TEST_NETWORK_MASK16,
	"Octopussy::Plugin::Network::Mask_16('$TEST_NETWORK') => $mask16");
my $mask24 = Octopussy::Plugin::Network::Mask_24($TEST_NETWORK);
cmp_ok($mask24, 'eq', $TEST_NETWORK_MASK24,
	"Octopussy::Plugin::Network::Mask_24('$TEST_NETWORK') => $mask24");

my $kbytes = Octopussy::Plugin::Unit::KiloBytes($TEST_BYTES);
cmp_ok($kbytes, 'eq', $TEST_BYTES_K_FR,
	"Octopussy::Plugin::Unit::KiloBytes('$TEST_BYTES') => $kbytes");
my $mbytes = Octopussy::Plugin::Unit::MegaBytes($TEST_BYTES);
cmp_ok($mbytes, 'eq', $TEST_BYTES_M_FR,
	"Octopussy::Plugin::Unit::MegaBytes('$TEST_BYTES') => $mbytes");

done_testing(1 + 10);

=head1 AUTHOR

Sebastien Thebert <octopussy@onetool.pm>

=cut

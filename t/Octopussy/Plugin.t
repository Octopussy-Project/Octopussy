#!/usr/bin/perl

=head1 NAME

t/Octopussy/Plugin.t - Test Suite for Octopussy::Plugin module

=cut

use strict;
use warnings;

use FindBin;
use List::MoreUtils qw(any);
use Readonly;
use Test::More;

use lib "$FindBin::Bin/../../usr/share/perl5";

use AAT::Application;
use Octopussy::Plugin;

Readonly my $AAT_CONFIG_FILE_TEST => "$FindBin::Bin/../data/etc/aat/aat.xml";
Readonly my $LANG => 'FR';
Readonly my $REQUIRED_NB_PLUGINS => 3;

Readonly my $TEST_MAIL        => 'octo.devel@gmail.com';
Readonly my $TEST_MAIL_DOMAIN => 'gmail.com';
Readonly my $TEST_MAIL_USER   => 'octo.devel';

Readonly my $TEST_NETWORK        => '10.20.30.40';
Readonly my $TEST_NETWORK_MASK8  => '10.XXX.XXX.XXX';
Readonly my $TEST_NETWORK_MASK16 => '10.20.XXX.XXX';
Readonly my $TEST_NETWORK_MASK24 => '10.20.30.XXX';

Readonly my $TEST_BYTES      => 32_000_000;
Readonly my $TEST_BYTES_K_FR => '31250.0 Koctets';
Readonly my $TEST_BYTES_M_FR => '30.5 Moctets';

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

AAT::Application::Set_Config_File($AAT_CONFIG_FILE_TEST);

my @list = Octopussy::Plugin::List();
ok(scalar @plugins >= $REQUIRED_NB_PLUGINS, 'Octopussy::Plugin::List()');

my $nb_plugins_init = Octopussy::Plugin::Init({lang => $LANG}, @functions);
ok($nb_plugins_init == $REQUIRED_NB_PLUGINS, 'Octopussy::Plugin::Init()');

my @p_functions = Octopussy::Plugin::Functions();
my $match       = 0;
foreach my $pf (@p_functions)
{
  foreach my $f (@{$pf->{functions}})
  {
    $match++ if (any { $f->{perl} eq $_ } @functions);
  }
}
ok($match == scalar @functions, 'Octopussy::Plugin::Functions()');

my $mail_domain = Octopussy::Plugin::Email::Domain($TEST_MAIL);
ok($mail_domain eq $TEST_MAIL_DOMAIN, 
	"Octopussy::Plugin::Email::Domain('$TEST_MAIL') => $mail_domain");
my $mail_user = Octopussy::Plugin::Email::User($TEST_MAIL);
ok($mail_user eq $TEST_MAIL_USER, 
	"Octopussy::Plugin::Email::User('$TEST_MAIL') => $mail_user");

my $mask8 = Octopussy::Plugin::Network::Mask_8($TEST_NETWORK);
ok($mask8 eq $TEST_NETWORK_MASK8, 
	"Octopussy::Plugin::Network::Mask_8('$TEST_NETWORK') => $mask8");
my $mask16 = Octopussy::Plugin::Network::Mask_16($TEST_NETWORK);
ok($mask16 eq $TEST_NETWORK_MASK16, 
	"Octopussy::Plugin::Network::Mask_16('$TEST_NETWORK') => $mask16");
my $mask24 = Octopussy::Plugin::Network::Mask_24($TEST_NETWORK);
ok($mask24 eq $TEST_NETWORK_MASK24, 
	"Octopussy::Plugin::Network::Mask_24('$TEST_NETWORK') => $mask24");

my $kbytes = Octopussy::Plugin::Unit::KiloBytes($TEST_BYTES);
ok($kbytes eq $TEST_BYTES_K_FR, 
	"Octopussy::Plugin::Unit::KiloBytes('$TEST_BYTES') => $kbytes");
my $mbytes = Octopussy::Plugin::Unit::MegaBytes($TEST_BYTES);
ok($mbytes eq $TEST_BYTES_M_FR, 
	"Octopussy::Plugin::Unit::MegaBytes('$TEST_BYTES') => $mbytes");

done_testing(10);

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut

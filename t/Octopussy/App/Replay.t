#!/usr/bin/perl

=head1 NAME

t/Octopussy/App/Replay.t - Test Suite for Octopussy::App::Replay module

=cut

use strict;
use warnings;

use FindBin;
use Test::More;
use Test::Output;

use lib "$FindBin::Bin/../../../lib";

use AAT::Application;

AAT::Application::Set_Config_File("$FindBin::Bin/../../data/etc/aat/aat.xml");

BEGIN { use_ok('Octopussy::App::Replay'); }

sub cmd_no_options { Octopussy::App::Replay->run(); }
stdout_like(\&cmd_no_options,
    qr/Prints this help/, 'no option OK');

sub cmd_help { Octopussy::App::Replay::run('--help'); }
stdout_like(\&cmd_help,
    qr/Prints this help/, q{Program option '--help' OK});

sub cmd_help_short { Octopussy::App::Replay->run('-h'); }
stdout_like(\&cmd_help_short,
    qr/Prints this help/, q{Program option '-h' OK});

sub cmd_version { Octopussy::App::Replay->run('--version'); }
stdout_like(\&cmd_version, 
    qr/octo_replay for Octopussy/, q{Program option '--version' OK});

sub cmd_version_short { Octopussy::App::Replay->run('-v'); }
stdout_like(\&cmd_version_short, 
	qr/octo_replay for Octopussy/, q{Program option '-v' OK});

sub usage_test { Octopussy::App::Replay::usage('usage test'); }
stdout_like(\&usage_test,
	qr/usage test/, 'Octopussy::App::Replay::usage()');

my $count = Octopussy::App::Replay::replay({ 
	device => 'WRONG_DEVICE', service => 'WRONGSERVICE', 
	begin => '201401010000', end => '201401312359' });
ok($count == 0, 'Octopussy::App::Replay::replay()');

done_testing(8);

=head1 AUTHOR

Sebastien Thebert <octopussy@onetool.pm>

=cut

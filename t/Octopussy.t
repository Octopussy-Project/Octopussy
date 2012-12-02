#!/usr/bin/perl

=head1 NAME

Octopussy.t - Test Suite for Octopussy

=cut

use strict;
use warnings;

use FindBin;
use Readonly;
use Test::More;

Readonly my $PREFIX => 'Octo_Test_';

use lib "$FindBin::Bin/../usr/share/perl5";

use AAT::Utils qw( NOT_NULL );
use Octopussy;

my $version = Octopussy::Version();
ok(NOT_NULL($version) && $version =~ /^\d+\.\d+.*$/,
  "Octopussy::Version() => $version");

ok(Octopussy::Parameter('logrotate') =~ /^\d+$/, 'Octopussy::Parameter()');

my $ts_version = Octopussy::Timestamp_Version();
like($ts_version, qr/^\d{12}$/, 
	"Octopussy::Timestamp_Version() => $ts_version");

done_testing(3);

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut

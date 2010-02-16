#!/usr/bin/perl
# $HeadURL$
# $Revision$
# $Date$
# $Author$

=head1 NAME

Octopussy.t - Octopussy Source Code Checker for Octopussy

=cut

use strict;
use warnings;

use Test::More tests => 8;
use AAT;
use Octopussy;

my $email = Octopussy::Email();
ok(AAT::NOT_NULL($email) && $email =~ /^\S+\@\S+$/, 'Octopussy::Email()');
my $user = Octopussy::User();
ok(AAT::NOT_NULL($user) && $user =~ /^\w+$/, 'Octopussy::User()');
my $version = Octopussy::Version();
ok(AAT::NOT_NULL($version) && $version =~ /^\d+\.\d+.*$/,
  'Octopussy::Version()');

ok(AAT::NOT_NULL(Octopussy::Directory('main')), 'Octopussy::Directory()');
my @dirs = Octopussy::Directories('main', 'data_logs');
ok(scalar @dirs == 2, 'Octopussy::Directories()');

ok(AAT::NOT_NULL(Octopussy::File('db')), 'Octopussy::File()');
my @files = Octopussy::Files('db', 'proxy');
ok(scalar @files == 2, 'Octopussy::Files()');

ok(Octopussy::Parameter('logrotate') =~ /^\d+$/, 'Octopussy::Parameter()');

1;

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut

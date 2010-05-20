#!/usr/bin/perl
# $HeadURL$
# $Revision$
# $Date$
# $Author$

=head1 NAME

Octopussy_Info.t - Octopussy Source Code Checker for Octopussy::Info

=cut

use strict;
use warnings;

use Test::More tests => 2;

use AAT::Utils qw( NOT_NULL );
use Octopussy::Info;

my $email = Octopussy::Info::Email();
ok(NOT_NULL($email) && $email =~ /^\S+\@\S+$/, 'Octopussy::Info::Email()');
my $user = Octopussy::Info::User();
ok(NOT_NULL($user) && $user =~ /^\w+$/, 'Octopussy::Info::User()');

1;

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut
#!/usr/bin/perl

=head1 NAME

t/AAT/XMPP.t - Test Suite for AAT::XMPP module

=cut

use strict;
use warnings;

use FindBin;
use List::MoreUtils qw(any);
use Test::More;

use lib "$FindBin::Bin/../../lib";

require_ok('AAT::XMPP');

done_testing(1);

=head1 AUTHOR

Sebastien Thebert <octopussy@onetool.pm>

=cut

#!/usr/bin/perl
# $HeadURL$
# $Revision$
# $Date$
# $Author$

=head1 NAME

Octopussy_Service.t - Octopussy Source Code Checker for Octopussy::Service

=cut

use strict;
use warnings;
use Readonly;

use Test::More tests => 11;

use Octopussy;
use Octopussy::Service;

Readonly my $DIR_SERVICES => Octopussy::Directory('services');
Readonly my $PREFIX       => 'Octo_TEST_';
Readonly my $SERVICE      => "${PREFIX}Service";
Readonly my $SERVICE_DESC => "${PREFIX}Service Description";
Readonly my $SERVICE_WEB  => 'http://www.8pussy.org';

Readonly my $REQUIRED_NB_MSGS => 3;

my %msg_conf = (
  msg_id   => "${SERVICE}:undef",
  loglevel => 'Information',
  taxonomy => 'Application',
  table    => 'Message',
  pattern  => 'Pattern',
);

unlink "${DIR_SERVICES}${SERVICE}.xml";
my @list = Octopussy::Service::List();
Octopussy::Service::New(
  {name => $SERVICE, description => $SERVICE_DESC, website => $SERVICE_WEB});
ok(-f "${DIR_SERVICES}${SERVICE}.xml", 'Octopussy::Service::New()');

my @list2 = Octopussy::Service::List();
ok(scalar @list + 1 == scalar @list2, 'Octopussy::Service::List()');

my $conf = Octopussy::Service::Configuration($SERVICE);
ok($conf->{name} eq $SERVICE && $conf->{description} eq $SERVICE_DESC,
  'Octopussy::Service::Configuration()');

my $msgid1 = Octopussy::Service::Msg_ID($SERVICE);

$msg_conf{msg_id} = "${SERVICE}:first";
Octopussy::Service::Add_Message($SERVICE, \%msg_conf);
$msg_conf{msg_id} = "${SERVICE}:second";
Octopussy::Service::Add_Message($SERVICE, \%msg_conf);
$msg_conf{msg_id} = "${SERVICE}:third";
Octopussy::Service::Add_Message($SERVICE, \%msg_conf);

my @messages = Octopussy::Service::Messages($SERVICE);
ok(scalar @messages == $REQUIRED_NB_MSGS, 'Octopussy::Service::Messages()');

my $rank =
  Octopussy::Service::Move_Message($SERVICE, "${SERVICE}:first", 'bottom');
ok($rank eq '003', 'Octopussy::Service::Move_Message(bottom)');

$rank = Octopussy::Service::Move_Message($SERVICE, "${SERVICE}:second", 'down');
ok($rank eq '002', 'Octopussy::Service::Move_Message(down)');

$rank = Octopussy::Service::Move_Message($SERVICE, "${SERVICE}:first", 'top');
ok($rank eq '001', 'Octopussy::Service::Move_Message(top)');

$rank = Octopussy::Service::Move_Message($SERVICE, "${SERVICE}:second", 'up');
ok($rank eq '002', 'Octopussy::Service::Move_Message(up)');

$msg_conf{msg_id} = "${SERVICE}:001";
Octopussy::Service::Add_Message($SERVICE, \%msg_conf);

my $msgid2 = Octopussy::Service::Msg_ID($SERVICE);
ok(($msgid1 eq "${SERVICE}:001") && ($msgid2 eq "${SERVICE}:002"),
  'Octopussy::Service::Msg_ID()');

Octopussy::Service::Remove($SERVICE);
ok(!-f "${DIR_SERVICES}${SERVICE}.xml", 'Octopussy::Service::Remove()');

my @unknowns = Octopussy::Service::Unknowns('-ANY-', $SERVICE);
ok(scalar @unknowns == 1, 'Octopussy::Service::Unknowns()');

1;

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut

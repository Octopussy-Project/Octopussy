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

use Test::More tests => 16;

use Octopussy::FS;
use Octopussy::Service;

Readonly my $DIR_SERVICES => Octopussy::FS::Directory('services');
Readonly my $PREFIX       => 'Octo_TEST_';
Readonly my $SERVICE      => "${PREFIX}Service";
Readonly my $SERVICE_DESC => "${PREFIX}Service Description";
Readonly my $SERVICE_FILENAME => "${DIR_SERVICES}${SERVICE}.xml";
Readonly my $SERVICE2      => "${PREFIX}Service2";
Readonly my $SERVICE2_DESC => "${PREFIX}Service2 Description &éèçà£µ§";
Readonly my $SERVICE2_FILENAME => "${DIR_SERVICES}${SERVICE2}.xml";
Readonly my $SERVICE3      => "${PREFIX}Service2 &éèçà£µ§";
Readonly my $SERVICE3_DESC => "${PREFIX}Service2 Description &éèçà£µ§";
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
unlink "${DIR_SERVICES}${SERVICE2}.xml";
my @list = Octopussy::Service::List();

my $svc = Octopussy::Service::New(
  {name => $SERVICE, description => $SERVICE_DESC, website => $SERVICE_WEB});
ok(($svc eq $SERVICE) && (-f $SERVICE_FILENAME), 
	'Octopussy::Service::New()');

$svc = Octopussy::Service::New(
  {name => $SERVICE2, description => $SERVICE2_DESC, website => $SERVICE_WEB});
ok(($svc eq $SERVICE2) && (-f $SERVICE2_FILENAME), 
	'Octopussy::Service::New() accepts any characters in description field');

$svc = Octopussy::Service::New(
  {name => $SERVICE3, description => $SERVICE3_DESC, website => $SERVICE_WEB});
ok((!defined $svc), 
	'Octopussy::Service::New() accepts only /^[-_a-z0-9]+$/i for name');

$svc = Octopussy::Service::New(
  {name => 'Incoming', description => $SERVICE3_DESC, website => $SERVICE_WEB});
ok((!defined $svc), 
	"Octopussy::Service::New() rejects 'Incoming' for name");
$svc = Octopussy::Service::New(
  {name => 'Unknown', description => $SERVICE3_DESC, website => $SERVICE_WEB});
ok((!defined $svc), 
	"Octopussy::Service::New() rejects 'Unknown' for name");
		
my @list2 = Octopussy::Service::List();
ok(scalar @list + 2 == scalar @list2, 'Octopussy::Service::List()');

my $conf = Octopussy::Service::Configuration($SERVICE);
ok($conf->{name} eq $SERVICE && $conf->{description} eq $SERVICE_DESC,
  'Octopussy::Service::Configuration()');

$conf = Octopussy::Service::Configuration($SERVICE2);
ok($conf->{name} eq $SERVICE2 && $conf->{description} eq $SERVICE2_DESC,
  'Octopussy::Service::Configuration() with special chars');
  
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

# Clean stuff
unlink "${DIR_SERVICES}${SERVICE}.xml";
unlink "${DIR_SERVICES}${SERVICE2}.xml";
unlink "${DIR_SERVICES}${SERVICE3}.xml";

1;

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut

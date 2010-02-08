#!/usr/bin/perl
# $HeadURL$
# $Revision$
# $Date$
# $Author$

=head1 NAME

Octopussy_Alert.t - Octopussy Source Code Checker for Octopussy::Alert

=cut

use strict;
use warnings;
use Readonly;

use Test::More tests => 5;

use Octopussy::Alert;

Readonly my $PREFIX => 'Octo_TEST_';

my ($name, $desc, $new_desc) = 
  ("${PREFIX}alert", "${PREFIX}alert_desc", "${PREFIX}alert_new_desc");

my @list = Octopussy::Alert::List();

my %conf =
  (
    name        => $name,
    description => $desc,
    level       => "Warning",
    type        => "Dynamic",
    loglevel    => "Warning",
    taxonomy    => "Auth.Failure",
    timeperiod  => "-ANY-",
    status      => "Disabled",
    device      => ["device1", "device2"],
    service     => ["service1", "service2"],
    regexp_include => undef,
    regexp_exclude => undef,
    thresold_time => 1,
    thresold_duration => 1,
    action => undef,
    contact => undef,
    msgsubject => Encode::decode_utf8("${PREFIX}alert msg subject"),
    msgbody => Encode::decode_utf8("${PREFIX}alert msg body"),
    action_host => Encode::decode_utf8("${PREFIX}alert_action_host"),
    action_service => Encode::decode_utf8("${PREFIX}alert_action_service"),
    action_body => Encode::decode_utf8("${PREFIX}alert action body"),
  );

my $file = Octopussy::Alert::New(\%conf);
ok(AAT::NOT_NULL($file) && -f $file, 'Octopussy::Alert::New()');

my @list2 = Octopussy::Alert::List();
ok(scalar @list + 1 == scalar @list2, 'Octopussy::Alert::List()'); 

my $old_size = -s $file;
$conf{description} = $new_desc;
Octopussy::Alert::Modify($name, \%conf);
ok($old_size < -s $file, 'Octopussy::Alert::Modify()');

my $new_conf = Octopussy::Alert::Configuration($name);
ok((($new_conf->{description} eq $new_desc) && ($new_conf->{name} eq $name)),
  'Octopussy::Alert::Configuration()');

Octopussy::Alert::Remove($name);
ok(AAT::NOT_NULL($file) && !-f $file, 'Octopussy::Alert::Remove()');

=head2
my @contacts2 = Octopussy::Contact::List();
ok((scalar @contacts) == (scalar @contacts2 + 1),
  'Octopussy::Contact::Remove()');
=cut
1;

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut

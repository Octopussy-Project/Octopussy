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

use Test::More tests => 6;

use FindBin;
use lib "$FindBin::Bin/../usr/share/perl5";

use AAT::Application;
use AAT::Utils qw( NOT_NULL );
use Octopussy::Alert;

Readonly my $AAT_CONFIG_FILE_TEST => 't/data/etc/aat/aat.xml';
Readonly my $PREFIX => 'Octo_TEST_';

AAT::Application::Set_Config_File($AAT_CONFIG_FILE_TEST);

my ($name, $desc, $new_desc) =
  ("${PREFIX}alert", "${PREFIX}alert_desc", "${PREFIX}alert_new_desc");

my @list = Octopussy::Alert::List();

my %conf = (
  name              => $name,
  description       => $desc,
  level             => 'Warning',
  type              => 'Dynamic',
  loglevel          => 'Warning',
  taxonomy          => 'Auth.Failure',
  timeperiod        => '-ANY-',
  status            => 'Disabled',
  device            => ['device1', 'device2'],
  service           => ['service1', 'service2'],
  regexp_include    => undef,
  regexp_exclude    => undef,
  thresold_time     => 1,
  thresold_duration => 1,
  action            => undef,
  contact           => undef,
  msgsubject        => Encode::decode_utf8("${PREFIX}alert msg subject"),
  msgbody           => Encode::decode_utf8("${PREFIX}alert msg body"),
  action_host       => Encode::decode_utf8("${PREFIX}alert action host"),
  action_service    => Encode::decode_utf8("${PREFIX}alert action service"),
  action_body       => Encode::decode_utf8("${PREFIX}alert action body"),
);

my $file = Octopussy::Alert::New(\%conf);
ok(NOT_NULL($file) && -f $file, 'Octopussy::Alert::New()');

$conf{name} = $name . " &éèçà£µ§";
my $undef_file = Octopussy::Alert::New(\%conf);
ok(!defined $undef_file, 'Octopussy::Alert::New() accepts only /^[-_a-z0-9]+$/i for name');
$conf{name} = $name;

my @list2 = Octopussy::Alert::List();
ok(scalar @list + 1 == scalar @list2, 'Octopussy::Alert::List()');

my $old_size = -s $file;
$conf{description} = $new_desc;
Octopussy::Alert::Modify($name, \%conf);
my $new_size = -s $file;
ok($old_size < $new_size, 'Octopussy::Alert::Modify()');

my $new_conf = Octopussy::Alert::Configuration($name);
ok((($new_conf->{description} eq $new_desc) && ($new_conf->{name} eq $name)),
  'Octopussy::Alert::Configuration()');

Octopussy::Alert::Remove($name);
ok(NOT_NULL($file) && !-f $file, 'Octopussy::Alert::Remove()');

# Clean stuff
unlink $file;

1;

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut

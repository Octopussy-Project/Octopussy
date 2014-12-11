#!/usr/bin/perl

=head1 NAME

t/Octopussy/Message.t - Test Suite for Octopussy::Message module

=cut

use strict;
use warnings;

use FindBin;
use Test::More;

use lib "$FindBin::Bin/../../lib";

use AAT::Application;

AAT::Application::Set_Config_File("$FindBin::Bin/../data/etc/aat/aat.xml");

use AAT::Utils qw( NOT_NULL );
use Octopussy::Message;

my $SERVICE = 'Octopussy';
my $MSGID   = 'Octopussy:user_logged_in';

my $RE =
'(\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(?:\.\d{1,6})?(?:Z|(?:.\d{2}:\d{2}))) (\S+) octo_(\S+): (User .+ succesfully logged in.)';
my $RE2 =
'\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(?:\.\d{1,6})?(?:Z|(?:.\d{2}:\d{2})) \S+ octo_\S+: User .+ succesfully logged in.';

my $SAMPLE =
'2011-01-10T10:10:00.123456+01:00 localhost octo_WebUI: User admin succesfully logged in.';
my $SAMPLE_MSG = 'User admin succesfully logged in.';

my $SHORT_PATTERN = qq/<\@DATE_TIME_ISO\@> <\@WORD\@> octo_<\@WORD\@>:/;
my $SHORT_PATTERN_RE =
'(\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(?:\.\d{1,6})?(?:Z|(?:.\d{2}:\d{2}))) (\S+) octo_(\S+):';

my $REQUIRED_NB_FIELDS = 4;

require_ok('Octopussy::Message');

my $mconf = Octopussy::Message::Configuration($SERVICE, $MSGID);
cmp_ok(NOT_NULL($mconf) && $mconf->{taxonomy},
    'eq', 'Auth.Success', 'Octopussy::Message::Configuration()');

my @fields = Octopussy::Message::Fields($SERVICE, $MSGID);
cmp_ok(scalar @fields,
    '==', $REQUIRED_NB_FIELDS, 'Octopussy::Message::Fields()');

my $table = Octopussy::Message::Table($SERVICE, $MSGID);
cmp_ok($table, 'eq', 'Message', 'Octopussy::Message::Table()');

my $str_colored = Octopussy::Message::Color($mconf->{pattern});
like($str_colored, qr/<b><font color="green"><\@WORD:device\@><\/font><\/b>/,
    'Octopussy::Message::Color()');

my $str_colored_without_field =
    Octopussy::Message::Color_Without_Field($SHORT_PATTERN);
like(
    $str_colored_without_field,
    qr/<b><font color="green"><\@WORD\@><\/font><\/b>/,
    'Octopussy::Message::Color_Without_Field()'
);

my $spre =
    Octopussy::Message::Short_Pattern_To_Regexp({pattern => $SHORT_PATTERN});
cmp_ok($SHORT_PATTERN_RE, 'eq', $spre,
    'Octopussy::Message::Short_Pattern_To_Regexp()');

my $sql = Octopussy::Message::Pattern_To_SQL($mconf, '123456', ());
like(
    $sql,
    qr/INSERT INTO Message_123456 \(datetime, device, module, msg\)/,
    'Octopussy::Message::Pattern_To_SQL() with no fields'
);

$sql = Octopussy::Message::Pattern_To_SQL($mconf, '789', ('datetime', 'msg'));
like(
    $sql,
    qr/INSERT INTO Message_789 \(datetime, msg\)/,
    'Octopussy::Message::Pattern_To_SQL() with 2 fields'
);

my $re = Octopussy::Message::Pattern_To_Regexp($mconf);
cmp_ok($re, 'eq', $RE, 'Octopussy::Message::Pattern_To_Regexp()');
$mconf->{re} = $re;

my $re2 = Octopussy::Message::Pattern_To_Regexp_Without_Catching($mconf);
cmp_ok($re2, 'eq', $RE2,
    'Octopussy::Message::Pattern_To_Regexp_Without_Catching()');

my %field = Octopussy::Message::Fields_Values($mconf, $SAMPLE);
ok(scalar(keys %field) == $REQUIRED_NB_FIELDS && $field{msg} eq $SAMPLE_MSG,
    'Octopussy::Message::Fields_Values()');

done_testing(1 + 11);

=head1 AUTHOR

Sebastien Thebert <octopussy@onetool.pm>

=cut

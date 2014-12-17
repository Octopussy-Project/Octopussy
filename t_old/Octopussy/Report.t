#!/usr/bin/perl

=head1 NAME

t/Octopussy/Report.t - Test Suite for Octopussy::Report module

=cut

use strict;
use warnings;

use File::Path;
use FindBin;
use Test::More;

use lib "$FindBin::Bin/../../lib";

use AAT::Application;

AAT::Application::Set_Config_File("$FindBin::Bin/../data/etc/aat/aat.xml");

use Octopussy::FS;

my $DIR_REPORTS  = Octopussy::FS::Directory('reports');
my $PREFIX       = 'Octo_TEST_';
my $REPORT_TITLE = "${PREFIX}report";
my $REPORT_TABLE = 'Message';
my $REPORT_QUERY =
    'SELECT datetime, device, msg FROM Message ORDER BY datetime, device asc';
my @REPORT_COLUMNS       = qw( datetime device msg);
my @REPORT_COLUMNS_NAMES = qw( Datetime Device Message );

my %conf = (
    name         => $REPORT_TITLE,
    description  => "${PREFIX}report Description",
    category     => "${PREFIX}report_category",
    graph_type   => 'array',
    table        => $REPORT_TABLE,
    loglevel     => '-ANY-',
    taxonomy     => '-ANY-',
    query        => $REPORT_QUERY,
    columns      => join(',', @REPORT_COLUMNS),
    columns_name => join(',', @REPORT_COLUMNS_NAMES),
    x            => undef,
    y            => undef,
);

require_ok('Octopussy::Report');

unlink "${DIR_REPORTS}${REPORT_TITLE}.xml";

my @list       = Octopussy::Report::List();
my @categories = Octopussy::Report::Categories();

Octopussy::Report::New(\%conf);
ok(-f "${DIR_REPORTS}${REPORT_TITLE}.xml",
    'Octopussy::Report::New(array_type)');

my @list2       = Octopussy::Report::List();
my @categories2 = Octopussy::Report::Categories();
cmp_ok(scalar @list + 1, '==', scalar @list2, 'Octopussy::Report::List()');
cmp_ok(
    scalar @categories + 1,
    '==',
    scalar @categories2,
    'Octopussy::Report::Categories()'
);

my $conf = Octopussy::Report::Configuration($REPORT_TITLE);
cmp_ok(
    $conf->{description}, 'eq',
    "${PREFIX}report Description",
    'Octopussy::Report::Configuration()'
);

$conf{description} = "${PREFIX}report New Description";
Octopussy::Report::Modify($REPORT_TITLE, \%conf);
$conf = Octopussy::Report::Configuration($REPORT_TITLE);
cmp_ok($conf->{description}, 'eq', "${PREFIX}report New Description",
    'Octopussy::Report::Modify()');

Octopussy::Report::Remove($REPORT_TITLE);
ok(!-f "${DIR_REPORTS}${REPORT_TITLE}.xml", 'Octopussy::Report::Remove()');

# 3 Tests for invalid report name
foreach my $name (undef, '', 'report with space')
{
    my $param_str = (defined $name ? "'$name'" : 'undef');

    my $is_valid = Octopussy::Report::Valid_Name($name);
    ok(!$is_valid,
        'Octopussy::Report::Valid_Name(' . $param_str . ") => $is_valid");
}

# 2 Tests for valid report name
foreach my $name ('valid-report', 'valid_report')
{
    my $param_str = (defined $name ? "'$name'" : 'undef');

    my $is_valid = Octopussy::Report::Valid_Name($name);
    ok($is_valid,
        'Octopussy::Report::Valid_Name(' . $param_str . ") => $is_valid");
}

rmtree $DIR_REPORTS;

done_testing(1 + 6 + 3 + 2);

=head1 AUTHOR

Sebastien Thebert <octopussy@onetool.pm>

=cut

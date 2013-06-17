#!/usr/bin/perl

=head1 NAME

t/AAT/XML.t - Test Suite for AAT::XML module

=cut

use strict;
use warnings;

use FindBin;
use List::MoreUtils qw(any);
use Readonly;
use Test::More;

use lib "$FindBin::Bin/../../usr/share/perl5";

use AAT::XML;

Readonly my $DIR_LISTS => "$FindBin::Bin/../../usr/share/aat/Lists/";
Readonly my $FILE_PORTS => "$FindBin::Bin/../../usr/share/aat/Lists/AAT_Port.xml";
Readonly my $FILE_PORTS2 => "$FindBin::Bin/../../usr/share/aat/Lists//AAT_Port.xml";
Readonly my $NAME_PORTS => 'AAT_Port';
Readonly my $SELECTED_BY_DEFAULT => 'HTTP';
Readonly my $OCTO_FILE_TEST => '/tmp/octo_test.xml';

# Filename
my $filename = AAT::XML::Filename($DIR_LISTS, $NAME_PORTS);
ok(($filename eq $FILE_PORTS) || ($filename eq $FILE_PORTS2), 'AAT::XML::Filename()');

# Name_List
my @names = AAT::XML::Name_List($DIR_LISTS);
ok((grep { /$NAME_PORTS/ } @names), 'AAT::XML::Name_List()');

# File_Array_Values
my @values = AAT::XML::File_Array_Values($FILE_PORTS, 'item', 'label');
ok((grep { /SYSLOG/ } @values), 'AAT::XML::File_Array_Values()');

# Read
my $conf = AAT::XML::Read($FILE_PORTS);
cmp_ok($conf->{selected_by_default}, 'eq', $SELECTED_BY_DEFAULT, 'AAT::XML::Read()');

# Write
$conf->{selected_by_default} = 'DEFAULT';
AAT::XML::Write($OCTO_FILE_TEST, $conf);
my $conf2 = AAT::XML::Read($OCTO_FILE_TEST);
cmp_ok($conf2->{selected_by_default}, 'eq', 'DEFAULT', 'AAT::XML::Write()');
unlink $OCTO_FILE_TEST;

done_testing(5);

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut

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
use Readonly;

Readonly my $PREFIX => 'Octo_Test_';

#Readonly my $FILE1 => "/tmp/${PREFIX}file1";
#Readonly my $FILE2 => "/tmp/${PREFIX}file2";

use Test::More tests => 8;

use AAT::Utils qw( NOT_NULL );
use Octopussy;

my $email = Octopussy::Email();
ok(NOT_NULL($email) && $email =~ /^\S+\@\S+$/, 'Octopussy::Email()');
my $user = Octopussy::User();
ok(NOT_NULL($user) && $user =~ /^\w+$/, 'Octopussy::User()');
my $version = Octopussy::Version();
ok(NOT_NULL($version) && $version =~ /^\d+\.\d+.*$/,
  'Octopussy::Version()');

#unlink $FILE1, $FILE2;
#system "touch $FILE1 $FILE2";
#Octopussy::Chown($FILE1, $FILE2);
#unlink $FILE1, $FILE2;
#Octopussy::Chown($FILE1, $FILE2);

ok(NOT_NULL(Octopussy::Directory('main')), 'Octopussy::Directory()');
my @dirs = Octopussy::Directories('main', 'data_logs');
ok(scalar @dirs == 2, 'Octopussy::Directories()');

ok(NOT_NULL(Octopussy::File('db')), 'Octopussy::File()');
my @files = Octopussy::Files('db', 'proxy');
ok(scalar @files == 2, 'Octopussy::Files()');

ok(Octopussy::Parameter('logrotate') =~ /^\d+$/, 'Octopussy::Parameter()');

1;

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut

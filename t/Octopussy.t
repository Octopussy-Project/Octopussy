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

use Test::More tests => 2;

use FindBin;
use lib "$FindBin::Bin/../usr/share/perl5";

use AAT::Utils qw( NOT_NULL );
use Octopussy;

my $version = Octopussy::Version();
ok(NOT_NULL($version) && $version =~ /^\d+\.\d+.*$/,
  'Octopussy::Version()');

#unlink $FILE1, $FILE2;
#system "touch $FILE1 $FILE2";
#Octopussy::FS::Chown($FILE1, $FILE2);
#unlink $FILE1, $FILE2;
#Octopussy::FS::Chown($FILE1, $FILE2);

ok(Octopussy::Parameter('logrotate') =~ /^\d+$/, 'Octopussy::Parameter()');

1;

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut

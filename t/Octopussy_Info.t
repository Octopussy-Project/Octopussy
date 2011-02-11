#!/usr/bin/perl
# $HeadURL$
# $Revision$
# $Date$
# $Author$

=head1 NAME

Octopussy_Info.t - Octopussy Source Code Checker for Octopussy::Info

=cut

use strict;
use warnings;
use Readonly;

use Test::More tests => 3;

use FindBin;
use lib "$FindBin::Bin/../usr/share/perl5";

use AAT::Application;
use AAT::Utils qw( NOT_NULL );
use Octopussy::Info;

Readonly my $AAT_CONFIG_FILE_TEST => 't/data/etc/aat/aat.xml';

AAT::Application::Set_Config_File($AAT_CONFIG_FILE_TEST);

my $email = Octopussy::Info::Email();
ok(NOT_NULL($email) && $email =~ /^\S+\@\S+$/, 'Octopussy::Info::Email()');

my $user = Octopussy::Info::User();
ok(NOT_NULL($user) && $user =~ /^\w+$/, 'Octopussy::Info::User()');

my $website = Octopussy::Info::WebSite();
ok(NOT_NULL($website) && $website =~ /^http.+$/, 'Octopussy::Info::WebSite()');

1;

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut
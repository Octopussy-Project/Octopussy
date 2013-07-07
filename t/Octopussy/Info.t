#!/usr/bin/perl

=head1 NAME

t/Octopussy/Info.t - Test Suite for Octopussy::Info module

=cut

use strict;
use warnings;

use FindBin;
use Readonly;
use Test::More;

use lib "$FindBin::Bin/../../usr/share/perl5";

use AAT::Application;
use AAT::Utils qw( NOT_NULL );
use Octopussy::Info;

Readonly my $AAT_CONFIG_FILE_TEST => "$FindBin::Bin/../data/etc/aat/aat.xml";

AAT::Application::Set_Config_File($AAT_CONFIG_FILE_TEST);

my $email = Octopussy::Info::Email();
ok(NOT_NULL($email) && $email =~ /^\S+\@\S+$/, 
	"Octopussy::Info::Email() => $email");

my $user = Octopussy::Info::User();
ok(NOT_NULL($user) && $user =~ /^\w+$/,
	"Octopussy::Info::User() => $user");

my $website = Octopussy::Info::WebSite();
ok(NOT_NULL($website) && $website =~ /^http.+$/, 
	"Octopussy::Info::WebSite() => $website");

done_testing(3);

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut

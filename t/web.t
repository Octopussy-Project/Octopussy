#!/usr/bin/perl -w
# $HeadURL$
# $Revision$
# $Date$
# $Author$

=head1 NAME

web.t - Octopussy 'login' web page Test

=head1 DESCRIPTION

It checks: 
 - bad and good login

=cut

use strict;
use warnings;
use Readonly;

use Test::More tests => 14;

BEGIN { use_ok('WWW::Mechanize') }

Readonly my $PAGE_ROOT => 'https://127.0.0.1:8888';
Readonly my $PAGE_HOME => "$PAGE_ROOT/index.asp";
Readonly my $PAGE_LOGIN => "$PAGE_ROOT/login.asp";
Readonly my $PAGE_MESSAGES => "$PAGE_ROOT/messages.asp";
Readonly my $PAGE_SERVICES => "$PAGE_ROOT/services.asp";
Readonly my $PAGE_STORAGES => "$PAGE_ROOT/storages.asp";
Readonly my $PAGE_SYSTEM => "$PAGE_ROOT/system.asp";
Readonly my $PAGE_TABLES => "$PAGE_ROOT/tables.asp";
Readonly my $PAGE_USER_PREFS => "$PAGE_ROOT/user_pref.asp";
Readonly my $PAGE_USERS => "$PAGE_ROOT/user.asp";
Readonly my $LOGIN => 'admin';
Readonly my $PASSWORD => 'admin';
Readonly my $DIR_STORAGE_DEFAULT => qr{/var/lib/octopussy/logs/};
Readonly my $MESSAGE => 'Octopussy:parser_device_seconds';
Readonly my $SERVICE => 'Octopussy';
Readonly my $TABLE => 'Message';
Readonly my $MSG_DB_CONNECTION_OK => qr{Database Connection is OK !};
Readonly my $MSG_WRONG_PASSWORD => qr{You entered an invalid login/password !};

my $mech = WWW::Mechanize->new();


#
# Login
#
$mech->get($PAGE_LOGIN);
$mech->submit_form(
	form_number => 1,
 	fields    	=> { login  => $LOGIN, password => 'wrong_password' },
 	button    	=> 'submit');
like($mech->content(), $MSG_WRONG_PASSWORD, 
	"User '$LOGIN' was unable to logged in with wrong password.");

$mech->submit_form(
	form_number => 1,
 	fields    	=> { login  => $LOGIN, password => $PASSWORD },
 	button    	=> 'submit');
like($mech->content(), qr/bt_exit\.png/, 
	"User '$LOGIN' was able to logged in with good password.");


#
# User Prefs
#
$mech->get($PAGE_USER_PREFS);

my @inputs = $mech->find_all_inputs(name => 'AAT_Language');
my $idx = ${$inputs[0]}{current};
my $language = ${${$inputs[0]}{menu}}[$idx]{value};
@inputs = $mech->find_all_inputs(name => 'AAT_MenuMode');
$idx = ${$inputs[0]}{current};
my $menumode = ${${$inputs[0]}{menu}}[$idx]{value};
print "$language - $menumode\n";

$mech->submit_form(
	form_number => 1,
	fields => { AAT_Language => 'FR' },
	button => 'submit');
like($mech->content(), qr/Utilisateur/, 
	"User Preferences changed to 'FR' language.");	
$mech->submit_form(
	form_number => 1,
	fields => { AAT_Language => $language },
	button => 'submit');
		
$mech->submit_form(
	form_number => 1,
	fields => { AAT_MenuMode => 'TEXT_ONLY' },
	button => 'submit');
unlike($mech->content(), qr/bt_wizard\.png/, 
	"User Preferences changed to 'TEXT_ONLY' Menu Mode.");	
$mech->submit_form(
	form_number => 1,
	fields => { AAT_MenuMode => $menumode },
	button => 'submit');
	
#
# Messages
#
$mech->get($PAGE_MESSAGES);
$mech->submit_form(
	form_number => 1,
	fields 			=> { service => $SERVICE, table => $SERVICE },
	button 			=> 'submit');
like($mech->content(), qr/$MESSAGE/, 
	"Message '$MESSAGE' found with filters (svc '$SERVICE'/tbl '$SERVICE') in Messages page.");


#
# Services
#
$mech->get($PAGE_SERVICES);
like($mech->content(), qr/services\.asp\?service=$SERVICE/,
	"Service '$SERVICE' available in Services page.");
$mech->follow_link(url_regex => qr/services\.asp\?service=$SERVICE$/);
like($mech->content(), qr/$MESSAGE/,
	"Message '$MESSAGE' available for Service '$SERVICE' in Services page.");


#
# Storages
#
$mech->get($PAGE_STORAGES);
like($mech->content(), $DIR_STORAGE_DEFAULT,
	"Default Storage available in Storages page.");


#
# System
#
$mech->get($PAGE_SYSTEM);
like($mech->content(), $MSG_DB_CONNECTION_OK,
	"'Database Connection OK' message in System page.");

		
#
# Tables
#
$mech->get($PAGE_TABLES);
like($mech->content(), qr/tables\.asp\?table=$TABLE/,
	"Table '$TABLE' available in Tables page.");
$mech->follow_link(url_regex => qr/tables\.asp\?table=$TABLE$/);
like($mech->content(), qr/daemon/,
	"Field 'daemon' available for Table '$TABLE' in Tables page.");

			
#
# Users
#
$mech->get($PAGE_USERS);
like($mech->content(), qr/Admin/,
	"At least one user with 'Admin' rights in Users page.");
	
#
# Logout
#
$mech->get($PAGE_HOME);
$mech->follow_link(url_regex => qr/dialog\.asp\?id=logout$/);
$mech->follow_link(url_regex => qr/logout\.asp$/);
like($mech->content(), qr/octo_login1\.png/, 
	"User '$LOGIN' was able to logged out.");

1;

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut
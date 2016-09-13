#!/usr/bin/perl

=head1 NAME

t/AAT/User.t - Test Suite for AAT::User module

=cut

use strict;
use warnings;

use FindBin;
use Test::More;

use lib "$FindBin::Bin/../../lib";

use AAT::Application;

AAT::Application::Set_Config_File("$FindBin::Bin/../data/etc/aat/aat.xml");

require_ok('AAT::User');

my @invalid_passwords = qw/
	only5
	lowercaseonly
	UPPERCASEONLY
	12345678
	UPPERlower
	UPPERlower2
	/;

my @valid_passwords = qw/
	UPPERlower3!
	P@ssw0rd
	P3rl_Rules!
	/;

foreach my $pwd (@invalid_passwords)
{
	my $result = AAT::User::Check_Password_Rules('Octopussy', $pwd);

	cmp_ok($result->{status}, 'eq', 'KO', 
		"'$pwd' is invalid password: $result->{error}");
}

foreach my $pwd (@valid_passwords)
{
        my $result = AAT::User::Check_Password_Rules('Octopussy', $pwd);

        cmp_ok($result->{status}, 'eq', 'OK', 
		"'$pwd' is valid password");
}

done_testing(1 + scalar @invalid_passwords + scalar @valid_passwords);

=head1 AUTHOR

Sebastien Thebert <octopussy@onetool.pm>

=cut

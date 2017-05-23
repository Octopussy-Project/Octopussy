#!/usr/bin/perl

=head1 NAME

t/AAT/Translation.t - Test Suite for AAT::Translation module

=cut

use strict;
use warnings;
use bytes;
use utf8;

use FindBin;
use Test::More;

use lib "$FindBin::Bin/../../lib";

BEGIN
{
use AAT::Application;

AAT::Application::Set_Config_File("$FindBin::Bin/../data/etc/aat/aat.xml");
}

use AAT::Translation;

my %trans = (
    de => 'Benutzer',
    en => 'User',
    es => 'Usuario',
    fr => 'Utilisateur',
    it => 'Utente',
    pt => 'Usuário',
    ru => 'Пользователь',
    tr => 'Kullanıcı',
);

foreach my $lang (sort keys %trans)
{
    my $translated = AAT::Translation::Get($lang, '_USER');
    ok($translated eq $trans{$lang},
        "$lang translation: 'User' => '$trans{$lang}'")
        or diag(
"Translation $lang of '_USER' get '$translated' but should be '$trans{$lang}'"
        );
}

done_testing(scalar keys %trans);

=head1 AUTHOR

Sebastien Thebert <octopussy@onetool.pm>

=cut

#!/usr/bin/perl
# $HeadURL$
# $Revision$
# $Date$
# $Author$

=head1 NAME

AAT_Translation.t - Octopussy Source Code Checker for AAT::Translation

=cut

use strict;
use warnings;
use bytes;
use utf8;

use Test::More tests => 7;

use FindBin;
use lib "$FindBin::Bin/../usr/share/perl5";

use AAT::Translation;

my %trans = 
	(
		DE => { good => 'Benutzer' },
		EN => { good => 'User' },
		ES => { good => 'Usuario' },
		FR => { good => 'Utilisateur' },
		IT => { good => 'Utente' },
		PT => { good => 'Usuário' },
		RU => { good => 'Пользователь' },
	);

foreach my $lang (sort keys %trans)
{
	$trans{$lang}{get} = AAT::Translation::Get($lang, '_USER');
	ok($trans{$lang}{get} eq $trans{$lang}{good}, "$lang Translation") 
	or diag("Translation $lang of '_USER' get '$trans{$lang}{get}' but should be '$trans{$lang}{good}'");
}

1;


=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut
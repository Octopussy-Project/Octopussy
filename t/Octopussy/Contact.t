#!/usr/bin/perl

=head1 NAME

t/Octopussy/Contact.t - Test Suite for Octopussy::Contact module

=cut

use strict;
use warnings;

use File::Path;
use FindBin;
use List::MoreUtils qw(any);
use Readonly;
use Test::More;

use lib "$FindBin::Bin/../../usr/share/perl5";

use AAT::Application;
use Octopussy::Contact;

Readonly my $AAT_CONFIG_FILE_TEST => "$FindBin::Bin/../data/etc/aat/aat.xml";
Readonly my $PREFIX => 'Octo_TEST_';

AAT::Application::Set_Config_File($AAT_CONFIG_FILE_TEST);

Readonly my $DIR_CONTACTS => Octopussy::FS::Directory('contacts');

my ($id, $lastname, $firstname, $desc, $email, $im) = (
  "${PREFIX}contact_id",    "${PREFIX}contact_last",
  "${PREFIX}contact_first", "${PREFIX}contact_desc",
  'c@gmail.com',            'c@gmail.com',
);

my $error = Octopussy::Contact::New(
  {
    cid         => $id,
    lastname    => $lastname,
    firstname   => $firstname,
    description => $desc,
    email       => $email,
    im          => $im
  }
);

ok((!defined $error) && (-f "t/data/conf/contacts/${id}.xml"), 
	'Octopussy::Contact::New()') or diag($error);

my $error2 = Octopussy::Contact::New(
  {
    cid         => $id,
    lastname    => $lastname,
    firstname   => $firstname,
    description => $desc,
    email       => $email,
    im          => $im
  }
);
ok($error2 eq "_MSG_CONTACT_ALREADY_EXISTS",
    'Octopussy::Contact::New() fails when contact already exists') 
	or diag($error);

my $c = Octopussy::Contact::Configuration($id);

ok((($c->{lastname} eq $lastname) && ($c->{email} eq $email)),
  'Octopussy::Contact::Configuration()');

my @contacts = Octopussy::Contact::Configurations('lastname');
ok((any { $_->{cid} eq $id } @contacts), 'Octopussy::Contact::Configurations()');

Octopussy::Contact::Remove($id);
my @contacts2 = Octopussy::Contact::List();
ok((scalar @contacts) == (scalar @contacts2 + 1),
  'Octopussy::Contact::Remove()');

rmtree $DIR_CONTACTS;

done_testing(5);

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut

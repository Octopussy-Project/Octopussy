#!/usr/bin/perl
# $HeadURL$
# $Revision$
# $Date$
# $Author$

=head1 NAME

Octopussy_Contact.t - Octopussy Source Code Checker for Octopussy::Contact

=cut

use strict;
use warnings;
use Readonly;

use List::MoreUtils qw(any);

use Test::More tests => 4;

use Octopussy::Contact;

Readonly my $PREFIX => 'Octo_TEST_';

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

ok(!defined $error, 'Octopussy::Contact::New()') or diag($error);

my $c = Octopussy::Contact::Configuration($id);

ok((($c->{lastname} eq $lastname) && ($c->{email} eq $email)),
  'Octopussy::Contact::Configuration()');

my @contacts = Octopussy::Contact::Configurations('lastname');
ok((any { $_->{cid} eq $id } @contacts), 'Octopussy::Contact::Configurations()');

Octopussy::Contact::Remove($id);
my @contacts2 = Octopussy::Contact::List();
ok((scalar @contacts) == (scalar @contacts2 + 1),
  'Octopussy::Contact::Remove()');

1;

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut

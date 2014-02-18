=head1 NAME

Octopussy::Plugin::Email - Octopussy Plugin Email

=cut

package Octopussy::Plugin::Email;

use strict;
use warnings;

use Octopussy;

my $RE_EMAIL = qr/^(.+)\@(.+)$/;

=head1 FUNCTIONS

=head2 Init(\%conf)

=cut

sub Init
{
}

=head2 Domain($email)

Returns Email Address Domain (ex: someone@somewhere.org -> somewhere.org)

=cut

sub Domain
{
  my $email = shift;

  if ($email =~ $RE_EMAIL)
  {
    return ($2);
  }
}

=head2 User($email)

Returns Email Address User (ex: someone@somewhere.org -> someone)

=cut

sub User
{
  my $email = shift;

  if ($email =~ $RE_EMAIL)
  {
    return ($1);
  }
}

1;

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut

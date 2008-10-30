=head1 NAME

Octopussy::Plugin::Email - Octopussy Plugin Email

=cut
package Octopussy::Plugin::Email;

use strict;
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
sub Domain($)
{
	my $email = shift;

	return ($2)	if ($email =~ $RE_EMAIL);
}

=head2 User($email)

Returns Email Address User (ex: someone@somewhere.org -> someone)

=cut
sub User($)
{
	my $email = shift;
  
  return ($1) if ($email =~ $RE_EMAIL);
}

1;

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut

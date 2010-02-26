# $HeadURL$
# $Revision$
# $Date$
# $Author$

=head1 NAME

Octopussy::Plugin::SMTP - Octopussy Plugin SMTP

=cut

package Octopussy::Plugin::SMTP;

use strict;
use warnings;

use Octopussy;

my @bounce_types = (
  {
    re   => qr/^Bad destination host.*$/i,
    type => 'Bad Destination Host'
  },
  {
    re   => qr/^Unknown address error.*$/i,
    type => 'Unknown Address Error'
  },
);

my @response_types = (
  {
    re   => qr/^.*accepted for delivery.*$/i,
    type => 'Accepeted for delivery'
  },
  {
    re   => qr/^.*Message.* accepted.*$/i,
    type => 'Message accepted'
  },
  {
    re   => qr/^.*message queued.*$/i,
    type => 'Queued'
  },
  {
    re   => qr/^ok.*$/i,
    type => 'Ok'
  },
  {
    re   => qr/.*ok\.*$/i,
    type => 'Ok'
  },
  {
    re   => qr/^.* queued as .*$/i,
    type => 'Queued'
  },
  {
    re   => qr/^.*Queued mail.*$/i,
    type => 'Queued'
  },
  {
    re   => qr/^.*Requested mail action okay.*$/i,
    type => 'Requested mail action okay'
  },
);

=head1 FUNCTIONS

=head2 Init()

=cut

sub Init
{
}

=head2 Bounce_Type($bounce) 

Returns Bounce Type

=cut

sub Bounce_Type
{
  my $bounce = shift;

  return (undef) if (!defined $bounce);
  foreach my $bt (@bounce_types)
  {
    return ($bt->{type}) if ($bounce =~ $bt->{re});
  }

  return ($bounce);
}

=head2 Response_Type($response)

Returns Response Type

=cut

sub Response_Type
{
  my $response = shift;

  return (undef) if (!defined $response);
  foreach my $rt (@response_types)
  {
    return ($rt->{type}) if ($response =~ $rt->{re});
  }

  return ($response);
}

=head2 Recipients_Count($recipients_list)

Reurns number of recipients

=cut

sub Recipients_Count
{
  my $recipients_list = shift;

  my @recipients = split /,/, $recipients_list;

  return (scalar @recipients);
}

1;

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut

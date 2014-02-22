=head1 NAME

Octopussy::Plugin::IronPort - Octopussy Plugin IronPort

=cut

package Octopussy::Plugin::IronPort;

use strict;
use warnings;

use Octopussy;

my $RE_ANTISPAM_STATUS  = qr/^using engine: CASE (spam \w+)$/;
my $RE_ANTIVIRUS_NAME   = qr/^antivirus (\w+) '(.+?)'.*$/;
my $RE_ANTIVIRUS_STATUS = qr/^antivirus (\w+).*$/;

=head1 FUNCTIONS

=head2 Init()

=cut

sub Init
{
}

=head2 AntiSpam_Status($line)

Returns Antispam status

=cut

sub AntiSpam_Status
{
  my $line = shift;

  if ($line =~ $RE_ANTISPAM_STATUS)
  {
    return ($1);
  }

  return (undef);
}

=head2 AntiVirus_Status($line)

Returns Antivirus status

=cut

sub AntiVirus_Status
{
  my $line = shift;

  if ($line =~ $RE_ANTIVIRUS_STATUS)
  {
    return ($1);
  }

  return (undef);
}

=head2 Virus_Name($line)

Returns Virus name

=cut

sub Virus_Name
{
  my $line = shift;

  if (($line =~ $RE_ANTIVIRUS_NAME) && ($1 ne 'unscannable'))
  {
    return ($2);
  }

  return (undef);
}

1;

=head1 AUTHOR

Sebastien Thebert <octopussy@onetool.pm>

=cut

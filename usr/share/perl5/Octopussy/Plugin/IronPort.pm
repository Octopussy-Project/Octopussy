=head1 NAME

Octopussy::Plugin::IronPort - Octopussy Plugin IronPort

=cut

package Octopussy::Plugin::IronPort;

use strict;
use warnings;

use Octopussy;

=head1 FUNCTIONS

=head2 Init()

=cut

sub Init()
{
}

=head2 AntiSpam_Status($line)

=cut

sub AntiSpam_Status($)
{
  my $line = shift;

  return ($1) if ($line =~ /^using engine: CASE (spam \w+)$/);

  return (undef);
}

=head2 AntiVirus_Status($line)

=cut

sub AntiVirus_Status($)
{
  my $line = shift;

  return ($1) if ($line =~ /^antivirus (\w+).*$/);

  return (undef);
}

=head2 Virus_Name($line)

=cut

sub Virus_Name($)
{
  my $line = shift;

  return ($2)
    if (($line =~ /^antivirus (\w+) '(.+?)'.*$/) && ($1 ne 'unscannable'));

  return (undef);
}

1;

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut

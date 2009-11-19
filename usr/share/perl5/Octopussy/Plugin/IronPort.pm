# $HeadURL$
# $Revision$
# $Date$
# $Author$

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

sub Init
{
}

=head2 AntiSpam_Status($line)

=cut

sub AntiSpam_Status
{
  my $line = shift;

  if ( $line =~ /^using engine: CASE (spam \w+)$/ )
  {
    return ($1);
  }

  return (undef);
}

=head2 AntiVirus_Status($line)

=cut

sub AntiVirus_Status
{
  my $line = shift;

  if ( $line =~ /^antivirus (\w+).*$/ )
  {
    return ($1);
  }

  return (undef);
}

=head2 Virus_Name($line)

=cut

sub Virus_Name
{
  my $line = shift;

  if ( ( $line =~ /^antivirus (\w+) '(.+?)'.*$/ ) && ( $1 ne 'unscannable' ) )
  {
    return ($2);
  }

  return (undef);
}

1;

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut

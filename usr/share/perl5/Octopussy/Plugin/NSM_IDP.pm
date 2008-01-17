=head1 NAME

Octopussy::Plugin::NSM_IDP - Octopussy Plugin NSM IDP

=cut
package Octopussy::Plugin::NSM_IDP;

use strict;
use Octopussy;

my $DATA_FILE = "/usr/share/perl5/Octopussy/Plugin/attack_table.nml";

my %attack = ();
my $id = undef;

=head1 FUNCTIONS

=head2 Init()

Get data from the Juniper 'attack_table.nml' file

=cut
sub Init()
{
	%attack = ();
  open(FILE, "< $DATA_FILE");
  while (<FILE>)
  {
    $id = $2  if ($_ =~ /:(\d+).+\("(\S+)"/);
    $attack{$id}{long_name} = $1  	if ($_ =~ /:long_name \("(.+)"\)/);
    $attack{$id}{description} = $1  if ($_ =~ /:description \("(.+)"\)/);
    push(@{$attack{$id}{refs}}, $1) if ($_ =~ /:url\d* \("(\S+)"\)/);
  }
  close(FILE);
}

=head2 Description($id)

Returns Description of the attack with id '$id'

=cut
sub Description($)
{
	my $id = shift;

	return ($attack{$id}{description});
}

=head2 Long_Name($id)

Returns Full Name of the attack with id '$id'

=cut 
sub Long_Name($)
{
  my $id = shift;

  return ($attack{$id}{long_name});
}

=head2 Refs($id)

Returns References of the attack with id '$id'

=cut
sub Refs($)
{
	my $id = shift;

  return ($attack{$id}{refs});
}

1;

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut

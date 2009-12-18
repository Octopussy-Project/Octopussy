# $HeadURL$
# $Revision$
# $Date$
# $Author$

=head1 NAME

Octopussy::World_Stats - Octopussy World Statistics module

=cut

package Octopussy::World_Stats;

use strict;
use warnings;
use Readonly;

use Octopussy;

Readonly my $FILE_WORLD_STATS => 'world_stats';
Readonly my $XML_ROOT         => 'octopussy_world_stats';

=head1 FUNCTIONS

=head2 ID()

Get/Generates World Statistics ID

=cut

sub ID
{
  Readonly my $RANDOM_NUMBER => 999;
  my $conf = Configuration();

  if (AAT::NOT_NULL($conf) && AAT::NOT_NULL($conf->{id}))
  {
    return ($conf->{id});
  }
  else
  {
    my $str = time() * rand $RANDOM_NUMBER;
    $str = `echo "$str" | md5sum`;
    chomp $str;
    $str =~ s/^(\S+).+$/$1/;
    return ($str);
  }
}

=head2 Modify(\%conf)

Modifies World Statistics configuration

=cut 

sub Modify
{
  my $conf = shift;

  AAT::XML::Write(Octopussy::File($FILE_WORLD_STATS), $conf, $XML_ROOT);

  return (undef);
}

=head2 Configuration()

Returns World Statistics Configuration

=cut

sub Configuration
{
  my $conf = AAT::XML::Read(Octopussy::File($FILE_WORLD_STATS));

  return ($conf);
}

1;

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut

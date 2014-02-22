=head1 NAME

Octopussy::Plugin::Web - Octopussy Plugin Web

=cut

package Octopussy::Plugin::Web;

use strict;
use warnings;

use AAT::List;
use AAT::Utils qw( ARRAY NOT_NULL);
use Octopussy;

my @browsers          = ();
my @operating_systems = ();

=head1 FUNCTIONS

=head2 Init()

Initializes Browsers and Operating Systems information

=cut

sub Init
{
  my $conf_bot     = AAT::List::Configuration('AAT_Bot');
  my $conf_browser = AAT::List::Configuration('AAT_Browser');
  my $conf_mobile  = AAT::List::Configuration('AAT_MobilePhone');
  my $conf_os      = AAT::List::Configuration('AAT_Operating_System');

  my @list = (
    ARRAY($conf_browser->{item}),
    ARRAY($conf_mobile->{item}),
    ARRAY($conf_bot->{item}),
  );
  foreach my $i (@list)
  {
    push @browsers,
      {
      label  => $i->{label},
      logo   => $i->{logo},
      regexp => qr/$i->{regexp}/
      }
      if (NOT_NULL($i->{regexp}));
  }
  foreach my $i (ARRAY($conf_os->{item}))
  {
    push @operating_systems,
      {
      label  => $i->{label},
      logo   => $i->{logo},
      regexp => qr/$i->{regexp}/
      }
      if (NOT_NULL($i->{regexp}));
  }

  return (1);
}

=head2 Logo($logo, $alt)

Returns Browser or Operating System Logo
 
=cut

sub Logo
{
  my ($logo, $alt) = @_;

  my $file = "AAT/IMG/${logo}.png";

  return ("<img src=\"$file\" alt=\"$alt\"><b>$alt</b>");
}

=head2 UserAgent_Browser($ua)

Returns Browser from UserAgent information
=cut

sub UserAgent_Browser
{
  my $ua = shift;

  foreach my $i (@browsers)
  {
    if ($ua =~ $i->{regexp})
    {
      return (Logo("$i->{logo}", $i->{label}))
        if (defined $i->{logo});
      return ($i->{label});
    }
  }

  return ($ua);
}

=head2 UserAgent_OS($ua)

Returns Operating System from UserAgent information

=cut

sub UserAgent_OS
{
  my $ua = shift;

  foreach my $i (@operating_systems)
  {
    return (Logo(($i->{logo} || ''), $i->{label}))
      if ($ua =~ $i->{regexp});
  }

  return ($ua);
}

1;

=head1 AUTHOR

Sebastien Thebert <octopussy@onetool.pm>

=cut

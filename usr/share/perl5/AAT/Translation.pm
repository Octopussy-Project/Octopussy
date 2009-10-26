
=head1 NAME

AAT::Translation - AAT Translation module

=cut

package AAT::Translation;

use strict;
use warnings;

my %AAT_Translation = ();

=head1 FUNCTIONS

=head2 Init($lang, @dirs)

Inits Translation Data from directories '@dirs' for language '$lang'

=cut

sub Init
{
  my ($lang, @dirs) = @_;
  my @list = (AAT::Directory('translations'), @dirs);

  foreach my $dir (@list)
  {
    if (-f "$dir${lang}.xml")
    {    # Basic Translations
      my $conf = AAT::XML::Read("$dir${lang}.xml");
      foreach my $m (AAT::ARRAY($conf->{msg}))
      {
        $AAT_Translation{$lang}{$m->{mid}} = $m->{value};
      }
    }
    if (-f "$dir${lang}_Tooltips.xml")
    {    # Tooltips Translations
      my $conf = AAT::XML::Read("$dir${lang}_Tooltips.xml");
      foreach my $m (AAT::ARRAY($conf->{msg}))
      {
        $AAT_Translation{$lang}{$m->{mid}} = $m->{value};
      }
    }
  }
}

=head2 Get($lang, $str)

Gets Translation for string '$str' in language '$lang'

=cut

sub Get
{
  my ($lang, $str) = @_;

  return (undef) if (AAT::NULL($str));
  Init($lang) if (!defined $AAT_Translation{$lang}{'_DAY'});

  return ($AAT_Translation{$lang}{$str} || $str);
}

1;

=head1 SEE ALSO

AAT(3), AAT::DB(3), AAT::Syslog(3), AAT::Theme(3), AAT::User(3), AAT::XML(3)

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut

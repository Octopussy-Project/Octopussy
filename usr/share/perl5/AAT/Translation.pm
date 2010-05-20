# $HeadURL$
# $Revision$
# $Date$
# $Author$

=head1 NAME

AAT::Translation - AAT Translation module

=cut

package AAT::Translation;

use strict;
use warnings;
use Readonly;

use AAT::Utils qw( NULL );

my %AAT_Translation = ();

use Locale::Maketext::Simple(
  Path => '/usr/share/aat/Translations/'
  ,    # can't use AAT::Application::Directory('AAT', 'translations') :(
);

=head1 FUNCTIONS

=head2 Init($lang)

Inits Translation Data for language '$lang'

=cut

sub Init
{
  my $lang = shift;

  loc_lang($lang);
  $AAT_Translation{$lang}{'_USER'} = loc("_USER");
}

=head2 Get($lang, $str)

Gets Translation for string '$str' in language '$lang'

=cut

sub Get
{
  my ($lang, $str) = @_;

  return (undef) if (NULL($str));
  Init($lang) if (!defined $AAT_Translation{$lang}{'_USER'});
  $AAT_Translation{$lang}{$str} = (loc($str) || $str)
    if (!defined $AAT_Translation{$lang}{$str});

  return ($AAT_Translation{$lang}{$str});
}

1;

=head1 SEE ALSO

AAT(3), AAT::DB(3), AAT::Syslog(3), AAT::Theme(3), AAT::User(3), AAT::XML(3)

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut

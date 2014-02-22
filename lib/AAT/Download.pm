=head1 NAME

AAT::Download - AAT Download module

=cut

package AAT::Download;

use strict;
use warnings;

use LWP;

use AAT::Proxy;
use AAT::Syslog;
use AAT::Utils qw( NOT_NULL );

my $TIMEOUT = 5; # 5 seconds before timeout


=head1 FUNCTIONS

=head2 File($appli, $download, $dest)

Downloads $download to local file $dest

=cut

sub File
{
  my ($appli, $download, $dest) = @_;
  my $pc = AAT::Proxy::Configuration($appli);
  my $proxy =
      (NOT_NULL($pc->{server}) ? "http://$pc->{server}" : '')
    . (NOT_NULL($pc->{port})   ? ":$pc->{port}"         : '');

  my $ua = LWP::UserAgent->new;
  $ua->agent($appli);
  $ua->proxy('http', $proxy);
  $ua->timeout($TIMEOUT);
  my $req = HTTP::Request->new(GET => $download);
  my $res = $ua->request($req);
  if ($res->is_success)
  {
    if (defined open(my $FILE, '>', $dest))
    {
      print $FILE $res->content;
      close($FILE);
      return ($dest);
    }
  }
  else
  {
    $download =~ s/\%\d\d/ /g;    # '%' is not good for sprintf used by syslog
    AAT::Syslog::Message($appli, 'DOWNLOAD_FAILED', $download);
  }

  return (undef);
}

1;

=head1 AUTHOR

Sebastien Thebert <octopussy@onetool.pm>

=cut

# $HeadURL$
# $Revision$
# $Date$
# $Author$

=head1 NAME

AAT::NSCA - AAT NSCA module

=cut

package AAT::NSCA;

use strict;
use warnings;

my %conf_file = ();

=head1 FUNCTIONS

=head2 Configuration($appli)

Returns NSCA Configuration

=cut

sub Configuration
{
  my $appli = shift;

  $conf_file{$appli} ||= AAT::Application::File($appli, 'nsca');
  my $conf = AAT::XML::Read($conf_file{$appli}, 1);

  return ($conf->{nsca});
}

=head2 Send($appli, $level, $msg, $nagios_host, $nagios_service)

Sends NSCA message '$msg' with level '$level'

=cut

sub Send
{
  my ($appli, $level, $msg, $nagios_host, $nagios_service) = @_;

  my $nsca = Configuration($appli);
  if ( (defined $nsca)
    && (defined $nsca->{bin})
    && (defined $nsca->{conf})
    && (-e $nsca->{bin})
    && (-e $nsca->{conf}))
  {
    my $host    = $nagios_host    || $nsca->{nagios_host};
    my $service = $nagios_service || $nsca->{nagios_service};
    my $nsca_cmd = "$nsca->{bin} -H $nsca->{nagios_server} -c $nsca->{conf}";
    if (defined open my $NSCA, '|-', $nsca_cmd)
    {
      print {$NSCA} "$host\t$service\t$level\t$msg\n";
      close $NSCA;

      return (1);
    }
  }

  return (0);
}

1;

=head1 SEE ALSO

AAT(3), AAT::Syslog(3), AAT::Theme(3), AAT::Translation(3), AAT::User(3), AAT::XML(3)

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut

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
sub Configuration($)
{
	my $appli = shift;

	$conf_file{$appli} ||= AAT::Application::File($appli, "nsca");
	my $conf = AAT::XML::Read($conf_file{$appli}, 1);

	return ($conf->{nsca});
}

=head2 Send($appli, $level, $msg, $nagios_host, $nagios_service)

Sends NSCA message '$msg' with level '$level'

=cut
sub Send($$$$$)
{
  my ($appli, $level, $msg, $nagios_host, $nagios_service) = @_;
	
	my $conf_nsca = Configuration($appli);
  if ((defined $conf_nsca)
    && (defined $conf_nsca->{bin}) && (defined $conf_nsca->{conf})
    && (-e $conf_nsca->{bin}) && (-e $conf_nsca->{conf}))
  {
    my $host = $nagios_host || $conf_nsca->{nagios_host};
    my $service = $nagios_service || $conf_nsca->{nagios_service};
    open(NSCA, "| $conf_nsca->{bin} -H $conf_nsca->{nagios_server} -c $conf_nsca->{conf}");
    print NSCA "$host\t$service\t$level\t$msg\n";
    close(NSCA);
  }
}

1;

=head1 SEE ALSO

AAT(3), AAT::Syslog(3), AAT::Theme(3), AAT::Translation(3), AAT::User(3), AAT::XML(3)

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut

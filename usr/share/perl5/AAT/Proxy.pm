=head1 NAME

AAT::Proxy - AAT Proxy module

=cut
package AAT::Proxy;

use strict;

use constant TEST_FILE => "/tmp/test.html";

my %conf_file = ();

=head1 FUNCTIONS

=head2 Configuration($appli)

Returns Proxy Configuration

=cut
sub Configuration($)
{
	my $appli = shift;

	$conf_file{$appli} ||= AAT::Application::File($appli, "proxy");
	my $conf = AAT::XML::Read($conf_file{$appli}, 1);

	return ($conf->{proxy});
}

=head2 Connection_Test($appli)

Check the Proxy Connection

=cut
sub Connection_Test($)
{
	my $appli = shift;

	AAT::Download($appli, "http://www.google.com", TEST_FILE);
	my $status = ((-s TEST_FILE > 0) ? 1 : 0);
	unlink(TEST_FILE)	if (-f TEST_FILE);

	return ($status);
}

1;

=head1 SEE ALSO

AAT(3), AAT::Syslog(3), AAT::Theme(3), AAT::Translation(3), AAT::User(3), AAT::XML(3)

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut

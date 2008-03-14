#################### Octopussy Project ####################
# $Id$
###########################################################
=head1 NAME

AAT::SMTP - AAT SMTP module

=cut
package AAT::SMTP;

use strict;
use Mail::Sender;
use Net::Telnet;

my %conf_file = ();

=head1 FUNCTIONS

=head2 Configuration($appli)

Returns SMTP configuration

=cut

sub Configuration($)
{
	my $appli = shift;

	$conf_file{$appli} ||= AAT::Application::File($appli, "smtp");
	my $conf = AAT::XML::Read($conf_file{$appli}, 1);

	return ($conf->{smtp});
}

=head2 Connection_Test($appli)

Checks the SMTP connection

=cut

sub Connection_Test($)
{
	my $appli = shift;
	my $status = 0;
	my $smtp_conf = Configuration($appli);
	if (AAT::NOT_NULL($smtp_conf->{server})
    && AAT::NOT_NULL($smtp_conf->{sender}))
  {
		my $con = new Net::Telnet(Host => $smtp_conf->{server}, 
			Port => 25, Errmode => "return", Timeout => 3);
		if (defined $con)
		{
    	$status = 1;
			$con->close();
		}
  }		

	return ($status);
}

=head2 Send_Message($appli, $subject, $body, @dests)

Send message to @dests

=cut

sub Send_Message($$$@)
{
  my ($appli, $subject, $body, @dests) = @_;

  my $conf = Configuration($appli);
	if (AAT::NOT_NULL($conf->{server}) && AAT::NOT_NULL($conf->{sender}))
	{
  	my $sender = new Mail::Sender 
			{ smtp => $conf->{server}, from => $conf->{sender} };
  	if ((defined $sender) && (ref $sender))
  	{
    	foreach my $dest (@dests)
    	{
      	$sender->MailMsg( { to => $dest, subject => $subject, msg => $body } );
    	}
			$sender->Close();
  	}
	}
	else
	{
		AAT::Syslog("AAT::SMTP", "SMTP_INVALID_CONFIG");
	}
}

=head2 Send_Message_With_File($appli, $subject, $body, $file, @dests)

Send message with file to @dests

=cut

sub Send_Message_With_File($$$$@)
{
  my ($appli, $subject, $body, $file, @dests) = @_;

  my $conf = Configuration($appli);
	if (AAT::NOT_NULL($conf->{server}) && AAT::NOT_NULL($conf->{sender}))
	{
  	my $sender = new Mail::Sender 
			{ smtp => $conf->{server}, from => $conf->{sender} };
  	if ((defined $sender) && (ref $sender))
  	{
    	foreach my $dest (@dests)
   		{
      	$sender->MailFile( { to => $dest, subject => $subject, msg => $body,
        	file => $file } );
    	}
			$sender->Close();
  	}
	}
	else
	{
		AAT::Syslog("AAT::SMTP", "SMTP_INVALID_CONFIG");
	}
}

1;

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut

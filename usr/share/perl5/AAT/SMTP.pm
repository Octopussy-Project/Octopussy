=head1 NAME

AAT::SMTP - AAT SMTP module

=cut
package AAT::SMTP;

use strict;
use Mail::Sender;
use Net::Telnet;

my $SMTP_FILE = undef;

=head1 FUNCTIONS

=head2 Configuration()

Returns SMTP configuration

=cut

sub Configuration()
{
	$SMTP_FILE ||= AAT::File("smtp");
	my $conf = AAT::XML::Read($SMTP_FILE, 1);

	return ($conf->{smtp});
}

=head2 Connection_Test()

Checks the SMTP connection

=cut

sub Connection_Test()
{
	my $status = 0;
	my $smtp_conf = Configuration();
	if (AAT::NOT_NULL($smtp_conf->{server})
    && AAT::NOT_NULL($smtp_conf->{sender}))
  {
		AAT::DEBUG("SMTP Connection::Test Begin");
		my $con = new Net::Telnet(Host => $smtp_conf->{server}, 
			Port => 25, Errmode => "return", Timeout => 3);
		if (defined $con)
		{
    	$status = 1;
			$con->close();
		}
		AAT::DEBUG("SMTP Connection::Test End");
  }		

	return ($status);
}

=head2 Send_Message($subject, $body, @dests)

Send message to @dests

=cut

sub Send_Message($$@)
{
  my ($subject, $body, @dests) = @_;

  my $conf = Configuration();
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

=head2 Send_Message_With_File($subject, $body, $file, @dests)

Send message with file to @dests

=cut

sub Send_Message_With_File($$$@)
{
  my ($subject, $body, $file, @dests) = @_;

  my $conf = Configuration();
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

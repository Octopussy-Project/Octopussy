#################### Octopussy Project ####################
# $Id$
###########################################################
=head1 NAME

AAT::Syslog - AAT Syslog module

=cut
package AAT::Syslog;

use strict;
use Unix::Syslog qw(:macros);
use Unix::Syslog qw(:subs);

my $MSG_LOGS_FILE = undef;

my %AAT_Syslog = ();

=head1 FUNCTIONS

=head2 Message($module, $msg, @args)

=cut

sub Message($$@)
{
	my ($module, $msg, @args) = @_;

	$MSG_LOGS_FILE ||= AAT::File("message_logs");	
	if (!defined $AAT_Syslog{GENERIC_CREATED})
  {
    my $conf = AAT::XML::Read($MSG_LOGS_FILE);
    foreach my $m (AAT::ARRAY($conf->{log}))
      { $AAT_Syslog{$m->{mid}} = $m->{message}; }
  }
  my $message = $AAT_Syslog{$msg} || $msg;
  $message =~ s/\%\%ARG(\d+)\%\%/$args[$1-1]/g	if ($#args >= 0);
  $message =~ s/\%\%LOGIN\%\%/$main::Session->{AAT_LOGIN}/g
		if (defined $main::Session->{AAT_LOGIN});

	openlog($module, LOG_INFO, LOG_LOCAL5);
  syslog(LOG_INFO, $message);
  closelog();
}

1;

=head1 SEE ALSO

AAT(3), AAT::DB(3), AAT::Theme(3), AAT::Translation(3), AAT::User(3), AAT::XML(3)

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut

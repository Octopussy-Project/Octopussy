
=head1 NAME

AAT::Syslog - AAT Syslog module

=cut

package AAT::Syslog;

use strict;
use warnings;

use Unix::Syslog qw(:macros);
use Unix::Syslog qw(:subs);

use AAT::FS;
use AAT::Utils qw( ARRAY );
use AAT::XML;

my $MSG_LOGS_FILE = undef;

my %AAT_Syslog = ();

=head1 FUNCTIONS

=head2 Message($module, $msg, @args)

Syslog Message $msg from $module

=cut

sub Message
{
    my ($module, $msg, @args) = @_;

    $MSG_LOGS_FILE ||= AAT::FS::File('message_logs');
    if (!defined $AAT_Syslog{GENERIC_CREATED})
    {
        my $conf = AAT::XML::Read($MSG_LOGS_FILE);
        foreach my $m (ARRAY($conf->{log}))
        {
            $AAT_Syslog{$m->{mid}} = $m->{message};
        }
    }
    my $message = $AAT_Syslog{$msg} || $msg;
    $message =~ s/\%\%ARG(\d+)\%\%/$args[$1-1]/g if (scalar(@args) > 0);

    openlog($module, LOG_INFO, LOG_LOCAL5);
    syslog(LOG_INFO, $message);
    closelog();

    return ($message);
}

=head2 Messages($module, \@messages)

Syslog many messages from $module in one shot

=cut

sub Messages
{
    my ($module, $msgs) = @_;

    openlog($module, LOG_INFO, LOG_LOCAL5);
    foreach my $msg (ARRAY($msgs)) { syslog(LOG_INFO, $msg); }
    closelog();

    return (scalar ARRAY($msgs));
}

1;

=head1 SEE ALSO

AAT(3), AAT::DB(3), AAT::Theme(3), AAT::Translation(3), AAT::User(3), AAT::XML(3)

=head1 AUTHOR

Sebastien Thebert <octopussy@onetool.pm>

=cut

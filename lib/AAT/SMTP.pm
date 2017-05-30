package AAT::SMTP;

=head1 NAME

AAT::SMTP - AAT SMTP module

=cut

use strict;
use warnings;

use Authen::SASL;
use Email::MIME;
use Email::Sender;
use Email::Sender::Simple;
use Email::Sender::Transport::SMTP;
use Net::Telnet;
use Path::Tiny;

use AAT::Application;
use AAT::Syslog;
use AAT::Utils qw( ARRAY NOT_NULL );
use AAT::XML;

my $SMTP_PORT    = 25;
my $SMTP_TIMEOUT = 3;

my %conf_file = ();

=head1 SUBROUTINES

=head2 Configuration($appli)

Returns SMTP configuration

=cut

sub Configuration
{
    my $appli = shift;

    $conf_file{$appli} ||= AAT::Application::File($appli, 'smtp');
    my $conf = AAT::XML::Read($conf_file{$appli}, 1);

    return ($conf->{smtp});
}

=head2 Connection_Test($appli)

Checks the SMTP connection

=cut

sub Connection_Test
{
    my $appli = shift;

    my $status = 0;
    my $conf   = Configuration($appli);
    if (   NOT_NULL($conf->{server})
        && NOT_NULL($conf->{sender}))
    {
        my $con = Net::Telnet->new(
            Host    => $conf->{server},
            Port    => $conf->{port} || $SMTP_PORT,
            Errmode => 'return',
            Timeout => $SMTP_TIMEOUT
        );
        my $transport = Email::Sender::Transport::SMTP->new(
            {
                host => $conf->{server},
                port => $conf->{port} || $SMTP_PORT,
            }
        );
        if ((defined $con) && (defined $transport) && (ref $transport))
        {
            $status = 1;
            $con->close();
        }
    }

    return ($status);
}

# Inspired by Email::Stuffer
sub _detect_content_type
{
    my $filename = shift;

    if (defined($filename))
    {
        if ($filename =~ /\.([a-z]{3,4})\z/i)
        {
            my $content_type = {
                'gif'  => 'image/gif',
                'png'  => 'image/png',
                'jpg'  => 'image/jpeg',
                'jpeg' => 'image/jpeg',
                'txt'  => 'text/plain',
                'htm'  => 'text/html',
                'html' => 'text/html',
                'xml'  => 'text/xml',
                'csv'  => 'text/csv',
                'pdf'  => 'application/pdf',
            }->{lc($1)};

            return $content_type if defined $content_type;
        }
    }

    return 'application/octet-stream';
}

=head2 Send_Message($appli, $msg_data)

Send message to @dests

=cut

sub Send_Message
{
    my ($appli, $msg_data) = @_;

    my $conf = (ref $appli ? $appli : Configuration($appli));

    if (NOT_NULL($conf->{server}) && NOT_NULL($conf->{sender}))
    {
        my $from    = $msg_data->{from} || $conf->{sender};
        my $subject = $msg_data->{subject};
        my $body    = $msg_data->{body};
        my $file    = $msg_data->{file};

        my $smtp_conf = (
            NOT_NULL($conf->{auth_login})
            ? {
                host          => $conf->{server},
                port          => $conf->{port} || $SMTP_PORT,
                sasl_username => $conf->{auth_login},
                sasl_password => $conf->{auth_password}
              }
            : {
                host => $conf->{server},
                port => $conf->{port} || $SMTP_PORT,
              }
        );
        my $transport = Email::Sender::Transport::SMTP->new($smtp_conf);

        if (defined $transport)
        {
            my $part_body = Email::MIME->create(body => $body || 'Your Body');
            my $part_attachment = (
                defined $file
                ? Email::MIME->create(
                    body       => path($file)->slurp_raw,
                    attributes => {
                        filename     => $file,
                        content_type => _detect_content_type($file),
                        encoding     => 'base64',
                    },
                    )
                : undef
            );
            foreach my $dest (ARRAY($msg_data->{dests}))
            {
                my $email = Email::MIME->create(
                    header => [
                        To      => $dest,
                        From    => $from,
                        Subject => $subject || 'Your Subject',
                    ],
                    parts => [$part_body, $part_attachment,],
                );
                Email::Sender::Simple->try_to_send($email,
                    {transport => $transport});
            }

            return (1);
        }
    }
    else
    {
        AAT::Syslog::Message('AAT_SMTP', 'SMTP_INVALID_CONFIG');
    }

    return (0);
}

1;

=head1 AUTHOR

Sebastien Thebert <octopussy@onetool.pm>

=cut

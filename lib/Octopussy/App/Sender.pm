package Octopussy::App::Sender;

=head1 NAME

Octopussy::App::Sender

=head1 DESCRIPTION

Module handling everything for octo_sender program

=cut

use strict;
use warnings;

use FindBin;

use lib "$FindBin::Bin/../lib";

use AAT::NSCA;
use AAT::SMTP;
use AAT::Syslog;
use AAT::Utils qw( ARRAY );
use AAT::XMPP;
use AAT::Zabbix;

use Octopussy;
use Octopussy::Alert;
use Octopussy::App;
use Octopussy::Cache;
use Octopussy::Contact;
use Octopussy::Message;

my $LOOP_SLEEP_SECONDS = 5;
my $PROGRAM = 'octo_sender';

__PACKAGE__->run(@ARGV) unless caller;

=head1 SUBROUTINES/METHODS

=head2 run(@ARGV)

=cut

sub run
{
    my $self = shift;

    return (-1) if (!Octopussy::App::Valid_User($PROGRAM));

	my $file_pid = Octopussy::PID_File($PROGRAM);

	my %contact  = ();
	$SIG{HUP} = \&Contact_Configuration(\%contact);

	Contact_Configuration(\%contact);
	my $cache = Octopussy::Cache::Init($PROGRAM);

	while (1)
	{
    	my @keys = $cache->get_keys();
    foreach my $k (sort @keys)
    {
        my $c_item = $cache->get($k);
        my $action = $c_item->{action};

        my ($svc) = split(/:/, $c_item->{msg_id});
        my $msg = Octopussy::Message::Configuration($svc, $c_item->{msg_id});
        my $re = Octopussy::Message::Pattern_To_Regexp($msg);
        $msg->{re} = qr/^$re\s*[^\t\n\r\f -~]?$/i;

        my ($subject, $body, $action_host, $action_service, $action_body) =
            Octopussy::Alert::Message_Building($action, $c_item->{device},
            $c_item->{data}, $msg);

        if (defined $action->{action_jabber}
            && AAT::XMPP::Configured('Octopussy'))
        {
            my @ims = Get_IM_Addresses($action, \%contact);
            AAT::XMPP::Send_Message('Octopussy', "$subject\n\n$body\n", @ims);
        }
        if (defined $action->{action_mail})
        {
            my @mails = Get_Mail_Addresses($action, \%contact);
            AAT::SMTP::Send_Message('Octopussy',
                {subject => $subject, body => $body, dests => \@mails});
        }
        AAT::NSCA::Send('Octopussy', (($action->{level} =~ /Warning/i) ? 1 : 2),
            $action_body, $action_host, $action_service)
            if (defined $action->{action_nsca});
        AAT::Zabbix::Send('Octopussy', $action_body, $action_host,
            $action_service)
            if (defined $action->{action_zabbix});

        $cache->remove($k);
    }
    	sleep $LOOP_SLEEP_SECONDS;
	}				
	
	return (0);
}

=head2 Contact_Configuration(\%contact)

Loads Contact Configuration

=cut

sub Contact_Configuration
{
	my $contact = shift;

    foreach my $c (keys %{$contact})
    {
        delete $contact->{$c};
    }
    foreach my $c (Octopussy::Contact::Configurations('cid'))
    {
        $contact->{$c->{cid}} = $c;
    }
    my $nb_contacts = scalar(keys %{$contact});
    AAT::Syslog::Message($PROGRAM, 'LOAD_CONTACTS_CONFIG', $nb_contacts);

    return ($nb_contacts);
}

=head2 Get_IM_Addresses($action, \%contact)

Returns list of IM addresses from Contacts

=cut

sub Get_IM_Addresses
{
    my ($action, $contact) = @_;
    my @ims    = ();

    foreach my $c (ARRAY($action->{contacts}))
    {
        push @ims, $contact->{$c}->{im}
            if (defined $contact->{$c}->{im});
    }

    return (@ims);
}

=head2 Get_Mail_Addresses($action, \%contact)

Returns list of mail addresses from Contacts

=cut

sub Get_Mail_Addresses
{
    my ($action, $contact) = @_;
    my @mails  = ();

    foreach my $c (ARRAY($action->{contacts}))
    {
        push @mails, $contact->{$c}->{email}
            if (defined $contact->{$c}->{email});
    }

    return (@mails);
}

1;

=head1 AUTHOR

Sebastien Thebert <octopussy@onetool.pm>

=cut

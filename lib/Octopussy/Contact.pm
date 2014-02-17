
=head1 NAME

Octopussy::Contact - Octopussy Contact module

=cut

package Octopussy::Contact;

use strict;
use warnings;
use Readonly;

use AAT::FS;
use AAT::LDAP;
use AAT::Utils qw( NOT_NULL );
use AAT::XML;
use Octopussy;
use Octopussy::FS;

Readonly my $XML_ROOT => 'octopussy_contact';

my ($dir_contacts, $dir_pid) = (undef, undef);
my %filename;

=head1 FUNCTIONS

=head2 New(\%conf)

Create a new contact
 
Parameters:

\%conf - hashref of the new contact configuration

=cut

sub New
{
    my $conf = shift;

    return ("Invalid Contact ID '$conf->{cid}'")
        if ($conf->{cid} !~ /^[-_a-z0-9]+$/i);

    $dir_contacts ||= Octopussy::FS::Directory('contacts');
    Octopussy::FS::Create_Directory($dir_contacts);
    if (NOT_NULL($conf->{cid})
        && (NOT_NULL($conf->{email}) || NOT_NULL($conf->{im})))
    {
        my @list  = List();
        my $exist = 0;
        foreach my $c (@list) { $exist = 1 if ($c =~ /^$conf->{cid}$/); }
        if (!$exist)
        {
            AAT::XML::Write("$dir_contacts/$conf->{cid}.xml", $conf, $XML_ROOT);
            Reload_Sender_Configuration();
        }
        else { return ('_MSG_CONTACT_ALREADY_EXISTS'); }
    }
    else { return ('_MSG_CONTACT_INFO_INVALID'); }

    return (undef);
}

=head2 Remove($contact)

Remove the contact '$contact'
 
Parameters:

$contact - Name of the contact to remove

=cut

sub Remove
{
    my $contact = shift;

    my $nb = unlink Filename($contact);
    $filename{$contact} = undef;
    Reload_Sender_Configuration();

    return ($nb);
}

=head2 List()

Get list of contacts
 
Returns:

@contacts - Array of contact names

=cut

sub List
{
    $dir_contacts ||= Octopussy::FS::Directory('contacts');
    my @files = AAT::FS::Directory_Files($dir_contacts, qr/.+\.xml$/);
    my @contacts = ();
    foreach my $f (@files)
    {
        my $conf = AAT::XML::Read("$dir_contacts/$f");
        push @contacts, $conf->{cid} if (defined $conf->{cid});
    }
    foreach my $c (AAT::LDAP::Contacts('Octopussy'))
    {
        push @contacts, $c->{cid} if (defined $c->{cid});
    }

    return (@contacts);
}

=head2 Filename($contact)

Get the XML filename for the contact '$contact'

Parameters:

$contact - Name of the contact

Returns:

$filename - Filename of the XML file for contact '$contact'

=cut

sub Filename
{
    my $contact = shift;

    return ($filename{$contact}) if (defined $filename{$contact});
    if (NOT_NULL($contact))
    {
        $dir_contacts ||= Octopussy::FS::Directory('contacts');
        my @files = AAT::FS::Directory_Files($dir_contacts, qr/.+\.xml$/);
        foreach my $f (@files)
        {
            my $conf = AAT::XML::Read("$dir_contacts/$f");
            if ((defined $conf) && ($conf->{cid} =~ /^$contact$/))
            {
                $filename{$contact} = "$dir_contacts/$f";
                return ("$dir_contacts/$f");
            }
        }
    }

    return (undef);
}

=head2 Configuration($contact)

Get the configuration for the contact '$contact'
 
Parameters:

$contact - Name of the contact

Returns:

\%conf - Hashref of the contact configuration

=cut

sub Configuration
{
    my $contact = shift;

    my $conf = AAT::XML::Read(Filename($contact));
    if (defined $conf)
    {
        $conf->{type} = 'local';
    }
    else
    {
        foreach my $c (AAT::LDAP::Contacts('Octopussy'))
        {
            if ((defined $c->{cid}) && ($c->{cid} eq $contact))
            {
                $conf = $c;
                $conf->{type} = 'LDAP';
                last;
            }
        }
    }

    return ($conf);
}

=head2 Configurations($sort)

Get the configuration for all contacts

Parameters:

$sort - selected field to sort configurations

Returns:

@configurations - Array of Hashref contact configurations  

=cut

sub Configurations
{
    my $sort = shift || 'cid';
    my (@configurations, @sorted_configurations) = ((), ());

    $dir_contacts ||= Octopussy::FS::Directory('contacts');
    my @files = AAT::FS::Directory_Files($dir_contacts, qr/.+\.xml$/);
    foreach my $f (@files)
    {
        my $conf = AAT::XML::Read("$dir_contacts/$f");
        $conf->{type} = 'local';
        push @configurations, $conf if (defined $conf->{cid});
    }

    foreach my $c (AAT::LDAP::Contacts('Octopussy'))
    {
        push @configurations, $c if (defined $c->{cid});
    }

    foreach my $c (sort { $a->{$sort} cmp $b->{$sort} } @configurations)
    {
        push @sorted_configurations, $c;
    }

    return (@sorted_configurations);
}

=head2 Reload_Sender_Configuration()

Sends 'HUP' signal to octo_sender in order to reload its Contacts configuration

=cut

sub Reload_Sender_Configuration
{
    $dir_pid ||= Octopussy::FS::Directory('running');
    my $file_pid = "$dir_pid/octo_sender.pid";
    if (-f $file_pid)
    {
        my $pid = Octopussy::PID_Value($file_pid);
        kill HUP => $pid;

        return (1);
    }

    return (0);
}

1;

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut

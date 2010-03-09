# $HeadURL$
# $Revision$
# $Date$
# $Author$

=head1 NAME

Octopussy::Contact - Octopussy Contact module

=cut

package Octopussy::Contact;

use strict;
use warnings;
use Readonly;

use AAT;
use AAT::FS;
use AAT::LDAP;
use AAT::XML;
use Octopussy;

Readonly my $XML_ROOT => 'octopussy_contact';

# String: $dir_contacts
# Directory for the Contacts configuration files
my $dir_contacts = undef;
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

  $dir_contacts ||= Octopussy::Directory('contacts');
  if (AAT::NOT_NULL($conf->{cid})
    && (AAT::NOT_NULL($conf->{email}) || AAT::NOT_NULL($conf->{im})))
  {
    my @list  = List();
    my $exist = 0;
    foreach my $c (@list) { $exist = 1 if ($c =~ /^$conf->{cid}$/); }
    if (!$exist)
    {
      AAT::XML::Write("$dir_contacts/$conf->{cid}.xml", $conf, $XML_ROOT);
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

  return ($nb);
}

=head2 List()

Get list of contacts
 
Returns:

@contacts - Array of contact names

=cut

sub List
{
  $dir_contacts ||= Octopussy::Directory('contacts');
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
  if (AAT::NOT_NULL($contact))
  {
    $dir_contacts ||= Octopussy::Directory('contacts');
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
      if (defined $c->{cid})
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
  my @contacts = List();

  foreach my $c (@contacts)
  {
    my $conf = Configuration($c);
    if (defined $conf->{cid})
    {
      push @configurations, $conf;
    }
  }
  foreach my $c (sort { $a->{$sort} cmp $b->{$sort} } @configurations)
  {
    push @sorted_configurations, $c;
  }

  return (@sorted_configurations);
}

1;

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut

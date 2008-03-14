#################### Octopussy Project ####################
# $Id$
###########################################################
=head1 NAME

Octopussy::Contact - Octopussy Contact module

=cut

package Octopussy::Contact;

use strict;
use utf8;
use Octopussy;

# String: $contacts_dir
# Directory for the Contacts configuration files
my $contacts_dir = undef;
my %filenames;

=head1 FUNCTIONS

=head2 New(\%conf)

Create a new contact
 
Parameters:

\%conf - hashref of the new contact configuration

=cut

sub New($)
{
	my $conf = shift;

	$contacts_dir ||= Octopussy::Directory("contacts");
	if (AAT::NOT_NULL($conf->{cid}) && 
		(AAT::NOT_NULL($conf->{email}) || AAT::NOT_NULL($conf->{im})))
	{
		my @list = List();
		my $exist = 0;
		foreach my $c (@list)
			{ $exist = 1	if ($c =~ /^$conf->{cid}$/); }
		if (!$exist)
		{
			AAT::XML::Write("$contacts_dir/$conf->{cid}.xml", 
				$conf, "octopussy_contact");
		}
		else
			{ return ("_MSG_CONTACT_ALREADY_EXISTS"); }
	}
	else
		{ return ("_MSG_CONTACT_INFO_INVALID"); }

	return (undef);
}

=head2 Remove($contact)

Remove the contact '$contact'
 
Parameters:

$contact - Name of the contact to remove

=cut
 
sub Remove($)
{
	my $contact = shift;

	$filenames{$contact} = undef;
	unlink(Filename($contact));
}

=head2 List()

Get list of contacts
 
Returns:

@contacts - Array of contact names

=cut
 
sub List()
{
	$contacts_dir ||= Octopussy::Directory("contacts");
	my @files = AAT::FS::Directory_Files($contacts_dir, qr/.+\.xml$/);
	my @contacts = ();
	foreach my $f (@files)
	{
		my $conf = AAT::XML::Read("$contacts_dir/$f");
		push(@contacts, $conf->{cid})	if (defined $conf->{cid});
	}
	foreach my $c (AAT::LDAP::Contacts("Octopussy"))
  	{ push(@contacts, $c->{cid})		if (defined $c->{cid}); }
	
	return (@contacts);
}

=head2 Filename($contact)

Get the XML filename for the contact '$contact'

Parameters:

$contact - Name of the contact

Returns:

$filename - Filename of the XML file for contact '$contact'

=cut
 
sub Filename($)
{
	my $contact = shift;

	return ($filenames{$contact})   if (defined $filenames{$contact});
	if (AAT::NOT_NULL($contact))
	{
		$contacts_dir ||= Octopussy::Directory("contacts");
		my @files = AAT::FS::Directory_Files($contacts_dir, qr/.+\.xml$/);
		foreach my $f (@files)
  	{
  		my $conf = AAT::XML::Read("$contacts_dir/$f");
			$filenames{$contact} = "$contacts_dir/$f";
   		return ("$contacts_dir/$f")     
				if ((defined $conf) && ($conf->{cid} =~ /^$contact$/));
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
 
sub Configuration($)
{
	my $contact = shift;

	my $conf = AAT::XML::Read(Filename($contact));
	$conf->{type} = "local";

	return ($conf);
}

=head2 Configurations($sort)

Get the configuration for all contacts

Parameters:

$sort - selected field to sort configurations

Returns:

@configurations - Array of Hashref contact configurations  

=cut
 
sub Configurations($)
{
  my $sort = shift;
	my (@configurations, @sorted_configurations) = ((), ());
	my @contacts = List();
	my %field;

	foreach my $c (@contacts)
	{
		my $conf = Configuration($c);
		if (defined $conf->{cid})
		{
			$field{$conf->{$sort}} = 1;
			push(@configurations, $conf);
		}
	}
	foreach my $c (AAT::LDAP::Contacts("Octopussy"))
	{
		$field{$c->{$sort}} = 1;
		push(@configurations, $c);
	}
	foreach my $f (sort keys %field)
	{
		foreach my $c (@configurations)
			{ push(@sorted_configurations, $c)    if ($c->{$sort} eq $f); }
	}

	return (@sorted_configurations);
}
																						
1;

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut

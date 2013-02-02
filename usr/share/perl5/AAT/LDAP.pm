=head1 NAME

AAT::LDAP - AAT LDAP module

=cut

package AAT::LDAP;

use strict;
use warnings;
use Readonly;

use Net::LDAP;

use AAT::Utils qw( ARRAY NOT_NULL );
use AAT::Application;
use AAT::XML;

Readonly my $DEFAULT_LANGUAGE  => 'EN';
Readonly my $DEFAULT_ROLE => 'rw';
Readonly my $DEFAULT_STATUS => 'Enabled';

Readonly my @CONTACT_FIELDS => 
	(qw/ uid firstname lastname description email im /);

my %conf_file = ();

=head1 FUNCTIONS

=head2 Configuration($appli)

Returns LDAP Configuration

=cut

sub Configuration
{
  my $appli = shift;

  $conf_file{$appli} ||= AAT::Application::File($appli, 'ldap');
  my $conf = AAT::XML::Read($conf_file{$appli}, 1);

  return ($conf->{ldap});
}

=head2 Contacts_Connection_Test($appli)

Checks LDAP Contacts connectivity

=cut

sub Contacts_Connection_Test
{
	my $appli = shift;

  	my $ldap = Configuration($appli);
  	my $l    = Net::LDAP->new($ldap->{contacts_server});
  	return (0) if (!defined $l);
  	my $msg = (
    	NOT_NULL($ldap->{contacts_auth_dn})
    	? $l->bind($ldap->{contacts_auth_dn},
      	password => $ldap->{contacts_auth_password})
    	: $l->bind()
  		);
  	return (0) if ($msg->code);
  	$msg = $l->search(
    	base   => $ldap->{contacts_base},
    	filter => $ldap->{contacts_filter}
  		);
  	return (0) if ($msg->code);

  	return (1);
}

=head2 Users_Connection_Test($appli)

Checks LDAP Users connectivity

=cut

sub Users_Connection_Test
{
  	my $appli = shift;

  	my $ldap = Configuration($appli);
  	my $l    = Net::LDAP->new($ldap->{users_server});
  	return (0) if (!defined $l);
  	my $msg = (
    	NOT_NULL($ldap->{users_auth_dn})
    	? $l->bind(
      	$ldap->{users_auth_dn}, password => $ldap->{users_auth_password}
      	)
    	: $l->bind()
  		);
  	return (0) if ($msg->code);
  	$msg = $l->search(
    	base   => $ldap->{users_base},
    	filter => $ldap->{users_filter}
  		);
  	return (0) if ($msg->code);

  	return (1);
}

=head2 Check_Password($appli, $user, $pwd)

Checks User/Password from LDAP

=cut

sub Check_Password
{
	my ($appli, $user, $pwd) = @_;

  	my $ldap = Configuration($appli);
  	if (defined $ldap)
  	{
    	my $l = Net::LDAP->new($ldap->{users_server});
    	return (0) if (!defined $l);

    	my $msg = $l->bind($ldap->{users_auth_dn}, 
			password => $ldap->{users_auth_password});
    	my $msg2 = $l->search(
      		base   => $ldap->{users_base},
      		filter => $ldap->{users_filter}
    		);
		my $valid_user = 0;
		my $dn = undef;
    	foreach my $entry ($msg2->entries)
    	{
			if ($entry->get_value($ldap->{users_attribute_login}) eq $user)
			{
      			$dn = $entry->dn();
				$valid_user = 1;
			}
    	}
		return (0)	if (! $valid_user);
		$msg = $l->bind($dn, password => $pwd);
		
    	return (1) if (($pwd ne '' && $msg->code == 0) && ($valid_user));
  	}

  	return (0);
}

=head2 Contacts($appli)

Returns Contacts List from LDAP

=cut

sub Contacts
{
	my $appli    = shift;
  	my @contacts = ();

	my ($pkg, $filename, $line) = caller;

  	my $ldap = Configuration($appli);
  	if (defined $ldap)
  	{
    	my $l = Net::LDAP->new($ldap->{contacts_server});
    	return () if (!defined $l);
    	my $msg = (
      		NOT_NULL($ldap->{contacts_auth_dn})
      		? $l->bind($ldap->{contacts_auth_dn},
        	password => $ldap->{contacts_auth_password})
      		: $l->bind()
    		);
    	return () if ($msg->code);

		# Gets LDAP Search Attributes from from contacts_filed_* config
		my %attr = ();
		foreach my $attr (@CONTACT_FIELDS)
		{ 
			$attr{$ldap->{"contacts_field_$attr"}} = 1
				if (AAT::NOT_NULL($ldap->{"contacts_field_$attr"})); 
		}
		my @ldap_attrs = keys %attr;
		
    	$msg = $l->search(
     		base   => $ldap->{contacts_base},
			filter => $ldap->{contacts_filter},
			attrs  => \@ldap_attrs 
    		);

    	foreach my $entry ($msg->entries)
    	{
			my %fields = ();
			foreach my $attr (@CONTACT_FIELDS)
        	{
				my $value = $entry->get_value($ldap->{"contacts_field_$attr"});
				my $f = ($attr eq 'uid' ? 'cid' : $attr);
            	$fields{$f} = $value;
			}
			$fields{type} = 'LDAP';
			push @contacts, \%fields	
				if ((defined $fields{cid}) && (defined $fields{email}));
    	}
    	$msg = $l->unbind();
  	}

  	return (@contacts);
}

=head2 Users($appli)

Returns Users List from LDAP

=cut

sub Users
{
	my $appli = shift;
  	my @users = ();

  	my $ldap = Configuration($appli);
  	if (defined $ldap)
  	{
    	my $l = Net::LDAP->new($ldap->{users_server});
    	return () if (!defined $l);
    	my $msg = (
      		NOT_NULL($ldap->{users_auth_dn})
      		? $l->bind($ldap->{users_auth_dn},
        	password => $ldap->{users_auth_password})
      		: $l->bind()
    		);
    	return () if ($msg->code);
    	$msg = $l->search(
      		base   => $ldap->{users_base},
      		filter => $ldap->{users_filter}
    		);
    	foreach my $entry ($msg->entries)
    	{
			my $login = $entry->get_value($ldap->{users_attribute_login});
      		push @users,
        		{
        		login => $login,
        		type  => 'LDAP'
        		};
    	}
    	$msg = $l->unbind();
  	}

  	return (@users);
}

1;

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut

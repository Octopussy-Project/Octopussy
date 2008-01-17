=head1 NAME

Octopussy::Plugin::SMTP - Octopussy Plugin SMTP

=cut
package Octopussy::Plugin::SMTP;

use strict;
use Octopussy;

my @bounce_types = (
	{ re => "Bad destination host.*",
		type => "Bad Destination Host" },
	{ re => "Unknown address error.*",
	 	type => "Unknown Address Error" } );
		
my @response_types = (
	{ re => ".*accepted for delivery.*", 
		type => "Accepeted for delivery" },
	{ re => ".*Message.* accepted.*",
		type => "Message accepted" },
	{ re => ".*message queued.*",
	 	type => "Queued" },
	{ re => "ok.*",
		type => "Ok" },
	{ re => ".*ok\.*",
	 	type => "Ok" },
	{ re => ".* queued as .*",
		type => "Queued" },
	{ re => ".*Queued mail.*",
	 	type => "Queued" },
	{ re => ".*Requested mail action okay.*",
		type => "Requested mail action okay" } );
		
=head1 FUNCTIONS

=head2 Init()

=cut
sub Init()
{
}

=head2 Bounce_Type($bounce) 

Returns Bounce Type

=cut
sub Bounce_Type
{
	my $bounce = shift;
	
	return (undef)	if (!defined $bounce);
	foreach my $bt (@bounce_types)
	{
		return ($bt->{type})  if ($bounce =~ /^$bt->{re}$/i);
	}
	
	return ($bounce);
}

=head2 Response_Type($response)

Returns Response Type

=cut
sub Response_Type
{
	my $response = shift;
	
	return (undef)  if (!defined $response);
	foreach my $rt (@response_types)
	{
		return ($rt->{type})	if ($response =~ /^$rt->{re}$/i);
	}

	return ($response);
}

=head2 Recipients_Count($recipients_list)

Reurns number of recipients

=cut
sub Recipients_Count
{
	my $recipients_list = shift;

	my @recipients = split(/,/, $recipients_list);

	return ($#recipients+1);
}

1;

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut

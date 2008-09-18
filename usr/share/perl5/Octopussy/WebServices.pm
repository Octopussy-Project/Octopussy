=head1 NAME

Octopussy::WebServices - Octopussy WebServices module

=cut
package Octopussy::WebServices;

use XML::Simple;

use Octopussy;

my %XML_OUTPUT_OPTIONS =
	( AttrIndent => 1,
		XMLDecl => "<?xml version='1.0' encoding='iso-8859-1'?>",
		RootName => "octopussy_api" );

my %api = (
	version => Octopussy::Version(),
	function =>
		[
			{ name => "Alert.Configuration", cmd => "AlertConfiguration" },
			{ name => "Alert.Viewer", cmd => "AlertViewer" },
			{ name => "Contact.Configuration", cmd => "ContactConfiguration" },
			{ name => "Device.Configuration", cmd => "DeviceConfiguration" },
			{ name => "Service.Configuration", cmd => "ServiceConfiguration" },
			{ name => "System.Configuration", cmd => "SystemConfiguration" },
			{ name => "Table.Configuration", cmd => "TableConfiguration" },
		]
	);

my %function = ();

=head1 FUNCTIONS

=head2 API_Init()

=cut
sub API_Init()
{
	foreach my $f (AAT::ARRAY($api{function}))
		{ $function{$f->{name}} = $f->{cmd}; }
}

=head2 Request($cmd, $arg1, $arg2)

=cut
sub Request($$$)
{
	my ($cmd, $arg1, $arg2) = @_;
	
	if (AAT::NOT_NULL($cmd))
	{
		API_Init()	if (!defined %function);	
		&{$function{$cmd}}($arg1, $arg2)  if (defined $function{$cmd});
	}
	else
	{
    my $xml = XMLout(\%api, %XML_OUTPUT_OPTIONS);
    print $xml;
	}
}

=head2 PrintFile($file)

=cut 
sub PrintFile($)
{
	my $file = shift;

	if (defined open(FILE, "< $file"))
	{
  	while (<FILE>)
  		{ print $_; }
  	close(FILE);
	}
	else
  {
    my ($pack, $file_pack, $line, $sub) = caller(0);
    AAT::Syslog("Octopussy::Service", "Unable to open file '$file' in $sub");
  }
}

=head2 AlertConfiguration($alert)

=cut
sub AlertConfiguration($)
{
	my $alert = shift;

	my $file = Octopussy::Alert::Filename($alert);
  PrintFile($file)  if (AAT::NOT_NULL($file));
}

=head2 AlertTracker($alert, $device, $status, $sort)

=cut
sub AlertViewer($$$$)
{
	my ($alert, $device, $status, $sort) = @_;
	
	my @alerts = Octopussy::Alert::Tracker($alert, $device, "Opened", 
		undef, undef);
	my $xml = XMLout({ alert => \@alerts }, %XML_OUTPUT_OPTIONS);
	print $xml;
}

=head2 ContactConfiguration($contact)

=cut
sub ContactConfiguration($)
{
	my $contact = shift;

  my $file = Octopussy::Contact::Filename($contact);
  PrintFile($file)  if (AAT::NOT_NULL($file));
}

=head2 DeviceConfiguration($device)

=cut
sub DeviceConfiguration($)
{
	my $device = shift;
	
	my $file = Octopussy::Device::Filename($device);
	PrintFile($file)	if (AAT::NOT_NULL($file));
}

=head2 ServiceConfiguration($service)

=cut
sub ServiceConfiguration($)
{
	my $service = shift;

  my $file = Octopussy::Service::Filename($service);
  PrintFile($file)	if (AAT::NOT_NULL($file));
}

=head2 TableConfiguration($table)

=cut
sub TableConfiguration($)
{
  my $table = shift;

  my $file = Octopussy::Table::Filename($table);
  PrintFile($file)  if (AAT::NOT_NULL($file));
}

1;

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut

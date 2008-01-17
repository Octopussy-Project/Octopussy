#
# Package: Octopussy::WebServices
#
# Octopussy WebServices module
#
package Octopussy::WebServices;

use XML::Simple;

use Octopussy;

my $CONF_FILE = "/etc/octopussy/main.xml";

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

#
# Function: API_Init()
#
sub API_Init()
{
	foreach my $f (AAT::ARRAY($api{function}))
		{ $function{$f->{name}} = $f->{cmd}; }
}

#
# Function: Request($cmd, $arg1, $arg2)
#
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

#
# Function: PrintFile($file)
#
sub PrintFile($)
{
	my $file = shift;

	open(FILE, "< $file");
  while (<FILE>)
  {
    print $_;
  }
  close(FILE);
}

#
# Function: AlertConfiguration($alert)
#
sub AlertConfiguration($)
{
	my $alert = shift;

	my $file = Octopussy::Alert::Filename($alert);
  PrintFile($file)  if (AAT::NOT_NULL($file));
}

#
# Function: AlertTracker($alert, $device, $status, $sort)
#
sub AlertViewer($$$$)
{
	my ($alert, $device, $status, $sort) = @_;
	
	my @alerts = Octopussy::Alert::Tracker($alert, $device, "Opened", 
		undef, undef);
	my $xml = XMLout({ alert => \@alerts }, %XML_OUTPUT_OPTIONS);
	print $xml;
}

#
# Function: ContactConfiguration($contact)
#
sub ContactConfiguration($)
{
	my $contact = shift;

  my $file = Octopussy::Contact::Filename($contact);
  PrintFile($file)  if (AAT::NOT_NULL($file));
}

#
# Function: DeviceConfiguration($device)
#
sub DeviceConfiguration($)
{
	my $device = shift;
	
	my $file = Octopussy::Device::Filename($device);
	PrintFile($file)	if (AAT::NOT_NULL($file));
}

#
# Function: ServiceConfiguration($service)
#
sub ServiceConfiguration($)
{
	my $service = shift;

  my $file = Octopussy::Service::Filename($service);
  PrintFile($file)	if (AAT::NOT_NULL($file));
}

sub SystemConfiguration()
{
  PrintFile($CONF_FILE);
}

#
# Function: TableConfiguration($table)
#
sub TableConfiguration($)
{
  my $table = shift;

  my $file = Octopussy::Table::Filename($table);
  PrintFile($file)  if (AAT::NOT_NULL($file));
}

1;

=head1 NAME

Octopussy::Service - Octopussy Service module

=cut

package Octopussy::Service;

use strict;
no strict 'refs';
use utf8;
use Encode;
use Octopussy;

my $SERVICE_DIR = "services";
my $services_dir = undef;
my %filenames;

=head1 FUNCTIONS

=head2 New(\%conf)

Create a new service

Parameters:

\%conf - hashref of the new service configuration

=cut
 
sub New($)
{
	my $conf = shift;

	$services_dir ||= Octopussy::Directory($SERVICE_DIR);
	$conf->{version} = Octopussy::Timestamp_Version(undef);
	AAT::XML::Write("$services_dir/$conf->{name}.xml", $conf, 
		"octopussy_service");
}

=head2 Remove($service)

Remove the service '$service'

Parameters:

$service - Name of the service to remove

=cut

sub Remove($)
{
	my $service = shift;

	$filenames{$service} = undef;
	unlink(Filename($service));
}

=head2 List()

Get List of Services

=cut

sub List()
{
	$services_dir ||= Octopussy::Directory($SERVICE_DIR);

	return (AAT::XML::Name_List($services_dir));
}

=head2 List_Used()

Get List of Services used

=cut

sub List_Used()
{
	my %service = ();

	foreach my $d (Octopussy::Device::List())
	{
		foreach my $s (Octopussy::Device::Services($d))
			{ $service{$s} = 1; }
	}

	return (sort keys %service);
}

=head2 Filename($service_name)

Get the XML filename for the service '$service_name'

=cut

sub Filename($)
{
	my $service_name = shift;

	return ($filenames{$service_name})   if (defined $filenames{$service_name});
	$services_dir ||= Octopussy::Directory($SERVICE_DIR);
	$filenames{$service_name} = "$services_dir/$service_name.xml";
	#AAT::XML::Filename($services_dir, $service_name);

	return ($filenames{$service_name});
}

=head2 Configuration($service_name)

Get the configuration for the service '$service_name'

=cut

sub Configuration($)
{
	my $service_name = shift;

	my $conf = AAT::XML::Read(Filename($service_name));

 	return ($conf);
}

=head2 Configurations($sort)

Get the configuration for all services

=cut

sub Configurations
{
  my $sort = shift || "name";
  my (@configurations, @sorted_configurations) = ((), ());
  my @services = List();
  my %field;
  foreach my $s (@services)
  {
    my $conf = Configuration($s);
		my $nb = $#{$conf->{message}} + 1;
		$conf->{nb_messages} = ($nb < 10 ? "00$nb" : ($nb < 100 ? "0$nb" : $nb));
    $field{$conf->{$sort}} = 1;
    push(@configurations, $conf);
  }
  foreach my $f (sort keys %field)
  {
    foreach my $c (@configurations)
    	{ push(@sorted_configurations, $c)	if ($c->{$sort} eq $f); }
  }

  return (@sorted_configurations);
}

=head2 Msg_ID($service)

Returns the next available message id for Service '$service'

=cut

sub Msg_ID($)
{
	my $service = shift;

	my $conf = AAT::XML::Read(Filename($service));
	my $msg_id = "";
	my $i = 1;
	while ($i)
	{
		$msg_id = $conf->{name} . ":$i";
		my $matched = 0;
		foreach my $m (AAT::ARRAY($conf->{message}))
		{
			$matched = 1	if ($m->{msg_id} =~ /^$msg_id$/i);	
		}
		return ($msg_id)	if (!$matched);
		$i++;
	}
}

=head2 Msg_ID_unique($service, $msgid)

=cut

sub Msg_ID_unique($$)
{
	my ($service, $msgid) = @_;

	return (0)	if ($msgid eq "$service:");
	my $conf = AAT::XML::Read(Filename($service));
	foreach my $m (AAT::ARRAY($conf->{message}))
	{
		return (0)	if ($m->{msg_id} =~ /^$msgid$/);
	}

	return (1);
}

=head2 Add_Message($service_name, $mconf)

Add a message '$mconf' to service '$service_name'

=cut

sub Add_Message($$)
{
	my ($service, $mconf) = @_;
	my $conf = AAT::XML::Read(Filename($service));
	$conf->{version} = Octopussy::Timestamp_Version($conf);
	my $rank = $#{$conf->{message}} + 2;
	$mconf->{rank} = AAT::Padding($rank, 3);

	return ("_MSG_MSGID_ALREADY_EXIST")
		if (! Msg_ID_unique($service, $mconf->{msg_id}));
	return ("_MSG_FIELD_DONT_EXIST")
		if (! Octopussy::Table::Valid_Pattern($mconf->{table}, $mconf->{pattern}));
	$mconf->{pattern} = Encode::decode_utf8($mconf->{pattern});
	push(@{$conf->{message}}, $mconf);	
	AAT::XML::Write(Filename($service), $conf, "octopussy_service");
	Parse_Restart($service);

	return (undef);
}

=head2 Remove_Message($service, $msgid)

Remove a message with id '$msgid' from service '$service'

=cut

sub Remove_Message($$)
{
	my ($service, $msgid) = @_;

	my @messages = ();
	my $rank = undef;
	my $conf = AAT::XML::Read(Filename($service));
	$conf->{version} = Octopussy::Timestamp_Version($conf);
	foreach my $m (AAT::ARRAY($conf->{message}))
	{
		if ($m->{msg_id} ne $msgid)
			{ push(@messages, $m); }
		else
			{ $rank = $m->{rank}; }
	}	
	foreach my $m (@messages)
	{
		if ($m->{rank} > $rank)
		{
			$m->{rank} -= 1;
			$m->{rank} = AAT::Padding($m->{rank}, 3);
		}
	}

	$conf->{message} = \@messages;
	AAT::XML::Write(Filename($service), $conf, "octopussy_service");
	Parse_Restart($service);
}

=head2 Modify_Message($service, $msgid, $modified_conf)

Modify a message with id '$msgid' from service '$service'

=cut

sub Modify_Message($$$)
{
	my ($service, $msgid, $modified_conf) = @_;

	my $conf = AAT::XML::Read(Filename($service));
	$conf->{version} = Octopussy::Timestamp_Version($conf);
	my @messages = ();
	$modified_conf->{pattern} = Encode::decode_utf8($modified_conf->{pattern});
	foreach my $m (AAT::ARRAY($conf->{message}))
	{
		if ($m->{msg_id} ne $msgid)
			{ push(@messages, $m); }
		else
			{ push(@messages, $modified_conf); }
	}
	$conf->{message} = \@messages;

  return ("FIELD_DONT_EXIST")
    if (! Octopussy::Table::Valid_Pattern($modified_conf->{table}, $modified_conf->{pattern}));

	AAT::XML::Write(Filename($service), $conf, "octopussy_service");
	Parse_Restart($service);

	return (undef);
}

=head2 Move_Message($service, $msgid, $direction)

Move message '$msgid' up/down ('$direction') inside service '$service'

=cut

sub Move_Message($$$)
{
	my ($service, $msgid, $direction) = @_;
	my $rank = undef;

	my $conf = AAT::XML::Read(Filename($service));
	$conf->{version} = Octopussy::Timestamp_Version($conf);
  my @messages = ();
	my $max = (defined $conf->{message} ? $#{$conf->{message}}+1 : 0);
	$max = AAT::Padding($max, 3);
	foreach my $m (AAT::ARRAY($conf->{message}))
  {
    if ($m->{msg_id} eq $msgid)
		{
			return ()	if (($m->{rank} eq "001") && ($direction eq "up"));
			return ()	if (($m->{rank} eq "$max") && ($direction eq "down"));
			$m->{rank} = ($direction eq "up" ? $m->{rank} - 1 : $m->{rank} + 1);
			$m->{rank} = AAT::Padding($m->{rank}, 3);
			$rank = $m->{rank};
		}
		push(@messages, $m);
  }	
	$conf->{message} = \@messages;
	my @messages2 = ();
	foreach my $m (AAT::ARRAY($conf->{message}))
  {
    if (($m->{rank} eq $rank) && ($m->{msg_id} ne $msgid))
    {
      $m->{rank} = ($direction eq "up" ? $m->{rank} + 1 : $m->{rank} - 1);
			$m->{rank} = AAT::Padding($m->{rank}, 3);
    }
    push(@messages2, $m);
  }
	$conf->{message} = \@messages2;
	AAT::XML::Write(Filename($service), $conf, "octopussy_service");
	Parse_Restart($service);
}

=head2 Messages($service)

Get messages from service '$service'

=cut

sub Messages($)
{
	my $service = shift;

	my $conf = AAT::XML::Read(Filename($service));
	my @messages = ();
	my %field;
	
	foreach my $m (AAT::ARRAY($conf->{message}))
		{ $field{$m->{rank}} = 1; }

	foreach my $f (sort keys %field)
	{
		foreach my $m (AAT::ARRAY($conf->{message}))
			{ push(@messages, $m)	if ($m->{rank} eq $f); }
	}
	
	return (@messages);
}

=head2 Messages_Configurations($service, $sort)

Get the configuration for all messages from '$service'

=cut

sub Messages_Configurations($$)
{
	my ($service, $sort) = @_;
	my (@configurations, @sorted_configurations) = ((), ());
	my %field;
	my @services = ();
	push(@services, (defined $service ? $service : List()));

	foreach my $s (@services)
	{	
		my @messages = Messages($s);
		foreach my $conf (@messages)
		{
			$field{$conf->{$sort}} = 1;
			push(@configurations, $conf);
		}
	}
	foreach my $f (sort keys %field)
	{
		foreach my $c (@configurations)
			{ push(@sorted_configurations, $c)    if ($c->{$sort} eq $f); }
	}

	return (@sorted_configurations);
}

=head2 Messages_Statistics_Files($service, $y, $mon, $d, $h, $m, $minutes)

=cut

sub Messages_Statistics_Files($$$$$$$)
{
	my ($service, $y, $mon, $d, $h, $m, $minutes) = @_;
	
	my @devices = Octopussy::Device::With_Service($service);
 	my %start = ( year => $y, month => $mon,
 		day => $d, hour => ($m < $minutes ? $h-1 : $h),
   	min => ($m < $minutes ? (60-$minutes)+$m : $m-$minutes) );
 	my %finish = ( year => $y, month => $mon,
   	day => $d, hour => $h, min => $m );
 	my $files = Octopussy::Logs::Files(\@devices, [ "$service" ],
  	\%start, \%finish);

	return ($files);
}

=head2 Messages_Statistics_Save($dir_pid, $service, $y, $mon, $d, $h, $m, $total, %stat)

=cut

sub Messages_Statistics_Save
{
	my ($dir_pid, $service, $y, $mon, $d, $h, $m, $total, %stat) = @_;

	my $del_serv = $service;
 	$del_serv =~ s/ /\\ /g;
 	`rm -rf $dir_pid/serv_$del_serv*.stats`;
 	open(STATS, "> $dir_pid/serv_$service$y$mon$d$h$m.stats");
 	foreach my $k (keys %stat)
  {
  	$stat{$k} = int($stat{$k}/$total*100);
   	print STATS "$k -> " .  $stat{$k} ."\n";
 	}
 	close(STATS);
}

=head2 Messages_Statistics($service, $minutes)

=cut

sub Messages_Statistics($$)
{
	my ($service, $minutes) = @_;
	my $dir_pid = Octopussy::Directory("running");
	my ($y, $mon, $d, $h, $m) = AAT::Datetime::Now();

	if (! -f "$dir_pid/serv_$service$y$mon$d$h$m.stats")
	{
		my %stat = ();
		my @messages = Messages($service);
		my $files = Messages_Statistics_Files($service, $y, $mon, $d, $h, $m, $minutes);
		my @msg_to_parse = ();
		my $total = 0;
		foreach my $msg (@messages)
		{
			my $regexp = Octopussy::Message::Pattern_To_Regexp($msg);
 			push(@msg_to_parse, { msg_id => $msg->{msg_id}, re => qr/$regexp/ });
		}
		foreach my $f (AAT::ARRAY($files))
  	{
			open(FILE, "zcat \"$f\" |");
			while (<FILE>)
			{
				my $line = $_;
				foreach my $msg (@msg_to_parse)
      	{
					if ($line =~ $msg->{re})
       		{
        		$stat{$msg->{msg_id}} = (defined $stat{$msg->{msg_id}} ?
          		$stat{$msg->{msg_id}} + 1 : 1);
						last;
       		}
				}
				$total++;
			}
			close(FILE);
		}
		Messages_Statistics_Save($dir_pid, $service, $y, $mon, $d, $h, $m, $total, %stat);
	}
	my %percent = ();	
	open(FILE, "< $dir_pid/serv_$service$y$mon$d$h$m.stats");
	while (<FILE>)
		{ $percent{$1} = $2	if ($_ =~ /^(.+) -> (\d+)$/); }
	close(FILE);

	return (%percent);
}

=head2 Tables($service)

Get tables from service '$service'

=cut

sub Tables($)
{
	my $service = shift;
	my @messages = Messages($service);
	my @tables = ();
	my %tmp;

	foreach my $m (@messages)
		{ $tmp{$m->{table}} = 1; }
	foreach my $k (sort keys %tmp)
		{ push(@tables, $k); }

	return (@tables);
}

=head2 Global_Regexp($service)

=cut

sub Global_Regexp($)
{
	my $service = shift;
	my $global = undef;
	
	my @messages = Messages($service);
	foreach my $m (@messages)
	{
		my $re = Octopussy::Message::Pattern_To_Regexp($m);
		$global = $re	if (!defined $global);
		while (index($re, $global) == -1)
			{ $global = substr($global, 0, length($global) - 1); }
	}
	$global =~ s/^\(//g;
	$global =~ s/([^\\])\(/$1/g;
	$global =~ s/([^\\])\)/$1/g;

	return (qr/$global/);
}

=head2 Parse_Restart($service)

Restart Device parsing for device with service '$service'

=cut

sub Parse_Restart($)
{
	my $service = shift;
	AAT::DEBUG("Service::Parse_Restart $service");

	my @devices = Octopussy::Device::With_Service($service);
  foreach my $d (@devices)
  {
    if (Octopussy::Device::Parse_Status($d))
    {
      Octopussy::Device::Parse_Pause($d);
      Octopussy::Device::Parse_Start($d);
    }
  }
}

=head2 Updates()

=cut

sub Updates()
{
	my %update;
	my $web = Octopussy::WebSite();
	my $run_dir = Octopussy::Directory("running");	

	AAT::Download("$web/Download/Services/_services.idx", 
		"$run_dir/_services.idx");
	open(UPDATE, "< $run_dir/_services.idx");
	while (<UPDATE>)
		{ $update{$1} = $2	if ($_ =~ /^(.+):(\d+)$/); }
	close(UPDATE);
	unlink("$run_dir/_services.idx");	

	return (\%update);
}

=head2 Updates_Installation(@services)

=cut

sub Updates_Installation
{
  my @services = @_;
  my $web = Octopussy::WebSite();
  $services_dir ||= Octopussy::Directory($SERVICE_DIR);

  foreach my $s (@services)
  {
    AAT::Download("$web/Download/Services/$s.xml", "$services_dir/$s.xml");
    Parse_Restart($s);
  }
}

=head2 Update_Get_Messages($service)

=cut

sub Update_Get_Messages($)
{
	my $service = shift;
	my $web = Octopussy::WebSite();
	my $run_dir = Octopussy::Directory("running");

	AAT::Download("$web/Download/Services/$service.xml", 
		"$run_dir$service.xml");
	my $new_conf =  AAT::XML::Read("$run_dir$service.xml");
	
	return (AAT::ARRAY($new_conf->{message}));
}

=head2 Updates_Diff($service)

=cut

sub Updates_Diff($)
{
  my $service = shift;
  my $conf = Configuration($service);
  my @messages = ();
	my @serv_property = ("rank", "taxonomy", "table", "loglevel", "pattern");
  my @new_messages =  Update_Get_Messages($service);
  foreach my $m (AAT::ARRAY($conf->{message}))
  {
    my @list = ();
    my $match = 0;
    foreach my $m2 (@new_messages)
    {
      if ($m2->{msg_id} eq $m->{msg_id})
      {
        $match = 1;
				foreach my $sp (@serv_property)
				{
					if ($m2->{$sp} ne $m->{$sp})
					{
						$m->{$sp} = "$m->{$sp} --> $m2->{$sp}";
						push(@messages, $m);
						last;
					}
				}
      }
      else
        { push(@list, $m2); }
    }
		if (!$match)
    {
      $m->{status} = "deleted";
      push(@messages, $m);
    }
    @new_messages = @list;
  }
  foreach my $m (@new_messages)
  {
    $m->{status} = "added";
    push(@messages, $m);
  }

  return (@messages);
}

1;

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut

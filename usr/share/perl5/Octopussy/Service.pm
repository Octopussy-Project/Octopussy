=head1 NAME

Octopussy::Service - Octopussy Service module

=cut
package Octopussy::Service;

use strict;
no strict 'refs';
use utf8;
use Encode;
use Octopussy;

use constant DIR_SERVICE => "services";
use constant XML_ROOT => "octopussy_service";

my $dir_services = undef;
my %filename;

=head1 FUNCTIONS

=head2 New(\%conf)

Create a new Service with configuration '$conf'

Parameters:

\%conf - hashref of the new Service configuration

=cut
sub New($)
{
	my $conf = shift;

	$dir_services ||= Octopussy::Directory(DIR_SERVICE);
	$conf->{version} = Octopussy::Timestamp_Version(undef);
	AAT::XML::Write("$dir_services/$conf->{name}.xml", $conf, XML_ROOT);
}

=head2 Remove($service)

Removes the Service '$service'

Parameters:

$service - Name of the Service to remove

=cut
sub Remove($)
{
	my $service = shift;

	$filename{$service} = undef;
	unlink(Filename($service));
}

=head2 List()

Returns List of Services

=cut
sub List()
{
	$dir_services ||= Octopussy::Directory(DIR_SERVICE);

	return (AAT::XML::Name_List($dir_services));
}

=head2 List_Used()

Returns List of Services used

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

=head2 Filename($service)

Returns the XML filename for the service '$service'

=cut
sub Filename($)
{
	my $service = shift;

	return ($filename{$service})   if (defined $filename{$service});
	$dir_services ||= Octopussy::Directory(DIR_SERVICE);
	$filename{$service} = "$dir_services/$service.xml";

	return ($filename{$service});
}

=head2 Configuration($service)

Returns the configuration for the Service '$service'

=cut
sub Configuration($)
{
	my $service = shift;

	my $conf = AAT::XML::Read(Filename($service));

 	return ($conf);
}

=head2 Configurations($sort)

Returns the configuration for all Services

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

Checks if $msgid is valid & unique for Service $service

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

=head2 Add_Message($service, $mconf)

Adds Message '$mconf' to Service '$service'

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
	AAT::XML::Write(Filename($service), $conf, XML_ROOT);
	Parse_Restart($service);

	return (undef);
}

=head2 Remove_Message($service, $msgid)

Removes Message with id '$msgid' from Service '$service'

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
	AAT::XML::Write(Filename($service), $conf, XML_ROOT);
	Parse_Restart($service);
}

=head2 Modify_Message($service, $msgid, $conf_modified)

Modifies Message with id '$msgid' from Service '$service'

=cut
sub Modify_Message($$$)
{
	my ($service, $msgid, $conf_modified) = @_;

	my $conf = AAT::XML::Read(Filename($service));
	$conf->{version} = Octopussy::Timestamp_Version($conf);
	my @messages = ();
	$conf_modified->{pattern} = Encode::decode_utf8($conf_modified->{pattern});
	foreach my $m (AAT::ARRAY($conf->{message}))
	{
		if ($m->{msg_id} ne $msgid)
			{ push(@messages, $m); }
		else
			{ push(@messages, $conf_modified); }
	}
	$conf->{message} = \@messages;

  return ("FIELD_DONT_EXIST")
    if (! Octopussy::Table::Valid_Pattern($conf_modified->{table}, $conf_modified->{pattern}));

	AAT::XML::Write(Filename($service), $conf, XML_ROOT);
	Parse_Restart($service);

	return (undef);
}

=head2 Move_Message($service, $msgid, $direction)

Moves Message '$msgid' up/down ('$direction') inside Service '$service'

=cut
sub Move_Message($$$)
{
	my ($service, $msgid, $direction) = @_;
	my ($rank, $old_rank) = (undef, undef);
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
			$old_rank = $m->{rank};
			$m->{rank} = ($direction eq "top" ? 1
        : ($direction eq "up" ? $m->{rank} - 1
        : ($direction eq "down" ? $m->{rank} + 1 : $max)));
			$m->{rank} = AAT::Padding($m->{rank}, 3);
			$rank = $m->{rank};
		}
		push(@messages, $m);
  }	
	$conf->{message} = \@messages;
	my @messages2 = ();
	foreach my $m (AAT::ARRAY($conf->{message}))
  {
		if ($m->{msg_id} ne $msgid)
		{
			if ($direction =~ /^(top|bottom)$/)
      {
        if (($direction =~ /^top$/) && ($m->{rank} < $old_rank))
          { $m->{rank} += 1; }
        elsif (($direction =~ /^bottom$/) && ($m->{rank} > $old_rank))
          { $m->{rank} -= 1; }
      }
      elsif ($m->{rank} eq $rank)
      {
        $m->{rank} = ($direction =~ /^up$/ ? $m->{rank} + 1 : $m->{rank} - 1);
      }
    }
		$m->{rank} = AAT::Padding($m->{rank}, 3);
    push(@messages2, $m);
  }
	$conf->{message} = \@messages2;
	AAT::XML::Write(Filename($service), $conf, XML_ROOT);
	Parse_Restart_Required($service);
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

=head2 Messages_Statistics($service, $minutes)

Returns Messages statistics for Service $service for the last $minutes

=cut
sub Messages_Statistics($$)
{
	my ($service, $minutes) = @_;
	my $dir_pid = Octopussy::Directory("running");
  my $cache_parser = new Cache::FileCache( { namespace => "octo_parser",
    default_expires_in => "1 day", cache_root => "$dir_pid/cache",
    directory_umask => "007" } )
    or croak( "Couldn't instantiate FileCache" );
 
  my (%percent, %stat) = ((), ());
  my ($y, $mon, $d, $h, $m) = AAT::Datetime::Now();
  my $limit = int("$y$mon$d$h$m") - $minutes;
  my $total = 0;
  foreach my $k (sort $cache_parser->get_keys())
  {
    if (($k =~ /^parser_msgid_stats_(\d{12})_(\S+)$/) && ($1 >= $limit))
    {
      my $stats = $cache_parser->get($k);
      foreach my $s (@{$stats})
      {
        if ($s->{service} =~ /^$service$/)
        {
          $stat{$s->{id}} = (defined $stat{$s->{id}} ?
            $stat{$s->{id}} + $s->{count} : $s->{count}); 
          $total += $s->{count};
          $stat{$k} = int($stat{$k}/$total*100);
        }
      }
    }
  }
  foreach my $k (keys %stat)
    { $percent{"$service:$k"} = int($stat{$k}/$total*100); }

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

=head2 Parse_Restart_Required($service)

Set 'reload_required' for device with service '$service'

=cut
sub Parse_Restart_Required($)
{
  my $service = shift;

  my @devices = Octopussy::Device::With_Service($service);
  foreach my $d (@devices)
  {
		Octopussy::Device::Reload_Required($d)
    	if (Octopussy::Device::Parse_Status($d));
  }
}

=head2 Updates()

Gets Services Updates from Internet

=cut
sub Updates()
{
	my %update;
	my $web = Octopussy::WebSite();
	my $dir_running = Octopussy::Directory("running");	
	my $file = "$dir_running/_services.idx";

	AAT::Download("Octopussy", "$web/Download/Services/_services.idx", $file);
	if (defined open(UPDATE, "< $file"))
	{
		while (<UPDATE>)
			{ $update{$1} = $2	if ($_ =~ /^(.+):(\d+)$/); }
		close(UPDATE);
	}
	else
  {
    my ($pack, $file_pack, $line, $sub) = caller(0);
    AAT::Syslog("Octopussy::Service", "Unable to open file '$file' in $sub");
  }
	unlink($file);	

	return (\%update);
}

=head2 Updates_Installation(@services)

Installs Services Updates

=cut
sub Updates_Installation
{
  my @services = @_;
  my $web = Octopussy::WebSite();
  $dir_services ||= Octopussy::Directory(DIR_SERVICE);

  foreach my $s (@services)
  {
    AAT::Download("Octopussy", "$web/Download/Services/$s.xml", 
			"$dir_services/$s.xml");
    Parse_Restart($s);
  }
}

=head2 Update_Get_Messages($service)

Returns Service Updates Messages

=cut
sub Update_Get_Messages($)
{
	my $service = shift;
	my $web = Octopussy::WebSite();
	my $dir_running = Octopussy::Directory("running");

	AAT::Download("Octopussy", "$web/Download/Services/$service.xml", 
		"$dir_running$service.xml");
	my $conf_new =  AAT::XML::Read("$dir_running$service.xml");
	
	return (AAT::ARRAY($conf_new->{message}));
}

=head2 Updates_Diff($service)

Returns Service Updates differences

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

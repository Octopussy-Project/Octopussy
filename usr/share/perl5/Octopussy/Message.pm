=head1 NAME

Octopussy::Message - Octopussy Message module

=cut
package Octopussy::Message;

use strict;
no strict 'refs';

use bytes;

use utf8;

use Octopussy;
use Octopussy::Contact;

=head1 FUNCTIONS

=head2 Configuration($service, $msg_id)

Get message '$msg_id' from service '$service' configuration

=cut 

sub Configuration($$)
{
	my ($service, $msg_id) = @_;

	my $conf = AAT::XML::Read(Octopussy::Service::Filename($service));
	foreach my $m (AAT::ARRAY($conf->{message}))
  	{ return ($m) if ($m->{msg_id} eq $msg_id); }

  return (undef);
}

=head2 Fields($service, $msg_id)

Returns Message Fields from Message '$msg_id' in Service '$service'

=cut

sub Fields($$)
{
	my ($service, $msg_id) = @_;
	my @fields = ();
	my $conf = AAT::XML::Read(Octopussy::Service::Filename($service));
	my $msg = undef;
 	foreach my $m (AAT::ARRAY($conf->{message}))
 		{ $msg = $m	if ($m->{msg_id} eq "$msg_id"); }	
	my $pattern = $msg->{pattern};
	while ($pattern =~ s/<\@(.+?):(\S+)\@>//)
 		{ push(@fields, { name => $2, type => $1 })	if ($2 !~ /NULL/i); }	
	
	return (@fields);
}

=head2 Table($service, $msg_id)

Get table associated with message '$msg_id' in service '$service'

=cut 

sub Table($$)
{
	my ($service, $msg_id) = @_;

	my $conf = AAT::XML::Read(Octopussy::Service::Filename($service));
	
	foreach my $m (AAT::ARRAY($conf->{message}))
		{ return ($m->{table})	if ($m->{msg_id} eq "$msg_id"); }

	return (undef);
}

=head2 Pattern_To_SQL($msg, $id, @fields)

Convert message pattern from message '$msg' into SQL with fields '@fields'

=cut 

sub Pattern_To_SQL
{
	my ($msg, $id, @fields) = @_;

	my $sql = "INSERT INTO " . $msg->{table} . "_$id (";
	my $i = 0;
	my $pattern = $msg->{pattern};
	while ($pattern =~ s/<\@.+?:(\S+)\@>//)
	{	 
		my $pattern_field = $1;
		if ($pattern_field !~ /NULL/i)
		{
			if ($#fields == -1)
			{
				$sql .= "$1, "; 
				$i++;
			}
			else
			{
				foreach my $f (@fields)
      	{
					if ($pattern_field =~ /^$f$/i)
					{
						$sql .= "$f, ";
         		$i++;
						last;
					}
				}
			}
		}
	}
	$sql =~ s/, $/\)/;
	$sql .= " VALUES (" . ("'\%s', " x $i);
	$sql =~ s/, $/\);/;

	return ($sql);
}

=head2 Escape_Characters($regexp)

Escape (adding '\') characters from regexp '$regexp'

=cut

sub Escape_Characters($)
{
	my $regexp = shift;

	$regexp =~ s/\//\\\//gi;
  $regexp =~ s/\\(\d+)/\\\\$1/gi;
	$regexp =~ s/\^/\\^/gi;
	$regexp =~ s/\$/\\\$/gi;
	$regexp =~ s/\(/\\(/gi;
  $regexp =~ s/\)/\\)/gi;
	$regexp =~ s/\[/\\[/gi;
  $regexp =~ s/\]/\\]/gi;
	$regexp =~ s/\|/\\|/gi;

	return ($regexp);
}

=head2 Color($pattern)

Colors pattern '$pattern'

=cut

sub Color($)
{
	my $pattern = shift;

	my %color = Octopussy::Type::Colors();
	my $re = $pattern; 
	$re =~ s/<(\w)/&lt;$1/g;
	$re =~ s/(<\@REGEXP\(".+?"\):\S+?\@>)/<b><font color="$color{REGEXP}">$1<\/font><\/b>/gi;
	$re =~ s/(<\@(\S+?):\S+?\@>)/<b><font color="$color{$2}">$1<\/font><\/b>/gi;

	return ($re);
}

=head2 Color_Without_Field($pattern)

=cut

sub Color_Without_Field($)
{
	my $pattern = shift;

	my %color = Octopussy::Type::Colors();
  my $re = $pattern;
  #$re =~ s/<(\w)/&lt;$1/g;
#  $re =~ s/(<\@REGEXP\(".+?"\):\S+?\@>)/<b><font color="$color{REGEXP}">$1<\/font><\/b>/gi;
#  $re =~ s/(<\@(\S+?):\S+?\@>)/<b><font color="$color{$2}">$1<\/font><\/b>/gi;
  $re =~ s/(<\@([^\@]+?)\@>)/<b><font color="$color{$2}">$1<\/font><\/b>/gi;

  return ($re);
}

=head2 Pattern_To_Regexp($msg)

Convert message pattern from message '$msg' into Regexp

=cut 

sub Pattern_To_Regexp($)
{
	my $msg = shift;

	my %re_types = Octopussy::Type::Regexps();
	my $regexp = Escape_Characters($msg->{pattern});

	while ($regexp =~ /^(.*)<\@REGEXP\\\(\"(.+?)\"\\\):(\S+?)\@>(.*)$/)
	{
		my ($start, $const, $field, $finish) = ($1, $2, $3, $4);
		$regexp = $start . (($field =~ /NULL/i) ? $const : "\($const\)") . $finish;
	}
  $regexp =~ s/<\@NUMBER:null\@>/[-+]?\\d+/gi;
  $regexp =~ s/<\@NUMBER:\S+?\@>/\([-+]?\\d+\)/gi;
  $regexp =~ s/<\@WORD:null\@>/\\S+/gi;
  $regexp =~ s/<\@WORD:\S+?\@>/\(\\S+\)/gi;
  $regexp =~ s/<\@STRING:null\@>/.+/gi;
  $regexp =~ s/<\@STRING:\S+?\@>/\(.+\)/gi;
  $regexp =~ s/<\@(\S+?):null\@>/$re_types{$1}/gi;
  $regexp =~ s/<\@(\S+?):\S+?\@>/\($re_types{$1}\)/gi;
	$regexp =~ s/\s+$//g;

	return ($regexp);
}

=head2 Short_Pattern_To_Regexp($msg)

=cut

sub Short_Pattern_To_Regexp($)
{
	my $msg = shift;
	my %re_types = Octopussy::Type::Regexps();
  my $regexp = Escape_Characters($msg->{pattern});

	$regexp =~ s/<\@NUMBER\@>/\([-+]?\\d+\)/gi;
  $regexp =~ s/<\@WORD\@>/\(\\S+\)/gi;
  $regexp =~ s/<\@STRING\@>/\(.+\)/gi;
  $regexp =~ s/<\@(\S+?)\@>/\($re_types{$1}\)/gi;

  return ($regexp);
}

=head2 Pattern_Field_Substitution

=cut

sub Pattern_Field_Substitution($$$$$$)
{
	my ($regexp, $f, $type, $field_regexp, $field_list, $re_types) = @_;

	my $function = undef;
	foreach my $fl (AAT::ARRAY($field_list))
	{
		$function = $1  
			if (($fl =~ /^(\S+::\S+)\($f\)$/) 
				&& (Octopussy::Plugin::Function_Source($1) eq "INPUT")); 
	}
	if ($type =~ /^REGEXP/)
  	{ $regexp =~ s/<\@REGEXP\\\(\"(.+?)\"\\\):\S+?\@>/\($1\)/i; }
 	elsif ($type =~ /^NUMBER$/)
 	{
  	my $substitution = (defined $field_regexp ? $field_regexp->{$f} || "[-+]?\\d+" : "[-+]?\\d+");
  	$regexp =~ s/<\@NUMBER:\S+?\@>/\($substitution\)/i;
 	}
 	elsif ($type =~ /^WORD$/)
 	{
  	my $substitution = (defined $field_regexp ? $field_regexp->{$f} || "\\S+" : "\\S+");
   	$regexp =~ s/<\@WORD:\S+?\@>/\($substitution\)/i;
 	}
	elsif ($type =~ /^STRING$/)
  {
  	my $substitution = (defined $field_regexp ? $field_regexp->{$f} || ".+" : ".+");
   	$regexp =~ s/<\@STRING:\S+?\@>/\($substitution\)/i;
	}
  else
  	{ $regexp =~ s/<\@(\S+?):(\S+?)\@>/\($re_types->{$1}\)/i; }	

	return ($regexp, $function);
}

=head2 Pattern_Field_Unmatched_Substitution($regexp, $type, $field_regexp, $re_types)

=cut

sub Pattern_Field_Unmatched_Substitution($$$$)
{
	my ($regexp, $type, $field_regexp, $re_types) = @_;

	if ($type =~ /^REGEXP/)
  	{ $regexp =~ s/<\@REGEXP\\\(\"(.+?)\"\\\):\S+?\@>/$1/i; }
 	elsif ($type =~ /^NUMBER$/)
 	{
  	if ($regexp =~ /^(.*?)<\@NUMBER:(\S+?)\@>(.*)$/)
  		{ $regexp = $1 . (defined $field_regexp ? $field_regexp->{$2} || "[-+]?\\d+" : "[-+]?\\d+") . $3; }
 	}
 	elsif ($type =~ /^WORD$/)
	{
  	if ($regexp =~ /^(.*?)<\@WORD:(\S+?)\@>(.*)$/)
    	{ $regexp = $1 . (defined $field_regexp ? $field_regexp->{$2} || "\\S+" : "\\S+") . $3; }
 	}
 	elsif ($type =~ /^STRING$/)
 	{
  	if ($regexp =~ /^(.*?)<\@STRING:(\S+?)\@>(.*)$/)
    	{ $regexp = $1 . (defined $field_regexp ? $field_regexp->{$2} || ".+" : ".+") . $3; }
 	}
	else
  	{ $regexp =~ s/<\@(\S+?):(\S+?)\@>/$re_types->{$1}/; }
	
	return ($regexp);		
}

=head2 Pattern_To_Regexp_Fields($msg, $field_regexp, $ref_fields, $field_list)

=cut

sub Pattern_To_Regexp_Fields($$$$)
{
  my ($msg, $field_regexp, $ref_fields, $field_list) = @_;
  my (@fields_position, @fields_function) = ((), ());
  my %re_types = Octopussy::Type::Regexps();
  my $regexp = Escape_Characters($msg->{pattern});
	my $function = undef;
  my $pos = 0;
	
  while ($regexp =~ /<\@(.+?):(\S+?)\@>/i)
  {
    my ($type, $pattern_field) = ($1, $2);
    my $matched = 0;
    my $i = 0;
    foreach my $f (AAT::ARRAY($ref_fields))
    {
      if ($pattern_field =~ /^$f$/)
      {
				($regexp, $function) = 
					Pattern_Field_Substitution($regexp, $f, $type, 
						$field_regexp, $field_list, \%re_types);
        $matched = 1;
        $fields_position[$i] = { pos => $pos, function => $function };
        $pos++;
      }
      $i++;
    }
    if (! $matched)
    {
			$regexp = 
				Pattern_Field_Unmatched_Substitution($regexp, $type, 
					$field_regexp, \%re_types);
    }
	}

  return ($regexp, \@fields_position);
}

=head2 Pattern_To_Regexp_Field_Values($msg, @fields)

=cut

sub Pattern_To_Regexp_Field_Values($$)
{
  my ($msg, @fields) = @_;
  my %re_types = Octopussy::Type::Regexps();
	my $regexp = Escape_Characters($msg->{pattern});

  while ($regexp =~ /<\@(.+?):(\S+?)\@>/i)
  {
    my ($type, $pattern_field) = ($1, $2);
    my $matched = 0;
    foreach my $f (@fields)
    {
      if ($pattern_field =~ /^$f->{name}$/)
      {
				$regexp =~ s/<\@.+?:\S+\@>/$f->{value}/i;
        $matched = 1;
      }
    }
    if (! $matched)
    {
			if ($type =~ /^REGEXP$/)
				{ $regexp =~ s/<\@REGEXP\\\(\\\"(.+?)\\\"\\\):\S+?\@>/$1/i; }		
			elsif ($type =~ /^NUMBER$/)
        { $regexp =~ s/<\@NUMBER:\S+?\@>/[-+]?\\d+/i; }
      elsif ($type =~ /^WORD$/)
        { $regexp =~ s/<\@WORD:\S+?\@>/\\S+/i; }
      elsif ($type =~ /^STRING$/)
        { $regexp =~ s/<\@STRING:\S+?\@>/.+/i; }
      else
        { $regexp =~ s/<\@(\S+?):\S+?\@>/$re_types{$1}/i; }
    }
  }

  return ($regexp);
}

=head2 Fields_Values($msg, $line)

=cut

sub Fields_Values($$)
{
	my ($msg, $line) = @_;
	my @fields = ();
	my %field = ();
	my $pattern = $msg->{pattern};

	while ($pattern =~ /<\@.+?:(\S+?)\@>/)
  {	
		push(@fields, $1)	if ($1 !~ /NULL/i);
		$pattern =~ s/.*?(<\@([^\@]+?)\@>)//;
	}
	my @data = $line =~ /$msg->{re}/;	
	foreach my $i (0..$#data)
		{ $field{$fields[$i]} = $data[$i]; }

	return (%field);
}

=head2 Regexped_Fields($query)

=cut

sub Regexped_Fields($)
{
	my $query = shift;
	my %field_regexp = ();
	if ($query =~ /WHERE (.+)/)
  {
    my $where = $1;
		return (undef)	if (($where =~ /.+ AND .+/i) || ($where =~ /.+ OR .+/i));
    while ($where =~ /(.*?)(\w+) LIKE '(.+?)'(.*)/i)
    {
      $where = "$1 $4";
      my $field = $2;
      my $like = $3;
      $like =~ s/%/.*/g;
      $field_regexp{$field} = $like;
    }
    while ($where =~ /(.*?)(\w+)=(\d+)(.*)/i)
    {
      $where = "$1 $4";
      $field_regexp{$2} = $3;
    }
    while ($where =~ /(.*?)(\w+)='(.+?)'(.*)/i)
    {
      $where = "$1 $4";
      $field_regexp{$2} = $3;
    }
  }
	
	return (\%field_regexp);
}

=head2 Parse_List($services, $taxonomy, $table, $fields_regexp)

=cut

sub Parse_List($$$$$$)
{
	my ($services, $taxonomy, $table, $fields, $fields_regexp, $fields_list) = @_;

	my @servs = ((defined $services) && (@{$services}[0] !~ /-ANY-/i) ? @{$services}
		: Octopussy::Service::List());
	my $taxo = (defined $taxonomy ?
    (($taxonomy ne "") && ($taxonomy !~ /-ANY-/i) ? $taxonomy : ".+") : ".+");
  my @msg_to_parse = ();
	foreach my $s (@servs)
  {
		my @messages = Octopussy::Service::Messages($s);
   	foreach my $m (@messages)
    {
			if (((!defined $table) || ($m->{table} eq $table)) 
				&& ($m->{taxonomy} =~ /^$taxo(\..+)?/))
      {
        my ($regexp, $fields_position) =
          Pattern_To_Regexp_Fields($m, $fields_regexp, $fields, $fields_list);
        if (defined $regexp)
        {
          push(@msg_to_parse, { re => qr/$regexp/, positions => $fields_position });
        }
      }
		}
	}

	return (@msg_to_parse);	
}

=head2 Alerts($device, $service, $message)

=cut

sub Alerts($$$)
{
  my ($device, $service, $message) = @_;
	my @alert_confs = Octopussy::Alert::For_Device($device);
  my @alerts = ();

  foreach my $ac (@alert_confs)
  {
		my @mails = ();
		my @ims = ();
		foreach my $c (AAT::ARRAY($ac->{contact}))
		{
			my $c_conf = Octopussy::Contact::Configuration($c);
			push(@mails, $c_conf->{email})	if (defined $c_conf->{email});
			push(@ims, $c_conf->{im})	if (defined $c_conf->{im});
		}
    if ($ac->{type} =~ /Dynamic/i)
    {
      foreach my $s (AAT::ARRAY($ac->{service}))
      {
        if ((($s =~ /^$service$/) || ($s =~ /^-ANY-$/i))
          && ($message->{taxonomy} =~ /$ac->{taxonomy}.*/))
        {
          push(@alerts, { name => $ac->{name}, level => $ac->{level},
            thresold_time => $ac->{thresold_time},
            thresold_duration => $ac->{thresold_duration},
						regexp_incl => $ac->{regexp_include}, 
						regexp_excl => $ac->{regexp_exclude}, 
            timeperiod => $ac->{timeperiod}, action => $ac->{action},
            msgsubject => $ac->{msgsubject},  msgbody => $ac->{msgbody},
            imdest => \@ims, maildest => \@mails } );
        }
      }
    }
    elsif ($ac->{type} =~ /Static/i)
    {
      foreach my $m (AAT::ARRAY($ac->{message}))
      {
        if ($message->{msg_id} =~ /^$m->{mid}$/)
        {
          my @fields = ();
          foreach my $f (AAT::ARRAY($m->{field}))
            { push(@fields, { name => $f->{fid}, value => $f->{value}, negate => $f->{negate} }); }
          push(@alerts, { name => $ac->{name}, level => $ac->{level},
              fields => \@fields,
              thresold_time => $ac->{thresold_time},
              thresold_duration => $ac->{thresold_duration},
							regexp_include => $ac->{regexp_include},
	            regexp_exclude => $ac->{regexp_exclude},
              timeperiod => $ac->{timeperiod}, action => $ac->{action},
              msgsubject => $ac->{msgsubject}, msgbody => $ac->{msgbody},
              imdest => \@ims, maildest => \@mails } );
        }
      }
    }
  }

  return (@alerts);
}

=head2 Wizard_Msg_Modified($line, $types)

=cut

sub Wizard_Msg_Modified($$)
{
	my ($line, $types) = @_;

	use bytes;

	$line =~ s/^\w{3} \s?\d{1,2} \d{2}:\d{2}:\d{2} \S+ /<\@DATE_TIME_SYSLOG\@> <\@WORD\@> /mgi;
	foreach my $t (AAT::ARRAY($types))
  {
		my $re = $t->{re};
		my $type = $t->{type_id}; 
		$line =~ s/$re/<\@$type\@>/mgi; 
	}
 	$line =~ s/([^\w\\]+)[-+]?\d+(\W+)/$1<\@NUMBER\@>$2/mgi;
 	$line =~ s/([=:;"])[\w\d_-]+/$1<\@WORD\@>/gi;
 	$line =~ s/\+/\\+/gi;
 	$line =~ s/\?/\\?/gi;
 	$line =~ s/\*/\\*/gi;	

	no bytes;

	return ($line);
}

=head2 Wizard_Msg_Regexp($re, $types)

=cut

sub Wizard_Msg_Regexp($$)
{
	my ($re, $types) = @_;

#	use bytes;

	foreach my $t (AAT::ARRAY($types))
  	{ $re =~ s/<\@$t->{type_id}\@>/$t->{re}/mgi; }
  $re =~ s/<\@NUMBER\@>/[-+]?\\d+/mgi;
 	$re =~ s/<\@WORD\@>/\\S+/gi;

#	no bytes;

	return ($re);
}

=head2 Wizard_Add_Message($timestamp, $line, $types)

=cut

sub Wizard_Add_Message($$$)
{
	my ($timestamp, $line, $types) = @_;
	my $sample = $line;

#	use bytes;
	
	my $pattern = $line = Wizard_Msg_Modified($line, $types);
	$line =~ s/\[/\\\[/g;
  $line =~ s/\]/\\\]/g;
  $line =~ s/\(/\\\(/g;
  $line =~ s/\)/\\\)/g;
  $line =~ s/\//\\\//g;	
	#my $re = Escape_Characters($line);
	#$re = Wizard_Msg_Regexp($re, @types);
	my $re = Wizard_Msg_Regexp($line, $types);

#	no bytes;
	
	return ( { re => qr/$re/, modified => $pattern, orig => $sample, 
		timestamp => $timestamp, nb => 1 } );
}

=head2 Wizard($device)

=cut

sub Wizard($)
{
	my $device = shift;
	my @types = Octopussy::Type::Configurations();
	my @messages = ();
	my @files = Octopussy::Logs::Unknown_Files($device);
	my $nb_max = Octopussy::Parameter("wizard_max_msgs");
	foreach my $f (sort @files)
  {
    chomp($f);
		my $timestamp = "$1$2$3$4$5"
			if ($f =~ /\/(\d{4})\/(\d{2})\/(\d{2})\/msg_(\d{2})h(\d{2})/);
    open(FILE, "zcat $f |");
    while (<FILE>)
    {
      my $line = $_;
      chomp($line);
      my $match = 0;
      foreach my $m (@messages)
      {
        if ($line =~ $m->{re})
        {
          $m->{nb} = $m->{nb} + 1;
          $match = 1;
					if ($m->{nb} > 100)
					{
						$m->{nb} = "100+";
						close(FILE);
						return (@messages);
					}
          last;
        }
      }
			push(@messages, Wizard_Add_Message($timestamp, $line, \@types))
      	if (! $match);
			last  if ($#messages+1 >= $nb_max);
    }
    close(FILE);
   	last  if ($#messages+1 >= $nb_max);
  }
	
	return (@messages);
}

1;

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut

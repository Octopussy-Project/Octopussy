# $HeadURL$
# $Revision$
# $Date$
# $Author$

=head1 NAME

Octopussy::Message - Octopussy Message module

=cut

package Octopussy::Message;

use strict;
use warnings;
use bytes;
use utf8;

use Octopussy;
use Octopussy::Contact;

=head1 FUNCTIONS

=head2 Configuration($service, $msg_id)

Get message '$msg_id' from service '$service' configuration

=cut 

sub Configuration
{
  my ( $service, $msg_id ) = @_;

  foreach my $s ( AAT::ARRAY($service) )
  {
    my $conf = Octopussy::Service::Configuration($s);
    foreach my $m ( AAT::ARRAY( $conf->{message} ) )
    {
      return ($m) if ( $m->{msg_id} eq $msg_id );
    }
  }

  return (undef);
}

sub List
{
  my ( $ref_serv, $loglevel, $taxonomy ) = @_;
  my %log_level = Octopussy::Loglevel::Levels();
  my $level = (
                ( AAT::NOT_NULL($loglevel) && ( $loglevel !~ /^-ANY-$/i ) )
                ? $log_level{$loglevel}
                : 0
              );
  my $qr_taxo = (
                  ( AAT::NOT_NULL($taxonomy) && ( $taxonomy !~ /^-ANY-$/i ) )
                  ? qr/^$taxonomy(\..+)?/
                  : qr/.+/
                );
  my @list = ();

  foreach my $serv ( AAT::ARRAY($ref_serv) )
  {
    my $conf = Octopussy::Service::Configuration($serv);
    foreach my $m ( AAT::ARRAY( $conf->{message} ) )
    {
      if (    ( $log_level{ $m->{loglevel} } >= $level )
           && ( $m->{taxonomy} =~ $qr_taxo ) )
      {
        push @list, $m->{msg_id};
      }
    }
  }

  return (@list);
}

=head2 Fields($service, $msg_id)

Returns Message Fields from Message '$msg_id' in Service '$service'

=cut

sub Fields
{
  my ( $service, $msg_id ) = @_;
  my @fields = ();
  my $conf   = Octopussy::Service::Configuration($service);
  my $msg    = undef;
  foreach my $m ( AAT::ARRAY( $conf->{message} ) )
  {
    $msg = $m if ( $m->{msg_id} eq "$msg_id" );
  }
  my $pattern = $msg->{pattern};
  while (    ( $pattern =~ s/<\@(REGEXP\(".+?"\)):(\S+?)\@>// )
          || ( $pattern =~ s/<\@(.+?):(\S+?)\@>// ) )
  {
    push @fields, { name => $2, type => $1 } if ( $2 !~ /NULL/i );
  }

  return (@fields);
}

=head2 Table($service, $msg_id)

Get table associated with message '$msg_id' in service '$service'

=cut 

sub Table
{
  my ( $service, $msg_id ) = @_;

  my $conf = Octopussy::Service::Configuration($service);

  foreach my $m ( AAT::ARRAY( $conf->{message} ) )
  {
    return ( $m->{table} ) if ( $m->{msg_id} eq "$msg_id" );
  }

  return (undef);
}

=head2 Pattern_To_SQL($msg, $id, @fields)

Convert message pattern from message '$msg' into SQL with fields '@fields'

=cut 

sub Pattern_To_SQL
{
  my ( $msg, $id, @fields ) = @_;

  my $sql     = 'INSERT INTO ' . $msg->{table} . "_$id (";
  my $i       = 0;
  my $pattern = $msg->{pattern};
  while ( $pattern =~ s/<\@.+?:(\S+)\@>// )
  {
    my $pattern_field = $1;
    if ( $pattern_field !~ /NULL/i )
    {
      if ( scalar(@fields) == 0 )
      {
        $sql .= "$1, ";
        $i++;
      }
      else
      {
        foreach my $f (@fields)
        {
          if ( $pattern_field =~ /^$f$/i )
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
  $sql .= ' VALUES (' . ( q('\%s', ) x $i );
  $sql =~ s/, $/\);/;

  return ($sql);
}

=head2 Escape_Characters($regexp)

Escape (adding '\') characters from regexp '$regexp'

=cut

sub Escape_Characters
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

=head2 Escape_Message($msg)

Escape (adding '\') characters from message '$msg' without escaping <@REGEXP@>

=cut

sub Escape_Message
{
  my $msg     = shift;
  my $escaped = '';

  while ( $msg =~ /^(.*?)(<\@REGEXP\(\".+?\"\):\S+?\@>)(.*)$/i )
  {
    my ( $before, $re, $after ) = ( $1, $2, $3 );
    $escaped .= ( Escape_Characters($before) . $re );
    $msg = $after;
  }
  $escaped .= Escape_Characters($msg);

  return ($escaped);
}

=head2 Color($pattern)

Colors pattern '$pattern'

=cut

sub Color
{
  my $pattern = shift;

  my %color = Octopussy::Type::Colors();
  my $re    = $pattern;
  $re =~ s/<(\w)/&lt;$1/g;
  $re =~
s/(<\@REGEXP\(".+?"\):\S+?\@>)/<b><font color="$color{REGEXP}">$1<\/font><\/b>/gi;
  $re =~
    s/(<\@([^\@]+?):\S+?\@>)/<b><font color="$color{$2}">$1<\/font><\/b>/gi;

  return ($re);
}

=head2 Color_Without_Field($pattern)

=cut

sub Color_Without_Field
{
  my $pattern = shift;

  my %color = Octopussy::Type::Colors();
  my $re    = $pattern;
  $re =~ s/(<\@([^\@]+?)\@>)/<b><font color="$color{$2}">$1<\/font><\/b>/gi;

  return ($re);
}

=head2 Pattern_To_Regexp($msg)

Converts message pattern from message '$msg' into Regexp

=cut 

sub Pattern_To_Regexp
{
  my $msg = shift;

  my %re_types = Octopussy::Type::Regexps();
  my $regexp   = '';
  my $tmp      = $msg->{pattern};
  while (    ( AAT::NOT_NULL($tmp) )
          && ( $tmp =~ /^(.*?)<\@(REGEXP)\(\"(.+?)\"\):(\S+?)\@>(.*)$/i ) )
  {
    my ( $before, $type, $re_value, $field, $after ) = ( $1, $2, $3, $4, $5 );
    my $subs = ( $field =~ /NULL/i ) ? $re_value : '(' . $re_value . ')';
    $regexp .= ( Escape_Characters($before) . $subs );
    $tmp = $after;
  }
  $tmp = $regexp . ( AAT::NOT_NULL($tmp) ? Escape_Characters($tmp) : '' );
  $regexp = '';
  while ( $tmp =~ /^(.*?)<\@([^\@]+?):(\S+?)\@>(.*)$/i )
  {
    my ( $before, $type, $field, $after ) = ( $1, $2, $3, $4 );
    my $subs =
      ( $field =~ /NULL/i ) ? $re_types{$type} : '(' . $re_types{$type} . ')';
    $regexp .= $before . $subs;
    $tmp = $after;
  }
  $regexp .= $tmp;
  $regexp =~ s/\s+$//g;

  return ($regexp);
}

=head2 Short_Pattern_To_Regexp($msg)

=cut

sub Short_Pattern_To_Regexp
{
  my $msg = shift;

  my %re_types = Octopussy::Type::Regexps();
  my $regexp   = Escape_Characters( $msg->{pattern} );
  $regexp =~ s/<\@([^\@]+?)\@>/\($re_types{$1}\)/gi;
  $regexp =~ s/\s+$//g;

  return ($regexp);
}

=head2 Pattern_Field_Substitution

=cut

sub Pattern_Field_Substitution
{
  my ( $regexp, $f, $type, $field_regexp, $field_list, $re_types ) = @_;

  my $long_f = $f;
  $f =~ s/Plugin_\S+__//;
  my $function = undef;
  foreach my $fl ( AAT::ARRAY($field_list) )
  {
    if (    ( $fl =~ /^(\S+::\S+)\($f\)$/ )
         && ( Octopussy::Plugin::Function_Source($1) eq 'INPUT' ) )
    {
      my $perl_fct  = $1;
      my $sql_field = Octopussy::Plugin::SQL_Convert($fl);
      $function = $perl_fct if ( $long_f =~ /^$sql_field$/ );
    }
  }
  if ( $type eq 'REGEXP' )
  {
    $regexp =~ s/<\@REGEXP\(\"(.+?)\"\):\S+?\@>/\($1\)/i;
  }
  elsif ( $type eq 'NUMBER' )
  {
    my $substitution = (
                         defined $field_regexp
                         ? $field_regexp->{$f} || '[-+]?\\d+'
                         : '[-+]?\\d+'
                       );
    $regexp =~ s/<\@NUMBER:\S+?\@>/\($substitution\)/i;
  }
  elsif ( $type eq 'WORD' )
  {
    my $substitution =
      ( defined $field_regexp ? $field_regexp->{$f} || '\\S+' : '\\S+' );
    $regexp =~ s/<\@WORD:\S+?\@>/\($substitution\)/i;
  }
  elsif ( $type eq 'STRING' )
  {
    my $substitution =
      ( defined $field_regexp ? $field_regexp->{$f} || '.+' : '.+' );
    $regexp =~ s/<\@STRING:\S+?\@>/\($substitution\)/i;
  }
  else { $regexp =~ s/<\@([^\@]+?):(\S+?)\@>/\($re_types->{$1}\)/i; }

  return ( $regexp, $function );
}

=head2 Pattern_Field_Unmatched_Substitution($regexp, $type, $field_regexp, $re_types)

=cut

sub Pattern_Field_Unmatched_Substitution
{
  my ( $regexp, $type, $field_regexp, $re_types ) = @_;

  if ( $type eq 'REGEXP' ) { $regexp =~ s/<\@REGEXP\(\"(.+?)\"\):\S+?\@>/$1/i; }
  elsif ( $type eq 'NUMBER' )
  {
    if ( $regexp =~ /^(.*?)<\@NUMBER:(\S+?)\@>(.*)$/ )
    {
      $regexp = $1
        . (
            defined $field_regexp
            ? $field_regexp->{$2} || '[-+]?\\d+'
            : '[-+]?\\d+'
          ) . $3;
    }
  }
  elsif ( $type eq 'WORD' )
  {
    if ( $regexp =~ /^(.*?)<\@WORD:(\S+?)\@>(.*)$/ )
    {
      $regexp =
          $1
        . ( defined $field_regexp ? $field_regexp->{$2} || '\\S+' : '\\S+' )
        . $3;
    }
  }
  elsif ( $type eq 'STRING' )
  {
    if ( $regexp =~ /^(.*?)<\@STRING:(\S+?)\@>(.*)$/ )
    {
      $regexp =
          $1
        . ( defined $field_regexp ? $field_regexp->{$2} || '.+' : '.+' )
        . $3;
    }
  }
  else { $regexp =~ s/<\@([^\@]+?):(\S+?)\@>/$re_types->{$1}/; }

  return ($regexp);
}

=head2 Pattern_To_Regexp_Fields($msg, $field_regexp, $ref_fields, $field_list)

=cut

sub Pattern_To_Regexp_Fields
{
  my ( $msg, $field_regexp, $ref_fields, $field_list ) = @_;
  my ( @fields_position, @fields_function ) = ( (), () );
  my %re_types         = Octopussy::Type::Regexps();
  my $regexp           = Escape_Message( $msg->{pattern} );
  my $function         = undef;
  my $pos              = 0;
  my %plugin_field_pos = ();

  while ( $regexp =~ /<\@(.+?):([^:\s]+?)\@>/i )
  {
    my ( $type, $pattern_field ) = ( $1, $2 );
    my $matched = 0;
    my $i       = 0;
    foreach my $f ( AAT::ARRAY($ref_fields) )
    {
      if (    ( $pattern_field =~ /^$f$/ )
           || ( $f =~ /^Plugin_\S+__$pattern_field$/ ) )
      {
        ( $regexp, $function ) =
          Pattern_Field_Substitution( $regexp, $f, $type, $field_regexp,
                                      $field_list, \%re_types );
        $matched = 1;
        $fields_position[$i] = {
                                 pos => (
                                       defined $plugin_field_pos{$pattern_field}
                                       ? $plugin_field_pos{$pattern_field}
                                       : $pos
                                 ),
                                 function => $function
                               };
        $plugin_field_pos{$pattern_field} = $pos;
        $pos++;
      }
      $i++;
    }
    if ( !$matched )
    {
      $regexp =
        Pattern_Field_Unmatched_Substitution( $regexp, $type, $field_regexp,
                                              \%re_types );
    }
  }
  $regexp =~ s/\s+$//g;

  return ( $regexp, \@fields_position );
}

=head2 Fields_Values($msg, $line)

=cut

sub Fields_Values
{
  my ( $msg, $line ) = @_;
  my @fields  = ();
  my %field   = ();
  my $pattern = $msg->{pattern};

  while ( $pattern =~ /<\@.+?:(\S+?)\@>/ )
  {
    push @fields, $1 if ( $1 !~ /NULL/i );
    $pattern =~ s/.*?(<\@([^\@]+?)\@>)//;
  }
  my @data = $line =~ /$msg->{re}/;
  my $last_data = scalar(@data) - 1;
  foreach my $i ( 0 .. $last_data ) { $field{ $fields[$i] } = $data[$i]; }

  return (%field);
}

=head2 Regexped_Fields($query)

=cut

sub Regexped_Fields
{
  my $query        = shift;
  my %field_regexp = ();
  if ( $query =~ /WHERE (.+)/ )
  {
    my $where = $1;
    return (undef)
      if ( ( $where =~ /.+ AND .+/i ) || ( $where =~ /.+ OR .+/i ) );
    while ( $where =~ /(.*?)(\w+) LIKE '(.+?)'(.*)/i )
    {
      $where = "$1 $4";
      my $field = $2;
      my $like  = $3;
      $like =~ s/%/.*/g;
      $field_regexp{$field} = $like;
    }
    while ( $where =~ /(.*?)(\w+)=(\d+)(.*)/i )
    {
      $where = "$1 $4";
      $field_regexp{$2} = $3;
    }
    while ( $where =~ /(.*?)(\w+)='(.+?)'(.*)/i )
    {
      $where = "$1 $4";
      $field_regexp{$2} = $3;
    }
  }

  return ( \%field_regexp );
}

=head2 Parse_List($services, $loglevel, $taxonomy, $table, $fields, $fields_regexp, $fields_list)

=cut

sub Parse_List
{
  my ( $services, $loglevel, $taxonomy, $table, $fields, $fields_regexp,
       $fields_list )
    = @_;

  my @servs = (
                ( defined $services ) && ( @{$services}[0] !~ /-ANY-/i )
                ? @{$services}
                : Octopussy::Service::List()
              );
  my %log_level = Octopussy::Loglevel::Levels();
  my $level = (
                ( AAT::NOT_NULL($loglevel) && ( $loglevel !~ /^-ANY-$/i ) )
                ? $log_level{$loglevel}
                : 0
              );
  my $qr_taxo = (
                  ( AAT::NOT_NULL($taxonomy) && ( $taxonomy !~ /^-ANY-$/i ) )
                  ? qr/^$taxonomy(\..+)?/
                  : qr/.+/
                );
  my @msg_to_parse = ();

  foreach my $s (@servs)
  {
    my @messages = Octopussy::Service::Messages($s);
    foreach my $m (@messages)
    {
      if (    ( ( !defined $table ) || ( $m->{table} eq $table ) )
           && ( $log_level{ $m->{loglevel} } >= $level )
           && ( $m->{taxonomy} =~ $qr_taxo ) )
      {
        my ( $regexp, $fields_position ) =
          Pattern_To_Regexp_Fields( $m, $fields_regexp, $fields, $fields_list );
        if ( defined $regexp )
        {
          push @msg_to_parse,
            { re => qr/$regexp/, positions => $fields_position };
        }
      }
    }
  }

  return (@msg_to_parse);
}

=head2 Alerts($device, $service, $message, \@dev_alerts, \%contact)

=cut

sub Alerts
{
  my ( $device, $service, $message, $dev_alerts, $contact ) = @_;
  my @alerts = ();

  foreach my $ac ( AAT::ARRAY($dev_alerts) )
  {
    my @mails = ();
    my @ims   = ();
    foreach my $c ( AAT::ARRAY( $ac->{contact} ) )
    {
      push @mails, $contact->{$c}->{email}
        if ( defined $contact->{$c}->{email} );
      push @ims, $contact->{$c}->{im}
        if ( defined $contact->{$c}->{im} );
    }
    if ( $ac->{type} =~ /Dynamic/i )
    {
      foreach my $s ( AAT::ARRAY( $ac->{service} ) )
      {
        if (    ( ( $s eq $service ) || ( $s =~ /^-ANY-$/i ) )
             && ( $message->{taxonomy} =~ /$ac->{taxonomy}.*/ ) )
        {
          push @alerts, {
            name              => $ac->{name},
            level             => $ac->{level},
            thresold_time     => $ac->{thresold_time},
            thresold_duration => $ac->{thresold_duration},
            regexp_incl       => $ac->{regexp_include},
            regexp_excl       => $ac->{regexp_exclude},
            timeperiod        => $ac->{timeperiod},
            action            => $ac->{action},
            msgsubject        => $ac->{msgsubject},
            msgbody           => $ac->{msgbody},
            nagios_host       => $ac->{nagios_host},       # only for NSCA
            nagios_service    => $ac->{nagios_service},    # only for NSCA
            action_host       => $ac->{action_host},       # for Nagios & Zabbix
            action_service    => $ac->{action_service},    # for Nagios & Zabbix
            imdest            => \@ims,
            maildest          => \@mails
                        };
        }
      }
    }
    elsif ( $ac->{type} =~ /Static/i )
    {
      foreach my $m ( AAT::ARRAY( $ac->{message} ) )
      {
        if ( $message->{msg_id} =~ /^$m->{mid}$/ )
        {
          my @fields = ();
          foreach my $f ( AAT::ARRAY( $m->{field} ) )
          {
            push @fields,
              {
                name   => $f->{fid},
                value  => $f->{value},
                negate => $f->{negate}
              };
          }
          push @alerts, {
            name              => $ac->{name},
            level             => $ac->{level},
            fields            => \@fields,
            thresold_time     => $ac->{thresold_time},
            thresold_duration => $ac->{thresold_duration},
            regexp_include    => $ac->{regexp_include},
            regexp_exclude    => $ac->{regexp_exclude},
            timeperiod        => $ac->{timeperiod},
            action            => $ac->{action},
            msgsubject        => $ac->{msgsubject},
            msgbody           => $ac->{msgbody},
            nagios_host       => $ac->{nagios_host},       # only for NSCA
            nagios_service    => $ac->{nagios_service},    # only for NSCA
            action_host       => $ac->{action_host},       # for Nagios & Zabbix
            action_service    => $ac->{action_service},    # for Nagios & Zabbix
            imdest            => \@ims,
            maildest          => \@mails
                        };
        }
      }
    }
  }

  return (@alerts);
}

=head2 Wizard_Msg_Modified($line, $types)

=cut

sub Wizard_Msg_Modified
{
  my ( $line, $types ) = @_;

  use bytes;

  $line =~ s/</&lt;/g;
  $line =~ s/>/&gt;/g;

  $line =~
s/^\w{3} \s?\d{1,2} \d{2}:\d{2}:\d{2} \S+ /<\@DATE_TIME_SYSLOG\@> <\@WORD\@> /mgi;
  foreach my $t ( AAT::ARRAY($types) )
  {
    my $re   = $t->{re};
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

sub Wizard_Msg_Regexp
{
  my ( $re, $types ) = @_;

  foreach my $t ( AAT::ARRAY($types) )
  {
    $re =~ s/<\@$t->{type_id}\@>/$t->{re}/mgi;
  }
  $re =~ s/<\@NUMBER\@>/[-+]?\\d+/mgi;
  $re =~ s/<\@WORD\@>/\\S+/gi;

  return ($re);
}

=head2 Wizard_Add_Message($timestamp, $line, $types)

=cut

sub Wizard_Add_Message
{
  my ( $timestamp, $line, $types ) = @_;
  my $sample = $line;
  $line =~ s/\\/\\\\/g;
  my $pattern = $line = Wizard_Msg_Modified( $line, $types );
  $line =~ s/\[/\\\[/g;
  $line =~ s/\]/\\\]/g;
  $line =~ s/\(/\\\(/g;
  $line =~ s/\)/\\\)/g;
  $line =~ s/\//\\\//g;
  my $re = Wizard_Msg_Regexp( $line, $types );

  return (
           {
             re        => qr/$re/,
             modified  => $pattern,
             orig      => $sample,
             timestamp => $timestamp,
             nb        => 1
           }
         );
}

=head2 Wizard($device)

=cut

sub Wizard
{
  my $device   = shift;
  my @types    = Octopussy::Type::Configurations();
  my @messages = ();
  my @files    = Octopussy::Logs::Unknown_Files($device);
  my $nb_max   = Octopussy::Parameter('wizard_max_msgs');
  foreach my $f ( sort @files )
  {
    chomp $f;
    if ( $f =~ /\/(\d{4})\/(\d{2})\/(\d{2})\/msg_(\d{2})h(\d{2})/ )
    {
      my $timestamp = "$1$2$3$4$5";
      if ( defined open my $FILE, '-|', "zcat $f" )
      {
        while ( my $line = <$FILE> )
        {
          chomp $line;
          my $match = 0;
          foreach my $m (@messages)
          {
            if ( $line =~ $m->{re} )
            {
              $m->{nb} = $m->{nb} + 1;
              $match = 1;
              if ( $m->{nb} > 100 )
              {
                $m->{nb} = '100+';
                close $FILE;
                return (@messages);
              }
              last;
            }
          }
          push @messages, Wizard_Add_Message( $timestamp, $line, \@types )
            if ( !$match );
          last if ( scalar(@messages) >= $nb_max );
        }
        close $FILE;
        last if ( scalar(@messages) >= $nb_max );
      }
      else
      {
        my ( $pack, $file_pack, $line, $sub ) = caller 0;
        AAT::Syslog( 'Octopussy::Message', 'UNABLE_OPEN_FILE_IN', $f, $sub );
      }
    }
  }

  return (@messages);
}

1;

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut

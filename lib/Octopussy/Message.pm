
=head1 NAME

Octopussy::Message - Octopussy Message module

=cut

package Octopussy::Message;

use strict;
use warnings;
use bytes;
use utf8;

use AAT::Syslog;
use AAT::Utils qw( ARRAY NOT_NULL NULL );
use Octopussy;
use Octopussy::Loglevel;
use Octopussy::Logs;
use Octopussy::Plugin;
use Octopussy::Service;
use Octopussy::Type;

my $WIZARD_MAX_SAME_MSG = 100;

=head1 FUNCTIONS

=head2 Configuration($service, $msg_id)

Get message '$msg_id' from service '$service' configuration

=cut 

sub Configuration
{
    my ($service, $msg_id) = @_;

    foreach my $s (ARRAY($service))
    {
        my $conf = Octopussy::Service::Configuration($s);
        foreach my $m (ARRAY($conf->{message}))
        {
            return ($m) if ($m->{msg_id} eq $msg_id);
        }
    }

    return (undef);
}

=head2 List($ref_serv, $loglevel, $taxonomy)

=cut

sub List
{
    my ($ref_serv, $loglevel, $taxonomy) = @_;
    my %log_level = Octopussy::Loglevel::Levels();
    my $level     = (
        (NOT_NULL($loglevel) && ($loglevel ne '-ANY-'))
        ? $log_level{$loglevel}
        : 0
    );
    my $qr_taxo = (
        (NOT_NULL($taxonomy) && ($taxonomy ne '-ANY-'))
        ? qr/^$taxonomy(\..+)?/
        : qr/.+/
    );
    my @list = ();

    foreach my $serv (ARRAY($ref_serv))
    {
        my $conf = Octopussy::Service::Configuration($serv);
        foreach my $m (ARRAY($conf->{message}))
        {
            if (   ($log_level{$m->{loglevel}} >= $level)
                && ($m->{taxonomy} =~ $qr_taxo))
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
    my ($service, $msg_id) = @_;
    my @fields = ();
    my $conf   = Octopussy::Service::Configuration($service);
    my $msg    = undef;
    foreach my $m (ARRAY($conf->{message}))
    {
        $msg = $m if ($m->{msg_id} eq "$msg_id");
    }
    my $pattern = $msg->{pattern};
    while (($pattern =~ s/<\@(REGEXP\(".+?"\)):(\S+?)\@>//)
        || ($pattern =~ s/<\@(.+?):(\S+?)\@>//))
    {
        push @fields, {name => $2, type => $1} if ($2 !~ /NULL/i);
    }

    return (@fields);
}

=head2 Table($service, $msg_id)

Gets Table associated with Message '$msg_id' in Service '$service'

=cut 

sub Table
{
    my ($service, $msg_id) = @_;

    my $conf = Octopussy::Service::Configuration($service);

    foreach my $m (ARRAY($conf->{message}))
    {
        return ($m->{table}) if ($m->{msg_id} eq "$msg_id");
    }

    return (undef);
}

=head2 Pattern_To_SQL($msg, $id, @fields)

Converts message pattern from Message '$msg' into SQL with fields '@fields'

=cut 

sub Pattern_To_SQL
{
    my ($msg, $id, @fields) = @_;

    my $sql     = 'INSERT INTO ' . $msg->{table} . "_$id (";
    my $i       = 0;
    my $pattern = $msg->{pattern};
    while ($pattern =~ s/<\@.+?:(\S+)\@>//)
    {
        my $pattern_field = $1;
        if ($pattern_field !~ /NULL/i)
        {
            if (scalar(@fields) == 0)
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
    $sql .= ' VALUES (' . (q('\%s', ) x $i);
    $sql =~ s/, $/\);/;

    return ($sql);
}

=head2 Escape_Characters($regexp)

Escapes (adding '\') characters from regexp '$regexp'

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

Escapes (adding '\') characters from message '$msg' without escaping <@REGEXP@>

=cut

sub Escape_Message
{
    my $msg     = shift;
    my $escaped = '';

    while ($msg =~ /^(.*?)(<\@REGEXP\(\".+?\"\):\S+?\@>)(.*)$/i)
    {
        my ($before, $re, $after) = ($1, $2, $3);
        $escaped .= (Escape_Characters($before) . $re);
        $msg = $after;
    }
    $escaped .= Escape_Characters($msg);

    return ($escaped);
}

=head2 Color_Reserved_Word(\%color, $word, $str)

Colors reserved word

=cut

sub Color_Reserved_Word
{
    my ($color, $word, $str) = @_;

    if (defined $color->{$word})
    {
        return (qq(<b><font color="$color->{$2}">$str</font></b>));
    }

    return ($str);
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
    $re =~ s/(\w)>/$1&gt;/g;
    $re =~
s/(<\@REGEXP\(".+?"\):\S+?\@>)/<b><font color="$color{REGEXP}">$1<\/font><\/b>/gi;
    $re =~ s/(<\@(\w+?):\w+?\@>)/&Color_Reserved_Word(\%color, $2, $1)/egi;

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

=head2 Longest_Valid_Regexp

Matches the longest valid regexp

=cut

sub Longest_Valid_Regexp
{
    my $re = shift;

    while ((!eval { use warnings FATAL => qw(regexp); qr/^$re/; })
        && ($re ne ''))
    {    # reduce regexp length until it becomes a valid regexp
        $re = substr $re, 0, -1;
    }

    return ($re);
}

=head2 Minimal_Match($log, $re)

=cut

sub Minimal_Match
{
    my ($log, $re) = @_;

    $re = Longest_Valid_Regexp($re);
    while (($log !~ qr/^$re/) && ($re ne ''))
    {
        $re = substr $re, 0, -1;
        $re = Longest_Valid_Regexp($re);
    }

    #$re =~ s/<(\w)/&lt;$1/g;
    #$re =~ s/(\w)>/$1&gt;/g;

    if ($re eq '')
    {
        return ('', $log);
    }
    elsif ($log =~ /^($re)/)
    {
        my $match = $1;
        my $unmatch = substr $log, length $match;

        return ($match, $unmatch);
    }
}

=head2 Reserved_Word_To_Regexp(\%re_types, $type, $field, $str)

Converts Reserved Word expression (<@$type:$field@>) into Regexp

=cut

sub Reserved_Word_To_Regexp
{
    my ($re_types, $type, $field, $str) = @_;

    if (defined $re_types->{$type})
    {
        $str =
            ($field =~ /NULL/i)
            ? $re_types->{$type}
            : '(' . $re_types->{$type} . ')';
    }

    return ($str);
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
    while ((NOT_NULL($tmp))
        && ($tmp =~ /^(.*?)<\@(REGEXP)\(\"(.+?)\"\):(\S+?)\@>(.*)$/i))
    {
        my ($before, $type, $re_value, $field, $after) = ($1, $2, $3, $4, $5);
        my $subs = ($field =~ /NULL/i) ? $re_value : '(' . $re_value . ')';
        $regexp .= (Escape_Characters($before) . $subs);
        $tmp = $after;
    }
    $tmp = $regexp . (NOT_NULL($tmp) ? Escape_Characters($tmp) : '');
    $regexp = '';
    $tmp =~
s/(<\@([^\@]+?):(\S+?)\@>)/&Reserved_Word_To_Regexp(\%re_types, $2, $3, $1)/egi;
    $regexp .= $tmp;
    $regexp =~ s/\s+$//g;

    return ($regexp);
}

=head2 Pattern_To_Regexp_Without_Catching($msg)

Converts message pattern from message '$msg' into Regexp without catching
(same as Pattern_To_Regexp except don't add 'catching' parentheses)

=cut

sub Pattern_To_Regexp_Without_Catching
{
    my $msg = shift;

    my %re_types = Octopussy::Type::Regexps();
    my $regexp   = '';
    my $tmp      = $msg->{pattern};
    while ((NOT_NULL($tmp))
        && ($tmp =~ /^(.*?)<\@(REGEXP)\(\"(.+?)\"\):(\S+?)\@>(.*)$/i))
    {
        my ($before, $type, $re_value, $field, $after) = ($1, $2, $3, $4, $5);
        $regexp .= (Escape_Characters($before) . $re_value);
        $tmp = $after;
    }
    $tmp = $regexp . (NOT_NULL($tmp) ? Escape_Characters($tmp) : '');
    $regexp = '';
    while ($tmp =~ /^(.*?)<\@([^\@]+?):(\S+?)\@>(.*)$/i)
    {
        my ($before, $type, $field, $after) = ($1, $2, $3, $4);
        $regexp .= $before . $re_types{$type};
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
    my $regexp   = Escape_Characters($msg->{pattern});
    $regexp =~ s/<\@([^\@]+?)\@>/\($re_types{$1}\)/gi;
    $regexp =~ s/\s+$//g;

    return ($regexp);
}

=head2 Pattern_Field_Substitution

=cut

sub Pattern_Field_Substitution
{
    my ($regexp, $f, $type, $field_regexp, $field_list, $re_types) = @_;
    my %subs = (
        'NUMBER' => {match => '<\@NUMBER:\S+?\@>', re => '[-+]?\\d+'},
        'STRING' => {match => '<\@STRING:\S+?\@>', re => '.+'},
        'WORD'   => {match => '<\@WORD:\S+?\@>',   re => '\\S+'},   
    );
    my $long_f = $f;
    $f =~ s/Plugin_\S+__//;
    my $function = undef;
    foreach my $fl (ARRAY($field_list))
    {
        if (   ($fl =~ /^(\S+::\S+)\($f\)$/)
            && (Octopussy::Plugin::Function_Source($1) eq 'INPUT'))
        {
            my $perl_fct  = $1;
            my $sql_field = Octopussy::Plugin::SQL_Convert($fl);
            $function = $perl_fct if ($long_f =~ /^$sql_field$/);
        }
    }

    if ($type =~ /^REGEXP/)
    {
        $regexp =~ s/<\@REGEXP\(\"(.+?)\"\):\S+?\@>/\($1\)/i;
    }
    elsif (defined $subs{$type})
    {
        my $substitution = (
            defined $field_regexp
            ? $field_regexp->{$f} || $subs{$type}{re}
            : $subs{$type}{re}
        );
        $regexp =~ s/$subs{$type}{match}/\($substitution\)/i;
    }
    else
    {
        $regexp =~ s/<\@([^\@]+?):(\S+?)\@>/\($re_types->{$1}\)/i;
    }

    return ($regexp, $function);
}

=head2 Pattern_Field_Unmatched_Substitution($regexp, $type, $field_regexp, $re_types)

=cut

sub Pattern_Field_Unmatched_Substitution
{
    my ($regexp, $type, $field_regexp, $re_types) = @_;

    my %subs = (
        'NUMBER' => {
            match => qr/^(.*?)<\@NUMBER:(\S+?)\@>(.*)$/,
            re    => '[-+]?\\d+'
        },
        'STRING' => {
            match => qr/^(.*?)<\@STRING:(\S+?)\@>(.*)$/,
            re    => '.+'
        },
        'WORD' => {
            match => qr/^(.*?)<\@WORD:(\S+?)\@>(.*)$/,
            re    => '\\S+'
        },
    );

    if ($type =~ /^REGEXP/) {
        $regexp =~ s/<\@REGEXP\(\"(.+?)\"\):\S+?\@>/$1/i;
    }
    elsif (defined $subs{$type})
    {
        if ($regexp =~ $subs{$type}{match})
        {
            $regexp = $1
                . (
                defined $field_regexp
                ? $field_regexp->{$2} || $subs{$type}{re}
                : $subs{$type}{re}
                ) . $3;
        }
    }
    else
    {
        $regexp =~ s/<\@([^\@]+?):(\S+?)\@>/$re_types->{$1}/;
    }

    return ($regexp);
}

=head2 Pattern_To_Regexp_Fields($msg, $field_regexp, $ref_fields, $field_list)

=cut

sub Pattern_To_Regexp_Fields
{
    my ($msg, $field_regexp, $ref_fields, $field_list) = @_;
    my (@fields_position, @fields_function) = ((), ());
    my %re_types         = Octopussy::Type::Regexps();
    my $regexp           = Escape_Message($msg->{pattern});
    my $function         = undef;
    my $pos              = 0;
    my %plugin_field_pos = ();

    while ($regexp =~ /<\@(.+?):([^:\s]+?)\@>/i)
    {
        my ($type, $pattern_field) = ($1, $2);
        my $matched = 0;
        my $i       = 0;
        foreach my $f (ARRAY($ref_fields))
        {
            if (   ($pattern_field =~ /^$f$/)
                || ($f =~ /^Plugin_\S+__$pattern_field$/))
            {
                ($regexp, $function) =
                    Pattern_Field_Substitution($regexp, $f, $type,
                    $field_regexp, $field_list, \%re_types);
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
        if (!$matched)
        {
            $regexp = Pattern_Field_Unmatched_Substitution($regexp, $type,
                $field_regexp, \%re_types);
        }
    }
    $regexp =~ s/\s+$//g;

    return ($regexp, \@fields_position);
}

=head2 Fields_Values($msg, $line)

=cut

sub Fields_Values
{
    my ($msg, $line) = @_;

    return () if ((!defined $msg) || (!defined $line));
    my @fields  = ();
    my %field   = ();
    my $pattern = $msg->{pattern};

    while ($pattern =~ /<\@.+?:(\S+?)\@>/)
    {
        push @fields, $1 if ($1 !~ /NULL/i);
        $pattern =~ s/.*?(<\@([^\@]+?)\@>)//;
    }
    my @data = $line =~ /$msg->{re}/;
    my $last_data = scalar(@data) - 1;
    foreach my $i (0 .. $last_data) { $field{$fields[$i]} = $data[$i]; }

    return (%field);
}

=head2 Regexped_Fields($query)

=cut

sub Regexped_Fields
{
    my $query        = shift;
    my %field_regexp = ();
    if ($query =~ /WHERE (.+)/)
    {
        my $where = $1;
        return (undef)
            if (($where =~ /.+ AND .+/i) || ($where =~ /.+ OR .+/i));
        while ($where =~ /(.*?)(\w+) LIKE '(.+?)'(.*)/i)
        {
            $where = "$1 $4";
            my $field = $2;
            my $like  = $3;
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

=head2 Parse_List($services, $loglevel, $taxonomy, $table, $fields, $fields_regexp, $fields_list)

=cut

sub Parse_List
{
    my ($services, $loglevel, $taxonomy, $table, $fields, $fields_regexp,
        $fields_list)
        = @_;

    my @servs = (
        (defined $services) && (@{$services}[0] ne '-ANY-')
        ? @{$services}
        : Octopussy::Service::List()
    );
    my %log_level = Octopussy::Loglevel::Levels();
    my $level     = (
        (NOT_NULL($loglevel) && ($loglevel ne '-ANY-'))
        ? $log_level{$loglevel}
        : 0
    );
    my $qr_taxo = (
        (NOT_NULL($taxonomy) && ($taxonomy ne '-ANY-'))
        ? qr/^$taxonomy(\..+)?/
        : qr/.+/
    );
    my @msg_to_parse = ();

    foreach my $s (@servs)
    {
        my @messages = Octopussy::Service::Messages($s);
        foreach my $m (@messages)
        {
            if (   ((!defined $table) || ($m->{table} eq $table))
                && ($log_level{$m->{loglevel}} >= $level)
                && ($m->{taxonomy} =~ $qr_taxo))
            {
                my ($regexp, $fields_position) =
                    Pattern_To_Regexp_Fields($m, $fields_regexp, $fields,
                    $fields_list);
                if (defined $regexp)
                {
                    push @msg_to_parse,
                        {re => qr/$regexp/, positions => $fields_position};
                }
            }
        }
    }

    return (@msg_to_parse);
}

=head2 Alerts($device, $service, $message, \@dev_alerts)

=cut

sub Alerts
{
    my ($device, $service, $message, $dev_alerts) = @_;
    my @alerts    = ();
    my %log_level = Octopussy::Loglevel::Levels();

    foreach my $ac (ARRAY($dev_alerts))
    {
        if ($ac->{type} =~ /Dynamic/i)
        {
            my $ac_level = (
                (NOT_NULL($ac->{loglevel}) && ($ac->{loglevel} ne '-ANY-'))
                ? $log_level{$ac->{loglevel}}
                : 0
            );

            foreach my $s (ARRAY($ac->{service}))
            {
                if (
                    (($s eq $service) || ($s eq '-ANY-'))
                    && (   (!defined $ac->{taxonomy})
                        || ($ac->{taxonomy} eq '-ANY-')
                        || ($message->{taxonomy} =~ /^$ac->{taxonomy}.*/))
                    && ($log_level{$message->{loglevel}} >= $ac_level)
                   )
                {
                    push @alerts, {
                        name               => $ac->{name},
                        level              => $ac->{level},
                        thresold_time      => $ac->{thresold_time},
                        thresold_duration  => $ac->{thresold_duration},
                        minimum_emit_delay => $ac->{minimum_emit_delay},
                        regexp_incl        => $ac->{regexp_include},
                        regexp_excl        => $ac->{regexp_exclude},
                        timeperiod         => $ac->{timeperiod},
                        action             => $ac->{action},
                        msgsubject         => $ac->{msgsubject},
                        msgbody            => $ac->{msgbody},
                        nagios_host    => $ac->{nagios_host},    # only for NSCA
                        nagios_service => $ac->{nagios_service}, # only for NSCA
                        action_host => $ac->{action_host}, # for Nagios & Zabbix
                        action_service =>
                            $ac->{action_service},         # for Nagios & Zabbix
                        action_body => $ac->{action_body}, # for Nagios & Zabbix
                        contacts    => $ac->{contact},
                    };
                }
            }
        }
        elsif ($ac->{type} =~ /Static/i)
        {
            foreach my $m (ARRAY($ac->{message}))
            {
                if ($message->{msg_id} =~ /^$m->{mid}$/)
                {
                    my @fields = ();
                    foreach my $f (ARRAY($m->{field}))
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
                        nagios_host    => $ac->{nagios_host},    # only for NSCA
                        nagios_service => $ac->{nagios_service}, # only for NSCA
                        action_host => $ac->{action_host}, # for Nagios & Zabbix
                        action_service =>
                            $ac->{action_service},         # for Nagios & Zabbix
                        action_body => $ac->{action_body}, # for Nagios & Zabbix
                        contacts    => $ac->{contact},
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
    my ($line, $types) = @_;

    use bytes;

    $line =~ s/</&lt;/g;
    $line =~ s/>/&gt;/g;

    $line =~
s/^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{6}.\d{2}:\d{2} \S+ /<\@DATE_TIME_ISO\@> <\@WORD\@> /mgi;
    foreach my $t (ARRAY($types))
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
    my ($re, $types) = @_;

    foreach my $t (ARRAY($types))
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
    my ($timestamp, $line, $types) = @_;
    my $sample = $line;
    $line =~ s/\\/\\\\/g;
    my $pattern = $line = Wizard_Msg_Modified($line, $types);
    $line =~ s/\[/\\\[/g;
    $line =~ s/\]/\\\]/g;
    $line =~ s/\(/\\\(/g;
    $line =~ s/\)/\\\)/g;
    $line =~ s/\//\\\//g;
    my $re = Wizard_Msg_Regexp($line, $types);

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

=head2 Wizard_File($f, $timestamp, $nb_max, $messages, $types)

=cut

sub Wizard_File
{
    my ($f, $timestamp, $nb_max, $messages, $types) = @_;

    if ((-f $f) && (defined open my $FILE, '-|', "zcat $f"))
    {
        while (my $line = <$FILE>)
        {
            chomp $line;
            my $match = 0;
            foreach my $m (grep { $line =~ $_->{re} } @{$messages})
            {
                $m->{nb} = $m->{nb} + 1;
                $match = 1;
                if ($m->{nb} > $WIZARD_MAX_SAME_MSG)
                {
                    close $FILE;
                    return ($WIZARD_MAX_SAME_MSG);
                }
                last if (scalar(@{$messages}) >= $nb_max);
            }
            push @{$messages}, Wizard_Add_Message($timestamp, $line, $types)
                if (!$match);
            last if (scalar(@{$messages}) >= $nb_max);
        }
        close $FILE;
    }
    else
    {
        my ($pack, $file_pack, $line, $sub) = caller 0;
        AAT::Syslog::Message('Octopussy_Message', 'UNABLE_OPEN_FILE_IN', $f,
            $sub);
    }

    return (scalar @{$messages});
}

=head2 Wizard($device, $timestamp_start)

=cut

sub Wizard
{
    my ($device, $timestamp_start) = @_;
    $timestamp_start =
        ((NULL($timestamp_start) || $timestamp_start !~ /^\d{12}$/)
        ? '0' x 12
        : $timestamp_start);
    my @types    = Octopussy::Type::Configurations();
    my @messages = ();
    my @files    = Octopussy::Logs::Unknown_Files($device);
    my $nb_max   = Octopussy::Parameter('wizard_max_msgs');

    foreach my $f (sort @files)
    {
        chomp $f;
        if ($f =~ /\/(\d{4})\/(\d{2})\/(\d{2})\/msg_(\d{2})h(\d{2})/)
        {
            my $timestamp = "$1$2$3$4$5";
            Wizard_File($f, $timestamp, $nb_max, \@messages, \@types)
                if ($timestamp >= $timestamp_start);
        }
        last if (scalar(@messages) >= $nb_max);
    }

    return (@messages);
}

1;

=head1 AUTHOR

Sebastien Thebert <octopussy@onetool.pm>

=cut

#!/usr/bin/perl
# $HeadURL$
# $Revision$
# $Date$
# $Author$

=head1 NAME

Octopussy_Message.t - Octopussy Source Code Checker for Octopussy::Message

=cut

use strict;
use warnings;
use Readonly;

use Test::More tests => 6;

use Octopussy::Message;

Readonly my $SERVICE  => 'Octopussy';
Readonly my $MSGID    => 'Octopussy:user_logged_in';

Readonly my $RE     => '(\w{3} \s?\d{1,2} \d{2}:\d{2}:\d{2}) (\S+) octo_(\S+): (User .+ succesfully logged in.)';
Readonly my $RE2    => '\w{3} \s?\d{1,2} \d{2}:\d{2}:\d{2} \S+ octo_\S+: User .+ succesfully logged in.';

Readonly my $SAMPLE => 'Feb  1 10:10:00 localhost octo_WebUI: User admin succesfully logged in.';
Readonly my $SAMPLE_MSG => 'User admin succesfully logged in.';

=head2 msg
<message loglevel="Notice"
           msg_id="Octopussy:user_logged_in"
           pattern="&lt;@DATE_TIME_SYSLOG:datetime@&gt; &lt;@WORD:device@&gt; oc
to_&lt;@WORD:module@&gt;: &lt;@REGEXP(&quot;User .+ succesfully logged in.&quot;
):msg@&gt;"
           rank="015"
           table="Message"
           taxonomy="Auth.Success" />
=cut

my $mconf = Octopussy::Message::Configuration($SERVICE, $MSGID);
ok(AAT::NOT_NULL($mconf) && $mconf->{taxonomy} eq 'Auth.Success', 
  'Octopussy::Message::Configuration()');

my @fields = Octopussy::Message::Fields($SERVICE, $MSGID);
ok(scalar @fields == 4, 'Octopussy::Message::Fields()');

my $table = Octopussy::Message::Table($SERVICE, $MSGID);
ok($table eq 'Message', 'Octopussy::Message::Table()');

#my $sql = Octopussy::Message::Pattern_To_SQL($mconf, '123456', ());
#print "$sql\n";
#$sql = Octopussy::Message::Pattern_To_SQL($mconf, '123456', ('datetime', 'msg'));
#print "$sql\n";

my $re = Octopussy::Message::Pattern_To_Regexp($mconf);
ok($re eq $RE, 'Octopussy::Message::Pattern_To_Regexp()');
$mconf->{re} = $re;

my $re2 = Octopussy::Message::Pattern_To_Regexp_Without_Catching($mconf);
ok($re2 eq $RE2, 'Octopussy::Message::Pattern_To_Regexp_Without_Catching()');

my %field = Octopussy::Message::Fields_Values($mconf, $SAMPLE);
ok(scalar(keys %field) == 4 && $field{msg} eq $SAMPLE_MSG, 
  'Octopussy::Message::Fields_Values()');

1;

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut

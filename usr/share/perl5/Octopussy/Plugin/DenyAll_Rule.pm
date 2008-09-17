=head1 NAME

Octopussy::Plugin::DenyAll_Rule - Octopussy Plugin DenyAll_Rule

=cut
package Octopussy::Plugin::DenyAll_Rule;

use strict;

use Octopussy;

my $ACCESS_CONF = "/usr/share/perl5/Octopussy/Plugin/DenyAll_BAM_access.conf";
my $ACCESS_DENY = "/usr/share/perl5/Octopussy/Plugin/DenyAll_BAM_access.deny";

my $HEADER = "EAccessHdrRule deny=";
my $URI = "EAccessUriRule deny=";

my %rule = ();

=head1 FUNCTIONS

=head2 Init()

=cut
sub Init()
{
	%rule = ();
	my $last_comment = "";
  my $last_nessus_id = "";
	my $hdr_count = 1;
	my $uri_count = 1;
  open(FILE, "cat $ACCESS_CONF $ACCESS_DENY |");
  while (<FILE>)
  {
		$last_comment = $1    if ($_ =~ /^# \d{5}: (.+)$/);
  	$last_nessus_id = $1  if ($_ =~ /^# CVE: .+\/ Nessus: (\d+).*$/);				
		if ($_ =~ /^$HEADER.+?"(.+)"$/)
		{
			$rule{"H" . $hdr_count} = { regexp => $1, comment => $last_comment,
				nessus_id => $last_nessus_id };
			#print "H" . $hdr_count . "regexp => $1\n";
			$hdr_count++;
		}
		if ($_ =~ /^$URI.+?"(.+)"$/)
    {
      $rule{"U" . $uri_count} = { regexp => $1, comment => $last_comment,
        nessus_id => $last_nessus_id };
			#print "U" . $uri_count . "regexp => $1\n";
      $uri_count++;
    }
  }
  close(FILE);
}

=head2 Info($id)

=cut
sub Info($)
{
	my $id = shift;

	return ($rule{$id}{comment} || "N/A");
}

=head2 Nessus_Id($id)

=cut
sub Nessus_Id($)
{
  my $id = shift;
	my $url = "<a href=\"http://cgi.nessus.org/plugins/dump.php3?id="
		. $rule{$id}{nessus_id} . "\">$rule{$id}{nessus_id}</a>";

  return (defined $rule{$id}{nessus_id} ? $url : "N/A");
}

=head2 Regexp($id)

=cut
sub Regexp($)
{
	my $id = shift;

  return ($rule{$id}{regexp} || "N/A");
}

1;

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut

=head1 NAME

Octopussy::Statistic_Report - Octopussy Statistic Report module

=cut

package Octopussy::Statistic_Report;

use strict;
use Octopussy;

use constant STAT_REPORT_DIR => "statistic_reports";

my $stat_reports_dir = undef;
my %filenames;

=head1 FUNCTIONS

=head2 New($conf)

Create a new statistic report

=cut

sub New($)
{
	my $conf = shift;

	$stat_reports_dir ||= Octopussy::Directory(STAT_REPORT_DIR);
	AAT::XML::Write("$stat_reports_dir/$conf->{name}.xml",
		$conf, "octopussy_statistic_report");
}

=head2 Remove($statistic_report)

Remove a statistic report

=cut

sub Remove($)
{
  my $statistic_report = shift;

	$filenames{$statistic_report} = undef;
	unlink(Filename($statistic_report));
}

=head2 Modify($old_report, $new_conf)

Modify the configuration for the statistic_report '$old_report'

=cut

sub Modify($$)
{
	my ($old_report, $new_conf) = @_;

	Remove($old_report);
	New($new_conf);
}

=head2 List()

Get List of Statistic Report

=cut

sub List()
{
  $stat_reports_dir ||= Octopussy::Directory(STAT_REPORT_DIR);

	return (AAT::XML::Name_List($stat_reports_dir));
}

=head2 Filename($statistic_report_name)

Get the XML filename for the statistic report '$statistic_report_name'

=cut

sub Filename($)
{
	my $statistic_report_name = shift;

	return ($filenames{$statistic_report_name})   
		if (defined $filenames{$statistic_report_name});
	$stat_reports_dir ||= Octopussy::Directory(STAT_REPORT_DIR);
	$filenames{$statistic_report_name} = 
		AAT::FS::Directory_Files($stat_reports_dir, $statistic_report_name);

	return ($filenames{$statistic_report_name});
}

=head2 Configuration($statistic_report)

Get the configuration for the accounting '$statistic_report'

=cut
 
sub Configuration($)
{
	my $statistic_report = shift;

	my $conf = AAT::XML::Read(Filename($statistic_report));

 	return ($conf);
}

=head2 Configurations($sort)

=cut

sub Configurations
{
  my $sort = shift || "name";
  my (@configurations, @sorted_configurations) = ((), ());
  my @stat_reports = List();
  my %field;

  foreach my $sr (@stat_reports)
  {
    my $conf = Configuration($sr);
    $field{$conf->{$sort}} = 1;
    push(@configurations, $conf);
  }
  foreach my $f (sort keys %field)
  {
    foreach my $c (@configurations)
      { push(@sorted_configurations, $c)    if ($c->{$sort} eq $f); }
  }

  return (@sorted_configurations);
}

=head2 Messages($statistic_report, $services)

=cut

sub Messages($$)
{
	my ($statistic_report, $services) = @_;
	my %re_types = Octopussy::Type::Regexps();
	my @result = ();
	
	my $conf = Configuration($statistic_report);
	my @filters = AAT::ARRAY($conf->{filter});
	my @messages = ();
	foreach my $s (AAT::ARRAY($services))
		{ push(@messages, Octopussy::Service::Messages($s)); }
	foreach my $m (@messages)
	{
		if ($m->{table} =~ /^$conf->{table}$/)
		{
		my $regexp = Octopussy::Message::Escape_Characters($m->{pattern});
		while ($regexp =~ /<\@(.+?):(\S+?)\@>/i)
  	{
    	my ($type, $pattern_field) = ($1, $2);
    	my $matched = 0;
    	foreach my $f (@filters)
    	{
      	if ($pattern_field =~ /^$f->{field}$/)
      	{
        	$regexp =~ s/<\@.+?:\S+\@>/$f->{regexp}/i;
        	$matched = 1;
      	}
    	}
			if ($pattern_field =~ /^$conf->{key}$/)
			{
				if ($type =~ /^REGEXP$/)
          { $regexp =~ s/<\@REGEXP\\\(\\\"(.+?)\\\"\\\):\S+?\@>/\($1\)/i; }
        elsif ($type =~ /^NUMBER$/)
          { $regexp =~ s/<\@NUMBER:\S+?\@>/\([-+]?\\d+\)/i; }
        elsif ($type =~ /^WORD$/)
          { $regexp =~ s/<\@WORD:\S+?\@>/\(\\S+\)/i; }
        elsif ($type =~ /^STRING$/)
          { $regexp =~ s/<\@STRING:\S+?\@>/\(.+\)/i; }
        else
          { $regexp =~ s/<\@(\S+?):\S+?\@>/\($re_types{$1}\)/i; }	
				$matched = 1;
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
		push(@result, qr/^$regexp\s*[^\t\n\r\f -~]?$/);
		}
	}

	return (@result);
}

1;

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut

=head1 NAME

Octopussy::Data_Report - Octopussy Data_Report module

=cut

package Octopussy::Data_Report;

use strict;
use Octopussy;

use constant REPORT_DATA_DIR	=> "data_reports";

my $reports_dir = undef;

=head1 FUNCTIONS

=head2 Type_List()

=cut

sub Type_List()
{
	$reports_dir ||= Octopussy::Directory(REPORT_DATA_DIR);
	
	opendir(DIR, $reports_dir);
  my @dirs = grep !/^\./, readdir(DIR);
  closedir(DIR);

	return (@dirs);
}

=head2 List()

Get List of Data Reports

=cut
 
sub List($)
{
	my $report = shift;
 
	$reports_dir ||= Octopussy::Directory(REPORT_DATA_DIR);
	my $dir = $reports_dir . $report;
	opendir(DIR, $dir);
	my @dirs = grep !/^\./, readdir(DIR);
	closedir(DIR);

	my %reports = ();
	foreach my $d (@dirs)
	{ push(@{$reports{$1}}, $2)	if ($d =~ /^(.+)\.(\w+)$/); }
	
	return (\%reports);
}

=head2 Remove($report, $filename)

Removes Report '$report' with Filename '$filename'

=cut

sub Remove($$)
{
	my ($report, $filename) = @_;

	$reports_dir ||= Octopussy::Directory(REPORT_DATA_DIR);
	`rm -f "$reports_dir$report/$filename".*`;
}

=head2 Remove_Month($report, $year, $month)

Removes All Reports '$report' in Month '$year/month'

=cut

sub Remove_Month($$$)
{
	my ($report, $year, $month) = @_;
	
	$reports_dir ||= Octopussy::Directory(REPORT_DATA_DIR);
	`rm -f "$reports_dir$report/$report-$year$month"*`;
}

1;

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut

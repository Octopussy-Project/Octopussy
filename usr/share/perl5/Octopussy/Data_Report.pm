=head1 NAME

Octopussy::Data_Report - Octopussy Data_Report module

=cut

package Octopussy::Data_Report;

use strict;
use warnings;

use File::Path qw(rmtree);
use Readonly;

use Octopussy::FS;

Readonly my $DIR_REPORT_DATA => 'data_reports';

my $dir_reports = undef;

=head1 FUNCTIONS

=head2 Type_List()

=cut

sub Type_List
{
  $dir_reports ||= Octopussy::FS::Directory($DIR_REPORT_DATA);
	my @dirs = ();
	
  if (defined opendir my $DH, $dir_reports)
  {
  	@dirs = grep { !/^\./ } readdir $DH;
  	closedir $DH;
  }

  return (@dirs);
}

=head2 List($report)

Returns List of Data Reports

=cut

sub List
{
  my $report = shift;

  $dir_reports ||= Octopussy::FS::Directory($DIR_REPORT_DATA);
  my $dir = $dir_reports . $report;
  opendir DIR, $dir;
  my @dirs = grep { !/^\./ } readdir DIR;
  closedir DIR;

  my %reports = ();
  foreach my $d (@dirs)
  {
    push @{$reports{$1}}, $2
      if ($d =~ /^(.+)\.(\w+)$/);
  }

  return (\%reports);
}

=head2 Remove($report, $filename)

Removes Report '$report' with Filename '$filename'

=cut

sub Remove
{
  my ($report, $filename) = @_;

  $dir_reports ||= Octopussy::FS::Directory($DIR_REPORT_DATA);
  system "rm -f \"$dir_reports$report/$filename\".*";

  return ("$dir_reports$report/${filename}.*");
}

=head2 Remove_All($report)

Removes All Reports '$report' 

=cut

sub Remove_All
{
  my $report = shift;

  $dir_reports ||= Octopussy::FS::Directory($DIR_REPORT_DATA);
  File::Path::rmtree("$dir_reports$report/");

  return ("$dir_reports$report/");
}

=head2 Remove_Month($report, $year, $month)

Removes All Reports '$report' in Month '$year/month'

=cut

sub Remove_Month
{
  my ($report, $year, $month) = @_;

  $dir_reports ||= Octopussy::FS::Directory($DIR_REPORT_DATA);
  system "rm -f \"$dir_reports$report/$report-$year$month\"*";

  return ("$dir_reports$report/$report-$year$month*");
}

1;

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut

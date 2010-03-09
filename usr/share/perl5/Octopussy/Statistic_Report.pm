# $HeadURL$
# $Revision$
# $Date$
# $Author$

=head1 NAME

Octopussy::Statistic_Report - Octopussy Statistic Report module

=cut

package Octopussy::Statistic_Report;

use strict;
use warnings;
use Readonly;

use AAT;
use AAT::FS;
use AAT::XML;
use Octopussy;
use Octopussy::Message;
use Octopussy::Service;
use Octopussy::Type;

Readonly my $DIR_STAT_REPORT => 'statistic_reports';
Readonly my $XML_ROOT        => 'octopussy_statistic_report';

my $dir_stat_reports = undef;
my %filename;

=head1 FUNCTIONS

=head2 New($conf)

Create a new statistic report

=cut

sub New
{
  my $conf = shift;

  $dir_stat_reports ||= Octopussy::Directory($DIR_STAT_REPORT);
  AAT::XML::Write("$dir_stat_reports/$conf->{name}.xml", $conf, $XML_ROOT);

  return ($conf->{name});
}

=head2 Remove($statistic_report)

Remove a statistic report

=cut

sub Remove
{
  my $statistic_report = shift;

  my $nb = unlink Filename($statistic_report);
  $filename{$statistic_report} = undef;

  return ($nb);
}

=head2 Modify($old_report, $conf_new)

Modify the configuration for the statistic_report '$old_report'

=cut

sub Modify
{
  my ($old_report, $conf_new) = @_;

  Remove($old_report);
  New($conf_new);

  return (undef);
}

=head2 List()

Get List of Statistic Report

=cut

sub List
{
  $dir_stat_reports ||= Octopussy::Directory($DIR_STAT_REPORT);

  return (AAT::XML::Name_List($dir_stat_reports));
}

=head2 Filename($statistic_report_name)

Get the XML filename for the statistic report '$statistic_report_name'

=cut

sub Filename
{
  my $statistic_report_name = shift;

  return ($filename{$statistic_report_name})
    if (defined $filename{$statistic_report_name});
  $dir_stat_reports ||= Octopussy::Directory($DIR_STAT_REPORT);
  $filename{$statistic_report_name} =
    AAT::FS::Directory_Files($dir_stat_reports, $statistic_report_name);

  return ($filename{$statistic_report_name});
}

=head2 Configuration($statistic_report)

Get the configuration for the accounting '$statistic_report'

=cut

sub Configuration
{
  my $statistic_report = shift;

  my $conf = AAT::XML::Read(Filename($statistic_report));

  return ($conf);
}

=head2 Configurations($sort)

=cut

sub Configurations
{
  my $sort = shift || 'name';
  my (@configurations, @sorted_configurations) = ((), ());
  my @stat_reports = List();

  foreach my $sr (@stat_reports)
  {
    my $conf = Configuration($sr);
    push @configurations, $conf;
  }
  foreach my $c (sort { $a->{$sort} cmp $b->{$sort} } @configurations)
  {
    push @sorted_configurations, $c;
  }

  return (@sorted_configurations);
}

=head2 Messages($statistic_report, $services)

=cut

sub Messages
{
  my ($statistic_report, $services) = @_;
  my %re_types = Octopussy::Type::Regexps();
  my @result   = ();
  my %subs     = (
    'NUMBER' => {match => '<\@NUMBER:\S+?\@>', re => '[-+]?\\d+'},  ## no critic
    'STRING' => {match => '<\@STRING:\S+?\@>', re => '.+'},         ## no critic
    'WORD'   => {match => '<\@WORD:\S+?\@>',   re => '\\S+'},       ## no critic
  );

  my $conf     = Configuration($statistic_report);
  my @filters  = AAT::ARRAY($conf->{filter});
  my @messages = ();
  foreach my $s (AAT::ARRAY($services))
  {
    push @messages, Octopussy::Service::Messages($s);
  }
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
          if ($type eq 'REGEXP')
          {
            $regexp =~ s/<\@REGEXP\\\(\\\"(.+?)\\\"\\\):\S+?\@>/\($1\)/i;
          }
          elsif (defined $subs{$type})
          {
            $regexp =~ s/$subs{$type}{match}/\($subs{$type}{re}\)/i;
          }
          else { $regexp =~ s/<\@(\S+?):\S+?\@>/\($re_types{$1}\)/i; }
          $matched = 1;
        }
        if (!$matched)
        {
          if ($type eq 'REGEXP')
          {
            $regexp =~ s/<\@REGEXP\\\(\\\"(.+?)\\\"\\\):\S+?\@>/$1/i;
          }
          elsif (defined $subs{$type})
          {
            $regexp =~ s/$subs{$type}{match}/$subs{$type}{re}/i;
          }
          else { $regexp =~ s/<\@(\S+?):\S+?\@>/$re_types{$1}/i; }
        }
      }
      push @result, qr/^$regexp\s*[^\t\n\r\f -~]?$/;
    }
  }

  return (@result);
}

1;

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut

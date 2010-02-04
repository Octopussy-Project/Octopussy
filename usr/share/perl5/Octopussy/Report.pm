# $HeadURL$
# $Revision$
# $Date$
# $Author$

=head1 NAME

Octopussy::Report - Octopussy Report module

=cut

package Octopussy::Report;

use strict;
use warnings;
use Readonly;

use POSIX qw(strftime);
use Proc::ProcessTable;

use AAT;
use AAT::FS;
use AAT::Translation;
use AAT::XML;
use Octopussy;
use Octopussy::Report::CSV;
use Octopussy::Report::HTML;
use Octopussy::Report::PDF;
use Octopussy::Report::XML;

Readonly my $DIR_REPORT   => 'reports';
Readonly my $REPORTER_BIN => 'octo_reporter';
Readonly my $XML_ROOT     => 'octopussy_report';
Readonly my $MINUTE       => 60;

my $dir_reports = undef;
my %filename;

=head1 FUNCTIONS

=head2 New($conf)

Create a new Report

=cut

sub New
{
  my $conf = shift;

  $dir_reports ||= Octopussy::Directory($DIR_REPORT);
  $conf->{query} =~ s/\r\n//;
  $conf->{version} = Octopussy::Timestamp_Version(undef);
  AAT::XML::Write("$dir_reports/$conf->{name}.xml", $conf, $XML_ROOT);

  return ($conf->{name});
}

=head2 Remove($report)

Removes a Report '$report'

=cut

sub Remove
{
  my $report = shift;

  my $nb = unlink Filename($report);
  $filename{$report} = undef;
  Octopussy::Data_Report::Remove_All($report);

  return ($nb);
}

=head2 Modify($old_report, $conf_new)

Modifies the configuration for the Report '$old_report'

=cut

sub Modify
{
  my ($old_report, $conf_new) = @_;

  $conf_new->{query} =~ s/\r\n//;
  unlink Filename($old_report);
  $filename{$old_report} = undef;
  New($conf_new);

  return (undef);
}

=head2 List($category, $restriction_list)

Returns list of Reports with category '$category' (if specified) 
 and restricted to list '$restriction_list' (if specified)

=cut 

sub List
{
  my ($category, $report_restriction_list) = @_;
  my @res_list = AAT::ARRAY($report_restriction_list);
  $dir_reports ||= Octopussy::Directory($DIR_REPORT);
  my @files = AAT::FS::Directory_Files($dir_reports, qr/.+\.xml$/);
  my @reports = ();
  foreach my $f (@files)
  {
    my $in_restriction = (scalar(@res_list) > 0 ? 0 : 1);
    my $conf = AAT::XML::Read("$dir_reports/$f");
    foreach my $res (@res_list)
    {
      $in_restriction = 1 if ($conf->{name} eq $res);
    }
    push @reports, $conf->{name}
      if (
      (!defined $category)
      || ( (defined $conf->{category})
        && ($conf->{category} eq $category)
        && $in_restriction)
      );
  }

  return (sort @reports);
}

=head2 Filename($report_name)

Get the XML filename for the report '$report_name'

=cut 

sub Filename
{
  my $report_name = shift;

  return ($filename{$report_name}) if (defined $filename{$report_name});
  $dir_reports ||= Octopussy::Directory($DIR_REPORT);
  $filename{$report_name} = AAT::XML::Filename($dir_reports, $report_name);

  return ($filename{$report_name});
}

=head2 Configuration($report)

Get the configuration for the report '$report'

=cut 

sub Configuration
{
  my $report = shift;

  my $conf = AAT::XML::Read(Filename($report));

  return ($conf);
}

=head2 Configurations($sort, $category)

Get the configuration for all reports

=cut

sub Configurations
{
  my ($sort, $category) = @_;
  my (@configurations, @sorted_configurations) = ((), ());
  my @reports = List(undef, undef);
  my %field;

  foreach my $r (@reports)
  {
    my $conf = Configuration($r);
    $field{$conf->{$sort}} = 1;
    push @configurations, $conf
      if ((!defined $category)
      || ((defined $conf->{category}) && ($conf->{category} eq $category))
      || (($category eq 'various') && (!defined $conf->{category})));
  }
  foreach my $f (sort keys %field)
  {
    push @sorted_configurations, grep { $_->{$sort} eq $f } @configurations;
  }

  return (@sorted_configurations);
}

=head2 Categories(@report_restriction_list)

Returns Reports Categories

=cut

sub Categories
{
  my @report_restriction_list = @_;
  my %category                = ();
  my @confs      = Octopussy::Report::Configurations('name', undef);
  my @categories = ();

  if (@report_restriction_list)
  {
    foreach my $c (@confs)
    {
      foreach my $res (@report_restriction_list)
      {
        if ($c->{name} eq $res)
        {
          my $cat = (defined $c->{category} ? $c->{category} : 'various');
          $category{$cat} = (defined $category{$cat} ? $category{$cat} + 1 : 1);
        }
      }
    }
  }
  else
  {
    foreach my $c (@confs)
    {
      my $cat = (defined $c->{category} ? $c->{category} : 'various');
      $category{$cat} = (defined $category{$cat} ? $category{$cat} + 1 : 1);
    }
  }
  foreach my $c (sort keys %category)
  {
    push @categories, {category => $c, nb => $category{$c}};
  }

  return (@categories);
}

=head2 Request($table, $query)

Data Request with query '$query' from table '$table'

=cut

sub Table_Creation
{
  my ($table, $query) = @_;
  my %hash_fields = ();
  my @fields      = ();
  my @indexes     = ();

  if ( ($query =~ /SELECT .+ FROM .+ GROUP BY (.+) ORDER BY/i)
    || ($query =~ /SELECT .+ FROM .+ GROUP BY (.+)/))
  {
    @indexes = split /, /, $1;
  }

  if ( ($query =~ /SELECT (.+) FROM .+ WHERE (.+) GROUP BY/i)
    || ($query =~ /SELECT (.+) FROM .+ WHERE (.+)/i)
    || ($query =~ /SELECT (.+) FROM .+/i))
  {
    my @data = split /, /, $1;    #"$1, $2");
    foreach my $f (@data)
    {
      $f =~ s/^\s*\(?UNIX_TIMESTAMP\(//gi;
      $f =~ s/^\s*DATE_FORMAT\((\S+),'(.+)?'\)/$1/gi;
      $f =~ s/\S+ AS (Plugin_\S+__\S+)$/$1/i;   # for fields modified by plugins
      $f =~ s/ AS .+$//i;
      $f =~ s/^\s*\(?COUNT\(//gi;
      $f =~ s/^\s*\(?DISTINCT\(//gi;
      $f =~ s/^\s*\(?SUM\(//gi;
      $f =~ s/^\s*\(?AVG\(//gi;
      $f =~ s/^\s*\(?MIN\(//gi;
      $f =~ s/^\s*\(?MAX\(//gi;
      $f =~ s/[\(,\)]//gi;
      $f =~ s/^\s*//i;
      $f =~ s/\s*$//i;
      $f =~ s/\S+\.(\S+)/$1/gi;
      $hash_fields{$f} = 1;
    }
  }
  @fields = keys %hash_fields;
  Octopussy::DB::Table_Creation($table . "_$$", \@fields, \@indexes);

  return (@fields);
}

=head2 Generate($rc, $begin, $end, $outputfile, $devices, $services, 
	$data, $conf_mail, $conf_ftp, $conf_scp, $stats, $lang)

=cut

sub Generate
{
  my (
    $rc,   $begin,     $end,      $outputfile, $devices, $services,
    $data, $conf_mail, $conf_ftp, $conf_scp,   $stats,   $lang
  ) = @_;
  my $type = $rc->{graph_type};

  if ($type eq 'array')
  {
    my $dir = $outputfile;
    $dir =~ s/(.+)\/.+/$1/;
    Octopussy::Create_Directory($dir);
    Octopussy::Plugin::Init({lang => $lang}, split /\s*,\s*/, $rc->{columns});
    Octopussy::Report::HTML::Generate($outputfile, $rc->{name}, $begin, $end,
      $devices, $services, $data, $rc->{columns}, $rc->{columns_name}, $stats,
      $lang);
    my $file_xml = Octopussy::File_Ext($outputfile, 'xml');
    Octopussy::Report::XML::Generate($file_xml, $rc->{name}, $begin, $end,
      $devices, $services, $data, $rc->{columns}, $rc->{columns_name}, $stats,
      $lang);
    Octopussy::Chown($file_xml);
    my $file_csv = Octopussy::File_Ext($outputfile, 'csv');
    Octopussy::Report::CSV::Generate($file_csv, $data, $rc->{columns},
      $rc->{columns_name});
    Octopussy::Chown($file_csv);
    Octopussy::Report::PDF::Generate_From_HTML($outputfile);
  }
  elsif ($type =~ /^rrd_/)
  {
    Octopussy::RRDTool::Report_Graph($rc, $begin, $end, $outputfile, $data,
      $stats, $lang);
  }
  elsif ($type =~ /^ofc_.+/)
  {
    my $file_json = Octopussy::File_Ext($outputfile, 'json');
    my %ofc_graph = (
      'ofc_area_hollow'  => \&Octopussy::OFC::Area_Hollow,
      'ofc_bar_3d'       => \&Octopussy::OFC::Bar_3D,
      'ofc_bar_cylinder' => \&Octopussy::OFC::Bar_Cylinder,
      'ofc_bar_glass'    => \&Octopussy::OFC::Bar_Glass,
      'ofc_bar_sketch'   => \&Octopussy::OFC::Bar_Sketch,
      'ofc_hbar'         => \&Octopussy::OFC::Horizontal_Bar,
      'ofc_pie'          => \&Octopussy::OFC::Pie,
    );

    if (defined $ofc_graph{$type})
    {
      $ofc_graph{$type}->($rc, $data, $file_json);
    }
  }
  Octopussy::Chown($outputfile);
  my $file_info = Octopussy::File_Ext($outputfile, 'info');
  File_Info($file_info, $begin, $end, $devices, $services, $stats);
  Octopussy::Chown($file_info);
  Export($outputfile, $conf_mail, $conf_ftp, $conf_scp);

  return ($outputfile);
}

=head2 CmdLine_Export_Options($conf_mail, $conf_ftp, $conf_scp)

Generates Command Line Export Options (mail/ftp/scp) 

=cut

sub CmdLine_Export_Options
{
  my ($conf_mail, $conf_ftp, $conf_scp) = @_;

  my $options = (
    AAT::NOT_NULL($conf_mail->{recipients})
    ? " --mail_recipients \"$conf_mail->{recipients}\""
    : ''
    )
    . (
    AAT::NOT_NULL($conf_mail->{subject})
    ? " --mail_subject \"$conf_mail->{subject}\""
    : ''
    )
    . (
    AAT::NOT_NULL($conf_ftp->{host})
    ? " --ftp_host \"$conf_ftp->{host}\" --ftp_dir \"$conf_ftp->{dir}\""
      . " --ftp_user \"$conf_ftp->{user}\" --ftp_pwd \"$conf_ftp->{pwd}\""
    : ''
    )
    . (
    AAT::NOT_NULL($conf_scp->{host})
    ? " --scp_host \"$conf_scp->{host}\" --scp_dir \"$conf_scp->{dir}\""
      . " --scp_user \"$conf_scp->{user}\""
    : ''
    );

  return ($options);
}

=head2 CmdLine($device, $service, $loglevel, $taxonomy, $report, 
	$start, $finish, $pid_param, $conf_mail, $conf_ftp, $conf_scp, $lang)

Generates Command Line and launch octo_reporter

=cut

sub CmdLine
{
  my (
    $device, $service,   $loglevel,  $taxonomy, $report,   $start,
    $finish, $pid_param, $conf_mail, $conf_ftp, $conf_scp, $lang
  ) = @_;

  my $base    = Octopussy::Directory('programs');
  my $dir_pid = Octopussy::Directory('running');
  my $date   = strftime("%Y%m%d-%H%M", localtime);;
  my $dir    = Octopussy::Directory('data_reports') . $report->{name} . '/';
  my $output = "$dir$report->{name}-$date."
    . (
    $report->{graph_type} eq 'array'
    ? 'html'
    : ($report->{graph_type} =~ /^ofc_.+/ ? 'json' : 'png')
    );

  my @devices = ();
  foreach my $d (AAT::ARRAY($device))
  {
    push @devices,
      (($d !~ /group (.+)/) ? ($d) : Octopussy::DeviceGroup::Devices($1));
  }
  my $device_list  = join '" --device "',  @devices;
  my $service_list = join '" --service "', AAT::ARRAY($service);

  Octopussy::Create_Directory($dir);

  my $cmd =
      "$base$REPORTER_BIN --report \"$report->{name}\""
    . " --device \"$device_list\" --service \"$service_list\""
    . " --loglevel $loglevel --taxonomy $taxonomy --pid_param \"$pid_param\""
    . " --begin $start --end $finish --lang \"$lang\" "
    . CmdLine_Export_Options($conf_mail, $conf_ftp, $conf_scp)
    . " --output \"$output\"";

  #. " 2> \"$dir_pid/octo_reporter_$report->{name}-$date.err\"";
  Octopussy::Commander("$cmd &");

  return ($cmd);
}

=head2 Export($file, $conf_mail, $conf_ftp, $conf_scp)

Exports generated report via Mail, FTP, SCP if defined

=cut

sub Export
{
  my ($file, $conf_mail, $conf_ftp, $conf_scp) = @_;

  Octopussy::Export::Using_Mail($conf_mail, $file);
  Octopussy::Export::Using_Ftp($conf_ftp, $file);
  Octopussy::Export::Using_Scp($conf_scp, $file);

  return ($file);
}

=head2 File_Info($file, $begin, $end, $devices, $services, $stats)

Generates Report's File Information

=cut

sub File_Info
{
  my ($file, $begin, $end, $devices, $services, $stats) = @_;

  my %data = (
    start           => $begin,
    finish          => $end,
    devices         => join(', ', @{$devices}),
    services        => join(', ', @{$services}),
    nb_files        => $stats->{nb_files},
    nb_lines        => $stats->{nb_lines},
    seconds         => $stats->{seconds},
    nb_result_lines => $stats->{nb_result_lines},
  );
  AAT::XML::Write($file, \%data, 'octopussy_report_info');

  return ($file);
}

=head2 File_Info_Tooltip($file, $lang)

Prints Report's File Information in Tooltip

=cut

sub File_Info_Tooltip
{
  my ($file, $lang) = @_;
  my $dir_reports = Octopussy::Directory('data_reports');
  $file = "$dir_reports/$1/$file"
    if ($file =~ /^(.+?)-\d{8}-\d{2}\d{2}.info$/);
  my $ttip = undef;

  if (-f $file)
  {
    my $c = AAT::XML::Read($file);
    $ttip = AAT::Translation::Get($lang, '_DEVICES') . ": $c->{devices}<br>";
    $ttip .= AAT::Translation::Get($lang, '_SERVICES') . ": $c->{services}<br>";
    $ttip .=
        AAT::Translation::Get($lang, '_PERIOD')
      . ": $c->{start} -> $c->{finish}<br><hr>"
      . sprintf(
      AAT::Translation::Get($lang, '_MSG_REPORT_DATA_SOURCE'),
      $c->{nb_files}, $c->{nb_lines},
      int($c->{seconds} / $MINUTE),
      $c->{seconds} % $MINUTE
      )
      . '<br>'
      . AAT::Translation::Get($lang, '_MSG_REPORT_GENERATED_BY') . ' v'
      . Octopussy::Version();
  }

  return ($ttip);
}

=head2 Updates_Installation(@reports)

=cut

sub Updates_Installation
{
  my @reports = @_;
  my $web     = Octopussy::WebSite();
  $dir_reports ||= Octopussy::Directory($DIR_REPORT);

  foreach my $r (@reports)
  {
    my $url = "$web/Download/Reports/$r.xml";
    $url =~ s/ /\%20/g;
    AAT::Download('Octopussy', $url, "$dir_reports/$r.xml");
  }

  return (scalar @reports);
}

=head2 Running_List()

Returns list of Reports in progress

=cut

sub Running_List
{
  my $cache = Octopussy::Cache::Init($REPORTER_BIN);
  my $pt    = new Proc::ProcessTable;
  my @list  = ();
  my @keys  = $cache->get_keys();
  foreach my $k (@keys)
  {
    my $v = $cache->get($k);
    if ($k =~ /^info_(\d+)/)
    {
      my $pid   = $1;
      my $pid_param = $v->{pid_param};
      my $match = 0;
      foreach my $p (@{$pt->table}) 
        { $match = 1 if ($pid == $p->{pid}); }
      if ($match)
      {
        my $status = $cache->get("status_${pid_param}");
        push @list,
          {
          report   => $v->{report},
          started  => $v->{started},
          devices  => join(',', @{$v->{devices}}),
          services => join(',', @{$v->{services}}),
          status   => $status
          };
      }
      else
      {
        $cache->remove("info_$pid");
        $cache->remove("status_$pid");
        $cache->remove("status_${pid_param}");
      }
    }
  }

  return (@list);
}

1;

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut

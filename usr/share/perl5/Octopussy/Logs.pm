# $HeadURL$
# $Revision$
# $Date$
# $Author$

=head1 NAME

Octopussy::Logs - Octopussy Logs module

=cut

package Octopussy::Logs;

use strict;
use warnings;

use Octopussy;

=head2 Device_List($devices)

Returns Device List

=cut

sub Device_List
{
  my $devices = shift;
  my @devs    = ();
  my %hash_dev;

  foreach my $d ( AAT::ARRAY($devices) )
  {
    push @devs,
      ( ( $d !~ /group (.+)/ ) ? $d : Octopussy::DeviceGroup::Devices($1) );
  }
  foreach my $d (@devs)
  {
    if ( $d =~ /-ANY-/i )
    {
      foreach my $e ( Octopussy::Device::List() )
      {
        $e =~ s/ /_/g;
        $hash_dev{$e} = 1;
      }
    }
    else
    {
      $d =~ s/ /_/g;
      $hash_dev{$d} = 1;
    }
  }

  return (%hash_dev);
}

=head2 Service_List($services)

Returns Service List

=cut

sub Service_List
{
  my $services = shift;
  my %hash_serv;

  foreach my $s ( AAT::ARRAY($services) )
  {
    if ( $s =~ /-ANY-/i )
    {
      foreach my $e ( Octopussy::Service::List() )
      {
        $e =~ s/ /_/g;
        $hash_serv{$e} = 1;
      }
      $hash_serv{'Unknown'} = 1;
    }
    else
    {
      $s =~ s/ /_/g;
      $hash_serv{$s} = 1;
    }
  }

  return (%hash_serv);
}

=head2 Get_Directories($dir)

Gets Logs Directories

=cut

sub Get_Directories
{
  my $dir = shift;

  return () if ( !-d $dir );

  opendir DIR, $dir;
  my @dirs = grep { !/^\./ } readdir DIR;
  closedir DIR;

  return ( sort @dirs );
}

=head2 Init_Directories($device)

Inits Logs Directories for Device '$device'

=cut

sub Init_Directories
{
  my $device = shift;

  my $storage  = Octopussy::Storage::Default();
  my $incoming = Octopussy::Storage::Directory( $storage->{incoming} );
  my $unknown  = Octopussy::Storage::Directory( $storage->{unknown} );
  Octopussy::Create_Directory("$incoming/$device/Incoming/");
  Octopussy::Create_Directory("$unknown/$device/Unknown/");

  return ( "$incoming/$device/Incoming/", "$unknown/$device/Unknown/" );
}

=head2 Remove_Directories($device)

Removes Logs Directories for Device '$device'

=cut

sub Remove_Directories
{
  my $device = shift;

  my $conf     = Octopussy::Device::Configuration($device);
  my $storage  = Octopussy::Storage::Default();
  my $incoming = Octopussy::Storage::Directory( $storage->{incoming} );
  my $unknown  = Octopussy::Storage::Directory( $storage->{unknown} );
  my $known    = Octopussy::Storage::Directory( $storage->{known} );
  File::Path::rmtree("$incoming/$device/");
  File::Path::rmtree("$unknown/$device/");
  File::Path::rmtree("$known/$device/");

  foreach my $k ( keys %{$conf} )
  {
    if ( $k =~ /^storage_.+$/ )
    {
      my $dir = Octopussy::Storage::Directory( $conf->{$k} );
      File::Path::rmtree("$dir/$device/");
    }
  }

  return (undef);
}

sub Files_Year_Month_Day
{
  my ( $start, $finish, $dir, $dev, $s, $y ) = @_;

  my @files = ();
  my $start_year   = $start->{year} * 100_000_000;
  my $start_month  = $start_year + $start->{month} * 1_000_000;
  my $start_day    = $start_month + $start->{day} * 10_000;
  my $finish_year  = $finish->{year} * 100_000_000;
  my $finish_month = $finish_year + $finish->{month} * 1_000_000;
  my $finish_day   = $finish_month + $finish->{day} * 10_000;

  my $num_year = $y * 100_000_000;
  if ( ( $start_year <= $num_year ) && ( $num_year <= $finish_year ) )
  {
    foreach my $m ( Get_Directories("$dir/$dev/$s/$y") )
    {
      my $num_month = $num_year + $m * 1_000_000;
      if ( ( $start_month <= $num_month ) && ( $num_month <= $finish_month ) )
      {
        foreach my $d ( Get_Directories("$dir/$dev/$s/$y/$m") )
        {
          my $num_day = $num_month + $d * 10_000;
          if ( ( $start_day <= $num_day ) && ( $num_day <= $finish_day ) )
          {
            push @files, 
              map { { file => "$y/$m/$d/" . $_, numday => $num_day } }
              AAT::FS::Directory_Files( "$dir/$dev/$s/$y/$m/$d", qr/^msg_/ );
          }
        }
      }
    }
  }

  return (@files);
}

=head2 Files($devices, $services, $start, $finish)

Get logs files from '$services' on devices '$devices' 
between '$start' & '$finish' (don't get Incoming logs files)

=cut

sub Files
{
  my ( $ref_devices, $ref_services, $start, $finish ) = @_;
  my @list         = ();
  my %devs         = Device_List($ref_devices);
  my %servs        = Service_List($ref_services);

  my $start_year   = $start->{year} * 100_000_000;
  my $start_month  = $start_year + $start->{month} * 1_000_000;
  my $start_day    = $start_month + $start->{day} * 10_000;
  my $start_num    = $start_day + $start->{hour} * 100 + $start->{min};
  my $finish_year  = $finish->{year} * 100_000_000;
  my $finish_month = $finish_year + $finish->{month} * 1_000_000;
  my $finish_day   = $finish_month + $finish->{day} * 10_000;
  my $finish_num   = $finish_day + $finish->{hour} * 100 + $finish->{min};

  foreach my $dev ( sort keys %devs )
  {
    foreach my $s ( sort ( Octopussy::Device::Services($dev), 'Unknown' ) )
    {
      if ( AAT::NOT_NULL( $servs{$s} ) )
      {
        my $dir = Octopussy::Storage::Directory_Service( $dev, $s );
        foreach my $y ( Get_Directories("$dir/$dev/$s") )
        {
          my @files = Files_Year_Month_Day($start, $finish, $dir, $dev, $s, $y);
          foreach my $f (@files)
          {
            my $file = $f->{file};
            if ( $file =~ /^(\d{4}\/\d{2}\/\d{2})\/msg_(\d{2})h(\d{2})/ )
            {
              my $num = ( $f->{numday} + $2 * 100 + $3 );
              if ( ( $start_num <= $num ) && ( $num <= $finish_num ) )
              {
                push @list, "$dir/$dev/$s/$file";
              }
            }
          }
        }
      }
    }
  }

  return ( \@list );
}

=head2 Availability($device, $start, $finish)

=cut

sub Availability
{
  my ( $device, $start, $finish ) = @_;

  my @services     = Octopussy::Device::Services($device);
  my %availability = ();
  foreach my $s (@services)
  {
    my $files = Octopussy::Logs::Files( $device, $s, $start, $finish );
    foreach my $f ( @{$files} )
    {
      if ( $f =~ /\/(\d{2})\/(\d{2})\/+msg_(\d{2})h(\d{2})/ )
      {
        $availability{'_DEVICE_'}{$1}{$2}{$3}{$4} = 1;
        $availability{$s}{$1}{$2}{$3}{$4} = 1;
      }
    }
  }

  return ( \%availability );
}

=head2 Minutes_Hash($ref_devices, $ref_services, $start, $finish)

=cut

sub Minutes_Hash
{
  my ( $ref_devices, $ref_services, $start, $finish ) = @_;
  my %devs         = Device_List($ref_devices);
  my %servs        = Service_List($ref_services);
  my %minute_files = ();
  my $nb_files     = 0;

  my $start_year   = $start->{year} * 100_000_000;
  my $start_month  = $start_year + $start->{month} * 1_000_000;
  my $start_day    = $start_month + $start->{day} * 10_000;
  my $start_num    = $start_day + $start->{hour} * 100 + $start->{min};
  my $finish_year  = $finish->{year} * 100_000_000;
  my $finish_month = $finish_year + $finish->{month} * 1_000_000;
  my $finish_day   = $finish_month + $finish->{day} * 10_000;
  my $finish_num   = $finish_day + $finish->{hour} * 100 + $finish->{min};

  foreach my $dev ( sort keys %devs )
  {
    foreach my $s ( sort ( Octopussy::Device::Services($dev), 'Unknown' ) )
    {
      if ( AAT::NOT_NULL( $servs{$s} ) )
      {
        my $dir = Octopussy::Storage::Directory_Service( $dev, $s );
        foreach my $y ( Get_Directories("$dir/$dev/$s") )
        {
          my @files = Files_Year_Month_Day($start, $finish, $dir, $dev, $s, $y);
          foreach my $f (@files)
          {
            my $file = $f->{file};
            if ( $file =~ /^(\d{4}\/\d{2}\/\d{2})\/msg_(\d{2})h(\d{2})/ )
            {
              my $num = ( $f->{numday} + $2 * 100 + $3 );
              if ( ( $start_num <= $num ) && ( $num <= $finish_num ) )
              {
                push @{ $minute_files{$num} }, "$dir/$dev/$s/$file";
                $nb_files++;
              }
            }
          }
        }
      }
    }
  }

  return ( \%minute_files, $nb_files );
}

=head2 Get_TimePeriod_Files($devices, $services, $begin, $end)

Returns list of Files for Devices $devices, Services $services 
and Period $begin-$end

=cut

sub Get_TimePeriod_Files
{
  my ( $devices, $services, $begin, $end ) = @_;

  my ( $y1, $m1, $d1, $hour1, $min1 );
  my ( $y2, $m2, $d2, $hour2, $min2 );

  if ( $begin =~ /^(\d{4})(\d{2})(\d{2})(\d{2})(\d{2})$/ )
  {
    ( $y1, $m1, $d1, $hour1, $min1 ) = ( $1, $2, $3, $4, $5 );
  }
  if ( $end =~ /^(\d{4})(\d{2})(\d{2})(\d{2})(\d{2})$/ )
  {
    ( $y2, $m2, $d2, $hour2, $min2 ) = ( $1, $2, $3, $4, $5 );
  }
  my %start = (
                year  => $y1,
                month => $m1,
                day   => $d1,
                hour  => $hour1,
                min   => $min1,
              );
  my %finish = (
                 year  => $y2,
                 month => $m2,
                 day   => $d2,
                 hour  => $hour2,
                 min   => $min2,
               );
  my ( $files, $nb_files ) =
    Octopussy::Logs::Minutes_Hash( $devices, $services, \%start, \%finish );

  return ( $files, $nb_files );
}

=head2 Get($devices, $services, $start, $finish, $re_incl, $re_excl, $limit)

Get logs lines from '$services' on devices '$devices'
between '$start' & '$finish'

=cut

sub Get
{
  my ( $devices, $services, $start, $finish, $re_incl, $re_excl, $limit ) = @_;

  my $files       = Files( $devices, $services, $start, $finish );
  my @sorted_logs = ();
  my %logs        = ();
  my ( $year, $month );
  my $counter  = 0;
  my @includes = ();
  my @excludes = ();
  foreach my $inc ( AAT::ARRAY($re_incl) )
  {
    push @includes, qr/$inc/ if ( AAT::NOT_NULL($inc) );
  }
  foreach my $excl ( AAT::ARRAY($re_excl) )
  {
    push @excludes, qr/$excl/ if ( AAT::NOT_NULL($excl) );
  }

  foreach my $f ( sort ( AAT::ARRAY($files) ) )
  {
    ( $year, $month ) = ( $1, $2 ) if ( $f =~ /(\d{4})\/(\d{2})\/\d{2}\/msg_/ );
    if ( defined open my $FILE, '-|', "zcat '$f'" )
    {
      while ( my $line = <$FILE> )
      {
        my $match = 1;
        foreach my $inc (@includes) { $match = 0 if ( $line !~ $inc ); }
        foreach my $excl (@excludes) { $match = 0 if ( $line =~ $excl ); }
        if ($match)
        {
          $counter++;
          push @{ $logs{"$year$month"} }, $_;
        }
        last if ( $counter >= $limit );
      }
      close $FILE;
    }
    else
    {
      my ( $pack, $file_pack, $line, $sub ) = caller 0;
      AAT::Syslog( 'Octopussy::Logs', 'UNABLE_OPEN_FILE_IN', $f, $sub );
    }
    last if ( $counter >= $limit );
  }
  foreach my $k ( sort keys %logs ) { push @sorted_logs, sort @{ $logs{$k} }; }

  return ( \@sorted_logs );
}

=head2 Incoming_Files($device)

Returns list of 'Incoming Files'

=cut

sub Incoming_Files
{
  my $device = shift;

  my $dir = Octopussy::Storage::Directory_Incoming($device);
  Octopussy::Create_Directory("$dir/$device/Incoming/");
  my @files = `find "$dir/$device/Incoming/" -name "msg_*.log"`;

  return ( sort @files );
}

=head2 Unknown_Files($device, $first_file)

Returns list of 'Unknown Files'
(lines of these files doesn't match any defined message)

=cut

sub Unknown_Files
{
  my ( $device, $first_file ) = @_;
  my @unknown = ();

  my $dir = Octopussy::Storage::Directory_Unknown($device);
  Octopussy::Create_Directory("$dir/$device/Unknown/");
  my @files        = `find "$dir/$device/Unknown/" -name "msg_*.log.gz"`;
  my @sorted_files = sort @files;
  return (@sorted_files) if ( !defined $first_file );
  foreach my $f (@sorted_files) { push @unknown, $f if ( $f ge $first_file ); }

  return (@unknown);
}

=head2 Unknown_Number($device)

Returns number of unknown log messages for device '$device'

=cut

sub Unknown_Number
{
  my $device = shift;

  my $max_nb = Octopussy::Parameter('wizard_max_msgs');
  my ( $total, $nb ) = ( 0, 0 );
  my $dir = Octopussy::Storage::Directory_Unknown($device);
  Octopussy::Create_Directory("$dir/$device/Unknown/");

  foreach my $fy ( glob "$dir/$device/Unknown/*" )
  {
    foreach my $fm ( glob "$fy/*" )
    {
      foreach my $fd ( glob "$fm/*" )
      {
        foreach my $f ( glob "$fd/*" )
        {
          chomp $f;
          $nb = `zcat "$f" | wc -l`;
          chomp $nb;
          $total += $nb if ( $nb >= 0 );
          last if ( $total > $max_nb );
        }
      }
    }
  }

  return ($total);
}

=head2 Remove($device, $log)

Removes Log '$log' from Unknown Logs for Device '$device'

=cut

sub Remove
{
  my ( $device, $log ) = @_;

  my $re    = qr/^$log\s*$/;
  my $match = 0;
  my @files = Unknown_Files($device);
  foreach my $f ( sort @files )
  {
    chomp $f;
    my @logs = ();
    if ( defined open my $FILE, '-|', "zcat '$f'" )
    {
      while ( my $line = <$FILE> )
      {
        if   ( $line =~ $re ) { $match++; }
        else                  { push @logs, $line; }
      }
      close $FILE;
    }
    else
    {
      my ( $pack, $file_pack, $line, $sub ) = caller 0;
      AAT::Syslog( 'Octopussy::Logs', 'UNABLE_OPEN_FILE_IN', $f, $sub );
    }
    unlink $f;
    if ( defined open my $NEW, '|-', "gzip > '$f'" )
    {
      foreach my $l (@logs) { print {$NEW} $l; }
      close $NEW;
    }
    else
    {
      my ( $pack, $file_pack, $line, $sub ) = caller 0;
      AAT::Syslog( 'Octopussy::Logs', 'UNABLE_OPEN_FILE_IN', $f, $sub );
    }
  }

  return ($match);
}

=head2 Remove_Minute($device, $year, $month, $day, $hour, $min)

Removes 1 minute of Log File for Device '$device'

=cut

sub Remove_Minute
{
  my ( $device, $year, $month, $day, $hour, $min ) = @_;
  my $re    = qr/.+Unknown\/$year\/$month\/$day\/msg_${hour}h$min/;
  my @files = Unknown_Files($device);
  foreach my $f ( sort @files )
  {
    chomp $f;
    unlink $f if ( $f =~ $re );
  }

  return (undef);
}

=head2 Extract_Cmd_Line($conf)

Generate Command Line for octo_extractor

=cut

sub Extract_Cmd_Line
{
  my $conf     = shift;
  my @devices  = AAT::ARRAY( $conf->{devices} );
  my @services = AAT::ARRAY( $conf->{services} );
  my $dev_str  = '--device "' . join( '" --device "', @devices ) . '"';
  my $serv_str = '--service "' . join( '" --service "', @services ) . '"';
  my ( $incl_str, $excl_str ) = ( '', '' );
  foreach my $inc ( AAT::ARRAY( $conf->{includes} ) )
  {
    $inc =~ s/"/\\"/g;
    $incl_str .= "--include \"$inc\" " if ( AAT::NOT_NULL($inc) );
  }
  foreach my $exc ( AAT::ARRAY( $conf->{excludes} ) )
  {
    $exc =~ s/"/\\"/g;
    $excl_str .= "--exclude \"$exc\" " if ( AAT::NOT_NULL($exc) );
  }
  my $cmd =
      "/usr/sbin/octo_extractor $dev_str $serv_str"
    . " --loglevel \"$conf->{loglevel}\" --taxonomy \"$conf->{taxonomy}\""
    . " --msgid \"$conf->{msgid}\""
    . " --begin $conf->{begin} --end $conf->{end} $incl_str $excl_str"
    . " --pid_param \"$conf->{pid_param}\" --output \"$conf->{output}\"";

  return ($cmd);
}

1;

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut

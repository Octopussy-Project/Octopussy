# $HeadURL$
# $Revision$
# $Date$
# $Author$

=head1 NAME

Octopussy::Schedule - Octopussy Schedule module

=cut

package Octopussy::Schedule;

use strict;
use warnings;
use Readonly;

use AAT::Utils qw( ARRAY NOT_NULL );
use AAT::XML;
use Octopussy::FS;

Readonly my $FILE_SCHEDULES => 'schedule';
Readonly my $XML_ROOT       => 'octopussy_schedule';
Readonly my $HOURS_IN_DAY   => 24;

Readonly my %day => (
    'Monday'    => 1,
    'Tuesday'   => 2,
    'Wednesday' => 3,
    'Thursday'  => 4,
    'Friday'    => 5,
    'Saturday'  => 6,
    'Sunday'    => 7,
    'Every Day' => 0,
);

Readonly my %month => (
    'January'     => 1,
    'February'    => 2,
    'March'       => 3,
    'April'       => 4,
    'May'         => 5,
    'June'        => 6,
    'July'        => 7,
    'August'      => 8,
    'September'   => 9,
    'October'     => 10,
    'November'    => 11,
    'December'    => 12,
    'Every Month' => 0,
);

=head1 FUNCTIONS

=head2 Add($add)

Create a new Schedule

=cut 

sub Add
{
  my $add    = shift;
  my $exists = 0;
  my $file   = Octopussy::FS::File($FILE_SCHEDULES);
  my $conf   = AAT::XML::Read($file);
  foreach my $sched (ARRAY($conf->{schedule}))
  {
    $exists = 1 if ($sched->{title} eq $add->{title});
  }
  if (!$exists)
  {
    push @{$conf->{schedule}}, $add;
    AAT::XML::Write($file, $conf, $XML_ROOT);
  }
  else { return ('_MSG_SCHEDULE_ALREADY_EXISTS'); }

  return (undef);
}

=head2 Remove($schedule_title)

Removes Schedule '$schedule_title'

=cut 

sub Remove
{
  my $schedule_title = shift;

  my $file = Octopussy::FS::File($FILE_SCHEDULES);
  my $conf = AAT::XML::Read($file);
  my @schedules =
    grep { $_->{title} ne $schedule_title } ARRAY($conf->{schedule});
  $conf->{schedule} = \@schedules;
  AAT::XML::Write($file, $conf, $XML_ROOT);

  return (scalar @schedules);
}

=head2 List()

Returns Schedules List

=cut

sub List
{
  my @schedules =
    AAT::XML::File_Array_Values(Octopussy::FS::File($FILE_SCHEDULES),
    $FILE_SCHEDULES, 'title');

  return (@schedules);
}

=head2 Configuration()

Returns Schedules Configuration

=cut

sub Configuration
{
  my $schedule = shift;
  my $conf     = AAT::XML::Read(Octopussy::FS::File($FILE_SCHEDULES));

  foreach my $s (ARRAY($conf->{schedule}))
  {
    return ($s) if ($s->{title} eq $schedule);
  }

  return (undef);
}

=head2 Configurations($sort)

Gets the configuration for all Schedules sorted by '$sort' (default: 'title')

=cut

sub Configurations
{
  my $sort = shift;
  $sort ||= 'title';

  my (@configurations, @sorted_configurations) = ((), ());
  my @schedules = List();

  foreach my $s (@schedules)
  {
    my $conf = Configuration($s);
    $conf->{start_datetime}  = "$conf->{start_day}/$conf->{start_hour}";
    $conf->{finish_datetime} = "$conf->{finish_day}/$conf->{finish_hour}";
    push @configurations, $conf;
  }
  foreach my $c (sort { $a->{$sort} cmp $b->{$sort} } @configurations)
  {
    push @sorted_configurations, $c;
  }

  return (@sorted_configurations);
}

=head2 Period_Check($begin_day, $begin_hour, $end_day, $end_hour)

Checks that Period beginning is before Period end

=cut

sub Period_Check
{
  my ($begin_day, $begin_hour, $end_day, $end_hour) = @_;

  $begin_day  =~ s/Day-//;
  $begin_hour =~ s/Hour-//;
  $end_day    =~ s/Day-//;
  $end_hour   =~ s/Hour-//;
  return (1)
    if (($begin_day * $HOURS_IN_DAY + $begin_hour) >
    ($end_day * $HOURS_IN_DAY + $end_hour));

  return (0);
}

=head2 Match($sched, $dt)

Checks that the schedule '$sched' matches the datetime '$dt'
Returns 1 if it maches, 0 if it doesn't

=cut

sub Match
{
	my ($sched, $dt) = @_;
	
	my $match = 0;
	
	return ($match)    if (!defined $sched->{start_time});
    my ($sched_hour, $sched_min) = split(/:/, $sched->{start_time});
    if ((defined $sched_hour && defined $sched_min) && ($dt->{hour} == $sched_hour) && ($dt->{min} == $sched_min))
    {    # time matches
        my @dow = defined $sched->{dayofweek} ? @{$sched->{dayofweek}} : ();
        $match = 1  if (! @dow);
        foreach my $dw (@dow) 
        { 
            $match    = 1 if (($day{$dw} == $dt->{wday}) || ($day{$dw} == 0)); 
        }
        if ($match)
        {    # day matches
            my @dom =
                defined $sched->{dayofmonth} ? @{$sched->{dayofmonth}} : ();
            $match = 0 if (@dom);
            foreach my $dm (@dom) { $match = 1 if ($dm == $dt->{day}); }
            if ($match)
            {    # dayofmonth matches
                my @months = defined $sched->{month} ? @{$sched->{month}} : ();
                $match = 0  if (@months);
                foreach my $m (@months)
                {
                    $match = 1
                        if ($month{$m} == $dt->{month});
                }
                foreach my $m (@months) { $match = 1 if ($month{$m} == 0); } # 'Every Month'
            }
        }
    }

    return ($match);
}

=head2 Valid_Name($name)

Checks that '$name' is valid for a Schedule name

=cut

sub Valid_Name
{
    my $name = shift;

    return (1)  if ((NOT_NULL($name)) && ($name =~ /^[a-z0-9][a-z0-9_-]*$/i));

    return (0);
}

1;

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut

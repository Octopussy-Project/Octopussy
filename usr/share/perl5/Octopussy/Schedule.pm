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

use AAT::Utils qw( ARRAY );
use AAT::XML;
use Octopussy::FS;

Readonly my $FILE_SCHEDULES => 'schedule';
Readonly my $XML_ROOT       => 'octopussy_schedule';
Readonly my $HOURS_IN_DAY   => 24;

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
  my @schedules = AAT::XML::File_Array_Values(Octopussy::FS::File($FILE_SCHEDULES),
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

1;

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut

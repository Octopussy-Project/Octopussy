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
use Octopussy;

Readonly my $FILE_SCHEDULES => 'schedule';
Readonly my $XML_ROOT       => 'octopussy_schedule';

=head1 FUNCTIONS

=head2 Add($add)

Create a new Schedule

=cut 

sub Add
{
  my $add    = shift;
  my $exists = 0;
  my $file   = Octopussy::File($FILE_SCHEDULES);
  my $conf   = AAT::XML::Read($file);
  foreach my $sched (AAT::ARRAY($conf->{schedule}))
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

  my $file = Octopussy::File($FILE_SCHEDULES);
  my $conf = AAT::XML::Read($file);
  my @schedules =
    grep { $_->{title} ne $schedule_title } AAT::ARRAY($conf->{schedule});
  $conf->{schedule} = \@schedules;
  AAT::XML::Write($file, $conf, $XML_ROOT);

  return (scalar @schedules);
}

=head2 List()

Returns Schedules List

=cut

sub List
{
  my @schedules = AAT::XML::File_Array_Values(Octopussy::File($FILE_SCHEDULES),
    $FILE_SCHEDULES, 'title');

  return (@schedules);
}

=head2 Configuration()

Returns Schedules Configuration

=cut

sub Configuration
{
  my $schedule = shift;
  my $conf     = AAT::XML::Read(Octopussy::File($FILE_SCHEDULES));

  foreach my $s (AAT::ARRAY($conf->{schedule}))
  {
    return ($s) if ($s->{title} eq $schedule);
  }

  return (undef);
}

=head2 Configurations($sort)

Get the configuration for all Schedules

=cut

sub Configurations
{
  my $sort = shift;
  $sort ||= 'title';

  my (@configurations, @sorted_configurations) = ((), ());
  my @schedules = List();
  my %field;

  foreach my $s (@schedules)
  {
    my $conf = Configuration($s);
    $conf->{start_datetime}  = "$conf->{start_day}/$conf->{start_hour}";
    $conf->{finish_datetime} = "$conf->{finish_day}/$conf->{finish_hour}";
    $field{$conf->{$sort}}   = 1;
    push @configurations, $conf;
  }
  foreach my $f (sort keys %field)
  {
    push @sorted_configurations, grep { $_->{$sort} eq $f } @configurations;
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
  return (1) if (($begin_day * 24 + $begin_hour) > ($end_day * 24 + $end_hour));

  return (0);
}

1;

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut

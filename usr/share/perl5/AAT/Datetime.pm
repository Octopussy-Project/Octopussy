# $HeadURL$
# $Revision$
# $Date$
# $Author$

=head1 NAME

AAT::Datetime - AAT Datetime module

=cut

package AAT::Datetime;

use strict;
use warnings;
use Readonly;

use Date::Manip;

Readonly my @MONTH_NAME => (
  '',        '_JANUARY',   '_FEBRUARY', '_MARCH',
  '_APRIL',  '_MAY',       '_JUNE',     '_JULY',
  '_AUGUST', '_SEPTEMBER', '_OCTOBER',  '_NOVEMBER',
  '_DECEMBER',
);

Readonly my @WEEKDAY_NAME => (
  '',          '_MONDAY', '_TUESDAY',  '_WEDNESDAY',
  '_THURSDAY', '_FRIDAY', '_SATURDAY', '_SUNDAY',
);

Readonly my $MAX_HOURS    => 23;
Readonly my $MAX_MINUTES  => 59;
Readonly my $MAX_MONTH    => 12;
Readonly my $MAX_MONTHDAY => 31;
Readonly my $YEAR_START   => 1900;

=head1 FUNCTIONS

=head2 Month_Name($month)

Get the Month Name

Parameters:
 $month - Integer value of Month

Returns:
 $month_name - String value of Month

=cut

sub Month_Name
{
  my $month = shift;

  return ($MONTH_NAME[$month]);
}

=head2 Month_Nb_Days($year, $month)

Get the number of days in specified month

Parameters:
 $year - year
 $month - month

Returns:
 $daysinmonth - Number of days

=cut

sub Month_Nb_Days
{
  my ($year, $month) = @_;

  return (Date::Manip::Date_DaysInMonth($month, $year));
}

=head2 Now()

Returns current date (now!) in an Array (YYYY, MM, DD, HH, MM, SS)

=cut

sub Now
{
  my ($sec, $min, $hour, $mday, $mon, $year) = localtime time;
  $year += $START_YEAR;
  $mon++;
  $mon  = ($mon < 10  ? '0' . $mon  : $mon);
  $mday = ($mday < 10 ? '0' . $mday : $mday);
  $hour = ($hour < 10 ? '0' . $hour : $hour);
  $min  = ($min < 10  ? '0' . $min  : $min);
  $sec  = ($sec < 10  ? '0' . $sec  : $sec);

  return ($year, $mon, $mday, $hour, $min, $sec);
}

=head2 Now_String()

Get te actual time in "YYYY/MM/DD HH:MM" format

Returns:
 $now_string - string "YYYY/MM/DD HH:MM" formated

=cut

sub Now_String
{
  my ($year, $month, $mday, $hour, $min) = Now();

  return ("$year/$month/$mday $hour:$min");
}

=head2 Delta

Returns Delta in minutes between 2 dates

=cut

sub Delta
{
  my ($date1, $date2) = @_;

  my $diff = DateCalc(ParseDate($date1), ParseDate($date2));
  my $result = Delta_Format($diff, 0, '%mt');    # delta in minutes

  if ($result =~ /^[-+]?(\d+)\.\d*$/)
  {
    return ($1);
  }

  return (undef);
}

=head2 Seconds_Since_1970($year, $month, $day, $hour, $min)

Returns number of seconds since 1970

=cut

sub Seconds_Since_1970
{
  my ($year, $month, $day, $hour, $min) = @_;

  return (
    Date::Manip::Date_SecsSince1970GMT($month, $day, $year, $hour, $min, 0));

#return (Date::Manip::Date_SecsSince1970($month,$day,$year,$hour,$min, 0)) # GMT+3 fix
}

=head2 WeekDay($year, $month, $day)

Get the Day of Week (1 for Monday, 7 for Sunday)

Parameters:
 $year - year
 $month - month
 $day - day

Returns:
 $dayofweek - Day of Week

=cut

sub WeekDay
{
  my ($year, $month, $day) = @_;

  return (Date::Manip::Date_DayOfWeek($month, $day, $year));
}

=head2 WeekDay_Name($wday)

Get the Day of Week

Parameters:
 $wday - Integer value of Day of Week

Returns:
 $weekday_name - String value of Day of Week

=cut

sub WeekDay_Name
{
  my $wday = shift;

  return ($WEEKDAY_NAME[$wday]);
}

=head2 YearWeek($year, $month, $day)

Get the Week of the Year

=cut

sub YearWeek
{
  my ($year, $month, $day) = @_;

  return (Date_WeekOfYear($month, $day, $year, 1));
}

=head2 Current_Day()

Returns an Array of 2 hashrefs with the Begin & End of the Day
 
=cut

sub Current_Day
{
  my ($year, $month, $day, $hour, $min) = Now();
  $hour =~ s/^0//;
  $min  =~ s/^0//;

  my (%begin, %end) = ((), ());
  ($begin{year}, $begin{month}, $begin{day}) = ($year, $month, $day);
  ($begin{hour}, $begin{min}) = (0, 0);
  ($end{year}, $end{month}, $end{day}) = ($year, $month, $day);
  ($end{hour}, $end{min}) = ($hour, $min);

  return (\%begin, \%end);
}

=head2 Current_Hour()

Returns an Array of 2 hashrefs with the Begin & End of the Hour

=cut

sub Current_Hour
{
  my ($year, $month, $day, $hour, $min) = Now();
  $hour =~ s/^0//;
  my (%begin, %end) = ((), ());
  ($begin{year}, $begin{month}, $begin{day}) = ($year, $month, $day);
  ($begin{hour}, $begin{min}) = ($hour, 0);
  ($end{year}, $end{month}, $end{day}) = ($year, $month, $day);
  ($end{hour}, $end{min}) = ($hour, $MAX_MINUTES);

  return (\%begin, \%end);
}

=head2 Current_Month()

Returns an Array of 2 hashrefs with the Begin & End of the Month

=cut

sub Current_Month
{
  my ($year, $month, $day, $hour, $min) = Now();
  $hour =~ s/^0//;
  $min  =~ s/^0//;

  my (%begin, %end) = ((), ());
  ($begin{year}, $begin{month}, $begin{day}) = ($year, $month, 1);
  ($begin{hour}, $begin{min}) = (0, 0);
  ($end{year}, $end{month}, $end{day}) = ($year, $month, $day);
  ($end{hour}, $end{min}) = ($hour, $min);

  return (\%begin, \%end);
}

=head2 Current_Week()

Returns an Array of 2 hashrefs with the Begin & End of the Week

=cut

sub Current_Week
{
  my ($year, $month, $day, $hour, $min) = Now();
  my $wday = WeekDay($year, $month, $day);
  $wday--;
  $hour =~ s/^0//;
  $min  =~ s/^0//;
  my $date = Date::Manip::DateCalc('today', "-${wday}day");
  my (%begin, %end) = ((), ());
  ($end{year}, $end{month}, $end{day}) = ($year, $month, $day);
  ($end{hour}, $end{min}) = ($hour, $min);
  ($year, $month, $day, $hour, $min) =
    Date::Manip::UnixDate($date, '%Y', '%f', '%e', '%k', '%M');
  ($begin{year}, $begin{month}, $begin{day}) = ($year, $month, $day);
  ($begin{hour}, $begin{min}) = (0, 0);

  return (\%begin, \%end);
}

=head2 Current_Year()

Returns an Array of 2 hashrefs with the Begin & End of the Year

=cut

sub Current_Year
{
  my ($year, $month, $day, $hour, $min) = Now();
  $hour =~ s/^0//;
  $min  =~ s/^0//;

  my (%begin, %end) = ((), ());
  ($begin{year}, $begin{month}, $begin{day}) = ($year, 1, 1);
  ($begin{hour}, $begin{min}) = (0, 0);
  ($end{year}, $end{month}, $end{day}) = ($year, $month, $day);
  ($end{hour}, $end{min}) = ($hour, $min);

  return (\%begin, \%end);
}

=head2 Last_Day()

Returns an Array of 2 hashrefs with the Begin & End of the Last/Previous Day

=cut

sub Last_Day
{
  my $date = Date::Manip::ParseDate('yesterday');
  my ($year, $month, $day, $hour, $min) =
    Date::Manip::UnixDate($date, '%Y', '%f', '%e', '%k', '%M');

  my (%begin, %end) = ((), ());
  ($begin{year}, $begin{month}, $begin{day}) = ($year, $month, $day);
  ($begin{hour}, $begin{min}) = (0, 0);
  ($end{year}, $end{month}, $end{day}) = ($year, $month, $day);
  ($end{hour}, $end{min}) = ($MAX_HOURS, $MAX_MINUTES);

  return (\%begin, \%end);
}

=head2 Last_Hour()

Returns an Array of 2 hashrefs with the Begin & End of the Last/Previous Hour

=cut

sub Last_Hour
{
  my $date = Date::Manip::DateCalc('today', '-1hour');
  my ($year, $month, $day, $hour, $min) =
    Date::Manip::UnixDate($date, '%Y', '%f', '%e', '%k', '%M');
  $hour =~ s/^0//;

  my (%begin, %end) = ((), ());
  ($begin{year}, $begin{month}, $begin{day}) = ($year, $month, $day);
  ($begin{hour}, $begin{min}) = ($hour, 0);
  ($end{year}, $end{month}, $end{day}) = ($year, $month, $day);
  ($end{hour}, $end{min}) = ($hour, $MAX_MINUTES);

  return (\%begin, \%end);
}

=head2 Last_Month()

Returns an Array of 2 hashrefs with the Begin & End of the Last/Previous Month

=cut

sub Last_Month
{
  my $date = Date::Manip::DateCalc('today', '-1month');
  my ($year, $month, $day, $hour, $min) =
    Date::Manip::UnixDate($date, '%Y', '%f', '%e', '%k', '%M');

  my (%begin, %end) = ((), ());
  ($begin{year}, $begin{month}, $begin{day}) = ($year, $month, 1);
  ($begin{hour}, $begin{min}) = (0, 0);
  ($end{year}, $end{month}, $end{day}) =
    ($year, $month, Month_Nb_Days($year, $month));
  ($end{hour}, $end{min}) = ($MAX_HOURS, $MAX_MINUTES);

  return (\%begin, \%end);
}

=head2 Last_Week()

Returns an Array of 2 hashrefs with the Begin & End of the Last/Previous Week

=cut

sub Last_Week
{
  my ($year, $month, $day, $hour, $min) = Now();
  my $wday = WeekDay($year, $month, $day);
  $wday--;
  my $date = Date::Manip::DateCalc('today', "-1week -${wday}day");
  my (%begin, %end) = ((), ());
  ($year, $month, $day, $hour, $min) =
    Date::Manip::UnixDate($date, '%Y', '%f', '%e', '%k', '%M');
  ($begin{year}, $begin{month}, $begin{day}) = ($year, $month, $day);
  ($begin{hour}, $begin{min}) = (0, 0);
  $date = Date::Manip::DateCalc($date, '+6days');
  ($year, $month, $day, $hour, $min) =
    Date::Manip::UnixDate($date, '%Y', '%f', '%e', '%k', '%M');
  ($end{year}, $end{month}, $end{day}) = ($year, $month, $day);
  ($end{hour}, $end{min}) = ($MAX_HOURS, $MAX_MINUTES);

  return (\%begin, \%end);
}

=head2 Last_Year()

Returns an Array of 2 hashrefs with the Begin & End of the Last/Previous Year

=cut

sub Last_Year
{
  my ($year, $month, $day, $hour, $min) = Now();

  my (%begin, %end) = ((), ());
  ($begin{year}, $begin{month}, $begin{day}) = ($year - 1, 1, 1);
  ($begin{hour}, $begin{min}) = (0, 0);
  ($end{year}, $end{month}, $end{day}) = ($year - 1, $MAX_MONTH, $MAX_MONTHDAY);
  ($end{hour}, $end{min}) = ($MAX_HOURS, $MAX_MINUTES);

  return (\%begin, \%end);
}

1;

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut

=head1 NAME

Octopussy::TimePeriod - Octopussy TimePeriod module

=cut

package Octopussy::TimePeriod;

use strict;
no strict 'refs';

use Octopussy;

=head1 FUNCTIONS

=head2 New($conf)

Create a new Timeperiod

=cut

sub New($)
{
	my $new = shift;

	my $file = Octopussy::File("timeperiods");
  my $conf = AAT::XML::Read($file);
	if (defined $conf)
		{ push(@{$conf->{timeperiod}}, $new); }
	else
		{ push(@{$conf->{timeperiod}}, $new); }
  AAT::XML::Write($file, $conf, "octopussy_timeperiods");
}

=head2 Remove($timeperiod)

Remove a Timeperiod

=cut

sub Remove($)
{
	my $timeperiod = shift;

 	my @tps = ();
	my $file = Octopussy::File("timeperiods");
 	my $conf = AAT::XML::Read($file);
  foreach my $t (AAT::ARRAY($conf->{timeperiod}))
  	{ push(@tps, $t)	if ($t->{label} ne $timeperiod); }
	$conf->{timeperiod} = \@tps;
	AAT::XML::Write($file, $conf, "octopussy_timeperiods");
}

=head2 List()

Returns List of Timeperiods

=cut

sub List()
{
	my @tps = AAT::XML::File_Array_Values(Octopussy::File("timeperiods"), 
		"timeperiod", "label");

	return (@tps);
}

=head2 Configuration($tp_name)

=cut

sub Configuration($)
{
  my $tp_name = shift;

  my $conf = AAT::XML::Read(Octopussy::File("timeperiods"));
	foreach my $tp (AAT::ARRAY($conf->{timeperiod}))
  {
		if ($tp->{label} eq $tp_name)
		{
			my $str = "";
			foreach my $dt (AAT::ARRAY($tp->{dt}))
			{ 
				foreach my $k (AAT::HASH_KEYS($dt))
				{
					my $day = $1	if ($k =~ /^(\S{3})\S+/);
					$str .= "$day: $dt->{$k}, "; 
				}
			}
			$str =~ s/, $//;
  		return ({ label => $tp->{label}, periods => $str })    
		}
 	}

  return (undef);
}

=head2 Configurations($sort)

=cut

sub Configurations
{
	my $sort = shift || "label";
	my (@configurations, @sorted_configurations) = ((), ());
 	my @tps = List();
 	my %field;

	foreach my $tp (@tps)
 	{
  	my $conf = Configuration($tp);
   	$field{$conf->{$sort}} = 1;
 		push(@configurations, $conf);
 	}
	foreach my $f (sort keys %field)
  {
  	foreach my $c (@configurations)
    	{ push(@sorted_configurations, $c)	if ($c->{$sort} eq $f); }
  }

	return (@sorted_configurations);
}

=head2 Match($timeperiod, $datetime)

=cut

sub Match($$)
{
	my ($timeperiod, $datetime) = @_;

	return (1)	if ((!defined $timeperiod) || ($timeperiod =~ /-ANY-/));
	my ($day, $hour, $min) = ($1, $2, $3)
		if ($datetime =~ /^(\S+) (\d+):(\d+)$/);
	my $nb = $hour*100 + $min;
	my $conf = AAT::XML::Read(Octopussy::File("timeperiods"));
  foreach my $tp (AAT::ARRAY($conf->{timeperiod}))
  {
    if ($tp->{label} eq $timeperiod)
    {
      foreach my $dt (AAT::ARRAY($tp->{dt}))
      {
        foreach my $k (AAT::HASH_KEYS($dt))
        {
					if ($k eq $day)
					{
						if ($dt->{$k} =~ /^\!(\d+):(\d+)-(\d+):(\d+)$/)
						{
							return (1)	if (($nb < ($1*100+$2)) || ($nb > ($3*100+$4)));
						}
						elsif ($dt->{$k} =~ /^(\d+):(\d+)-(\d+):(\d+)$/)
						{
							return (1)  if (($nb > ($1*100+$2)) && ($nb < ($3*100+$4)));
						}
					}
        }
      }
    }
  }	
	return (0);
}

1;

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut

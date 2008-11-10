=head1 NAME

Octopussy::Loglevel - Octopussy Loglevel module

=cut
package Octopussy::Loglevel;

use strict;

use Octopussy;

use constant FILE_LOGLEVEL => "loglevel";

=head1 FUNCTIONS

=head2 List(\@dev_list, \@serv_list)

Get list of loglevel entries

=cut
sub List(@)
{
	my ($dev_list, $serv_list) = @_;
	my @list = ();

	if ((AAT::NOT_NULL($dev_list)) || (AAT::NOT_NULL($serv_list)))
	{
		my %level = ();
		my @services = ((AAT::NOT_NULL($serv_list)) ? AAT::ARRAY($serv_list)
			: Octopussy::Device::Services(AAT::ARRAY($dev_list)));
		foreach my $s (@services)
    { 
			@services = Octopussy::Device::Services(AAT::ARRAY($dev_list))  
				if ($s eq "-ANY-"); 
		}
    foreach my $m (Octopussy::Service::Messages(@services))
    	{ $level{$m->{loglevel}} = 1; }
		foreach my $k (keys %level)
			{ push(@list, $k); }
	}
	else
	{
		my %field;
		my $conf = AAT::XML::Read(Octopussy::File(FILE_LOGLEVEL));
		foreach my $l (AAT::ARRAY($conf->{loglevel}))
      { $field{$l->{value}} = 1; }
		foreach my $f (reverse sort keys %field)
  	{
    	foreach my $l (AAT::ARRAY($conf->{loglevel}))
      	{ push(@list, $l) if ($l->{value} eq $f); }
  	}
	}

	return (undef) if ($#list == -1);
	return (@list);
}

=head2 List_And_Any(\@dev_list, \@serv_list)

Get list of loglevel entries and '-ANY-'

=cut
sub List_And_Any(@)
{
	my ($dev_list, $serv_list) = @_;

  my @list = ("-ANY-");
  push(@list, List($dev_list, $serv_list));

	return (undef) if ($#list == -1);
  return (@list);
}

sub Colors
{
	my %color = ();

	my $conf = AAT::XML::Read(Octopussy::File(FILE_LOGLEVEL));
 	foreach my $l (AAT::ARRAY($conf->{loglevel}))
  	{ $color{$l->{label}} = $l->{color}; }

	return (%color);
}

1;

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut

=head1 NAME

Octopussy::Taxonomy - Octopussy Taxonomy module

=cut
package Octopussy::Taxonomy;

use strict;
no strict 'refs';

use Octopussy;

use constant FILE_TAXONOMY => "taxonomy";

=head1 FUNCTIONS

=head2 List(\@dev_list, \@serv_list)

Get list of taxonomy entries

=cut
sub List(@)
{
	my ($dev_list, $serv_list) = @_;
	my @list = ();

	if ((AAT::NOT_NULL($dev_list)) || (AAT::NOT_NULL($serv_list)))
	{
		my %taxo = ();
		my %color = Colors();
		my @services = ((AAT::NOT_NULL($serv_list)) ? AAT::ARRAY($serv_list)
			: Octopussy::Device::Services(AAT::ARRAY($dev_list)));
		@services = sort keys %{{ map { $_ => 1 } @services }}; # sort unique @services
		foreach my $s (@services)
    { 
			@services = Octopussy::Device::Services(AAT::ARRAY($dev_list))  
				if ($s eq "-ANY-"); 
		}
		@services = sort keys %{{ map { $_ => 1 } @services }}; # sort unique @services
    foreach my $m (Octopussy::Service::Messages(@services))
    	{ $taxo{$m->{taxonomy}} = 1; }
		foreach my $k (keys %taxo)
			{ push(@list, { value => $k, label => $k, color => $color{$k} }); }
	}
	else
	{
		my %field;
    my $conf = AAT::XML::Read(Octopussy::File(FILE_TAXONOMY));
    foreach my $t (AAT::ARRAY($conf->{taxonomy}))
      { $field{$t->{value}} = 1; }
    foreach my $f (sort keys %field)
    {
      foreach my $t (AAT::ARRAY($conf->{taxonomy}))
      {
        $t->{label} = $t->{value}; 
        push(@list, $t) if ($t->{value} eq $f); 
      }
    }
	}

	return (undef) if (scalar(@list) == 0);
	return (@list);
}

=head2 List_And_Any(\@dev_list, \@serv_list)

Get list of taxonomy entries and '-ANY-'

=cut
sub List_And_Any(@)
{
	my ($dev_list, $serv_list) = @_;

  my @list = ("-ANY-");
  push(@list, List($dev_list, $serv_list));

	return (undef) if (scalar(@list) == 0);
  return (@list);
}

=head2 String_List($devices, $services)

=cut
sub String_List(@)
{
  my ($devices, $services) = @_;
  my @data = Octopussy::Taxonomy::List($devices, $services);
  my @list = ("-ANY-");
  foreach my $d (@data)
  { 
    push(@list, $d->{value}); 
  }   
  
  return ("Taxonomy list: " . join(", ", sort @list));
}

=head2 Colors()

=cut
sub Colors()
{
  my $conf = AAT::XML::Read(Octopussy::File(FILE_TAXONOMY));
  my %color = ();
  foreach my $t (AAT::ARRAY($conf->{taxonomy}))
  	{ $color{"$t->{value}"} = $t->{color}; }

  return (%color);
}

1;

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut

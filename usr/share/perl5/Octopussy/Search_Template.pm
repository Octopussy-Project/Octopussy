#################### Octopussy Project ####################
# $Id$
###########################################################
=head1 NAME

Octopussy::Search_Template - Octopussy Search Template module

=cut

package Octopussy::Search_Template;

use strict;
use utf8;
use Octopussy;

my $SEARCH_TPL_DIR = "search_templates";
my $search_tpl_dir = undef;
my %filenames;

=head1 FUNCTIONS

=head2 New(\%conf)

Create a new Search Template
 
Parameters:

\%conf - hashref of the new Search Template configuration

=cut

sub New($)
{
	my $conf = shift;

	$search_tpl_dir ||= Octopussy::Directory($SEARCH_TPL_DIR);
	AAT::XML::Write("$search_tpl_dir/$conf->{name}.xml", 
				$conf, "octopussy_search_template");
}

=head2 Remove($search_tpl)

Remove the Search Template '$search_tpl'
 
Parameters:

$search_tpl - Name of the Search Template to remove

=cut
 
sub Remove($)
{
	my $search_tpl = shift;

	$filenames{$search_tpl} = undef;
	unlink(Filename($search_tpl));
}

=head2 List()

Get list of Search Templates
 
Returns:

@tpls - Array of Search Templates names

=cut
 
sub List()
{
	$search_tpl_dir ||= Octopussy::Directory($SEARCH_TPL_DIR);
	my @files = AAT::FS::Directory_Files($search_tpl_dir, qr/.+\.xml$/);
	my @tpls = ();
	foreach my $f (@files)
	{
		my $conf = AAT::XML::Read("$search_tpl_dir/$f");
		push(@tpls, $conf->{name})	if (defined $conf->{name});
	}
	
	return (sort @tpls);
}

=head2 Filename($search_tpl)

Get the XML filename for the Search Template '$search_tpl'

Parameters:

$search_tpl - Name of the Search Template

Returns:

$filename - Filename of the XML file for Search Template '$search_tpl'

=cut
 
sub Filename($)
{
	my $search_tpl = shift;

	return ($filenames{$search_tpl})   if (defined $filenames{$search_tpl});
	if (AAT::NOT_NULL($search_tpl))
	{
		$search_tpl_dir ||= Octopussy::Directory($SEARCH_TPL_DIR);
		my @files = AAT::FS::Directory_Files($search_tpl_dir, qr/.+\.xml$/);
		foreach my $f (@files)
  	{
  		my $conf = AAT::XML::Read("$search_tpl_dir/$f");
			$filenames{$search_tpl} = "$search_tpl_dir/$f";
   		return ("$search_tpl_dir/$f")     
				if ((defined $conf) && ($conf->{name} =~ /^$search_tpl$/));
		}
	}

	return (undef);
}

=head2 Configuration($search_tpl)

Get the configuration for the Search Template '$search_tpl'
 
Parameters:

$search_tpl - Name of the Search Template

Returns:

\%conf - Hashref of the Search Template configuration

=cut
 
sub Configuration($)
{
	my $search_tpl = shift;

	return (AAT::XML::Read(Filename($search_tpl)));
}

=head2 Configurations($sort)

Get the configuration for all Search Templates

Parameters:

$sort - selected field to sort configurations

Returns:

@configurations - Array of Hashref Search Template configurations  

=cut
 
sub Configurations($)
{
  my $sort = shift;
	my (@configurations, @sorted_configurations) = ((), ());
	my @tpls = List();
	my %field;

	foreach my $t (@tpls)
	{
		my $conf = Configuration($t);
		if (defined $conf->{name})
		{
			$field{$conf->{$sort}} = 1;
			push(@configurations, $conf);
		}
	}
	foreach my $f (sort keys %field)
	{
		foreach my $c (@configurations)
			{ push(@sorted_configurations, $c)    if ($c->{$sort} eq $f); }
	}

	return (@sorted_configurations);
}
																						
1;

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut

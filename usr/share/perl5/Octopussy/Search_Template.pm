=head1 NAME

Octopussy::Search_Template - Octopussy Search Template module

=cut

package Octopussy::Search_Template;

use strict;
use utf8;
use Octopussy;

use constant SEARCH_TPL_DIR => "search_templates";

my $search_tpl_dir = undef;
my %filenames;

=head1 FUNCTIONS

=head2 New($user, \%conf)

Create a new Search Template
 
Parameters:

$user - user who create this template
\%conf - hashref of the new Search Template configuration

=cut

sub New($$)
{
	my ($user, $conf) = @_;

	$search_tpl_dir ||= Octopussy::Directory(SEARCH_TPL_DIR);
	Octopussy::Create_Directory("$search_tpl_dir/$user");	
	AAT::XML::Write("$search_tpl_dir/$user/$conf->{name}.xml", 
				$conf, "octopussy_search_template");
}

=head2 Remove($user, $search_tpl)

Remove the Search Template '$search_tpl'
 
Parameters:

$user - user who created this template
$search_tpl - Name of the Search Template to remove

=cut
 
sub Remove($$)
{
	my ($user, $search_tpl) = @_;

	$filenames{$user}{$search_tpl} = undef;
	unlink(Filename($user, $search_tpl));
}

=head2 List($user)

Get list of Search Templates
 
Parameters:

$user - user who created this template

Returns:

@tpls - Array of Search Templates names

=cut
 
sub List($)
{
	my $user = shift;

	$search_tpl_dir ||= Octopussy::Directory(SEARCH_TPL_DIR);
	my @files = AAT::FS::Directory_Files("$search_tpl_dir/$user/", qr/.+\.xml$/);
	my @tpls = ();
	foreach my $f (@files)
	{
		my $conf = AAT::XML::Read("$search_tpl_dir/$user/$f");
		push(@tpls, $conf->{name})	if (defined $conf->{name});
	}
	
	return (sort @tpls);
}

=head2 List_Any_User($sort)

Get template name / user List

Parameters:

$sort - selected field to sort List

Returns:

@sorted_list - Array of Search Templates names for all users

=cut

sub List_Any_User($)
{
	my $sort = shift;

	my (@list, @sorted_list) = ();
	my %field;

	$search_tpl_dir ||= Octopussy::Directory(SEARCH_TPL_DIR);
	my @dirs = AAT::FS::Directory_Files("$search_tpl_dir/", qr/\w+$/);
	foreach my $d (@dirs)
	{
		my @files = AAT::FS::Directory_Files("$search_tpl_dir/$d/", qr/.+\.xml$/);
		foreach my $f (@files)
  	{
    	my $conf = AAT::XML::Read("$search_tpl_dir/$d/$f");
			my $key = (defined $conf->{$sort} ? $conf->{$sort} : $d);
			$field{$key} = 1;
			push(@list, { name => $conf->{name}, user => $d })
				if (defined $conf->{name});
		}
  }
  foreach my $f (sort keys %field)
  {
    foreach my $e (@list)
      { push(@sorted_list, $e)    if ($e->{$sort} eq $f); }
  }

	return (@sorted_list);
}

=head2 Filename($user, $search_tpl)

Get the XML filename for the Search Template '$search_tpl'

Parameters:

$user - user who created this template
$search_tpl - Name of the Search Template

Returns:

$filename - Filename of the XML file for Search Template '$search_tpl'

=cut
 
sub Filename($$)
{
	my ($user, $search_tpl) = @_;

	return ($filenames{$user}{$search_tpl})   
		if (defined $filenames{$user}{$search_tpl});
	if (AAT::NOT_NULL($search_tpl))
	{
		$search_tpl_dir ||= Octopussy::Directory(SEARCH_TPL_DIR);
		my @files = 
			AAT::FS::Directory_Files("$search_tpl_dir/$user/", qr/.+\.xml$/);
		foreach my $f (@files)
  	{
  		my $conf = AAT::XML::Read("$search_tpl_dir/$user/$f");
			$filenames{$user}{$search_tpl} = "$search_tpl_dir/$user/$f";
   		return ("$search_tpl_dir/$user/$f")     
				if ((defined $conf) && ($conf->{name} =~ /^$search_tpl$/));
		}
	}

	return (undef);
}

=head2 Configuration($user, $search_tpl)

Get the configuration for the Search Template '$search_tpl'
 
Parameters:

$user - user who created this template
$search_tpl - Name of the Search Template

Returns:

\%conf - Hashref of the Search Template configuration

=cut
 
sub Configuration($$)
{
	my ($user, $search_tpl) = @_;

	return (AAT::XML::Read(Filename($user, $search_tpl)));
}

=head2 Configurations($user, $sort)

Get the configuration for all Search Templates from User $user

Parameters:

$user - user who created this template
$sort - selected field to sort configurations

Returns:

@configurations - Array of Hashref Search Template configurations  

=cut
 
sub Configurations($$)
{
  my ($user, $sort) = @_;
	my (@configurations, @sorted_configurations) = ((), ());
	my @tpls = List($user);
	my %field;

	foreach my $t (@tpls)
	{
		my $conf = Configuration($user, $t);
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

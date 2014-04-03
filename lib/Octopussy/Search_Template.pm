package Octopussy::Search_Template;

=head1 NAME

Octopussy::Search_Template - Octopussy Search Template module

=cut

use strict;
use warnings;
use bytes;
use utf8;

use File::Slurp;

use AAT::Utils qw( NOT_NULL );
use AAT::XML;
use Octopussy;
use Octopussy::FS;

my $DIR_SEARCH_TPL = 'search_templates';
my $XML_ROOT       = 'octopussy_search_template';

my $dir_search_tpl = undef;
my %filename;

=head1 FUNCTIONS

=head2 New($user, \%conf)

Create a new Search Template
 
Parameters:

$user - user who create this template
\%conf - hashref of the new Search Template configuration

=cut

sub New
{
    my ($user, $conf) = @_;

    $dir_search_tpl ||= Octopussy::FS::Directory($DIR_SEARCH_TPL);
    Octopussy::FS::Create_Directory("$dir_search_tpl/$user");
    AAT::XML::Write("$dir_search_tpl/$user/$conf->{name}.xml", $conf,
        $XML_ROOT);

    return ($conf->{name});
}

=head2 Remove($user, $search_tpl)

Remove the Search Template '$search_tpl'
 
Parameters:

$user - user who created this template
$search_tpl - Name of the Search Template to remove

=cut

sub Remove
{
    my ($user, $search_tpl) = @_;

    my $nb = unlink Filename($user, $search_tpl);
    $filename{$user}{$search_tpl} = undef;

    return ($nb);
}

=head2 List($user)

Get list of Search Templates
 
Parameters:

$user - user who created this template

Returns:

@tpls - Array of Search Templates names

=cut

sub List
{
    my $user = shift;

    $dir_search_tpl ||= Octopussy::FS::Directory($DIR_SEARCH_TPL);

    return ()	if (! -r "$dir_search_tpl/$user/");

	my @files = grep { /.+\.xml$/ } read_dir("$dir_search_tpl/$user/");
    my @tpls = ();
    foreach my $f (@files)
    {
        my $conf = AAT::XML::Read("$dir_search_tpl/$user/$f");
        push @tpls, $conf->{name} if (defined $conf->{name});
    }

    return (sort @tpls);
}

=head2 List_Any_User($sort)

Get template name / user List

Parameters:

$sort - selected field to sort List (default: 'name')

Returns:

@sorted_list - Array of Search Templates names for all users

=cut

sub List_Any_User
{
    my $sort = shift || 'name';
    my (@list, @sorted_list) = ((), ());

    $dir_search_tpl ||= Octopussy::FS::Directory($DIR_SEARCH_TPL);

	return ()   if (! -r $dir_search_tpl);

    my @dirs = grep { /\w+$/ } read_dir($dir_search_tpl); 
    foreach my $d (@dirs)
    {
        my @files = grep { /.+\.xml$/ } read_dir("$dir_search_tpl/$d/", err_mode => 'quiet');
        foreach my $f (@files)
        {
            my $conf = AAT::XML::Read("$dir_search_tpl/$d/$f");
            push @list, {name => $conf->{name}, user => $d}
                if (defined $conf->{name});
        }
    }
    foreach my $i (sort { $a->{$sort} cmp $b->{$sort} } @list)
    {
        push @sorted_list, $i;
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

sub Filename
{
    my ($user, $search_tpl) = @_;

    return ($filename{$user}{$search_tpl})
        if (defined $filename{$user}{$search_tpl});
    if (NOT_NULL($search_tpl))
    {
        $dir_search_tpl ||= Octopussy::FS::Directory($DIR_SEARCH_TPL);
        my @files = grep { /.+\.xml$/ } read_dir("$dir_search_tpl/$user/", err_mode => 'quiet'); 
        foreach my $f (@files)
        {
            my $conf = AAT::XML::Read("$dir_search_tpl/$user/$f");
            if ((defined $conf) && ($conf->{name} =~ /^$search_tpl$/))
            {
                $filename{$user}{$search_tpl} = "$dir_search_tpl/$user/$f";
                return ("$dir_search_tpl/$user/$f");
            }
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

sub Configuration
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

sub Configurations
{
    my ($user, $sort) = @_;
    my (@configurations, @sorted_configurations) = ((), ());
    my @tpls = List($user);

    foreach my $t (@tpls)
    {
        my $conf = Configuration($user, $t);
        if (defined $conf->{name})
        {
            push @configurations, $conf;
        }
    }
    foreach my $c (sort { $a->{$sort} cmp $b->{$sort} } @configurations)
    {
        push @sorted_configurations, $c;
    }

    return (@sorted_configurations);
}

=head2 Valid_Name($name)

Checks that '$name' is valid for a Search Template name

=cut

sub Valid_Name
{
    my $name = shift;

    return (1) if ((NOT_NULL($name)) && ($name =~ /^[a-z0-9][a-z0-9_-]*$/i));

    return (0);
}

1;

=head1 AUTHOR

Sebastien Thebert <octopussy@onetool.pm>

=cut

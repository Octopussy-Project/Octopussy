package Octopussy::Plugin;

=head1 NAME

Octopussy::Plugin - Octopussy Plugin module

=cut

use strict;
use warnings;

use Path::Tiny;
use FindBin;

use AAT::Syslog;
use AAT::Utils qw( ARRAY );
use AAT::XML;
use Octopussy::FS;

my $DIR_PLUGIN         = 'plugins';
my $DIR_PLUGIN_MODULES = undef;

my $dir_plugins     = undef;
my %function_source = ();

BEGIN
{
    my $DIR_PLUGIN_MODULES = (
        -d '/usr/share/perl5/Octopussy/Plugin/'
        ? '/usr/share/perl5/Octopussy/Plugin/'
		: 	( -d "$FindBin::Bin/../../lib/Octopussy/Plugin/" # for test suite
			? "$FindBin::Bin/../../lib/Octopussy/Plugin/"
        	: $Config::Config{installsitelib} . '/Octopussy/Plugin/'
			)
    );

    if (defined opendir DIR, $DIR_PLUGIN_MODULES)
    {
        my @plugins = grep { /.+\.pm$/ } readdir DIR;
        foreach my $p (@plugins)
        {
            if ("Octopussy/Plugin/$p" =~ /^(Octopussy\/Plugin\/)(.+\.pm)$/)
            {
                my $file_module = "$1$2";
                eval {
		  no strict 'refs';	## no critic (strict)
		  require $file_module;
		  1;
                }
                    or do
                {
                    AAT::Syslog::Message('octopussy',
                        'UNABLE_LOAD_PLUGIN_MODULE', $file_module);
                    }
            }
        }
        closedir DIR;
    }
}

=head1 SUBROUTINES/METHODS

=head2 Init_All(\%conf)

Launches 'Init' subroutine for all pluins in plugins directory

=cut

sub Init_All
{
    my $conf = shift;

    my @plugins = grep { /.+\.pm$/ } path($DIR_PLUGIN_MODULES)->children;
    foreach my $p (@plugins)
    {
        $p =~ s/\.pm$//;
        my $func = 'Octopussy::Plugin::' . $p . '::Init';
        &{$func}($conf);
    }

    return (scalar @plugins);
}

=head2 Init(\%conf, @plugins)

Launches 'Init' subroutine for plugins listed in @plugins

=cut

sub Init
{
    my ($conf, @plugins) = @_;
    my %done = ();

    foreach my $p (@plugins)
    {
        if (($p =~ /Octopussy::Plugin::(.+?)::/) && (!defined $done{$1}))
        {
            my $func = 'Octopussy::Plugin::' . $1 . '::Init';
            $done{$1} = 1;
			no strict 'refs';	## no critic (strict)
            &{$func}($conf);
        }
    }

    return (scalar(keys %done));
}

=head2 List()

Returns List of Plugins

=cut

sub List
{
    $dir_plugins ||= Octopussy::FS::Directory($DIR_PLUGIN);

    return (AAT::XML::Name_List($dir_plugins));
}

=head2 Functions()

Returns List of Plugins Functions

=cut

sub Functions
{
    my @functions = ();

    $dir_plugins ||= Octopussy::FS::Directory($DIR_PLUGIN);

    return ()	if (! -r $dir_plugins);

    my @files = grep { /.+\.xml$/ } path($dir_plugins)->children;
    foreach my $f (@files)
    {
        my $conf = AAT::XML::Read("$dir_plugins/$f");
        push @functions,
            {plugin => $conf->{name}, functions => $conf->{function}}
            if (defined $conf->{function});
    }

    return (@functions);
}

=head2 Function_Source($fct)

=cut

sub Function_Source
{
    my $fct = shift;

    if ($fct =~ /Octopussy::Plugin::(.+)::.+$/)
    {
        my $mod = $1;
        if (!defined $function_source{$fct})
        {
            $dir_plugins ||= Octopussy::FS::Directory($DIR_PLUGIN);
            my $conf = AAT::XML::Read("$dir_plugins/$mod.xml");
            foreach my $pf (ARRAY($conf->{function}))
            {
                $function_source{$fct} = $pf->{source} if ($pf->{perl} eq $fct);
            }
            $function_source{$fct} = 'OUTPUT'
                if (!defined $function_source{$fct});
        }
    }

    return ($function_source{$fct});
}

=head2 SQL_Convert($str)

Returns Plugin Function to SQL
Octopussy::Plugin::Function(field) -> Plugin_Function__field

=cut

sub SQL_Convert
{
    my $str = shift;

    if ($str =~ /^(\S+::\S+?)\((\S+)\)$/)
    {
        my ($fct, $field) = ($1, $2);
        $fct =~ s/^Octopussy:://;
        $fct =~ s/::/_/g;
        return ("${fct}__${field}");
    }
    else
    {
        return ($str);
    }
}

=head2 Field_Data

=cut

sub Field_Data
{
    my ($line, $long_field) = @_;
    my $result = undef;

    if ($long_field =~ /^(\S+::\S+?)\((\S+)\)$/)
    {
        my ($plugin, $field) = ($1, $2);
        if (Function_Source($plugin) eq 'OUTPUT')
        {
            $result = &{$plugin}($line->{$field});
        }
        else
        {
            my $plugin_sql = SQL_Convert($long_field);
            $result = $line->{$plugin_sql};
        }
    }

    return ($result);
}

1;

=head1 AUTHOR

Sebastien Thebert <octopussy@onetool.pm>

=cut

=head1 NAME

Octopussy::Plugin - Octopussy Plugin module

=cut

package Octopussy::Plugin;

use strict;
no strict 'refs';
use Octopussy;

my $PLUGIN_DIR = "plugins";
my $PLUGINS_MODULES_DIR = "/usr/share/perl5/Octopussy/Plugin/";
my $plugins_dir = undef;

my %function_source = ();


BEGIN
{
	opendir(DIR, "/usr/share/perl5/Octopussy/Plugin/");
 	my @plugins = grep /.+\.pm$/, readdir(DIR);
 	foreach my $p (@plugins)
  { 
		my $plugin_filename = "$1$2"	
			if ("Octopussy/Plugin/$p" =~ /^(Octopussy\/Plugin\/)(.+\.pm)$/);
		require "$plugin_filename";
	}
	closedir(DIR);
}

=head1 FUNCTIONS

=head2 Init_All(\%conf)

=cut

sub Init_All
{
	my $conf = shift;

	my @plugins = AAT::FS::Directory_Files($PLUGINS_MODULES_DIR, qr/.+\.pm$/);
  foreach my $p (@plugins)
  { 
		$p =~ s/\.pm$//;
		my $func = "Octopussy::Plugin::" . $p . "::Init";
		print "Init Plugin $p\n";
		&{$func}($conf); 
	}
}

=head2 Init(\%conf, @plugins)

=cut

sub Init
{
	my ($conf, @plugins) = @_;
	my %done = ();

  foreach my $p (@plugins)
  {
		if (($p =~ /Octopussy::Plugin::(.+?)::/) && (!defined $done{$1}))
		{
    	my $func = "Octopussy::Plugin::" . $1 . "::Init";
    	print "Init Plugin $1\n";
			$done{$1} = 1;
    	&{$func}($conf);
		}
  }
}

=head2 List()

Returns List of Plugins

=cut

sub List()
{	
	$plugins_dir ||= Octopussy::Directory($PLUGIN_DIR);

	return (AAT::XML::Name_List($plugins_dir));
}

=head2 Functions()

Returns List of Plugins Functions

=cut

sub Functions()
{
	my @functions = ();

	$plugins_dir ||= Octopussy::Directory($PLUGIN_DIR);
	my @files = AAT::FS::Directory_Files($plugins_dir, qr/.+\.xml$/);
  foreach my $f (@files)
  {
    my $conf = AAT::XML::Read("$plugins_dir/$f");
    push(@functions, { plugin => $conf->{name}, functions => $conf->{function} })  
			if (defined $conf->{function});
  }	

  return (@functions);
}

=head2 Function_Source($fct)

=cut

sub Function_Source($)
{
	my $fct = shift;	
	my $source = undef;
	my $mod = $1	if ($fct =~ /Octopussy::Plugin::(.+)::.+$/);

	if (!defined $function_source{$fct})
	{
		$plugins_dir ||= Octopussy::Directory($PLUGIN_DIR);
		my $conf = AAT::XML::Read("$plugins_dir/$mod.xml");
		foreach my $pf (AAT::ARRAY($conf->{function})) 
		{ 
			$function_source{$fct} = $pf->{source}	if ($pf->{perl} eq $fct);
		}
		$function_source{$fct} = "OUTPUT"	if (!defined $function_source{$fct});
	}
	
	return ($function_source{$fct});
}

1;

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut

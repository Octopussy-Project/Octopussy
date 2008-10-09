=head1 NAME

Octopussy::Plugin - Octopussy Plugin module

=cut
package Octopussy::Plugin;

use strict;
no strict 'refs';
use Octopussy;

use constant DIR_PLUGIN => "plugins";
use constant DIR_PLUGIN_MODULES => "/usr/share/perl5/Octopussy/Plugin/";

my $dir_plugins = undef;
my %function_source = ();

BEGIN
{
	opendir(DIR, DIR_PLUGIN_MODULES);
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
sub Init_All($)
{
	my $conf = shift;

	my @plugins = AAT::FS::Directory_Files(DIR_PLUGIN_MODULES, qr/.+\.pm$/);
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
sub Init($@)
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
	$dir_plugins ||= Octopussy::Directory(DIR_PLUGIN);

	return (AAT::XML::Name_List($dir_plugins));
}

=head2 Functions()

Returns List of Plugins Functions

=cut
sub Functions()
{
	my @functions = ();

	$dir_plugins ||= Octopussy::Directory(DIR_PLUGIN);
	my @files = AAT::FS::Directory_Files($dir_plugins, qr/.+\.xml$/);
  foreach my $f (@files)
  {
    my $conf = AAT::XML::Read("$dir_plugins/$f");
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
		$dir_plugins ||= Octopussy::Directory(DIR_PLUGIN);
		my $conf = AAT::XML::Read("$dir_plugins/$mod.xml");
		foreach my $pf (AAT::ARRAY($conf->{function})) 
		{ 
			$function_source{$fct} = $pf->{source}	if ($pf->{perl} eq $fct);
		}
		$function_source{$fct} = "OUTPUT"	if (!defined $function_source{$fct});
	}
	
	return ($function_source{$fct});
}

=head2 SQL_Convert($str)

Returns Plugin Function to SQL
Octopussy::Plugin::Function(field) -> Plugin_Function__field

=cut
sub SQL_Convert($)
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
    if (Function_Source($plugin) eq "OUTPUT")
    {
      $result = &{$plugin}($line->{$field});
    }
    else
    {
      my $plugin_sql = Octopussy::Plugin::SQL_Convert($long_field);
      $result = $line->{$plugin_sql};
    } 
  }

  return ($result);
}

1;

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut

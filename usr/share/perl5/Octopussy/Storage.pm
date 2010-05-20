# $HeadURL$
# $Revision$
# $Date$
# $Author$

=head1 NAME

Octopussy::Storage - Octopussy Storage module

=cut

package Octopussy::Storage;

use strict;
use warnings;
use Readonly;

use List::MoreUtils qw(any firstval);

use AAT::Utils qw( ARRAY );
use AAT::XML;
use Octopussy::Device;
use Octopussy::FS;

Readonly my $FILE_STORAGES => 'storages';
Readonly my $XML_ROOT      => 'octopussy_storages';

=head1 FUNCTIONS

=head2 Add($conf_storage)

Add a new Storage

=cut

sub Add
{
  my $conf_storage = shift;
  my @storages     = ();

  my $file = Octopussy::FS::File($FILE_STORAGES);
  my $conf = AAT::XML::Read($file);
  if (any { $_->{s_id} eq $conf_storage->{s_id} } ARRAY($conf->{storage}))
  {
    return ('_MSG_STORAGE_ALREADY_EXISTS');
  }
  push @{$conf->{storage}}, $conf_storage;
  AAT::XML::Write($file, $conf, $XML_ROOT);

  return (undef);
}

=head2 Remove($storage)

Removes Storage '$storage'

=cut

sub Remove
{
  my $storage = shift;

  my $file     = Octopussy::FS::File($FILE_STORAGES);
  my $conf     = AAT::XML::Read($file);
  my @storages = grep { $_->{s_id} ne $storage } ARRAY($conf->{storage});
  $conf->{storage} = \@storages;
  AAT::XML::Write($file, $conf, $XML_ROOT);

  return (undef);
}

=head2 Default()

=cut

sub Default
{
  my $conf = AAT::XML::Read(Octopussy::FS::File($FILE_STORAGES));

  return (undef) if (!defined $conf);
  return (
    {
      incoming => $conf->{default_incoming},
      unknown  => $conf->{default_unknown},
      known    => $conf->{default_known}
    }
  );
}

=head2 Default_Set($conf_new)

=cut

sub Default_Set
{
  my $conf_new = shift;

  my $file = Octopussy::FS::File($FILE_STORAGES);
  my $conf = AAT::XML::Read($file);
  $conf->{default_incoming} = $conf_new->{incoming};
  $conf->{default_unknown}  = $conf_new->{unknown};
  $conf->{default_known}    = $conf_new->{known};

  AAT::XML::Write($file, $conf, $XML_ROOT);

  return ($file);
}

=head2 List()

Get list of storages

Returns:

@storages - Array of storages names

=cut

sub List
{
  my @storages = AAT::XML::File_Array_Values(Octopussy::FS::File($FILE_STORAGES),
    'storage', 's_id');

  return (@storages);
}

=head2 Configuration($storage)

Get the configuration for the storage '$storage'
 
Parameters:

$storage - Name of the storage

Returns:

\%conf - Hashref of the storage configuration

=cut 

sub Configuration
{
  my $storage = shift;

  my $conf = AAT::XML::Read(Octopussy::FS::File($FILE_STORAGES));
  return ({name => 'DEFAULT', directory => Octopussy::FS::Directory('data_logs')})
    if ($storage eq 'DEFAULT');
  foreach my $s (ARRAY($conf->{storage}))
  {
    return ($s) if ($s->{s_id} eq $storage);
  }

  return (undef);
}

=head2 Configurations($sort)

Get the configuration for all storages

Parameters:

$sort - selected field to sort configurations
 
Returns:

@configurations - Array of Hashref storage configurations  

=cut

sub Configurations
{
  my $sort = shift || 's_id';
  my (@configurations, @sorted_configurations) = ((), ());
  my @storages    = List();
  my $dir_default = Octopussy::FS::Directory('data_logs');

  push @sorted_configurations, {s_id => 'DEFAULT', directory => $dir_default};
  foreach my $s (@storages)
  {
    my $conf = Configuration($s);
    if (defined $conf->{s_id})
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

=head2 Directory($storage)

Returns directory for Storage '$storage'

=cut

sub Directory
{
  my $storage = shift;

  return (undef) if (!defined $storage);
  my $conf = AAT::XML::Read(Octopussy::FS::File($FILE_STORAGES));
  return (Octopussy::FS::Directory('data_logs')) if ($storage eq 'DEFAULT');

  my $dir = firstval { $_->{s_id} eq $storage } ARRAY($conf->{storage});

  return ($dir->{directory});
}

=head2 Directory_Service($device, $service)

Returns directory for Device '$device' Service '$service' Logs

=cut

sub Directory_Service
{
  my ($device, $service) = @_;

  my $storage = Default();
  my $dconf   = Octopussy::Device::Configuration($device);
  my $dir =
       Directory($dconf->{"storage_$service"})
    || Directory($dconf->{'storage_known'})
    || Directory($storage->{known});

  return ($dir);
}

=head2 Directory_Incoming($device)

Returns directory for Device '$device' Incoming Logs

=cut

sub Directory_Incoming
{
  my $device = shift;

  my $storage = Default();
  my $dconf   = Octopussy::Device::Configuration($device);
  my $dir     = Directory($dconf->{storage_incoming})
    || Directory($storage->{incoming});

  return ($dir);
}

=head2 Directory_Unknown($device)

Returns directory for Device '$device' Unknown Logs

=cut

sub Directory_Unknown
{
  my $device = shift;

  my $storage = Default();
  my $dconf   = Octopussy::Device::Configuration($device);
  my $dir     = Directory($dconf->{storage_unknown})
    || Directory($storage->{unknown});

  return ($dir);
}

1;

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut

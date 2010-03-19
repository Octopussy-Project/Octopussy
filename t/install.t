#!/usr/bin/perl -w
# $HeadURL$
# $Revision$
# $Date$
# $Author$

=head1 NAME

install.t - Octopussy install Test

=head1 DESCRIPTION

It checks:
  - that files are present and with good rights

=cut

use strict;
use warnings;

use Readonly;
use Test::More tests => 26;

Readonly my $USER          => 'octopussy';
Readonly my $GROUP         => 'octopussy';
Readonly my $DIR_BIN       => '/usr/sbin';
Readonly my $DIR_CONF      => '/var/lib/octopussy/conf';
Readonly my $DIR_SERVICES  => '/var/lib/octopussy/conf/services';
Readonly my $DIR_TABLES    => '/var/lib/octopussy/conf/tables';
Readonly my $MASK          => 07777;
Readonly my $FILESTAT_MODE => 2;
Readonly my $FILESTAT_UID  => 4;
Readonly my $FILESTAT_GID  => 5;

Readonly my @FILES_BIN => (
  "$DIR_BIN/octopussy",       "$DIR_BIN/octo_commander",
  "$DIR_BIN/octo_dispatcher", "$DIR_BIN/octo_extractor",
  "$DIR_BIN/octo_logrotate",  "$DIR_BIN/octo_parser",
  "$DIR_BIN/octo_reporter",   "$DIR_BIN/octo_rrd",
  "$DIR_BIN/octo_scheduler",  "$DIR_BIN/octo_uparser",
);

Readonly my @FILES_CONF => (
  "$DIR_CONF/device_models.xml", "$DIR_CONF/loglevel.xml",
  "$DIR_CONF/taxonomy.xml",      "$DIR_CONF/types.xml",
  "$DIR_CONF/user_roles.xml",    "$DIR_CONF/users.xml",
);

Readonly my @FILES_SERVICES => (
  "$DIR_SERVICES/Linux_Kernel.xml", "$DIR_SERVICES/Linux_System.xml",
  "$DIR_SERVICES/Octopussy.xml",    "$DIR_SERVICES/Sshd.xml",
);

Readonly my @FILES_TABLES => (
  "$DIR_TABLES/Firewall_Traffic.xml", "$DIR_TABLES/Mail_Traffic.xml",
  "$DIR_TABLES/Message.xml",          "$DIR_TABLES/Octopussy.xml",
);

=head1 FUNCTIONS

=head2 Check_Files(@files)

Checks that files exists

=cut

sub Check_Files
{
  my ($mode_required, @files) = @_;
  my $error     = 0;
  my $str_error = '';

  foreach my $f (@files)
  {
    if (!-f $f)
    {
      $error++;
      $str_error .= sprintf("Missing file: %s\n", $f);
    }
    else
    {
      my ($mode, $uid, $gid) =
        (stat($f))[$FILESTAT_MODE, $FILESTAT_UID, $FILESTAT_GID];
      $mode = sprintf("%04o", $mode & $MASK);
      my $user  = (getpwuid($uid))[0];
      my $group = (getgrgid($gid))[0];
      if ($user ne $USER || $group ne $GROUP)
      {
        $error++;
        $str_error .=
          sprintf("Wrong user/group: %s (%s/%s)\n", $f, $user, $group);
      }
      if ($mode ne $mode_required)
      {
        $error++;
        $str_error .= sprintf("Wrong mode: %s (%s)\n", $f, $mode);
      }

      #printf("$f -> mode: %s uid: %s gid: %s\n", $mode, $user, $group);
    }
  }

  return ($error, $str_error);
}

=head2 MAIN

=cut

# Checks Modules
BEGIN { use_ok('AAT') }
BEGIN { use_ok('Octopussy') }
BEGIN { use_ok('Octopussy::Alert') }
BEGIN { use_ok('Octopussy::Cache') }
BEGIN { use_ok('Octopussy::Configuration') }
BEGIN { use_ok('Octopussy::Contact') }
BEGIN { use_ok('Octopussy::Device') }
BEGIN { use_ok('Octopussy::DeviceGroup') }
BEGIN { use_ok('Octopussy::Location') }
BEGIN { use_ok('Octopussy::Loglevel') }
BEGIN { use_ok('Octopussy::Logs') }
BEGIN { use_ok('Octopussy::Message') }
BEGIN { use_ok('Octopussy::Plugin') }
BEGIN { use_ok('Octopussy::Report') }
BEGIN { use_ok('Octopussy::Schedule') }
BEGIN { use_ok('Octopussy::Service') }
BEGIN { use_ok('Octopussy::ServiceGroup') }
BEGIN { use_ok('Octopussy::Storage') }
BEGIN { use_ok('Octopussy::Table') }
BEGIN { use_ok('Octopussy::Taxonomy') }
BEGIN { use_ok('Octopussy::TimePeriod') }
BEGIN { use_ok('Octopussy::Type') }

my $error     = 0;
my $str_error = '';

# Checks Binary Files
($error, $str_error) = Check_Files('0700', @FILES_BIN);
ok(!$error, 'Octopussy Binary Files') or diag($str_error);

# Checks Configuration Files
($error, $str_error) = Check_Files('0660', @FILES_CONF);
ok(!$error, 'Octopussy Configurations Files') or diag($str_error);

# Checks Services Files
($error, $str_error) = Check_Files('0660', @FILES_SERVICES);
ok(!$error, 'Octopussy Services Files') or diag($str_error);

# Checks Tables Files
($error, $str_error) = Check_Files('0660', @FILES_TABLES);
ok(!$error, 'Octopussy Tables Files') or diag($str_error);

1;

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut

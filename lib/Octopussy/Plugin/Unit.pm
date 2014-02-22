=head1 NAME

Octopussy::Plugin::Unit - Octopussy Plugin Unit

=cut

package Octopussy::Plugin::Unit;

use strict;
use warnings;

use Readonly;

Readonly my $KBYTES  => 1024;
Readonly my $MBYTES  => 1024 * $KBYTES;
Readonly my $GBYTES  => 1024 * $MBYTES;
Readonly my $TBYTES  => 1024 * $GBYTES;
Readonly my $MINUTES => 60;
Readonly my $HOURS   => 60 * $MINUTES;

my ($str_bytes, $str_minutes, $str_hours) = (undef, undef, undef);

=head1 FUNCTIONS

=head2 Init(\%conf)

=cut

sub Init
{
  	my $conf = shift;

	require AAT::Translation;
  
	$str_bytes   = lc AAT::Translation::Get($conf->{lang} || 'EN', '_BYTES');
  	$str_minutes = lc AAT::Translation::Get($conf->{lang} || 'EN', '_MINUTES');
  	$str_hours   = lc AAT::Translation::Get($conf->{lang} || 'EN', '_HOURS');

  	return (1);
}

=head2 KiloBytes($bytes)

Converts Bytes to KiloBytes

=cut

sub KiloBytes
{
  my $bytes = shift;

  return (sprintf '%.1f %s', $bytes / $KBYTES, "K${str_bytes}");
}

=head2 MegaBytes($bytes)

Converts Bytes to MegaBytes

=cut

sub MegaBytes
{
  my $bytes = shift;

  return (sprintf '%.1f %s', $bytes / $MBYTES, "M${str_bytes}");
}

=head2 GigaBytes($bytes)

Converts Bytes to GigaBytes

=cut

sub GigaBytes
{
  my $bytes = shift;

  return (sprintf '%.1f %s', $bytes / $GBYTES, "G${str_bytes}");
}

=head2 TeraBytes($bytes)

Converts Bytes to TeraBytes

=cut

sub TeraBytes
{
  my $bytes = shift;

  return (sprintf '%.1f %s', $bytes / $TBYTES, "T${str_bytes}");
}

=head2 Minutes($seconds)

Converts Seconds to Minutes

=cut

sub Minutes
{
  my $seconds = shift;

  return (sprintf '%.1f %s', $seconds / $MINUTES, ${str_minutes});
}

=head2 Hours($seconds)

Converts Seconds to Hours

=cut

sub Hours
{
  my $seconds = shift;

  return (sprintf '%.1f %s', $seconds / $HOURS, ${str_hours});
}

1;

=head1 AUTHOR

Sebastien Thebert <octopussy@onetool.pm>

=cut

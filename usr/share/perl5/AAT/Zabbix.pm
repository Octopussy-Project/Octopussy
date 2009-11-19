# $HeadURL$
# $Revision$
# $Date$
# $Author$

=head1 NAME

AAT::Zabbix - AAT Zabbix module

=cut

package AAT::Zabbix;

use strict;
use warnings;

my %conf_file = ();

=head1 FUNCTIONS

=head2 Configuration($appli)

Returns Zabbix Configuration

=cut

sub Configuration
{
  my $appli = shift;

  $conf_file{$appli} ||= AAT::Application::File( $appli, 'zabbix' );
  my $conf = AAT::XML::Read( $conf_file{$appli}, 1 );

  return ( $conf->{zabbix} );
}

=head2 Send($appli, $msg, $zabbix_host, $zabbix_item)

Sends Zabbix message '$msg'

=cut

sub Send
{
  my ( $appli, $msg, $zabbix_host, $zabbix_item ) = @_;

  my $conf_zabbix = Configuration($appli);
  if (    ( defined $conf_zabbix )
       && ( defined $conf_zabbix->{bin} )
       && ( -e $conf_zabbix->{bin} ) )
  {
    my $host = $zabbix_host || $conf_zabbix->{zabbix_host};
    my $item = $zabbix_item || $conf_zabbix->{zabbix_item};
    my $cmd =
"$conf_zabbix->{bin} -z $conf_zabbix->{zabbix_server} -s $conf_zabbix->{zabbix_host} -k $conf_zabbix->{zabbix_item} -o \"$msg\"";
    system $cmd;

    return (1);
  }

  return (0);
}

1;

=head1 SEE ALSO

AAT(3), AAT::Syslog(3), AAT::Theme(3), AAT::Translation(3), AAT::User(3), AAT::XML(3)

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut

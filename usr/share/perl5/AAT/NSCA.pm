=head1 NAME

AAT::NSCA - AAT NSCA module

=cut
package AAT::NSCA;

use strict;

my $NSCA_FILE = undef;

=head1 FUNCTIONS

=head2 Configuration()

Returns NSCA Configuration

=cut
sub Configuration
{
	$NSCA_FILE ||= AAT::File("nsca");
	my $conf = AAT::XML::Read($NSCA_FILE, 1);

	return ($conf->{nsca});
}

=head2 Send($level, $msg)

Send NSCA message '$msg' with level '$level'

=cut
sub Send
{
  my ($level, $msg) = @_;
	
	my $nsca_conf = Configuration();
  if ((defined $nsca_conf)
    && (defined $nsca_conf->{bin}) && (defined $nsca_conf->{conf})
    && (-e $nsca_conf->{bin}) && (-e $nsca_conf->{conf}))
  {
    open(NSCA, "| $nsca_conf->{bin} -H $nsca_conf->{nagios_server} -c $nsca_conf->{conf}");
    print NSCA "$nsca_conf->{nagios_host}\t$nsca_conf->{nagios_service}\t$level\t$msg\n";
    close(NSCA);
  }
}

1;

=head1 SEE ALSO

AAT(3), AAT::Syslog(3), AAT::Theme(3), AAT::Translation(3), AAT::User(3), AAT::XML(3)

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut

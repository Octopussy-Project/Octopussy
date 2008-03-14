#################### Octopussy Project ####################
# $Id$
###########################################################
=head1 NAME

AAT::WebService - AAT WebService module

=cut
package AAT::WebService;

use strict;
no strict 'refs';

my %ws = ();

=head1 FUNCTIONS

=head2 Init($appli)

=cut
sub Init($)
{
	my $appli = shift;
	my $conf = AAT::XML::Read(AAT::Application::File($appli, "webservices"));

	foreach my $f (AAT::ARRAY($conf->{function}))
		{ $ws{$appli}{$f->{label}} = $f->{cmd}; }
}

=head2 Command($cmd, $args)

=cut
sub Command($$)
{
	my ($appli, $cmd, $args) = @_;

	print "$ws{$appli}{$cmd} ()";
}

1;

=head1 SEE ALSO

AAT(3), AAT::Syslog(3), AAT::Theme(3), AAT::Translation(3), AAT::User(3), AAT::XML(3)

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut

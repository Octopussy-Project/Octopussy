package OneTool::LogManagement::Service;

=head1 NAME

OneTool::LogManagement::Service - OneTool LogManagement Service module

=cut

use strict;
use warnings;

use OneTool::LogManagement::Configuration;

=head1 SUBROUTINES/METHODS

=head2 configuration($service_name)

Returns Service '$service_name' configuration

=cut

sub configuration
{
    my $service_name = shift;

    my $conf = OneTool::LogManagement::Configuration::load('services', 
		$service_name);

    return ($conf);
}

=head2 list()

Returns list of all Services

=cut

sub list
{
    my @items = OneTool::LogManagement::Configuration::items('services');

    return (@items);
}

=head2 move_message($service_name, $current_pos, $new_pos)

Moves Message from $service_name Service from $current_pos to $new_pos position
(position starts at 0)

=cut

sub move_message
{
    my ($service_name, $current_pos, $new_pos) = @_;

    my $conf = configuration($service_name);
    my @messages = @{$conf->{messages}};
    printf "\nAVANT:\n";
    foreach my $msg (@messages)
    {
        printf "$msg->{msg_id},  ";
    }
    splice(@messages, $new_pos, 0, splice(@messages, $current_pos, 1));
    printf "\nAPRES\n";
    foreach my $msg (@messages)
    {
        printf "$msg->{msg_id},  ";
    }
    $conf->{messages} = \@messages;
    
    OneTool::LogManagement::Configuration::save('services', $service_name, $conf);
}

1;

=head1 AUTHOR

Sebastien Thebert <octopussy@onetool.pm>

=cut

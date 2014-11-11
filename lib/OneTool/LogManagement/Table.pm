package OneTool::LogManagement::Table;

=head1 NAME

OneTool::LogManagement::Table - OneTool LogManagement Table module

=cut

use strict;
use warnings;

use OneTool::LogManagement::Configuration;

=head1 SUBROUTINES/METHODS

=head2 configuration($table_name)

=cut

sub configuration
{
    my $table_name = shift;

    my $conf = OneTool::LogManagement::Configuration::get('tables', 
        $table_name);

    return ($conf);
}

=head2 list()

=cut

sub list
{
    my @items = OneTool::LogManagement::Configuration::items('tables');

    return (@items);
}

1;

=head1 AUTHOR

Sebastien Thebert <octopussy@onetool.pm>

=cut

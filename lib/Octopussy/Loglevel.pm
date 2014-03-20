
=head1 NAME

Octopussy::Loglevel - Octopussy Loglevel module

=cut

package Octopussy::Loglevel;

use strict;
use warnings;

use List::MoreUtils qw(uniq);
use Readonly;

use AAT::Utils qw( ARRAY NOT_NULL );
use AAT::XML;
use Octopussy::Device;
use Octopussy::FS;
use Octopussy::Loglevel;
use Octopussy::Service;

Readonly my $FILE_LOGLEVEL => 'loglevel';

my @LOGLEVEL_CONFIGURATIONS = ();

=head1 FUNCTIONS

=head2 Configurations()

Get list of loglevel configurations

=cut

sub Configurations
{
    if (!scalar @LOGLEVEL_CONFIGURATIONS)
    {
        my $conf = AAT::XML::Read(Octopussy::FS::File($FILE_LOGLEVEL));
        @LOGLEVEL_CONFIGURATIONS = ARRAY($conf->{loglevel});
    }

    return (@LOGLEVEL_CONFIGURATIONS);
}

=head2 List(\@dev_list, \@serv_list)

Get list of loglevel entries

=cut

sub List
{
    my ($dev_list, $serv_list) = @_;
    my @list = ();

    if ((NOT_NULL($dev_list)) || (NOT_NULL($serv_list)))
    {
        my %level    = ();
        my %color    = Colors();
        my %levels   = Levels();
        my @services = (
            (NOT_NULL($serv_list))
            ? ARRAY($serv_list)
            : Octopussy::Device::Services(ARRAY($dev_list))
        );
        @services = sort(uniq(@services));
        foreach my $s (@services)
        {
            @services = Octopussy::Device::Services(ARRAY($dev_list))
                if ($s eq '-ANY-');
        }
        @services = sort(uniq(@services));
        foreach my $m (Octopussy::Service::Messages(@services))
        {
            $level{$m->{loglevel}} = 1;
        }
        foreach my $k (keys %level)
        {
            push @list,
                {
                value => $k,
                label => $k,
                color => $color{$k},
                level => $levels{$k}
                };
        }
    }
    else
    {
        my %field;
        my @loglevels = Octopussy::Loglevel::Configurations();
        foreach my $l (@loglevels)
        {
            $field{$l->{level}} = 1;
        }
        foreach my $f (reverse sort keys %field)
        {
            foreach my $l (@loglevels)
            {
                $l->{label} = $l->{value};
                push @list, $l if ($l->{level} eq $f);
            }
        }
    }

    return (undef) if (scalar(@list) == 0);
    return (@list);
}

=head2 List_And_Any(\@dev_list, \@serv_list)

Get list of loglevel entries and '-ANY-'

=cut

sub List_And_Any
{
    my ($dev_list, $serv_list) = @_;

    my @list = ('-ANY-');
    push @list, List($dev_list, $serv_list);

    return (undef) if (scalar(@list) == 0);
    return (@list);
}

=head2 String_List($devices, $services)

Returns Loglevel List as a string like 'Loglevel list: <loglevel_list>'

=cut

sub String_List
{
    my ($devices, $services) = @_;

    my @d_unknowns = Octopussy::Device::Unknowns(@{$devices});
    my @s_unknowns = Octopussy::Service::Unknowns(@{$services});
    if (scalar @d_unknowns)
    {
        return (sprintf '[ERROR] Unknown Device(s): %s', join ', ',
            @d_unknowns);
    }
    elsif (scalar @s_unknowns)
    {
        return (sprintf '[ERROR] Unknown Service(s): %s', join ', ',
            @s_unknowns);
    }
    else
    {
        my @data = Octopussy::Loglevel::List($devices, $services);
        my @list = ('-ANY-');
        foreach my $d (@data) { push @list, $d->{value}; }

        return ('Loglevel list: ' . join ', ', sort @list);
    }
}

=head2 Unknowns(@loglevels)

Returns list of Unknown Loglevels in @loglevels list

=cut

sub Unknowns
{
    my @loglevels = @_;
    my @unknowns  = ();

    my %exist = map { $_->{label} => 1 } List();
    foreach my $l (@loglevels)
    {
        push @unknowns, $l
            if (NOT_NULL($l) && (!defined $exist{$l}) && ($l =~ /^-ANY-$/i));
    }

    return (@unknowns);
}

=head2 Colors()

=cut

sub Colors
{
    my %color = ();

    my @loglevels = Octopussy::Loglevel::Configurations();
    foreach my $l (@loglevels)
    {
        $color{$l->{value}} = $l->{color};
    }

    return (%color);
}

=head2 Levels()

=cut

sub Levels
{
    my %level = ();

    my @loglevels = Octopussy::Loglevel::Configurations();
    foreach my $l (@loglevels)
    {
        $level{$l->{value}} = $l->{level};
    }

    return (%level);
}

=head2 Valid_Name($name)

Checks that '$name' is valid for an Alert name

=cut

sub Valid_Name
{
    my $name = shift;

    my @loglevels = Octopussy::Loglevel::Configurations();
    my $re_loglevel = join '|', map { $_->{value} } @loglevels;
    return (1) if ((NOT_NULL($name)) && ($name =~ /^$re_loglevel$/i));

    return (0);
}

1;

=head1 AUTHOR

Sebastien Thebert <octopussy@onetool.pm>

=cut


=head1 NAME

Octopussy::OFC - Octopussy Open Flash Chart (OFC) module

=cut

package Octopussy::OFC;

use strict;
use warnings;

use JSON;

use AAT::Utils qw( ARRAY );
use Octopussy::DB;
use Octopussy::FS;

my $STEP_HBAR = 10;
my $STYLE_TITLE =
'{font-size: 20px; color:#0000ff; font-family: Verdana; text-align: center;}';
my $SIZE_3D     = 5;
my $TICK_HEIGHT = 4;

=head1 FUNCTIONS

=head2 Generate(\%conf, $output_file)

=cut

sub Generate
{
    my ($conf, $output_file) = @_;

    my $json = to_json($conf, {utf8 => 1, pretty => 1});
    if (defined open my $FILE, '>', $output_file)
    {
        print {$FILE} $json;
        close $FILE;
        Octopussy::FS::Chown($output_file);

        return ($output_file);
    }

    return (undef);
}

=head2 Step($max)

=cut

sub Step
{
    my $max  = shift;
    my $step = 1;

    if ($max =~ /^(\d)(\d+)$/)
    {
        ## no critic
        my $multi = 10**(length($2) - 1);
        $multi ||= 1;
        if ($1 == 1) { $step = 2 * $multi; }
        elsif ($1 =~ /[2-5]/) { $step = 5 * $multi; }
        else                  { $step = 10 * $multi; }
        ## use critic
    }

    return ($step);
}

=head2 Area_Hollow($rc, $data, $output_file)

=cut

sub Area_Hollow
{
    my ($rc, $data, $output_file) = @_;

    my $x      = Octopussy::DB::SQL_As_Substitution($rc->{x});
    my $y      = Octopussy::DB::SQL_As_Substitution($rc->{y});
    my @labels = ();
    my @values = ();
    my $max    = 0;
    foreach my $line (ARRAY($data))
    {
        my $value = $line->{$y} + 0;    # ensuring it will be dumped as a number
        my $label = $line->{$x};
        push @labels, $line->{$x};
        push @values, {value => $value, label => $label, text => $label};
        $max = (($value > $max) ? $value : $max);
    }
    my %conf = (
        title => {text => $rc->{name}, style => $STYLE_TITLE},
        x_axis => {labels => {steps => 10, labels => \@labels}},
        y_axis   => {steps => Step($max),    min    => 0, max => $max},
        elements => [{type => 'area_hollow', values => \@values}],
    );
    Octopussy::OFC::Generate(\%conf, $output_file);

    return ($output_file);
}

=head2 Bar_3D($rc, $data, $output_file)

=cut

sub Bar_3D
{
    my ($rc, $data, $output_file) = @_;

    my $x      = Octopussy::DB::SQL_As_Substitution($rc->{x});
    my $y      = Octopussy::DB::SQL_As_Substitution($rc->{y});
    my @labels = ();
    my @values = ();
    my $max    = 0;
    foreach my $line (ARRAY($data))
    {
        my $value = $line->{$y} + 0;    # ensuring it will be dumped as a number
        my $label = $line->{$x};
        push @labels, $label;
        push @values, $value;
        $max = (($value > $max) ? $value : $max);
    }
    my %conf = (
        title => {text => $rc->{name}, style => $STYLE_TITLE},
        x_axis => {labels => {steps => 10, labels => \@labels}},
        y_axis   => {steps => Step($max), min    => 0, max => $max},
        elements => [{type => 'bar_3d',   values => \@values}],
    );
    Octopussy::OFC::Generate(\%conf, $output_file);

    return ($output_file);
}

=head2 Bar_Cylinder($rc, $data, $output_file)

=cut

sub Bar_Cylinder
{
    my ($rc, $data, $output_file) = @_;

    my $x      = Octopussy::DB::SQL_As_Substitution($rc->{x});
    my $y      = Octopussy::DB::SQL_As_Substitution($rc->{y});
    my @labels = ();
    my @values = ();
    my $max    = 0;
    foreach my $line (ARRAY($data))
    {
        my $value = $line->{$y} + 0;    # ensuring it will be dumped as a number
        my $label = $line->{$x};
        push @labels, $label;
        push @values, $value;
        $max = (($value > $max) ? $value : $max);
    }
    my %conf = (
        title  => {text => $rc->{name}, style => $STYLE_TITLE},
        x_axis => {
            colour        => '#909090',
            '3d'          => $SIZE_3D,
            'tick-height' => $TICK_HEIGHT,
            labels        => {steps => 10, labels => \@labels},
        },
        y_axis   => {steps => Step($max),     min    => 0, max => $max},
        elements => [{type => 'bar_cylinder', values => \@values}],
    );
    Octopussy::OFC::Generate(\%conf, $output_file);

    return ($output_file);
}

=head2 Bar_Glass($rc, $data, $output_file)

=cut

sub Bar_Glass
{
    my ($rc, $data, $output_file) = @_;

    my $x      = Octopussy::DB::SQL_As_Substitution($rc->{x});
    my $y      = Octopussy::DB::SQL_As_Substitution($rc->{y});
    my @labels = ();
    my @values = ();
    my $max    = 0;
    foreach my $line (ARRAY($data))
    {
        my $value = $line->{$y} + 0;    # ensuring it will be dumped as a number
        my $label = $line->{$x};
        push @labels, $label;
        push @values, $value;
        $max = (($value > $max) ? $value : $max);
    }
    my %conf = (
        title => {text => $rc->{name}, style => $STYLE_TITLE},
        x_axis => {labels => {steps => 10, labels => \@labels}},
        y_axis   => {steps => Step($max),  min    => 0, max => $max},
        elements => [{type => 'bar_glass', values => \@values}],
    );
    Octopussy::OFC::Generate(\%conf, $output_file);

    return ($output_file);
}

=head2 Bar_Sketch($rc, $data, $output_file)

=cut

sub Bar_Sketch
{
    my ($rc, $data, $output_file) = @_;

    my $x      = Octopussy::DB::SQL_As_Substitution($rc->{x});
    my $y      = Octopussy::DB::SQL_As_Substitution($rc->{y});
    my @labels = ();
    my @values = ();
    my $max    = 0;
    foreach my $line (ARRAY($data))
    {
        my $value = $line->{$y} + 0;    # ensuring it will be dumped as a number
        my $label = $label;
        push @labels, $line->{$x};
        push @values, $value;
        $max = (($value > $max) ? $value : $max);
    }
    my %conf = (
        title => {text => $rc->{name}, style => $STYLE_TITLE},
        x_axis => {labels => {steps => 10, labels => \@labels}},
        y_axis   => {steps => Step($max),   min    => 0, max => $max},
        elements => [{type => 'bar_sketch', values => \@values}],
    );
    Octopussy::OFC::Generate(\%conf, $output_file);

    return ($output_file);
}

=head2 Horizontal_Bar($rc, $data, $output_file)

=cut

sub Horizontal_Bar
{
    my ($rc, $data, $output_file) = @_;

    my $x      = Octopussy::DB::SQL_As_Substitution($rc->{x});
    my $y      = Octopussy::DB::SQL_As_Substitution($rc->{y});
    my @labels = ();
    my @values = ();
    my $max    = 0;
    foreach my $line (ARRAY($data))
    {
        my $value = $line->{$y} + 0;    # ensuring it will be dumped as a number
        push @labels, $line->{$x};
        push @values, {right => $value};
        $max = (($value > $max) ? $value : $max);
    }
    my %conf = (
        title => {text => $rc->{name}, style => $STYLE_TITLE},
        x_axis => {steps => int($max / $STEP_HBAR), min => 0, max => $max},
        y_axis   => {offset => 1,      labels => \@labels},
        elements => [{type  => 'hbar', values => \@values}],
    );
    Octopussy::OFC::Generate(\%conf, $output_file);

    return ($output_file);
}

=head2 Pie($rc, $data, $output_file)

=cut

sub Pie
{
    my ($rc, $data, $output_file) = @_;

    my $x      = Octopussy::DB::SQL_As_Substitution($rc->{x});
    my $y      = Octopussy::DB::SQL_As_Substitution($rc->{y});
    my @values = ();
    foreach my $line (ARRAY($data))
    {
        my $value = $line->{$y} + 0;    # ensuring it will be dumped as a number
        my $label = $line->{$x};
        push @values, {value => $value, label => $label, text => $label};
    }
    my %conf = (
        title    => {text  => $rc->{name}, style  => $STYLE_TITLE},
        elements => [{type => 'pie',       values => \@values}]
    );
    Octopussy::OFC::Generate(\%conf, $output_file);

    return ($output_file);
}

1;

=head1 AUTHOR

Sebastien Thebert <octopussy@onetool.pm>

=cut

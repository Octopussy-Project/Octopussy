#!/usr/bin/perl
# $HeadURL$
# $Revision$
# $Date$
# $Author$

=head1 NAME

Octopussy_Search_Template.t - Octopussy Source Code Checker for Octopussy::Search_Template

=cut

use strict;
use warnings;
use Readonly;

use List::MoreUtils qw(true);
use Test::More tests => 5;

use Octopussy;
use Octopussy::Search_Template;

Readonly my $DIR_REPORTS    => Octopussy::Directory('search_templates');
Readonly my $PREFIX         => 'Octo_TEST_';
Readonly my $USER           => "${PREFIX}user";
Readonly my $DEVICE         => "${PREFIX}device";
Readonly my $SERVICE        => "${PREFIX}service";
Readonly my $SRCH_TPL_TITLE => "${PREFIX}search_template";
Readonly my $FILE_TPL       => "${DIR_REPORTS}${USER}/${SRCH_TPL_TITLE}.xml";
Readonly my $BEGIN_TPL      => '201001010000';
Readonly my $END_TPL        => '201001010010';

my %conf = (
  name        => $SRCH_TPL_TITLE,
  device      => [$DEVICE],
  service     => [$SERVICE],
  loglevel    => '-ANY-',
  taxonomy    => '-ANY-',
  msgid       => '-ANY-',
  begin       => $BEGIN_TPL,
  end         => $END_TPL,
  re_include  => 'incl1',
  re_include2 => 'incl2',
  re_include3 => 'incl3',
  re_exclude  => 'excl1',
  re_exclude2 => 'excl2',
  re_exclude3 => 'excl3',
);

unlink $FILE_TPL;

my @list1 = Octopussy::Search_Template::List($USER);

Octopussy::Search_Template::New($USER, \%conf);
ok(-f $FILE_TPL, 'Octopussy::Search_Template::New()');

my @list2 = Octopussy::Search_Template::List($USER);
ok((scalar @list1 == scalar @list2 - 1) && (grep { /$SRCH_TPL_TITLE/ } @list2),
  'Octopussy::Search_Template::List()');

my @list3 = Octopussy::Search_Template::List_Any_User();
ok(
  (scalar @list3 >= scalar @list2)
    && (true { $_->{name} =~ /^$SRCH_TPL_TITLE$/ } @list3),
  'Octopussy::Search_Template::List_Any_User()'
);

my $tconf = Octopussy::Search_Template::Configuration($USER, $SRCH_TPL_TITLE);
ok($tconf->{begin} eq $BEGIN_TPL && $tconf->{end} eq $END_TPL,
  'Octopussy::Search_Template::Configuration()');

Octopussy::Search_Template::Remove($USER, $SRCH_TPL_TITLE);
ok(!-f $FILE_TPL, 'Octopussy::Search_Template::Remove()');

unlink $FILE_TPL;

1;

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut

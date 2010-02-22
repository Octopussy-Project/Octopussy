#!/usr/bin/perl -w
# $HeadURL$
# $Revision$
# $Date$
# $Author$

=head1 NAME

services_integrity.t - Octopussy Services integrity Test

=head1 DESCRIPTION

It checks that:

=cut

use strict;
use warnings;

use English qw( -no_match_vars );
use Test::More tests => 1;

use AAT;
use Octopussy;
use Octopussy::Message;
use Octopussy::Table;
use Octopussy::Taxonomy;

my ($error_enabled, $warning_enabled) = (1, 1);
my %error     = ();
my $str_error = '';

my %msg = (
  MSG_ID_DUPLICATED    => "Service: %s - Duplicated msgid '%s'",
  MSG_ID_INVALID       => "Service: %s - Invalid msgid '%s'",
  MSG_ID_NOT_EXPLICIT  => "Service: %s - Not enough explicit msgid '%s'",
  MSG_LOGLEVEL_UNKNOWN => "Service: %s - msgid '%s' has unknown loglevel '%s'",
  MSG_PATTERN_DUPLICATED_FIELD =>
    "Service: %s - Duplicated field '%s' in msgid '%s'",
  MSG_PATTERN_FIELD_UNKNOWN  => "Service: %s - Field '%s' unknown for msgid '%s'",
  MSG_PATTERN_INVALID_REGEXP => "Service: %s - msg regexp of '%s' is invalid: %s",
  MSG_PATTERN_PID =>
    "Service: %s - msg pattern of '%s' contains pid field not of PID type",
  MSG_RANK_BAD_FORMAT => "Service: %s - Bad rank format for msgid '%s'",
  MSG_RANK_DUPLICATED =>
    "Service: %s - Duplicated msg rank '%s' between '%s' and '%s'",
  MSG_RANK_MISSING      => "Service: %s - msg rank '%s' is missing",
  MSG_RANK_OUT_OF_RANGE => "Service: %s - msg rank '%s' is out of range[001-%s]",
  MSG_TABLE_UNKNOWN     => "Service: %s - msgid '%s' has unknown table '%s'",
  MSG_TAXONOMY_UNKNOWN  => "Service: %s - msgid '%s' has unknown taxonomy '%s'",
  SVC_NAME_INVALID      => "Service: %s -  Invalid service name",
);

=head1 FUNCTIONS

=head2 Msg($level, $type, $m, @args)

=cut

sub Msg
{
  my ($level, $type, $m, @args) = @_;
  $level = uc($level);
  $type  = lc($type);

  if ( (($level eq "ERROR") && ($error_enabled))
    || (($level eq "WARNING") && ($warning_enabled)))
  {
    $str_error .= sprintf("[$level] " . $msg{$m} . "\n", @args);
  }

  $error{$level}{$type} =
    (AAT::NOT_NULL($error{$level}{$type}) ? $error{$level}{$type} + 1 : 1);

  return ($error{$level}{$type});
}

=head2 Check_Service_Message_Id($service, $msgid)

=cut

sub Check_Service_Message_Id
{
  my ($service, $msgid, $seen_msgid) = @_;

  if (AAT::NOT_NULL($seen_msgid->{$msgid}))
  {
    Msg("ERROR", "service", "MSG_ID_DUPLICATED", $service, $msgid);
  }
  else { $seen_msgid->{$msgid} = 1; }

  if ($msgid =~ /^${service}:[a-zA-Z0-9_]+$/)
  {
    if ($msgid =~ /^${service}:\d+$/)
    {
      Msg("WARNING", "service", "MSG_ID_NOT_EXPLICIT", $service, $msgid);
    }
  }
  else
  {
    Msg("ERROR", "service", "MSG_ID_INVALID", $service, $msgid);
  }

  return (undef);
}

=head2 Check_Service_Message_Rank($service, $msgid, $rank, $nb_msg, $seen_rank)

=cut

sub Check_Service_Message_Rank
{
  my ($service, $msgid, $rank, $nb_msg, $seen_rank) = @_;
  my $i_rank = int($rank);

  Msg("ERROR", "service", "MSG_RANK_BAD_FORMAT", $service, $msgid)
    if (length($rank) != 3);    ## no critic
  if (AAT::NOT_NULL($seen_rank->{"$i_rank"}))
  {
    Msg("ERROR", "service", "MSG_RANK_DUPLICATED", $service, $rank, $msgid,
      $seen_rank->{"$i_rank"});
  }
  else { $seen_rank->{"$i_rank"} = $msgid; }
  if (($i_rank < 1) || ($i_rank > $nb_msg))
  {
    Msg("ERROR", "service", "MSG_RANK_OUT_OF_RANGE", $service, $rank,
      sprintf('%03d', 3));
  }

  return (undef);
}

=head2 Check_Service_Message_Pattern($service, $msgid, $m)

=cut

sub Check_Service_Message_Pattern
{
  my ($service, $msgid, $m) = @_;

  my @fields = Octopussy::Message::Fields($service, $msgid);
  my $table   = Octopussy::Message::Table($service, $msgid);
  my @tfields = Octopussy::Table::Fields($table);
  my %tf      = %{{map { $_->{title} => 1 } @tfields}};
  my %fcount  = ();
  foreach my $f (@fields)
  {
    Msg("WARNING", "service", "MSG_PATTERN_PID", $service, $msgid)
      if (($f->{name} eq 'pid') && ($f->{type} ne 'PID'));
    $fcount{$f->{name}} =
      (AAT::NOT_NULL($fcount{$f->{name}}) ? $fcount{$f->{name}} + 1 : 1);
  }
  foreach my $fc (sort keys %fcount)
  {
    Msg("ERROR", "service", "MSG_PATTERN_DUPLICATED_FIELD",
      $service, $fc, $msgid)
      if ($fcount{$fc} > 1);
    Msg("ERROR", "service", "MSG_PATTERN_FIELD_UNKNOWN", $service, 
      "$table:$fc", $msgid)
      if (AAT::NULL($tf{$fc}));
  }
  my $re = Octopussy::Message::Pattern_To_Regexp($m);
  eval ' "test" =~ /$re/ ';
  Msg("WARNING", "service", "MSG_PATTERN_INVALID_REGEXP", $service, $msgid,
    $EVAL_ERROR)
    if ($EVAL_ERROR);

  return (undef);
}

=head2 Check_Service_Messages($service, \%table, \%loglevel, \%taxo)

=cut

sub Check_Service_Messages
{
  my ($service, $table, $loglevel, $taxo) = @_;
  my $conf        = Octopussy::Service::Configuration($service);
  my $serv        = $conf->{name};
  my $nb_messages = scalar(@{$conf->{message}});
  my %seen_msgid  = ();
  my %seen_rank   = ();
  foreach my $m (@{$conf->{message}})
  {
    my ($msgid, $rank, $m_table, $m_loglevel, $m_taxo, $pattern) = (
      $m->{msg_id},   $m->{rank},     $m->{table},
      $m->{loglevel}, $m->{taxonomy}, $m->{pattern}
    );
    Check_Service_Message_Id($serv, $msgid, \%seen_msgid);
    Check_Service_Message_Rank($serv, $msgid, $rank, $nb_messages, \%seen_rank);
    Check_Service_Message_Pattern($serv, $msgid, $m);
    Msg("ERROR", "service", "MSG_TABLE_UNKNOWN", $service, $msgid, $m_table)
      if (AAT::NULL($table->{$m_table}));
    Msg("ERROR", "service", "MSG_LOGLEVEL_UNKNOWN", $service, $msgid,
      $m_loglevel)
      if (AAT::NULL($loglevel->{$m_loglevel}));
    Msg("ERROR", "service", "MSG_TAXONOMY_UNKNOWN", $service, $msgid, $m_taxo)
      if (AAT::NULL($taxo->{$m_taxo}));
  }
  for my $i (1 .. $nb_messages)
  {
    Msg("ERROR", "service", "MSG_RANK_MISSING", $serv, $i)
      if (AAT::NULL($seen_rank{$i}));
  }

  return (undef);
}

=head2 MAIN

=cut

my @services = Octopussy::Service::List();
my %table    = %{{map { $_ => 1 } Octopussy::Table::List()}};
my %loglevel = %{{map { $_->{value} => 1 } Octopussy::Loglevel::List()}};
my %taxo     = %{{map { $_->{value} => 1 } Octopussy::Taxonomy::List()}};
($error{ERROR}{service}, $error{WARNING}{service}) = (0, 0);

foreach my $service (@services)
{
  if ($service !~ /^[a-z][a-z0-9_-]+$/i)
  {
    Msg("ERROR", "service", "SVC_NAME_INVALID", $service);
  }
  else { Check_Service_Messages($service, \%table, \%loglevel, \%taxo); }
}
print "->Checker_Services:\n";
print "  Errors: $error{ERROR}{service} Warnings: $error{WARNING}{service}\n";

ok($error{ERROR}{service} == 0 && $error{WARNING}{service} == 0,
  'Services Integrity')
  or diag($str_error);

1;

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut

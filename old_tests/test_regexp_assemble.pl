#!/usr/bin/perl 

use strict;
use warnings;

use Regexp::Assemble;

use FindBin;
use lib "$FindBin::Bin/../usr/share/perl5";

use Octopussy;
use Octopussy::Message;
use Octopussy::Service;


my @services = ($ARGV[0]) || Octopussy::Service::List();
my $nb_ok = 0;
my %invalid;

printf("Nb Services: %d\n", scalar @services);

foreach my $serv (@services)
{
  my $ra   = Regexp::Assemble->new;
  my @messages     = Octopussy::Service::Messages($serv);
  foreach my $m (@messages)
  {
    # check if the regexp is valid
    my $valid_regexp = eval {
      use warnings FATAL => qw( regexp );
      my $re = Octopussy::Message::Pattern_To_Regexp($m);
      qr/$re/;
    };

    if ($valid_regexp)
    {
	$ra->add(Octopussy::Message::Pattern_To_Regexp($m));
    }
  }
  # Regexp::Assemble succeed to assemble ?
  eval 
  {
    my $global = $ra->re; 
  };
  printf("Service %s => %s\n", $serv, ($@ ? "NOK => $@" : "OK"));
  $nb_ok++  if (! $@);
  $invalid{$serv} = 1 if ($@);
}

printf "Result: %s / %s\n", $nb_ok, scalar @services;
foreach my $s (keys %invalid)
{
  print "$s\n";
}

1;


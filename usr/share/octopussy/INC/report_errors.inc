<!--
#################### Octopussy Project ####################
 $Id$
###########################################################
-->
<%
my %arg = @_;

my @table = ( 
	[ { label => "Report Errors", align => "center", 
			style => "bold", colspan => 2 } ],
 	[ { label => "<hr>", colspan => 2 } ] );

open(FILE, "< $arg{file}");
while(<FILE>)
{
  if ($_ =~ /^(.+) at (.+) line (\d+).$/)
  {
    my ($error, $file, $line) = ($1, $2, $3);
    push(@table, [ { label => "File: $file" }, { label => "Line: $line" } ]);
    push(@table, [ { label => $error, colspan => 2, color => "red" } ]);
    push(@table, [ { label => "<hr>", colspan => 2 } ]);
  }
  else
  {
    push(@table, [ { label => $error, colspan => 2, color => "red" } ]);
    push(@table, [ { label => "<hr>", colspan => 2 } ]);
  }
}
close(FILE);
push(@table, [ { label => "Back to Reports", align => "center",
  colspan => 2, link => "./reports.asp" } ]);

$Response->Include('INC/box.inc', elements => \@table, width => 800);
%>

<% 
use constant BUFFER_SIZE     => 65_536;

my $buffer = "";
my $file = $Request->QueryString("file");

local *IMAGE;
open IMAGE, $file;
while (read(IMAGE, $buffer, BUFFER_SIZE))
{
  $Response->Write($buffer);
}
close IMAGE;
%>

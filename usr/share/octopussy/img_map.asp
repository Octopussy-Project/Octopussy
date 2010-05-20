<% 
use constant BUFFER_SIZE => 65_536;

my $buffer = "";
my $map = $Request->QueryString("map");

my $conf = Octopussy::Map::Configuration($map);
my $map_dir = Octopussy::FS::Directory("maps");

local *IMAGE;
open IMAGE, $map_dir . $conf->{filename};
while (read(IMAGE, $buffer, BUFFER_SIZE))
{
  $Response->Write($buffer);
}
close IMAGE;
%>

<%
my $q = $Request->QueryString();

if ($q->{id} =~ /^\d+$/)
{
	my @data = AAT::DB::Query("Octopussy", 
  		"SELECT * FROM World_Servers where id='$q->{id}'");

	AAT::DB::Insert("Octopussy", "World_Servers",
    	{ id => $q->{id}, version => $q->{version}, country => $q->{country}, 
      	cpu => $q->{cpu}, memory => $q->{memory} } );
#  if ($#data >= 0);

	my $dt = "$1-$2-$3 $4:00:00" 
  		if ($q->{hour} =~ /(\d{4})(\d{2})(\d{2})(\d{2})/);

	AAT::DB::Insert("Octopussy", "World_Logs",
    	{ id => $q->{id}, hour => $dt,
      	nb_devices => $q->{nb_devices}, nb_services => $q->{nb_services}, 
      	nb_logs => $q->{nb_logs} } );
}
%>

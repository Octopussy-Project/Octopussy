<%
my $run_dir = Octopussy::FS::Directory("running");
my $login = $Session->{AAT_LOGIN};
my $filename = $Session->{extracted};

if (NOT_NULL($login) && NOT_NULL($Session->{file}))
{
	my $output = $Session->{export} . ".txt";
	($Session->{file}, $Session->{export}, $Session->{extractor},
  	$Session->{extracted}) = (undef, undef, undef, undef);
	AAT::File_Save( { contenttype => "text/txt",
  	input_file => "${run_dir}/logs_${login}_$filename", 
		output_file => $output } );
}
elsif (NOT_NULL($login) && NOT_NULL($Session->{csv}))
{
	open(FILE, "<", "$run_dir/logs_${login}_$filename");
 	while (<FILE>)
  	{
  		$text .= "$1;$2;$3\n"
    		if ($_ =~ /^(\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(?:\.\d{1,6})?.\d{2}:\d{2}) (\S+) (.+)$/);
  	}
  	close(FILE);
  
	my $output = $Session->{export} . ".csv";
  	($Session->{csv}, $Session->{export}, $Session->{extractor},
  		$Session->{extracted}) = (undef, undef, undef, undef);
  	AAT::File_Save( { contenttype => "text/csv",
  		input_data => $text, output_file => $output } );
}
elsif (NOT_NULL($login) && NOT_NULL($Session->{zip}))
{
	my $output = $Session->{export} . ".txt.gz";
 	open(ZIP, "|gzip >> $run_dir/logs_${login}_$filename.gz");
 	open(FILE, "<", "$run_dir/logs_${login}_$filename");
 	while (<FILE>)
  		{ print ZIP $_; }
  	close(FILE);
 	close(ZIP);
  	($Session->{zip}, $Session->{export}, $Session->{extractor},
  		$Session->{extracted}) = (undef, undef, undef, undef);
  	AAT::File_Save( { contenttype => "archive/gzip",
  		input_file => "$run_dir/logs_${login}_$filename.gz",
    	output_file => $output } );
}
%>

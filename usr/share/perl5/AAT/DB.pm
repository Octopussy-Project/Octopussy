=head1 NAME

AAT::DB - AAT Database module

=cut
package AAT::DB;

use strict;
use DBI;

my %conf_file = ();
my %dbh = ();

=head1 FUNCTIONS

=head2 Configuration($appli)

Returns the Database configuration for the application '$appli'

=cut
sub Configuration($)
{
	my $appli = shift;

	$conf_file{$appli} ||= AAT::Application::File($appli, "db");
  my $conf = AAT::XML::Read($conf_file{$appli}, 1);

  return ($conf->{database});	
}

=head2 Connect($appli)

Connects to the Database for the application '$appli'

=cut
sub Connect($)
{
	my $appli = shift;

	my $conf_db = Configuration($appli);
	my $type = $conf_db->{db_type} || "mysql";
	$dbh{$appli} = DBI->connect("DBI:$type:database=$conf_db->{db};host=$conf_db->{host}",
		$conf_db->{user}, $conf_db->{password});

	return ("$DBI::err: $DBI::errstr")  if (!defined $dbh{$appli});
	return (undef);
}

=head2 Connection_Test($appli)

Checks the Database Connection for the application '$appli'

=cut
sub Connection_Test($)
{
	my $appli = shift;

	Connect($appli);
	my $status = (defined $dbh{$appli} ? 1 : 0);	
	Disconnect($appli);

	return ($status);
}

=head2 Disconnect($appli)

Disconnects from Database application '$appli'

=cut
sub Disconnect($)
{
	my $appli = shift;

  $dbh{$appli}->disconnect() if (defined $dbh{$appli});
	$dbh{$appli} = undef;
}

=head2 Do($appli, $sql)

Does the SQL action '$sql' in application '$appli'

=cut
sub Do($$)
{
  my ($appli, $sql) = @_;

  Connect($appli);
  $dbh{$appli}->do($sql)  if (defined $dbh{$appli});
  Disconnect($appli);
}

=head2 Table_Destruction($appli, $table)

Drops the Table '$table' in application '$appli'

=cut
sub Table_Destruction($$)
{
  my ($appli, $table) = @_;

	Do($appli, "DROP TABLE IF EXISTS $table");
}

=head2 Insert($appli, $table, $field_values)

Inserts values '$field_values' in Table '$table' in application '$appli'

=cut
sub Insert($$$)
{
  my ($appli, $table, $field_values) = @_;

  Connect($appli);
  if (defined $dbh{$appli})
	{
		my $sql = "INSERT INTO $table(";
  	$sql .= join(", ", sort (AAT::HASH_KEYS($field_values)));
  	$sql .= ") VALUES(";
  	foreach my $k (sort (AAT::HASH_KEYS($field_values)))
    	{ $sql .= $dbh{$appli}->quote($field_values->{$k}) . ", "; }
  	$sql =~ s/, $/\)/;
  	$dbh{$appli}->do($sql);
		Disconnect($appli);
	}
}

=head2 Prepare($appli, $sql)

Prepares the SQL statement '$sql' in application '$appli'

=cut
sub Prepare($$)
{
  my ($appli, $sql) = @_;

  Connect($appli);
  my $prepared = $dbh{$appli}->prepare($sql)  if (defined $dbh{$appli});
  Disconnect($appli);

  return ($prepared);
}

=head2 Query($appli, $query)

Executes the SQL Query '$query' in application '$appli'

=cut
sub Query($$)
{
  my ($appli, $query) = @_;

  Connect($appli);
	if (defined $dbh{$appli})
	{
  	my $sth = $dbh{$appli}->prepare($query);
  	$sth->execute();
  	my @data = ();
  	while (my $ref = $sth->fetchrow_hashref())
    	{ push(@data, $ref); }
  	Disconnect($appli);

  	return (@data);
	}
	return (undef);
}

=head2 Load_File($appli, $table, $file, $lines)

Loads Data File '$file' with lines '$lines' 
into table '$table' in application '$appli'

=cut
sub Load_Infile($$$$)
{
  my ($appli, $table, $file, $lines) = @_;

  if (defined open(DBFILE, "> $file"))
	{
  	foreach my $l (AAT::ARRAY($lines))
    	{ print DBFILE "$l\n" if ($l =~ /\S+/); }
  	close(DBFILE);
		Do($appli, "LOAD DATA INFILE '$file' INTO TABLE $table" . "_$$");
	}
	else
	{ 
		my ($pack, $file, $line, $sub) = caller(0);
		AAT::Syslog("AAT::DB", "Unable to open file '$file' in $sub");
	}
}

1;

=head1 SEE ALSO

AAT(3), AAT::Syslog(3), AAT::Theme(3), AAT::Translation(3), AAT::User(3), AAT::XML(3)

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut

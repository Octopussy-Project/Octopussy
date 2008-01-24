=head1 NAME

AAT::DB - AAT Database module

=cut

package AAT::DB;

use strict;
use DBI;

my $DB_FILE = undef;
my $dbh = undef;

=head1 FUNCTIONS

=head2 Configuration()

=cut

sub Configuration()
{
	$DB_FILE ||= AAT::File("db");
  my $conf = AAT::XML::Read($DB_FILE, 1);

  return ($conf->{database});	
}

=head2 Connect()

Connect to Database

=cut

sub Connect()
{
	my $db_conf = Configuration();
	my $type = $db_conf->{db_type} || "mysql";
	$dbh = DBI->connect("DBI:$type:database=$db_conf->{db};host=$db_conf->{host}",
		$db_conf->{user}, $db_conf->{password});
	
	return ("$DBI::err: $DBI::errstr")	if (!defined $dbh);
	return (undef);
}

=head2 Connection_Test()

Check the Database Connection

=cut

sub Connection_Test()
{
	Connect();
	my $status = (defined $dbh ? 1 : 0);	
	Disconnect();

	return ($status);
}

=head2 Disconnect()

Disconnect from Database

=cut

sub Disconnect()
{
  $dbh->disconnect() if (defined $dbh);
	$dbh = undef;
}

=head2 Do($sql)

Do the SQL action '$sql'

=cut

sub Do($)
{
  my $sql = shift;

  Connect();
  $dbh->do($sql)  if (defined $dbh);
  Disconnect();
}

=head2 Table_Destruction($tablename)

=cut

sub Table_Destruction($)
{
  my $tablename = shift;

	Do("DROP TABLE IF EXISTS $tablename");
}

=head2 Insert($table, $field_values)

=cut

sub Insert($$)
{
  my ($table, $field_values) = @_;

  Connect();
  if (defined $dbh)
	{
		my $sql = "INSERT INTO $table(";
  	$sql .= join(", ", sort (AAT::HASH_KEYS($field_values)));
  	$sql .= ") VALUES(";
  	foreach my $k (sort (AAT::HASH_KEYS($field_values)))
    	{ $sql .= $dbh->quote($field_values->{$k}) . ", "; }
  	$sql =~ s/, $/\)/;
  	$dbh->do($sql);
		Disconnect();
	}
}

=head2 Prepare($sql)

Prepare the SQL statement '$sql'

=cut

sub Prepare($)
{
  my $sql = shift;

  Connect();
  my $prepared = $dbh->prepare($sql)  if (defined $dbh);
  Disconnect();

  return ($prepared);
}

=head2 Query($query)

Execute the SQL Query '$query'

=cut

sub Query($)
{
  my $query = shift;

  Connect();
	if (defined $dbh)
	{
  	my $sth = $dbh->prepare($query);
  	$sth->execute();
  	my @data = ();
  	while (my $ref = $sth->fetchrow_hashref())
    	{ push(@data, $ref); }
  	Disconnect();

  	return (@data);
	}
	return (undef);
}

=head2 Load_File($table, $file)

Load Data File '$file' with lines '$lines' into table '$table'

=cut

sub Load_Infile($$$)
{
  my ($table, $file, $lines) = @_;

  open(DBFILE, "> $file");
  foreach my $l (AAT::ARRAY($lines))
    { print DBFILE "$l\n" if ($l =~ /\S+/); }
  close(DBFILE);
	Do("LOAD DATA INFILE '$file' INTO TABLE $table" . "_$$");
}

1;

=head1 SEE ALSO

AAT(3), AAT::Syslog(3), AAT::Theme(3), AAT::Translation(3), AAT::User(3), AAT::XML(3)

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut

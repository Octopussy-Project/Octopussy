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

=cut

sub Configuration($)
{
	my $appli = shift;

	$conf_file{$appli} ||= AAT::Application::File($appli, "db");
  my $conf = AAT::XML::Read($conf_file{$appli}, 1);

  return ($conf->{database});	
}

=head2 Connect($appli)

Connect to Database

=cut

sub Connect($)
{
	my $appli = shift;

	my $db_conf = Configuration($appli);
	my $type = $db_conf->{db_type} || "mysql";
	$dbh{$appli} = DBI->connect("DBI:$type:database=$db_conf->{db};host=$db_conf->{host}",
		$db_conf->{user}, $db_conf->{password});
	
	return ("$DBI::err: $DBI::errstr")	if (!defined $dbh{appli});
	return (undef);
}

=head2 Connection_Test($appli)

Check the Database Connection

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

Disconnect from Database

=cut

sub Disconnect($)
{
	my $appli = shift;

  $dbh{$appli}->disconnect() if (defined $dbh{$appli});
	$dbh{$appli} = undef;
}

=head2 Do($appli, $sql)

Do the SQL action '$sql'

=cut

sub Do($$)
{
  my ($appli, $sql) = @_;

  Connect($appli);
  $dbh{$appli}->do($sql)  if (defined $dbh{$appli});
  Disconnect($appli);
}

=head2 Table_Destruction($appli, $tablename)

=cut

sub Table_Destruction($$)
{
  my ($appli, $tablename) = @_;

	Do($appli, "DROP TABLE IF EXISTS $tablename");
}

=head2 Insert($appli, $table, $field_values)

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

Prepare the SQL statement '$sql'

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

Execute the SQL Query '$query'

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

=head2 Load_File($appli, $table, $file)

Load Data File '$file' with lines '$lines' into table '$table'

=cut

sub Load_Infile($$$$)
{
  my ($appli, $table, $file, $lines) = @_;

  open(DBFILE, "> $file");
  foreach my $l (AAT::ARRAY($lines))
    { print DBFILE "$l\n" if ($l =~ /\S+/); }
  close(DBFILE);
	Do($appli, "LOAD DATA INFILE '$file' INTO TABLE $table" . "_$$");
}

1;

=head1 SEE ALSO

AAT(3), AAT::Syslog(3), AAT::Theme(3), AAT::Translation(3), AAT::User(3), AAT::XML(3)

=head1 AUTHOR

Sebastien Thebert <octo.devel@gmail.com>

=cut

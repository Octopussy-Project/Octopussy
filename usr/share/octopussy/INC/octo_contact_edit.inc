<%
my %arg = @_;

my $conf = Octopussy::Contact::Configuration($arg{contact});
my ($c_cid, $c_lastname, $c_firstname, $c_desc, $c_email, $c_im, $c_type) = 
	($conf->{cid}, $conf->{lastname}, $conf->{firstname}, $conf->{description}, 
	$conf->{email}, $conf->{im}, $conf->{type});
%>
<AAT:Form action="./contacts.asp">
<AAT:Form_Hidden name="action" value="update" />
<AAT:Form_Hidden name="cid" value="$c_cid" />
<AAT:Form_Hidden name="type" value="$c_type" />
<AAT:Box align="C">
<AAT:BoxRow>
	<AAT:BoxCol rspan="5"><AAT:IMG name="generic_contacts" /></AAT:BoxCol>
	<AAT:BoxCol><AAT:Label value="_LASTNAME" style="B" /></AAT:BoxCol>
	<AAT:BoxCol>
	<AAT:Entry name="lastname" value="$c_lastname" size="60" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
    <AAT:BoxCol><AAT:Label value="_FIRSTNAME" style="B" /></AAT:BoxCol>
    <AAT:BoxCol>
    <AAT:Entry name="firstname" value="$c_firstname" size="60" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
	<AAT:BoxCol><AAT:Label value="_DESCRIPTION" style="B" /></AAT:BoxCol>
 	<AAT:BoxCol>
  <AAT:Entry name="description" value="$c_desc" size="60" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
    <AAT:BoxCol><AAT:Label value="_EMAIL" style="B" /></AAT:BoxCol>
    <AAT:BoxCol>
  <AAT:Entry name="email" value="$c_email" size="60" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
    <AAT:BoxCol><AAT:Label value="IM" style="B" /></AAT:BoxCol>
    <AAT:BoxCol>
  <AAT:Entry name="im" value="$c_im" size="60" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow><AAT:BoxCol cspan="3"><hr></AAT:BoxCol></AAT:BoxRow>
<AAT:BoxRow>
  <AAT:BoxCol cspan="3" align="C">
	<AAT:Form_Submit value="_UPDATE" /></AAT:BoxCol>
</AAT:BoxRow>
</AAT:Box>
</AAT:Form>

<%
my %arg = @_;
my $url = $arg{url};
my $sort = defined $arg{sort} ? lc($arg{sort}) : "cid";
my $role = $Session->{AAT_ROLE};
my $lnk = "${url}?contacts_table_sort";
%>
<AAT:Box align="C" title="_CONTACTS" icon="buttons/bt_contact">
<AAT:BoxRow>
  <AAT:BoxCol>
  <AAT:Label value="ID" link="$lnk=cid" /></AAT:BoxCol>
	<AAT:BoxCol>
  <AAT:Label value="_LASTNAME" link="$lnk=lastname" /></AAT:BoxCol>
	<AAT:BoxCol>
  <AAT:Label value="_FIRSTNAME" link="$lnk=firstname" /></AAT:BoxCol>
	<AAT:BoxCol>
  <AAT:Label value="_DESCRIPTION" link="$lnk=description" /></AAT:BoxCol>
	<AAT:BoxCol cspan="2" align="C">
  <AAT:Label value="_EMAIL" link="$lnk=email" /></AAT:BoxCol>
	<AAT:BoxCol cspan="2" align="C">
  <AAT:Label value="IM" link="$lnk=im" /></AAT:BoxCol>
	<AAT:BoxCol>
  <AAT:Label value="_TYPE" link="$lnk=type" /></AAT:BoxCol>
	<AAT:BoxCol align="C" cspan="2">
<%
if ($Session->{AAT_ROLE} =~ /(admin|rw)/i)
{
	%><AAT:Label value="_ACTION" style="B"/><%
}
%>	</AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow><AAT:BoxCol cspan="11"><hr></AAT:BoxCol></AAT:BoxRow>
<%
my $i = 0;
foreach my $c (Octopussy::Contact::Configurations($sort))
{
	my ($id, $lastname, $firstname, $desc, $email, $im, $type) =
		($c->{cid}, $c->{lastname}, $c->{firstname}, $c->{description}, 
		$c->{email}, $c->{im}, $c->{type});
	my $id_url = $Server->URLEncode($id);
	my $class = (($i%2) ? "boxcolor1" : "boxcolor2");
  $i++;
%><AAT:BoxRow class="$class">
	<AAT:BoxCol><AAT:Label value="$id" /></AAT:BoxCol>
	<AAT:BoxCol><AAT:Label value="$lastname" /></AAT:BoxCol>
	<AAT:BoxCol><AAT:Label value="$firstname" /></AAT:BoxCol>
	<AAT:BoxCol><i><AAT:Label value="$desc" /></i></AAT:BoxCol>
	<AAT:BoxCol>
  <%
  if (NOT_NULL($email))
  {
  %><AAT:IMG name="buttons/bt_mail_forward" width="20" 
    link="./send_test.asp?type=smtp&dest=$email" tooltip="Test SMTP Send" /><%
  }
  %>
  </AAT:BoxCol>
  <AAT:BoxCol><AAT:Label value="$email" /></AAT:BoxCol>
  <AAT:BoxCol>
  <%
  if (NOT_NULL($im))
  {
  %><AAT:IMG name="buttons/bt_mail_forward" width="20" 
    link="./send_test.asp?type=xmpp&dest=$im" tooltip="Test XMPP Send" /><%
  }
  %>
  </AAT:BoxCol>
	<AAT:BoxCol><AAT:Label value="$im" /></AAT:BoxCol>
	<AAT:BoxCol><AAT:Label value="$type" /></AAT:BoxCol>
	<AAT:BoxCol align="C"><%
	if ($Session->{AAT_ROLE} =~ /(admin|rw)/i)
	{%>
	<AAT:Button name="edit" tooltip="_EDIT"
    	link="./contacts.asp?cid=$id&action=edit" /><%
	}%>
	</AAT:BoxCol>
	<AAT:BoxCol align="C"><%
	if (($type eq "local") && ($Session->{AAT_ROLE} =~ /(admin|rw)/i))
	{ 
		%><AAT:Button name="remove" tooltip="_REMOVE"
    popup_link="./dialog.asp?id=delete_contact&arg1=$id_url&action=remove" /><%
	}%>
	</AAT:BoxCol>
</AAT:BoxRow><%
}

if ($role !~ /ro/i)
{
%>
<AAT:Form action="$url">
<AAT:BoxRow><AAT:BoxCol cspan="11"><hr></AAT:BoxCol></AAT:BoxRow>
<AAT:BoxRow>
  <AAT:BoxCol><AAT:Entry name="cid" size="12" /></AAT:BoxCol>
  <AAT:BoxCol><AAT:Entry name="lastname" size="16" /></AAT:BoxCol>
  <AAT:BoxCol><AAT:Entry name="firstname" size="16" /></AAT:BoxCol>
  <AAT:BoxCol><AAT:Entry name="description" /></AAT:BoxCol>
  <AAT:BoxCol cspan="2"><AAT:Entry name="email" /></AAT:BoxCol>
  <AAT:BoxCol cspan="2"><AAT:Entry name="im" /></AAT:BoxCol>
	<AAT:BoxCol cspan="3"><AAT:Form_Submit value="_NEW_CONTACT" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:Form_Hidden name="action" value="new" />
</AAT:Form><%
}%>
</AAT:Box>

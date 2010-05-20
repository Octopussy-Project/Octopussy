<WebUI:PageTop title="_CONTACTS" help="contacts" />
<%
my $f = $Request->Form();
my $cid = $f->{cid} || $Request->QueryString("cid");
my $action = $f->{action} || $Request->QueryString("action");
my $sort = $Request->QueryString("contacts_table_sort") || "lastname";	

if ((NOT_NULL($action)) && ($action eq "remove") 
		&& ($Session->{AAT_ROLE} !~ /ro/i))
{
	Octopussy::Contact::Remove($cid);
	AAT::Syslog::Message("octo_WebUI", "GENERIC_DELETED", "Contact", $cid);
	$Response->Redirect("./contacts.asp");
}
elsif ((NOT_NULL($action)) && ($action eq "new") 
			&& ($Session->{AAT_ROLE} !~ /ro/i))
{
 	$Session->{AAT_MSG_ERROR} = Octopussy::Contact::New( { 
		cid => $f->{cid}, lastname => Encode::decode_utf8($f->{lastname}), 
    firstname => Encode::decode_utf8($f->{firstname}),
  	description => Encode::decode_utf8($f->{description}), 
    email => $Server->HTMLEncode($f->{email}), im => $f->{im} } );
	AAT::Syslog::Message("octo_WebUI", "GENERIC_CREATED", "Contact", $cid)
		if (NOT_NULL($Session->{AAT_MSG_ERROR}));
	$Response->Redirect("./contacts.asp");
}
%>
<AAT:Inc file="octo_contacts_list" url="./contacts.asp" sort="$sort" />
<WebUI:PageBottom />

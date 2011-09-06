<select id="search_template" name="search_template" 
	onchange="update_search_params(this.options[this.selectedIndex].value)">
<%
my %arg = @_;
my $login = $Session->{AAT_LOGIN};
$Response->Include("AAT/INC/AAT_OptionSelector.inc", value => "",
	selected => ($arg{selected} eq "" ? "selected" : ""), label => "-- NONE --");
foreach my $e (Octopussy::Search_Template::List($login))
{
	$Response->Include("AAT/INC/AAT_OptionSelector.inc", value => $e,
    selected => ($arg{selected} eq $e ? "selected" : ""), label => $e );
}
%>
</select>
<script type="text/javascript">

function update_search_params(tpl)
{
	$.get('ajax_list_searchtemplate.asp?template=' + tpl, function(xml) { print_search_params(xml); });

	return true;
}

function print_search_params(xml)
{
	var xmldoc = $.parseXML(xml);

	$("#template").val($(xmldoc).find('template').text());

	$("#device option:selected").removeAttr("selected");
        var devices = $(xmldoc).find('device').text().split(',');
	$(devices).each(function (i, value)
                {                
		$('#device option[value="' + value + '"]').attr('selected', 'selected');
                } );
	$("#service option:selected").removeAttr("selected");
	var services = $(xmldoc).find('service').text().split(',');
	$(services).each(function (i, value)
		{
		$('#service option[value="' + value + '"]').attr('selected', 'selected');
		} );

	$("#loglevel option:selected").removeAttr("selected");
    	$('#loglevel option[value="' + $(xmldoc).find('loglevel').text() + '"]').attr('selected', 'selected'); 
	$("#taxonomy option:selected").removeAttr("selected");
	$('#taxonomy option[value="' + $(xmldoc).find('taxonomy').text() + '"]').attr('selected', 'selected');
	$("#msgid option:selected").removeAttr("selected");
	$('#msgid option[value="' + $(xmldoc).find('msgid').text() + '"]').attr('selected', 'selected');
 
	$('#re_include').val($(xmldoc).find('re_include').text());
        $('#re_include2').val($(xmldoc).find('re_include2').text());
        $('#re_include3').val($(xmldoc).find('re_include3').text());
	$('#re_exclude').val($(xmldoc).find('re_exclude').text());
	$('#re_exclude2').val($(xmldoc).find('re_exclude2').text());
	$('#re_exclude3').val($(xmldoc).find('re_exclude3').text());
}
</script>

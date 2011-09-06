<% 
my %arg = @_; 
my $select_options = (defined $arg{multiple} ? " multiple" : "")
  . (defined $arg{size} ? " size=$arg{size}" : "");
my %selected = ();
foreach my $s (ARRAY($arg{selected}))
  { $selected{$s} = 1; }

my $str_any = AAT::Translation("-- ANY --");
my $str_unknown = "-- " . uc(AAT::Translation("_UNKNOWN")) . " --";
%>
<select<%= $select_options %> id="service" name="service" 
	onchange="refresh_selector_loglevel();refresh_selector_taxonomy();refresh_selector_msgid();">
</select>
<script type="text/javascript">

function print_selector_service(xml)
{
        var xmldoc = $.parseXML(xml);
        var items = $(xmldoc).find('item');

	$('#service option').remove();
	$('#service').append($('<option></option>').val('-ANY-').html('<%= $str_any %>'));
<%
if ($selected{"-ANY-"})
{
  %>$('#service option[0]').attr('selected', 'selected');<%
}
my $start = 1;
if (defined $arg{unknown})
{
%>
	$('#service').append($('<option></option>').val('Unknown').html('<%= $str_unknown %>'));
<%
        if ($selected{"Unknown"})
        {
        %>$('#service option[<%= $start %>]').attr('selected', 'selected');<%
        }
        $start++;
}
%>
        $(items).each( function (i)
                {
                var value = items[i].getAttribute('label');
		var selected = items[i].getAttribute('selected');
                $('#service').append($('<option></option>').val(value).html(value));
		if (selected == 1)
			$('#service option[i]').attr('selected', 'selected');
                } );
}

function refresh_selector_service()
{
  var selector_device = $('#device');
  var devices_str = '';
  var selected_str = '';

  <%
  if (defined $arg{selected})
  {%>
  selected_str = '<% print join(",", @{$arg{selected}}); %>';<% 
  }%>

	$('#device option:selected').each( function () 
		{ devices_str = devices_str + $(this).text() + ','; } );
  
  	var params = 'devices=' + encodeURIComponent(devices_str) 
    		+ '&selected=' + encodeURIComponent(selected_str);

	$.get('ajax_list_service.asp?' + params, function(xml) { print_selector_service(xml); } );
	
  return true;
}

refresh_selector_service();
</script>

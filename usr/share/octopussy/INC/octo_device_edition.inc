<%
my %arg = @_;
my $device = $arg{device};

my $conf = Octopussy::Device::Configuration($device);
my @models = Octopussy::Device::Models($conf->{type});

my $name = "$conf->{name} / $conf->{address}";
my $type = $arg{type} || $conf->{type};
my $model = $conf->{model};
my $desc = $conf->{description};
my $logtype = $conf->{logtype} || "syslog";
my $location = (NOT_NULL($conf->{rack}) ? 
    "$conf->{city},$conf->{building},$conf->{room},$conf->{rack}"
    : (NOT_NULL($conf->{room}) ? "$conf->{city},$conf->{building},$conf->{room}"
    : (NOT_NULL($conf->{building}) ? "$conf->{city},$conf->{building}"
    : "$conf->{city}")));
my $logrotate = $conf->{logrotate};
my $minutes_without_logs = $conf->{minutes_without_logs};
my @logtype_list = ("asynchronous", "syslog");
my $icon = undef;
foreach my $m (@models)
{
	if ($m->{name} eq $conf->{model})
 	{
  	$icon = $m->{icon};
    last;
  }
}
%>
<AAT:Form action="./device_edit.asp">
<AAT:Box align="C">
<AAT:BoxRow>
	<AAT:BoxCol><AAT:Label value="_DEVICE" style="B" /></AAT:BoxCol>
	<AAT:BoxCol cspan="2"><AAT:Label value="$name" style="B" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow><AAT:BoxCol cspan="3"><hr></AAT:BoxCol></AAT:BoxRow>
<AAT:BoxRow>
	<AAT:BoxCol rspan="3"><%
if (defined $icon)
{ %><AAT:IMG name="$icon" /><% } %>
	</AAT:BoxCol>
	<AAT:BoxCol><AAT:Label value="_DEVICE_TYPE" /></AAT:BoxCol>
	<AAT:BoxCol cspan="2">
	<%
	if ($Session->{AAT_ROLE} =~ /(admin|rw)/i)
	{
		%><AAT:Inc file="octo_selector_device_type_dynamic" selected="$type" 
		url="./device_edit.asp?device=$device&device_type=" /><%
	}
	else
	{
		%><AAT:Label value="$type" /><%
	}
	%>
	</AAT:BoxCol>
	</AAT:BoxRow>
	<AAT:BoxRow>
  	<AAT:BoxCol><AAT:Label value="_DEVICE_MODEL" /></AAT:BoxCol>
  	<AAT:BoxCol>
	<%
    if ($Session->{AAT_ROLE} =~ /(admin|rw)/i)
    {
        %><AAT:Inc file="octo_selector_device_model" device_type="$type" 
		selected="$model" /><%
	}
    else
    {
        %><AAT:Label value="$model" /><%
    }
    %>
  	</AAT:BoxCol>
	</AAT:BoxRow>
	<AAT:BoxRow>
  	<AAT:BoxCol><AAT:Label value="_DESCRIPTION" /></AAT:BoxCol>
  	<AAT:BoxCol>
	<%
    if ($Session->{AAT_ROLE} =~ /(admin|rw)/i)
    {
        %><AAT:Entry name="description" size="50" value="$desc" /><%
	}
    else
    {        
		%><AAT:Label value="$desc" /><%
    }
    %>
	</AAT:BoxCol>
	</AAT:BoxRow>
	<AAT:BoxRow><AAT:BoxCol cspan="3"><hr></AAT:BoxCol></AAT:BoxRow>
	<AAT:BoxRow>
  	<AAT:BoxCol></AAT:BoxCol>
  	<AAT:BoxCol><AAT:Label value="_LOG_TYPE" /></AAT:BoxCol>
	<AAT:BoxCol>
	<%
    if ($Session->{AAT_ROLE} =~ /(admin|rw)/i)
    {
        %><AAT:Selector name="logtype" list=\@logtype_list selected="$logtype" /><%
	}
    else
    {        
		%><AAT:Label value="$logtype" /><%
    }
    %>
	</AAT:BoxCol>
</AAT:BoxRow>
<%
if ($conf->{logtype} eq "asynchronous")
{
	foreach my $a (ARRAY($conf->{async}))
  	{
		if ($a->{regexp} ne "")
		{
			my ($regexp, $output) = ($a->{regexp}, $a->{output});
			%><AAT:BoxRow>
  			<AAT:BoxCol></AAT:BoxCol>
			<AAT:BoxCol><AAT:Label value="_LOG_REGEXP" /></AAT:BoxCol>
			<AAT:BoxCol>
			<%
    		if ($Session->{AAT_ROLE} =~ /(admin|rw)/i)
    		{
        		%><AAT:Entry name="regexp" size="60" value="$regexp" /><%
			}
    		else
    		{        
				%><AAT:Label value="$regexp" /><%
    		}
    		%>
			</AAT:BoxCol>
			</AAT:BoxRow>
			<AAT:BoxRow>
  			<AAT:BoxCol></AAT:BoxCol>
			<AAT:BoxCol><AAT:Label value="_SYSLOG_OUTPUT" /></AAT:BoxCol>
			<AAT:BoxCol>
			<%
            if ($Session->{AAT_ROLE} =~ /(admin|rw)/i)
            {
                %><AAT:Entry name="output" size="60" value="$output" /><%
			}
            else
            {        
                %><AAT:Label value="$output" /><%
            }
            %>
			</AAT:BoxCol>
			</AAT:BoxRow><%
		}
	}
	%>
	<AAT:BoxRow>
  	<AAT:BoxCol></AAT:BoxCol>
	<AAT:BoxCol><AAT:Label value="_LOG_REGEXP" /></AAT:BoxCol>
  	<AAT:BoxCol><AAT:Entry name="regexp" size="60" value="" /></AAT:BoxCol>
	</AAT:BoxRow>
  	<AAT:BoxRow>
  	<AAT:BoxCol></AAT:BoxCol>
	<AAT:BoxCol><AAT:Label value="_SYSLOG_OUTPUT" /></AAT:BoxCol>
  	<AAT:BoxCol><AAT:Entry name="output" size="60" value="" /></AAT:BoxCol>
  	</AAT:BoxRow><%
} 
%>
<AAT:BoxRow><AAT:BoxCol cspan="3"><hr></AAT:BoxCol></AAT:BoxRow>
	<AAT:BoxRow>
  	<AAT:BoxCol></AAT:BoxCol>
	<AAT:BoxCol><AAT:Label value="_LOCATION" /></AAT:BoxCol>
	<AAT:BoxCol>
	<%
    if ($Session->{AAT_ROLE} =~ /(admin|rw)/i)
    {
        %><AAT:Inc file="octo_selector_location" selected="$location" /><%
	}
    else
    {
        %><AAT:Label value="$location" /><%
    }
    %>
	</AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow><AAT:BoxCol cspan="3"><hr></AAT:BoxCol></AAT:BoxRow>
<AAT:BoxRow>
  <AAT:BoxCol></AAT:BoxCol>
  <AAT:BoxCol><AAT:Label value="_LOGROTATE" /></AAT:BoxCol>
  <AAT:BoxCol>
  <%
    if ($Session->{AAT_ROLE} =~ /(admin|rw)/i)
    {
        %><AAT:Inc file="octo_selector_nbdays" name="logrotate" 
		min="10" max="600" step="10" selected="$logrotate" /><%
	}
    else
    {        
        %><AAT:Label value="$logrotate" /><%
    }
    %>
  </AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
  <AAT:BoxCol></AAT:BoxCol>
  <AAT:BoxCol><AAT:Label value="_MAX_TIME_WITHOUT_LOG" /></AAT:BoxCol>
  <AAT:BoxCol>
	<%
    if ($Session->{AAT_ROLE} =~ /(admin|rw)/i)
    {
        %><AAT:Inc file="octo_selector_max_mins_without_log"
			selected="$minutes_without_logs" /><%
	}
    else
    {
        %><AAT:Label value="$$minutes_without_logs" /><%
    }
    %>
  </AAT:BoxCol>
</AAT:BoxRow>
<%
if ($Session->{AAT_ROLE} =~ /(admin|rw)/i)
{
	%><AAT:BoxRow><AAT:BoxCol cspan="3"><hr></AAT:BoxCol></AAT:BoxRow>
	<AAT:BoxRow>
	<AAT:BoxCol cspan="3" align="C">
	<AAT:Form_Hidden name="modify" value="yes" />
	<AAT:Form_Hidden name="device" value="$device" />
	<AAT:Form_Submit value="_UPDATE" /></AAT:BoxCol>
	</AAT:BoxRow><%
}
%>
</AAT:Box>
</AAT:Form>

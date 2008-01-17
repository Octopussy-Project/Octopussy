<% my %arg = @_; %>
<AAT:Box width="$arg{width}">
<AAT:BoxRow>
  <AAT:BoxCol cspan="4"><AAT:Label value="_EXPORT_FTP" style="B"/></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow><AAT:BoxCol cspan="6"><hr></AAT:BoxCol></AAT:BoxRow>
<AAT:BoxRow>
	<AAT:BoxCol><AAT:Button name="device" /></AAT:BoxCol>
	<AAT:BoxCol><AAT:Label value="_HOST" /></AAT:BoxCol>
	<AAT:BoxCol><AAT:Entry name="ftp_host" /></AAT:BoxCol>
	<AAT:BoxCol><AAT:Button name="directory" /></AAT:BoxCol>
	<AAT:BoxCol><AAT:Label value="_DIRECTORY" /></AAT:BoxCol>
	<AAT:BoxCol><AAT:Entry name="ftp_dir" size="40" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
	<AAT:BoxCol><AAT:Button name="user" /></AAT:BoxCol>
	<AAT:BoxCol><AAT:Label value="_USER" /></AAT:BoxCol>
	<AAT:BoxCol><AAT:Entry name="ftp_user" /></AAT:BoxCol>
	<AAT:BoxCol><AAT:Button name="locked" /></AAT:BoxCol>
	<AAT:BoxCol><AAT:Label value="_PASSWORD" /></AAT:BoxCol>
	<AAT:BoxCol><AAT:Entry name="ftp_pwd" /></AAT:BoxCol>
</AAT:BoxRow>
</AAT:Box>

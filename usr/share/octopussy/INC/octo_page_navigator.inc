<%
my %arg = @_;
my ($url, $page, $page_last) = ($arg{url}, $arg{page}, $arg{page_last});
my $page_prev = ($page == 1 ? 1 : $page-1);
my $page_next = ($page == $page_last ? $page_last : $page+1);
%>
<table align="center">
<tr>
<td><AAT:Button name="2leftarrow" tooltip="_PAGE_FIRST" 
	link="$url&page=1" /></td>
<td><AAT:Button name="1leftarrow" tooltip="_PAGE_PREVIOUS" 
	link="$url&page=$page_prev" /></td>
<td><AAT:Label value="_PAGE" /><%= " $page / $page_last" %></td>
<td><AAT:Button name="1rightarrow" tooltip="_PAGE_NEXT" 
	link="$url&page=$page_next" /></td>
<td><AAT:Button name="2rightarrow" tooltip="_PAGE_LAST" 
	link="$url&page=$page_last" /></td>
</tr>
</table>

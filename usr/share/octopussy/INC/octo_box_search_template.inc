<AAT:Form action="$url">
<AAT:Box align="C">
<AAT:BoxRow>
	<AAT:BoxCol rspan="2" align="C">
	<AAT:Button name="search_template" tooltip="_SEARCH_TEMPLATES" />
	</AAT:BoxCol>
	<AAT:BoxCol width="*">
 	<AAT:Inc file="octo_selector_search_template" selected="" /></AAT:BoxCol>
	<AAT:BoxCol><AAT:Form_Button name="remove" value="template_remove" 
		tooltip="_REMOVE" /></AAT:BoxCol>
</AAT:BoxRow>
<AAT:BoxRow>
	<AAT:BoxCol>
  <AAT:Entry name="template" value="enter your template name" size="30" />
  </AAT:BoxCol>
	<AAT:BoxCol><AAT:Form_Button name="backup" value="template_save" 
		tooltip="_SAVE_AS_SEARCH_TEMPLATE" /></AAT:BoxCol>
</AAT:BoxRow>
</AAT:Box>
</AAT:Form>

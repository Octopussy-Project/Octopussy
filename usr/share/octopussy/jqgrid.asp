<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>My First Grid</title>
 
<link rel="stylesheet" type="text/css" media="screen" href="jqgrid/css/ui-lightness/jquery-ui-1.7.2.custom.css" />
<link rel="stylesheet" type="text/css" media="screen" href="jqgrid/css/ui.jqgrid.css" />
 
<style>
html, body {
    margin: 0;
    padding: 0;
    font-size: 75%;
}
</style>
 
<script src="jqgrid/js/jquery-1.3.2.min.js" type="text/javascript"></script>
<script src="jqgrid/js/i18n/grid.locale-en.js" type="text/javascript"></script>
<script src="jqgrid/js/jquery.jqGrid.min.js" type="text/javascript"></script>
 
 <script type="text/javascript">
jQuery(document).ready(function(){ 
  jQuery("#s4list").jqGrid({
    url:'example.php',
    datatype: 'xml',
    mtype: 'GET',
    colNames:['DateTime','Device', 'Daemon','Pid','Msg'],
    colModel :[ 
      {name:'datetime', index:'datetime', width:55}, 
      {name:'device', index:'device', width:90}, 
      {name:'daemon', index:'daemon', width:80, align:'right'}, 
      {name:'pid', index:'pid', width:80, align:'right'}, 
      {name:'msg', index:'msg', width:80, align:'right'}, 
      ],
    pager: '#s3pager',
    rowNum:10,
    rowList:[10,20,30],
    sortname: 'invid',
    sortorder: 'desc',
    viewrecords: true,
    caption: 'Octopussy Logs Viewer' 
  }).navGrid('#s3pager', 
  { edit:false,add:false,del:false,search:true,refresh:true }, 
  {}, // edit options 
  {}, // add options 
  {}, //del options 
  {multipleSearch:true} // search options 
  ); 


</script>
 
</head>
<body>
<table id="list"></table> 
<div id="pager"></div> 
</body>
</html>
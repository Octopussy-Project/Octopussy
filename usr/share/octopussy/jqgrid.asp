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
  jQuery("#mygrid").jqGrid({
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
    pager: '#mypager',
    width:700,
    rowNum:10,
    rowList:[10,20,30],
    sortname: 'invid',
    sortorder: 'desc',
    viewrecords: true,
    caption: 'Octopussy Logs Viewer',
  })
});

jQuery("#mygrid").jqGrid('navGrid','#mypager',
  {add:false,edit:false,del:false,search:true,refresh:true},
  {}, // edit options 
  {}, // add options 
  {}, //del options 
  {multipleSearch:true} // search options 
  ); 


/*jQuery("#mygrid").jqGrid('navGrid','#mypager',{edit:false,add:false,del:false});

jQuery("#mygrid").jqGrid('gridResize',{minWidth:350,maxWidth:800,minHeight:80, maxHeight:350});

jQuery("#mygrid").searchGrid( {multipleSearch:true} );

jQuery("mygrid").jqGrid('navButtonAdd','mypager',
  { caption: "Columns", title: "Reorder Columns", 
    onClickButton : function (){ jQuery("mygrid").jqGrid('columnChooser'); } 
  }); 
*/
</script>
 
</head>
<body>
<table id="mygrid"></table> 
<div id="mypager"></div> 
</body>
</html>

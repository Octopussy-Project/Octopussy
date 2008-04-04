var nb_lines = 0;
var timeoutid = 0;

function Timer()
{
  clearTimeout(timeoutid);
  timeoutid = setTimeout("FilterData()", 2000);
}

function FilterData()
{
  clearTimeout(timeoutid);
  nb_lines = 0;
  filter = document.getElementById("filter").value;
  if (filter.length > 1)
  { // at least 2 chars
    rows = document.getElementById("resultsTable").tBodies[0].rows;
    var regex = new RegExp("<\/?(font|b).*?>", "gi");
    var search = new RegExp("("+filter+")", "g");
    for (i = 0; i < rows.length; i++)
    {
      var cell = rows[i].cells[0];
      var str = cell.innerHTML;
      var newstr = str.replace(regex, "");
      newtext = newstr.replace(search,"<font color=\"orange\"><b>$1</b></font>");
      if (newtext == newstr)
      {
        rows[i].style.display = "none";
      }
      else
      {
        nb_lines++;
        rows[i].style.display = "";
        cell.innerHTML = newtext;
      }
    }
    spanNumber = document.getElementById("nb_lines");
    spanNumber.innerHTML = "<b>" + nb_lines + "</b>";
  }
  else
  {     
		for (i = 0; i < rows.length; i++)     
		{
			nb_lines++;       
			rows[i].style.display = "";     
		}   
	} 
} 

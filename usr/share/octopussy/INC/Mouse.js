/*
// JavaScript Mouse Module
*/

/*
// Function: Mouse_Coords(ev)
//
// Returns Mouse Coords
//
// in IE, ev.clientX is the Xpos in the Window, not in the Document
//  so we need to add  document.body.scrollLeft 
//  and then substract the body margin
// in Firefox, it's easy ! :)
*/
function Mouse_Coords(evt)
{
	// Firefox
  if (evt.pageX || evt.pageY)
  {
    return {x:evt.pageX, y:evt.pageY};
  }
  
	// IE
	return {
    x:evt.clientX + document.body.scrollLeft - document.body.clientLeft,
    y:evt.clientY + document.body.scrollTop - document.body.clientTop
  };
}


/*
// Function: Mouse_Offset(obj, evt)
//
// Returns X&Y offset between Mouse Coords and Object Coords
//
// in IE, event is global and is in window.event
// in Firefox, event is passed to the function
*/
function Mouse_Offset(obj, evt)
{
  evt = evt || window.event;

  var ObjPos = Object_Coords(obj);
  var MousePos = Mouse_Coords(evt);
  return {x:MousePos.x - ObjPos.x, y:MousePos.y - ObjPos.y};
}


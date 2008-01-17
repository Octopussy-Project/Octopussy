/*
// JavaScript Object Module
*/

/*
// Function: Object_Coords(obj)
//
// Returns Object Coords through all his parents
*/
function Object_Coords(obj)
{
	var left = 0;
	var top  = 0;

	while (obj.offsetParent)
	{
		left += obj.offsetLeft 
			+ (obj.currentStyle
				? (parseInt(obj.currentStyle.borderLeftWidth)).NaN0() : 0);
		top += obj.offsetTop 
			+ (obj.currentStyle 
				? (parseInt(obj.currentStyle.borderTopWidth)).NaN0() : 0);
		obj = obj.offsetParent;
	}
	left += obj.offsetLeft 
		+ (obj.currentStyle 
			? (parseInt(obj.currentStyle.borderLeftWidth)).NaN0() : 0);
	top += obj.offsetTop 
		+ (obj.currentStyle 
			? (parseInt(obj.currentStyle.borderTopWidth)).NaN0() : 0);

	return {x:left, y:top};
}

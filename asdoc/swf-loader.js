$(document).ready(function(){
	var idBase = "swfLoader";
	var idNum = 0;
	var width, height;
	var params = {
		quality: "high",
		scale: "noscale",
		allowscriptaccess: "always",
		bgcolor: "#FFFFFF"
	};
	var flashvars = {};

	$("div[src]").each(function(){
		$(this).attr("id",idBase + idNum);
		width = $(this).attr('width') || "100%";
		height = $(this).attr('height') || "100%";
		
		var flasvarsString = $(this).attr("flashvars");
		var flashvarsArray = flasvarsString.split("&");
		for ( var i = 0; i < flashvarsArray.length; i++) {
			var flasvar = flashvarsArray[i].split(":");
			flashvars[flasvar[0]] = flasvar[1];
		}
		
		
		swfobject.embedSWF($(this).attr("src"), idBase + idNum, width, height, "10.0.0", "expressInstall.swf", flashvars, params, {});
	
		idNum++;
	});
});
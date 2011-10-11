// execute your scripts when the DOM is ready. this is mostly a good habit
$(function() {

	// initialize scrollable
	//~ jQuery(".scrollable").scrollable();
	jQuery(".scrollable").scrollable({ touch: false });
	
	var items = document.getElementById("scrollableContents");
	var images = items.getElementsByTagName("img");
	if (images.length == 1) {
		jQuery('.browse').css("visibility", "hidden");
	}
	
	
});
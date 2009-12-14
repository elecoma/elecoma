/*
*	Image rollover js
*	Author : Kazuhito Hokamura
*	http://webtech-walker.com/
*
*	Licensed under the MIT License:
*	http://www.opensource.org/licenses/mit-license.php
*/

(function(){
	function rollover(){
		var targetClassName = "hoverImg";
		var suffix = "_ov";

		var overReg = new RegExp("^(.+)(\\.[a-z]+)$");
		var outReg = new RegExp("^(.+)" + suffix + "(\\.[a-z]+)$");

		var preload = new Array();
		var images = document.getElementsByTagName("img");

		for (var i = 0, il = images.length; i < il; i++) {
			var classStr = images[i].getAttribute("class") || images[i].className;
			var classNames = classStr.split(/\s+/);
			for(var j = 0, cl = classNames.length; j < cl; j++){
				if(classNames[j] == targetClassName){

					//preload
					preload[i] = new Image();
					preload[i].src = images[i].getAttribute("src").replace(overReg, "$1" + suffix + "$2");

					//mouseover
					images[i].onmouseover = function() {
						this.src = this.getAttribute("src").replace(overReg, "$1" + suffix + "$2");
					}

					//mouseout
					images[i].onmouseout = function() {
						this.src = this.getAttribute("src").replace(outReg, "$1$2");
					}
				}
			}
		}
	}

	function addEvent(elem,event,func){
		if(elem.addEventListener) {
			elem.addEventListener(event, func, false);
		}else if(elem.attachEvent) {
			elem.attachEvent("on" + event, func);
		}
	}
	addEvent(window,"load",rollover);
})();

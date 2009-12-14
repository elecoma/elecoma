// prevent right-click on images
(function(){
  function addEventListener(element, name, handler) {
    if (element.addEventListener) {
      element.addEventListener(name, handler, false);
    }
    else {
      element.attachEvent("on"+name, handler);
    }
  }
  addEventListener(document, 'contextmenu', function(e) {
    var element = e.target || e.srcElement;
    if (!element) return;
    if (element.nodeName.toLowerCase() != 'img') return;
    alert("\u753b\u50cf\u306f\u4fdd\u5b58\u3067\u304d\u307e\u305b\u3093") // gazou ha hozon dekimasen
    e.cancelBubble = true;
    e.returnValue = false;
    if (e.preventDefault) e.preventDefault();
    if (e.stopPropagation) e.stopPropagation();
    return false;
  });
})();

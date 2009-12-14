function setRecommendPager(prefix) {
  var recos = [];
  var position = 0;
  var perPage = 0;
  var backButton = $(prefix+'-back');
  var nextButton = $(prefix+'-next');
  for (var i = 0;; ++i) {
    var e = $(prefix+i);
    if (!e) break;
    if (e.style.display != 'none') ++perPage;
    recos.push(e);
  }
  if (!recos.length) return;
  backButton.style.visibility = 'hidden';
  if (recos.length > perPage) {
    nextButton.style.visibility = 'visible';
  }
  else {
    nextButton.style.visibility = 'hidden';
  }
  function show() {
    if (recos[position-1]) {
      recos[position-1].style.display = 'none';
      backButton.style.visibility = 'visible';
    }
    else {
      backButton.style.visibility = 'hidden';
    }
    var i;
    for (i = 0; i < perPage; ++i) {
      try {
        recos[position+i].style.display = 'table-cell';
      }
      catch(e) {
        recos[position+i].style.display = 'block';
      }
    }
    if (recos[position+i]) {
      recos[position+i].style.display = 'none';
      nextButton.style.visibility = 'visible';
    }
    else {
      nextButton.style.visibility = 'hidden';
    }
  }
  Event.observe(nextButton, 'click', function() {
    if (position + perPage >= recos.length) return;
    position += 1;
    show();
  });
  Event.observe(backButton, 'click', function() {
    if (position <= 0) return;
    position -= 1;
    show();
  });
}

Event.observe(window, 'load', function() {
  setRecommendPager('reco-buy');
  setRecommendPager('reco-view');
  setRecommendPager('reco-you');
});

function resizeImage(element, size){
  var image = new Image();
  image.src = $(element).src;
  var x = image.width
    var y = image.height;
  if(x > y){
    var mx = size;
    var my = y / (x / mx);
  }else{
    var my = size;
    var mx = x / (y / my);
  }

  $(element).width = mx;
  $(element).height = my;
}

Event.observe(window, 'load', function(){
  var images = $A(document.getElementsByClassName('itemImage'));
  images.each(function(image){
    resizeImage(image, 120);
  });
}, false);

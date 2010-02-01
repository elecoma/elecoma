// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
    
function fnSubWindow(URL,Winname,Wwidth,Wheight){
//サブウィンドウを表示
  var WIN;
  WIN = window.open(URL,Winname,"width="+Wwidth+",height="+Wheight+",scrollbars=yes,resizable=yes,toolbar=no,location=no,directories=no,status=no");
  WIN.focus();
}

function address_by_zip(zipcode_first, zipcode_second, prefecture_name, city_name, town_name, prefecture_id, controller, base_path){
//郵便番号から住所を自動入力
  var first = $F(zipcode_first);
  var second = $F(zipcode_second);
  if (first.length != 3 || second.length != 4) {
    alert("郵便番号を入力してください。");
    return;
  }
  var params = $H({first: first, second: second});
  new Ajax.Request(base_path + '/'+controller+'/get_address?' + params.toQueryString(), {
    method: "get",
    onSuccess: function(request) { 
      var data = request.responseText.split("/");
      if($(prefecture_name) != null){
        $(prefecture_name).value = data[0];
      }
      $(city_name).value = data[1] + data[2];
      if($(prefecture_id) != null){
        $(prefecture_id).value = data[3];
      }
    },
    onFailure: function(request) { alert("該当する郵便番号がありません") 
    }
  });

}
/*
Event.observe(window, 'load', function() {
  var img = document.createElement('img');
  document.body.appendChild(img);
  img.id = 'loading-image';
  img.alt = 'loading...';
  with (img.style) {
    display = 'none';
    position = 'fixed';
    top = '50%';
    left = '50%';
  }
  img.src = '/images/indicator.gif';
  if (img.width) {
    img.style.marginLeft = String(-(img.width / 2)) + 'px';
    img.style.marginTop = String(-(img.height / 2)) + 'px';
  }
});
*/
Ajax.Responders.register({
  onCreate: function() {
    Element.show('loading-image');
    //document.body.style.cursor = 'wait';
  },
  onComplete: function() {
    if(Ajax.activeRequestCount == 0){
      Element.hide('loading-image');
      //document.body.style.cursor = 'auto';
    }
  }
});

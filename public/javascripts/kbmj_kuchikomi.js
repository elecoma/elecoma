function kbmjTrackback(serial, id, option, charset, target_id) {
  kbmjKuchikomi("tb", serial, id, option, charset, target_id);
}
function kbmjComment(serial, id, option, charset, target_id) {
  kbmjKuchikomi("cm", serial, id, option, charset, target_id);
}
function kbmjKuchikomi(type, serial, id, option, charset, target_id) {
  var host = "recommend.kbmj.com";
  var url = location.protocol + "//" + host;
  option = option ? "&" + option : "" ;

  if(!navigator.userAgent.match(/Mozilla\/4\.0 \(compatible; MSIE 5\.\d*; (Windows|MSN|AOL)/
)){
    charset = "UTF-8";
  }
  switch(type){
  case "cm":
    target_id = target_id || "kbmj_comment";
    url += "/cm/list/";
    break;
  case "tb":
    url += "/tb/list/";
    target_id = target_id || "kbmj_trackback";
    break;
  }
  url += serial + "/" + id  + "?target_id=" + target_id + "&charset=" + charset + option;

  var func = function(){
    var script = document.createElement('script');
    script.setAttribute('type', 'text/javascript');
    script.setAttribute('charset', charset);
    script.setAttribute('src', url);
    var target = document.getElementById(target_id);
    target.appendChild(script);
  }
  if(window.addEventListener){
    window.addEventListener('load', func, false);
  }else if(window.attachEvent){
    window.attachEvent('onload', func);
  }else{
    window.onload = func;
  }
}
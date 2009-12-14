function kbmjRecommend(type, query, charset, target_id) {
  var host = "recommend.kbmj.com";
  if(!navigator.userAgent.match(/Mozilla\/4\.0 \(compatible; MSIE 5\.\d*; (Windows|MSN|AOL)/)){
    charset = "UTF-8";
  }
  if(!target_id){
    target_id = type;
  }
  var q = query == "" ? "" : query + "&";
  var url = location.protocol + "//" + host + "/recommend/" + type + "/?" + q + "target_id=" + target_id + "&charset=" + charset;

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

var host = "";
if (document.all) {
  script_tag = document.all("richedit.js");
} else {
  script_tag = document.getElementById("richedit.js");
}
if (script_tag!=null) {
  host = script_tag.src.match(/^https*:\/\/[^\/]+/i);
}

//var image_path = "/images/emoticons";

var isRichText = false;
var rng;
var currentIdName;
var allInputs = "";

var isIE;
var isGecko;
var isSafari;
var isKonqueror;

var imagesPath;
var includesPath;
var cssFile;
var generateXHTML;

var lang = "ja";
var encoding = "UTF-8";

emoji_maps = [
["sun", "F89F", "晴れ"],
["cloud", "F8A0", "曇り"],
["rain", "F8A1", "雨"],
["snow", "F8A2", "雪"],
["thunder", "F8A3", "雷"],
["typhoon", "F8A4", "台風"],
["mist", "F8A5", "霧"],
["sprinkle", "F8A6", "小雨"],
["aries", "F8A7", "牡羊座"],
["taurus", "F8A8", "牡牛座"],
["gemini", "F8A9", "双子座"],
["cancer", "F8AA", "蟹座"],
["leo", "F8AB", "獅子座"],
["virgo", "F8AC", "乙女座"],
["libra", "F8AD", "天秤座"],
["scorpius", "F8AE", "蠍座"],
["sagittarius", "F8AF", "射手座"],
["capricornus", "F8B0", "山羊座"],
["aquarius", "F8B1", "水瓶座"],
["pisces", "F8B2", "魚座"],
["sports", "F8B3", "スポーツ"],
["baseball", "F8B4", "野球"],
["golf", "F8B5", "ゴルフ"],
["tennis", "F8B6", "テニス"],
["soccer", "F8B7", "サッカー"],
["ski", "F8B8", "スキー"],
["basketball", "F8B9", "バスケットボール"],
["motorsports", "F8BA", "モータースポーツ"],
["pocketbell", "F8BB", "ポケットベル"],
["train", "F8BC", "電車"],
["subway", "F8BD", "地下鉄"],
["bullettrain", "F8BE", "新幹線"],
["car", "F8BF", "車（セダン）"],
["rvcar", "F8C0", "車（ＲＶ）"],
["bus", "F8C1", "バス"],
["ship", "F8C2", "船"],
["airplane", "F8C3", "飛行機"],
["house", "F8C4", "家"],
["building", "F8C5", "ビル"],
["postoffice", "F8C6", "郵便局"],
["hospital", "F8C7", "病院"],
["bank", "F8C8", "銀行"],
["atm", "F8C9", "ＡＴＭ"],
["hotel", "F8CA", "ホテル"],
["24hours", "F8CB", "コンビニ"],
["gasstation", "F8CC", "ガソリンスタンド"],
["parking", "F8CD", "駐車場"],
["signaler", "F8CE", "信号"],
["toilet", "F8CF", "トイレ"],
["restaurant", "F8D0", "レストラン"],
["cafe", "F8D1", "喫茶店"],
["bar", "F8D2", "バー"],
["beer", "F8D3", "ビール"],
["fastfood", "F8D4", "ファーストフード"],
["boutique", "F8D5", "ブティック"],
["hairsalon", "F8D6", "美容院"],
["karaoke", "F8D7", "カラオケ"],
["movie", "F8D8", "映画"],
["upwardright", "F8D9", "右斜め上"],
["carouselpony", "F8DA", "遊園地"],
["music", "F8DB", "音楽"],
["art", "F8DC", "アート"],
["drama", "F8DD", "演劇"],
["event", "F8DE", "イベント"],
["ticket", "F8DF", "チケット"],
["smoking", "F8E0", "喫煙"],
["nosmoking", "F8E1", "禁煙"],
["camera", "F8E2", "カメラ"],
["bag", "F8E3", "カバン"],
["book", "F8E4", "本"],
["ribbon", "F8E5", "リボン"],
["present", "F8E6", "プレゼント"],
["birthday", "F8E7", "バースデー"],
["telephone", "F8E8", "電話"],
["mobilephone", "F8E9", "携帯電話"],
["memo", "F8EA", "メモ"],
["tv", "F8EB", "ＴＶ"],
["game", "F8EC", "ゲーム"],
["cd", "F8ED", "ＣＤ"],
["heart", "F8EE", "ハート"],
["spade", "F8EF", "スペード"],
["diamond", "F8F0", "ダイヤ"],
["club", "F8F1", "クラブ"],
["eye", "F8F2", "目"],
["ear", "F8F3", "耳"],
["rock", "F8F4", "手（グー）"],
["scissors", "F8F5", "手（チョキ）"],
["paper", "F8F6", "手（パー）"],
["downwardright", "F8F7", "右斜め下"],
["upwardleft", "F8F8", "左斜め上"],
["foot", "F8F9", "足"],
["shoe", "F8FA", "くつ"],
["eyeglass", "F8FB", "眼鏡"],
["wheelchair", "F8FC", "車椅子"],
["newmoon", "F940", "新月"],
["moon1", "F941", "やや欠け月"],
["moon2", "F942", "半月"],
["moon3", "F943", "三日月"],
["fullmoon", "F944", "満月"],
["dog", "F945", "犬"],
["cat", "F946", "猫"],
["yacht", "F947", "リゾート"],
["xmas", "F948", "クリスマス"],
["downwardleft", "F949", "左斜め下"],
["phoneto", "F972", "phoneto"],
["mailto", "F973", "mailto"],
["faxto", "F974", "faxto"],
["info01", "F975", "iモード"],
["info02", "F976", "iモード（枠付き）"],
["mail", "F977", "メール"],
["by-d", "F978", "ドコモ提供"],
["d-point", "F979", "ドコモポイント"],
["yen", "F97A", "有料"],
["free", "F97B", "無料"],
["id", "F97C", "ID"],
["key", "F97D", "パスワード"],
["enter", "F97E", "次項有"],
["clear", "F980", "クリア"],
["search", "F981", "サーチ（調べる）"],
["new", "F982", "ＮＥＷ"],
["flag", "F983", "位置情報"],
["freedial", "F984", "フリーダイヤル"],
["sharp", "F985", "シャープダイヤル"],
["mobaq", "F986", "モバＱ"],
["one", "F987", "1"],
["two", "F988", "2"],
["three", "F989", "3"],
["four", "F98A", "4"],
["five", "F98B", "5"],
["six", "F98C", "6"],
["seven", "F98D", "7"],
["eight", "F98E", "8"],
["nine", "F98F", "9"],
["zero", "F990", "0"],
["ok", "F9B0", "決定"],
["heart01", "F991", "黒ハート"],
["heart02", "F992", "揺れるハート"],
["heart03", "F993", "失恋"],
["heart04", "F994", "ハートたち（複数ハート）"],
["happy01", "F995", "わーい（嬉しい顔）"],
["angry", "F996", "ちっ（怒った顔）"],
["despair", "F997", "がく～（落胆した顔）"],
["sad", "F998", "もうやだ～（悲しい顔）"],
["wobbly", "F999", "ふらふら"],
["up", "F99A", "グッド（上向き矢印）"],
["note", "F99B", "るんるん"],
["spa", "F99C", "いい気分（温泉）"],
["cute", "F99D", "かわいい"],
["kissmark", "F99E", "キスマーク"],
["shine", "F99F", "ぴかぴか（新しい）"],
["flair", "F9A0", "ひらめき"],
["annoy", "F9A1", "むかっ（怒り）"],
["punch", "F9A2", "パンチ"],
["bomb", "F9A3", "爆弾"],
["notes", "F9A4", "ムード"],
["down", "F9A5", "バッド（下向き矢印）"],
["sleepy", "F9A6", "眠い(睡眠)"],
["sign01", "F9A7", "exclamation"],
["sign02", "F9A8", "exclamation&question"],
["sign03", "F9A9", "exclamation×2"],
["impact", "F9AA", "どんっ（衝撃）"],
["sweat01", "F9AB", "あせあせ（飛び散る汗）"],
["sweat02", "F9AC", "たらーっ（汗）"],
["dash", "F9AD", "ダッシュ（走り出すさま）"],
["sign04", "F9AE", "ー（長音記号１）"],
["sign05", "F9AF", "ー（長音記号２）"],
["slate", "F950", "カチンコ"],
["pouch", "F951", "ふくろ"],
["pen", "F952", "ペン"],
["shadow", "F955", "人影"],
["chair", "F956", "いす"],
["night", "F957", "夜"],
["soon", "F95B", "soon"],
["on", "F95C", "on"],
["end", "F95D", "end"],
["clock", "F95E", "時計"],
["appli01", "F9B1", "iアプリ"],
["appli02", "F9B2", "iアプリ（枠付き）"],
["t-shirt", "F9B3", "Tシャツ（ボーダー）"],
["moneybag", "F9B4", "がま口財布"],
["rouge", "F9B5", "化粧"],
["denim", "F9B6", "ジーンズ"],
["snowboard", "F9B7", "スノボ"],
["bell", "F9B8", "チャペル"],
["door", "F9B9", "ドア"],
["dollar", "F9BA", "ドル袋"],
["pc", "F9BB", "パソコン"],
["loveletter", "F9BC", "ラブレター"],
["wrench", "F9BD", "レンチ"],
["pencil", "F9BE", "鉛筆"],
["crown", "F9BF", "王冠"],
["ring", "F9C0", "指輪"],
["sandclock", "F9C1", "砂時計"],
["bicycle", "F9C2", "自転車"],
["japanesetea", "F9C3", "湯のみ"],
["watch", "F9C4", "腕時計"],
["think", "F9C5", "考えてる顔"],
["confident", "F9C6", "ほっとした顔"],
["coldsweats01", "F9C7", "冷や汗"],
["coldsweats02", "F9C8", "冷や汗2"],
["pout", "F9C9", "ぷっくっくな顔"],
["gawk", "F9CA", "ボケーっとした顔"],
["lovely", "F9CB", "目がハート"],
["good", "F9CC", "指でOK"],
["bleah", "F9CD", "あっかんべー"],
["wink", "F9CE", "ウィンク"],
["happy02", "F9CF", "うれしい顔"],
["bearing", "F9D0", "がまん顔"],
["catface", "F9D1", "猫2"],
["crying", "F9D2", "泣き顔"],
["weep", "F9D3", "涙"],
["ng", "F9D4", "NG"],
["clip", "F9D5", "クリップ"],
["copyright", "F9D6", "コピーライト"],
["tm", "F9D7", "トレードマーク"],
["run", "F9D8", "走る人"],
["secret", "F9D9", "マル秘"],
["recycle", "F9DA", "リサイクル"],
["r-mark", "F9DB", "レジスタードトレードマーク"],
["danger", "F9DC", "危険・警告"],
["ban", "F9DD", "禁止"],
["empty", "F9DE", "空室・空席・空車"],
["pass", "F9DF", "合格マーク"],
["full", "F9E0", "満室・満席・満車"],
["leftright", "F9E1", "矢印左右"],
["updown", "F9E2", "矢印上下"],
["school", "F9E3", "学校"],
["wave", "F9E4", "波"],
["fuji", "F9E5", "富士山"],
["clover", "F9E6", "クローバー"],
["cherry", "F9E7", "さくらんぼ"],
["tulip", "F9E8", "チューリップ"],
["banana", "F9E9", "バナナ"],
["apple", "F9EA", "りんご"],
["bud", "F9EB", "芽"],
["maple", "F9EC", "もみじ"],
["cherryblossom", "F9ED", "桜"],
["riceball", "F9EE", "おにぎり"],
["cake", "F9EF", "ショートケーキ"],
["bottle", "F9F0", "とっくり（おちょこ付き）"],
["noodle", "F9F1", "どんぶり"],
["bread", "F9F2", "パン"],
["snail", "F9F3", "かたつむり"],
["chick", "F9F4", "ひよこ"],
["penguin", "F9F5", "ペンギン"],
["fish", "F9F6", "魚"],
["delicious", "F9F7", "うまい！"],
["smile", "F9F8", "ウッシッシ"],
["horse", "F9F9", "ウマ"],
["pig", "F9FA", "ブタ"],
["wine", "F9FB", "ワイングラス"],
["shock", "F9FC", "げっそり"]
  ];




function initInput(imgPath, incPath, css, genXHTML) {
  //set browser vars
  var ua = navigator.userAgent.toLowerCase();
  isIE = ((ua.indexOf("msie") != -1) && (ua.indexOf("opera") == -1) && (ua.indexOf("webtv") == -1));
  isGecko = (ua.indexOf("gecko") != -1);
  isSafari = (ua.indexOf("safari") != -1);
  isKonqueror = (ua.indexOf("konqueror") != -1);

  generateXHTML = genXHTML;
  //check to see if designMode mode is available
  //Konqueror think they are designMode capable even though they are not
  if (document.getElementById && document.designMode && !isKonqueror) {
    isRichText = true;
  }
  if (isIE) {
    document.onmouseover = raiseButton;
    document.onmouseout  = normalButton;
    document.onmousedown = lowerButton;
    document.onmouseup   = raiseButton;
  }
  //set paths vars
  imagesPath = imgPath;
  includesPath = incPath;
  cssFile = css;
  //for testing standard textarea, uncomment the following line
  //isRichText = false;
}
//初期化
initInput("/emoji/images/", "/emoji/", "", false);


function fnTextCount(id){
	if(document.getElementById("hdn"+id)!=null){
		submitForm(id);
		var count = document.getElementById("hdn"+id).value.length;
	}else{
		var count = document.getElementById(id).value.length;
	}
	document.getElementById("text_count").value = count;
}


function writeRichText(id_name, html, width, height, buttons, readOnly, use_emoji, _image_path) {
  var image_path = _image_path;
  //init variables
  var target_area = "";
  if (document.all) {
    target_area = frames["emoji_area_"+id_name];
  } else {
    target_area = document.getElementById("emoji_area_"+id_name);
  }

  var area_html = "";

  if (use_emoji==1) {
  //絵文字offの場合
  	html=html.replace(/<br \/>/g,"\n");
		html=html.replace(/&apos;/g,"\'");

    area_html += '<textarea name="' + id_name + '" id="' + id_name + '" style="width:690px; height:400px">' + html + '</textarea>\n';
    target_area.innerHTML = area_html;
  } else if (isRichText) {
    if (allInputs.length > 0) allInputs += ";";
    allInputs += id_name;

    if (readOnly) buttons = false;

    //adjust minimum table widths
    if (isIE) {
      if (buttons && (width < 690)) width = 690;
      var tablewidth = width;
    } else {
      if (buttons && (width < 690)) width = 690;
      var tablewidth = width + 4;
    }
    area_html += '<div class="id_nameDiv">\n';
    if (buttons == true) {
      area_html += '<table class="id_nameBack" border="0" cellpadding="0" cellspacing="0" id="Buttons2_' + id_name + '" width="' + tablewidth + '" style="margin-bottom:7px;">\n';
      area_html += '  <tr>\n';
      if (use_emoji==2) {
        area_html += '    <span id="emoji_' + id_name + '"><INPUT type="button" value="絵文字を使用する" onClick="dlgEmojiPalette(\'' + id_name + '\', \'emoji\')" class="btn_s"></span>\n';
      }
      area_html += '    <div style="position: absolute; color: white; background: white; border:1px solid #000000;  padding: 0px; text-align: center; display: none;" id="emoji' + id_name + '" >\n';
      //area_html += '    <img src="'+ host +'/images/emoticons/emoticons.gif" style="border: 0px none \;" usemap="#emoji" alt="">\n';
      area_html += '    <img src="'+ image_path +'/emoticons.gif" style="border: 0px none \;" usemap="#emoji" alt="">\n';
      area_html += '    <map name="emoji" id="emoji_map'+id_name+'">\n';

      var size=20;
      var col=20;
      for (var idx=0; idx < emoji_maps.length; idx++) {
        area_html += '    <area shape="rect" coords="'+(size*(idx%col))+','+(size*(Math.floor(idx/col)))+','+(size+size*(idx%col))+','+(size+size*(Math.floor(idx/col)))+'" alt="'+emoji_maps[idx][2]+'" title="'+emoji_maps[idx][2]+'" id="'+emoji_maps[idx][0]+'">\n';
      }
      area_html += '    <area shape="default" alt="" nohref="nohref">\n';
      area_html += '    </map>\n';

      area_html += '    </div>\n';



      area_html += '  </tr>\n';
      area_html += '</table>\n';
    }
    area_html += '<iframe id="' + id_name + '" name="' + id_name + '" width="' + width + 'px" height="' + height + 'px" src="' + includesPath + 'blank.htm"></iframe>\n';
    area_html += '<input type="hidden" id="hdn' + id_name + '" name="' + id_name + '" value="">\n';
    area_html += '</div>\n';
    target_area.innerHTML = area_html;
    document.getElementById('hdn' + id_name).value = html;
    enableDesignMode(id_name, html, readOnly);
    addMapEvent(id_name, image_path);
  } else {
    if (!readOnly) {
      area_html += '<textarea name="' + id_name + '" id="' + id_name + '" style="width: ' + width + 'px; height: ' + height + 'px;">' + html + '</textarea>\n';
    } else {
      area_html += '<textarea name="' + id_name + '" id="' + id_name + '" style="width: ' + width + 'px; height: ' + height + 'px;" readonly>' + html + '</textarea>\n';
    }
    target_area.innerHTML = area_html;
  }

}

function enableDesignMode(id_name, html, readOnly) {
  var frameHtml = "<html id=\"" + id_name + "\">\n";
  frameHtml += "<head>\n";
  //to reference your stylesheet, set href property below to your stylesheet path and uncomment
  if (cssFile.length > 0) {
    frameHtml += "<link media=\"all\" type=\"text/css\" href=\"" + cssFile + "\" rel=\"stylesheet\">\n";
  } else {
    frameHtml += "<style>\n";
    frameHtml += "body {\n";
    frameHtml += "  background: #FFFFFF;\n";
    frameHtml += "  margin: 0px;\n";
    frameHtml += "  padding: 0px;\n";
    frameHtml += "}\n";
    frameHtml += "</style>\n";
  }
  frameHtml += "</head>\n";
  frameHtml += "<body>";
  frameHtml += html;
  frameHtml += "</body>\n";
  frameHtml += "</html>";
  if (document.all) {
    var oInput = frames[id_name].document;
    oInput.open();
    oInput.write(frameHtml);
    oInput.close();
    if (!readOnly) {
      oInput.designMode = "On";
      frames[id_name].document.attachEvent("onkeypress", function evt_ie_keypress(event) {ieKeyPress(event, id_name);});
    }
  } else {
    try {

      if (!readOnly) document.getElementById(id_name).contentDocument.designMode = "on";
      try {
        var oInput = document.getElementById(id_name).contentWindow.document;
        oInput.open();
        oInput.write(frameHtml);
        oInput.close();
      } catch (e) {
      }
    } catch (e) {
      //gecko may take some time to enable design mode.
      //Keep looping until able to set.
      if (isGecko) {
                                html = html.replace(/\n/g, "\\n");
                                html = html.replace(/\r/g, "\\r");
//        setTimeout("enableDesignMode('" + id_name + "', '" + html + "', " + readOnly + ");", 10);
      } else {
        return false;
      }
    }
  }
}

function updateInput(id_name) {
  if (!isRichText) return;
  //check for readOnly mode
  var readOnly = false;
  if (document.all) {
    if (frames[id_name].document.designMode != "On") readOnly = true;
  } else {
    if (document.getElementById(id_name).contentDocument.designMode != "on") readOnly = true;
  }
  if (isRichText && !readOnly) {
    setHiddenVal(id_name);
  }
}

function setHiddenVal(id_name) {
  //set hidden form field value for current id_name
  var oHdnField = document.getElementById('hdn' + id_name);
  //convert html output to xhtml (thanks Timothy Bell and Vyacheslav Smolin!)
  if (oHdnField.value == null) oHdnField.value = "";
  if (document.all) {
    if (generateXHTML) {
      oHdnField.value = get_xhtml(frames[id_name].document.body, lang, encoding);
    } else {
      oHdnField.value = frames[id_name].document.body.innerHTML;
    }
  } else {
    if (generateXHTML) {
      oHdnField.value = get_xhtml(document.getElementById(id_name).contentWindow.document.body, lang, encoding);
    } else {
      oHdnField.value = document.getElementById(id_name).contentWindow.document.body.innerHTML;
      if (isSafari) {
    // <div>が入ってしまうので削除
        oHdnField.value = oHdnField.value.replace(/\n$/ig,"");
        oHdnField.value = oHdnField.value.replace(/<br>/ig,"\n");
        oHdnField.value = oHdnField.value.replace(/<div>/ig,"");
        oHdnField.value = oHdnField.value.replace(/<\/div>/ig,"\n");
      }
    }
  }
  //if there is no content (other than formatting) set value to nothing
  if (stripHTML(oHdnField.value.replace("&nbsp;", " ")) == "" &&
    oHdnField.value.toLowerCase().search("<hr") == -1 &&
    oHdnField.value.toLowerCase().search("<img") == -1) oHdnField.value = "";
}

function updateInputs() {
  var vInputs = allInputs.split(";");
  for (var i = 0; i < vInputs.length; i++) {
    updateInput(vInputs[i]);
  }
}

function dlgEmojiPalette(id_name, command) {
  setRange(id_name);
  //get dialog position
  var oDialog = document.getElementById('emoji' + id_name); //
  var buttonElement = document.getElementById(command + '_' + id_name);
  var iLeftPos = getOffsetLeft(buttonElement);
  var iTopPos = getOffsetTop(buttonElement);
  oDialog.style.left = (iLeftPos) + "px";
  oDialog.style.top = (iTopPos) + "px";
  if ((command == parent.command) && (id_name == currentIdName)) {
    //if current command dialog is currently open, close it
    if (document.getElementById('emoji' + id_name).style.display == "none") {
      document.getElementById('emoji' + id_name).style.display = "block";
    } else {
      document.getElementById('emoji' + id_name).style.display = "none";
    }
  } else {
    //if opening a new dialog, close all others
    var vInputs = allInputs.split(";");
    for (var i = 0; i < vInputs.length; i++) {
      document.getElementById('emoji' + vInputs[i]).style.display = "none";
    }
    document.getElementById('emoji' + id_name).style.display = "block";
  }
  //save current values
  parent.command = command;
  currentIdName = id_name;
}



function setEmoji(url) {
    var id_name = currentIdName;
    var content = '<img src="' + url + '" />';
    insertHTML(content);
    document.getElementById('emoji' + id_name).style.display = "none";
}


// Ernst de Moor: Fix the amount of digging parents up, in case the Input editor itself is displayed in a div.
// KJR 11/12/2004 Changed to position palette based on parent div, so palette will always appear in proper location regardless of nested divs
function getOffsetTop(elm) {
  var mOffsetTop = elm.offsetTop;
  var mOffsetParent = elm.offsetParent;

  while(mOffsetParent) {
    mOffsetTop += mOffsetParent.offsetTop;
    mOffsetParent = mOffsetParent.offsetParent;
  }
  if (!document.all) { mOffsetTop += (elm.offsetHeight + 4); } //IEの場合は基準位置がボタン下なので
  return mOffsetTop;
}

// Ernst de Moor: Fix the amount of digging parents up, in case the Input editor itself is displayed in a div.
// KJR 11/12/2004 Changed to position palette based on parent div, so palette will always appear in proper location regardless of nested divs
function getOffsetLeft(elm) {
  var mOffsetLeft = elm.offsetLeft;
  var mOffsetParent = elm.offsetParent;

  while(mOffsetParent) {
    mOffsetLeft += mOffsetParent.offsetLeft;
    mOffsetParent = mOffsetParent.offsetParent;
  }

  return mOffsetLeft;
}

function insertHTML(html) {
  //function to add HTML -- thanks dannyuk1982
  var id_name = currentIdName;

  var oInput;
  if (document.all) {
    oInput = frames[id_name];
  } else {
    oInput = document.getElementById(id_name).contentWindow;
  }

  oInput.focus();
  if (document.all) {
    var oRng = oInput.document.selection.createRange();
    oRng.pasteHTML(html);
    oRng.collapse(false);
    oRng.select();
  } else {
    oInput.document.execCommand('insertHTML', false, html);
  }
}

function showHideElement(element, showHide) {
  //function to show or hide elements
  //element variable can be string or object
  if (document.getElementById(element)) {
    element = document.getElementById(element);
  }

  if (showHide == "show") {
    element.style.visibility = "visible";
  } else if (showHide == "hide") {
    element.style.visibility = "hidden";
  }
}

function setRange(id_name) {
  //function to store range of current selection
  var oInput;
  if (document.all) {
    oInput = frames[id_name];
    var selection = oInput.document.selection;
    if (selection != null) rng = selection.createRange();
  } else if (isSafari) {
  } else {
    oInput = document.getElementById(id_name).contentWindow;
    var selection = oInput.getSelection();
    rng = selection.getRangeAt(selection.rangeCount - 1).cloneRange();
  }
  return rng;
}

function stripHTML(oldString) {
  //function to strip all html
  var newString = oldString.replace(/(<([^>]+)>)/ig,"");

  //replace carriage returns and line feeds
   newString = newString.replace(/\r\n/g," ");
   newString = newString.replace(/\n/g," ");
   newString = newString.replace(/\r/g," ");

  //trim string
  newString = trim(newString);

  return newString;
}

function trim(inputString) {
   // Removes leading and trailing spaces from the passed string. Also removes
   // consecutive spaces and replaces it with one space. If something besides
   // a string is passed in (null, custom object, etc.) then return the input.
   if (typeof inputString != "string") return inputString;
   var retValue = inputString;
   var ch = retValue.substring(0, 1);

   while (ch == " ") { // Check for spaces at the beginning of the string
      retValue = retValue.substring(1, retValue.length);
      ch = retValue.substring(0, 1);
   }
   ch = retValue.substring(retValue.length - 1, retValue.length);

   while (ch == " ") { // Check for spaces at the end of the string
      retValue = retValue.substring(0, retValue.length - 1);
      ch = retValue.substring(retValue.length - 1, retValue.length);
   }

  // Note that there are two spaces in the string - look for multiple spaces within the string
   while (retValue.indexOf("  ") != -1) {
    // Again, there are two spaces in each of the strings
      retValue = retValue.substring(0, retValue.indexOf("  ")) + retValue.substring(retValue.indexOf("  ") + 1, retValue.length);
   }
   return retValue; // Return the trimmed string back to the user
}

//*****************
//IE-Only Functions
//*****************
function ieKeyPress(evt, id_name) {
  var key = (evt.which || evt.charCode || evt.keyCode);
  var stringKey = String.fromCharCode(key).toLowerCase();

//the following breaks list and indentation functionality in IE (don't use)
  switch (key) {
    case 13:
      //insert <br> tag instead of <p>
      //change the key pressed to null
      evt.keyCode = 0;

      //insert <br> tag
      currentIdName = id_name;
      insertHTML('<br>');
      break;
  };
}

function raiseButton(e) {
  var el = window.event.srcElement;

  className = el.className;
  if (className == 'rteImage' || className == 'rteImageLowered') {
    el.className = 'rteImageRaised';
  }
}

function normalButton(e) {
  var el = window.event.srcElement;

  className = el.className;
  if (className == 'rteImageRaised' || className == 'rteImageLowered') {
    el.className = 'rteImage';
  }
}

function lowerButton(e) {
  var el = window.event.srcElement;

  className = el.className;
  if (className == 'rteImage' || className == 'rteImageRaised') {
    el.className = 'rteImageLowered';
  }
}




//var emojiBase = host + image_path +"/";

function setEmojiTag(emoji, image_path) {
  var emojiBase = host + image_path +"/";
  var img_url = emojiBase + emoji +".gif";
  window.setEmoji(img_url);
}

function addEvent(elem,name,func,opt){
  if (window.addEventListener){
    elem.addEventListener(name,func,opt);
  }
  else if (window.attachEvent){
    elem.attachEvent('on' + name, func);
  }
}
function foreach(array,callback){
  for(var i=0;i<array.length;i++)
    callback(i,array[i],array);
}

function addMapEvent(id_name, image_path){
  var area = document.getElementById("emoji_map"+id_name).getElementsByTagName("area");
  foreach(area, function(i,el){
    addEvent(el, "mouseup", function(){ setEmojiTag( el.id, image_path );
    });
  });
}

//form
function submitForm(id) {
	if(document.getElementById("hdn"+id)!=null){
     updateInputs();
     //change the following line to true to submit form
     return true;
	}
}

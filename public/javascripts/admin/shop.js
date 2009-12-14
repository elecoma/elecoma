//配送料金を自動入力
function fnSetDelivFee(max){
  for (cnt = 0; cnt <= max; cnt++) {
    name = "delivery_fee[" + cnt + "][price]";
    document.delivery_form[name].value = document.delivery_form.delivery_fee_all.value;
  }
}

//文字数カウント
function fnTextCount(sch, cnt){
  document.getElementById(cnt).value = document.getElementById(sch).value.length;
}

// タグの表示非表示切り替え
function fnDispChange(disp_id, inner_id, disp_flg){
  disp_state = document.getElementById(disp_id).style.display;
  if (disp_state == "") {
    document.getElementById(disp_id).style.display="none";
    document.getElementById(inner_id).innerHTML = '<FONT Color="#FFFF99"> << 表示</FONT>';
  }else{
    document.getElementById(disp_id).style.display="";
    document.getElementById(inner_id).innerHTML = ' <FONT Color="#FFFF99"> >> 非表示 </FONT>';
  }
}

function getDeliveryTimes(form) {
  var re = /^delivery_time\[\d+\]\[name\]$/;
  return $A(form.elements).select(function(e) {
    return e.name.match(re);
  });
}

// 配送時間の間の空白を切り詰める
function defrag(form, event) {
  var EMPTY = /^\s*$/;
  var deliveryTimes = getDeliveryTimes(form);
  var values = deliveryTimes.map(function(e) {
    return e.value;
  });
  values = dropWhileFromLast(values, function(value) {
    return value == null || value.match(EMPTY);
  });
  var newValues = values.reject(function(value) {
    return !!value.match(EMPTY);
  });
  if (values.length != newValues.length) {
    if (!confirm("入力されていない配送時間は切り詰められます。\r\nよろしいですか？")) {
      event.stop();
      return;
    }
  }
  deliveryTimes.zip(newValues).each(function(t) {
    var element = t[0];
    var value = t[1];
    if (value == null) value = "";
    element.value = value;
  });
}

function dropWhileFromLast(array, func) {
  var i = array.length;
  for (; i > 0; --i) {
    if (!func(array[i-1])) break;
  }
  return array.slice(0, i);
}


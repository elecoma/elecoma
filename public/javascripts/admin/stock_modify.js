//一括更新を行うときに書く在庫が非同期に更新される
//一斉に表示するための変数
var ajax_list = new Array(); // 更新中はtrue
var count_list = new Array(); // trueのみ表示
var error_list = new Array(); // 0:エラー無し 1:入力エラー 2:在庫エラー
var success_list = new Array(); // １つでもtrueがあれば更新成功メッセージを表示
var first = true; //初期化判定

//リスト初期化 success_listは毎回初期化
function init_lists(ids){
  for( var i=0; i<ids.length; i++){
    success_list[i] = false;
  }
  if(!first) return;
  for( var i=0; i<ids.length; i++){
    ajax_list[i] = false;
    error_list[i] = 0;
    count_list[i] = false;
    success_list[i] = false;
  }
  first = false;
}

//在庫数とエラーの同時表示
function show_sync(ids){
  for (var i=0; i<ids.length; i++){
    if(ajax_list[i]) return;
  }
  for (var i=0; i<ids.length; i++){
    if(count_list[i]) show_count(ids[i]);
    count_list[i] = false;
  }
  show_err(ids);
}

//エラー表示
function show_err(ids){
  var e_msg_box = document.getElementById("errorExplanation");
  var n_errors = 4;
  var e_msgs = new Array();
 
  for (var e=1; e<=n_errors; e++){
    e_msgs[e] = document.getElementById("msg"+e);
    e_msgs[e].style.display = "none";
  }

  e_msg_box.style.display = "none";
  for( var i=0; i<ids.length; i++){
    var e_field = document.getElementById("ac"+ids[i]);
    e_field.style.backgroundColor = "white";
    if(error_list[i] > 0) {
      e_msg_box.style.display = "";
      e_msgs[error_list[i]].style.display = "";
      e_field.style.backgroundColor = "lightpink";
    }
  }
  for( var i=0; i<ids.length; i++){
    if(success_list[i]){
      show_update_msg(0);
      return;
    }
  }
}

//更新成功メッセージ表示
var timer_id = 0;
function show_update_msg(cnt){
  var e_msgs = document.getElementById("stock_update_now");

  if(cnt == 0){
    if (timer_id != 0) clearTimeout(timer_id);
    e_msgs.style.display = "";
    timer_id = setTimeout("show_update_msg("+(cnt+1)+")",3000);
  } else {
    timer_id = 0;
    e_msgs.style.display = "none";
  }
}

//在庫数更新リクエスト
function submit_now(num, ids) {
  var e_edit = document.getElementById("edit_product_style_"+num);
  var e_num = document.getElementById("ac"+num);
  var e_act = document.getElementById("act"+num).innerHTML;

  if (e_edit.style.display == "none" || ajax_list[ids.indexOf(num)]){
    return;
  }
  ajax_list[ids.indexOf(num)] = false;
  error_list[ids.indexOf(num)] = 0;
  count_list[ids.indexOf(num)] = true;
  e_act = e_act.replace(/[^0-9]/g, "");
  if(e_num.value=="") {
    e_num.value = e_act;
    return;
  }
  var new_num = Number(e_num.value);
  ajax_list[ids.indexOf(num)] = true;
  new Ajax.Request('/admin/stock_modify/edit_now/'+num, {
    asynchronous:true,
    evalScripts:true,
    parameters:Form.serialize('edit_product_style_'+num),
 });
 return;
}

//実在庫数表示
function show_count(num) {
  var e_act = document.getElementById("act"+num);
  var e_ebutton = document.getElementById("ebutton"+num);
  var e_edit = document.getElementById("edit_product_style_"+num);

  e_act.style.display = "";
  e_ebutton.style.display = "";
  e_edit.style.display = "none";
}

//テキストボックス表示
function show_edit(num) {
  var e_act = document.getElementById("act"+num);
  var e_ebutton = document.getElementById("ebutton"+num);
  var e_edit = document.getElementById("edit_product_style_"+num);

  e_act.style.display = "none";
  e_ebutton.style.display = "none";
  e_edit.style.display = "";
}

//１商品在庫更新
function submit_one(num, ids){
  init_lists(ids);
  submit_now(num, ids);
  show_sync(ids);
}

//全商品在庫更新
function submit_all(ids){
  init_lists(ids);
  for (var i=0; i<ids.length; i++) {
    submit_now(ids[i], ids);
  }
  show_sync(ids);
}


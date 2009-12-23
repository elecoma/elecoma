//コピーボタン押下
function copy(){
	from = document.getElementById("copy_from").value;
	to = document.getElementById("copy_to").value;
	if (from == "" || to == ""){
		alert("コピー元とコピー先をご選択ください");
		return;
	}
	if (from == to){
		alert("コピー元とコピー先が同じです。ご確認ください。");
		return;
	}
	var src  = document.getElementById("privacy_"  + from);
	var desc = document.getElementById("privacy_" + to);
	if (src.value == ""){
		if(!confirm("コピー元の内容が空白です。本当にコピーしますか。")) return;
	}
	desc.value = src.value;
}
//プレビューボタン押下
function preview(preview_id) {
	form = document.forms[0];
	form.action = "/admin/shops/privacy_preview";
	form.target = "_blank";
	form.preview_id.value = preview_id;
	form.submit();
}
//登録ボタン押下
function regist() {
	if(confirm("登録しても宜しいですか")){
		form = document.forms[0];
		form.action = "/admin/shops/privacy_update";
		form.target = "_self";
		form.submit();
	}else{
		return;
	}
}
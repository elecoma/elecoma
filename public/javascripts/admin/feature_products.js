//検索ウィンドウの表示
function fnSearchSubWindow(Winname,Wwidth,Wheight){
  var WIN;
  WIN = window.open("/admin/feature_products/product_search",Winname,"width="+Wwidth+",height="+Wheight+",scrollbars=yes,resizable=yes,toolbar=no,location=no,directories=no,status=no");
  WIN.focus();
}

//検索ウィンドウで決定した商品をメインウィンドウに反映
function fnProductSubmit(product_id, resource_id, product_name){
  window.opener.document.getElementById("product_name").innerHTML = product_name;
  window.opener.document.getElementById("feature_product_product_id").value = product_id;
  window.opener.document.getElementById("feature_product_image_resource_id").value = resource_id;
  resource_old_id = window.opener.document.getElementById("feature_product_image_resource_old_id")
  if(resource_old_id != null && resource_old_id.value > 0){
	window.opener.document.getElementById("feature_product_image_resource_old_id").value = 0;
    window.opener.document.getElementById("feature_product_image_resource_old_file").style.display = 'none';
  }
  window.close();
  return false;
}



//検索ウィンドウの表示
function fnSearchSubWindow(Winname,Wwidth,Wheight){
  var WIN;
  WIN = window.open("/admin/recommend_products/product_search", Winname,"width="+Wwidth+",height="+Wheight+",scrollbars=yes,resizable=yes,toolbar=no,location=no,directories=no,status=no");
  WIN.focus();
}

//検索ウィンドウで決定した商品をメインウィンドウに反映
function fnProductSubmit(pou_id, product_name){
  window.opener.document.getElementById("product_name").innerHTML = product_name;
  window.opener.document.getElementById("recommend_product_product_order_unit_id").value = pou_id;
  window.close();
  return false;
}


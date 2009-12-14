function product_style_all_select_change(value){
  options = document.getElementsByTagName("input");
  for(var cnt=0; cnt < options.length; cnt++){
    if( options[cnt].id.search( /product_styles_\d+_enable/ ) != -1 ){
        options[cnt].checked = value;
    }
  }
}

function product_style_all_select(){
  product_style_all_select_change(true);
}

function product_style_all_un_select() {
  product_style_all_select_change(false);
}

function product_style_all_copy() {
  options = document.getElementsByTagName("input");

  var sell_price = document.getElementById("product_styles_0_sell_price").value;

  for(var cnt=0; cnt < options.length; cnt++){
    if( options[cnt].id.search( /product_styles_\d+_sell_price/ ) != -1 ){
        options[cnt].value = sell_price;
    }
  }
}

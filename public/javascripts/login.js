function check_login_form(){ 
  if(document.getElementById("customer_email").value == "" || 
      document.getElementById("customer_password").value == ""){
    alert("メールアドレス/パスワードを入力して下さい");
    return false;
  }else{
    return true;
  }
}

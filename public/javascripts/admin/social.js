//mixy_keyの入力可否
window.onload = function(){
    if(document.getElementById("mixi_check").checked || document.getElementById("mixi_like").checked){
	document.getElementById("mixi_key").disabled = false;
	document.getElementById("mixi_description").disabled = false;
    } else {
	document.getElementById("mixi_key").disabled = true;
	document.getElementById("mixi_description").disabled = true;
    }
    if(document.getElementById("twitter").checked){
	document.getElementById("twitter_user").disabled = false;
    } else {
	document.getElementById("twitter_user").disabled = true;
    }
}

function changemixi(){
    if(document.getElementById("mixi_check").checked || document.getElementById("mixi_like").checked){
	document.getElementById("mixi_key").disabled = false;
	document.getElementById("mixi_description").disabled = false;
    } else {
	document.getElementById("mixi_key").disabled = true;
	document.getElementById("mixi_description").disabled = true;
    }
}

function changetwitter(){
    if(document.getElementById("twitter").checked){
	document.getElementById("twitter_user").disabled = false;
    } else {
	document.getElementById("twitter_user").disabled = true;
    }
}

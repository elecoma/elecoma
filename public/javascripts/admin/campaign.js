function preview() {
	form = document.forms[0];
	form.action = "/admin/campaigns/campaign_preview";
	form.target = "_blank";
	form.submit();
}

function regist() {
	form = document.forms[0];
	form.action = "/admin/campaigns/campaign_design_update";
	form.target = "_self";
	form.submit();
}

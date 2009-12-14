function all_check(param) {
  check_all = document.forms[1].check_all.checked
	form = document.forms[1]
  if (form.length) {
		for (i=0; i<form.length; i++) {
      if (form[i].name == "checked[]") {
				form[i].checked = check_all;
			}
		}
	}
}


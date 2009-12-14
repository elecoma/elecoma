function changeCheckboxAll(form, name, checked) {
  var elements = form.elements[name];
  if (!elements || !elements.length) return;
  for (var i = 0; i < elements.length; ++i) {
    if (elements[i].type != "checkbox") continue;
    elements[i].checked = checked;
  }
}
document.observe("dom:loaded", function() {
  $$(".checkall").each(function(element) {
    element.observe("click", function(e) {
      e.stop();
      changeCheckboxAll(this.form, "id_array[]", true);
    });
  });
  $$(".uncheckall").each(function(element) {
    element.observe("click", function(e) {
      e.stop();
      changeCheckboxAll(this.form, "id_array[]", false);
    });
  });
});

Event.observe(window, 'load', function() {

  var element = $('credit_brand_id');
  var form = element.form;
  Event.observe(element, 'change', function(ev) {
    selectBrand(ev.target);
  });
  selectBrand(element, function() {
    form.action = '/cart/credit_confirm';
  });
});

function selectBrand(element, callback) {
  var form = element.form;
  var brandId = element.value;
  var targets = form.elements["credit[payment_id]"];
  if (targets && typeof(targets.length) == 'undefined') targets = [targets];
  targets = $A(targets);
  new Ajax.Updater({success: 'credit_detail'}, '/cart/credit_partial', {
    method: 'GET',
    parameters: 'brand_id='+brandId,
    onCreate: function() {
      targets.each(function(e) { e.disabled = true });
    },
    onComplete: function() {
      targets.each(function(e) { e.disabled = true });
    },
    onSuccess: function() {
      if (callback) callback();
    }
  });
}

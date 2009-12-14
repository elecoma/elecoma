Event.observe(window, 'load', function() {
  var form = document.forms['form1'];
  var radios = form['order_delivery[payment_id]'];
  if (!radios.length) radios = [radios];
  $A(radios).each(function(radio) {
    Event.observe(radio, 'click', function(e) {
      var id = 'delivery_time';
      var params = $H({
        payment_id: this.value
      });
      new Ajax.Updater({success: id}, '/cart/select_delivery_time', {
        method: 'POST',
        parameters: params.toQueryString(),
        onCreate: function() {
          $(id).disabled = true;
        },
        onComplete: function() {
          $(id).disabled = false;
        }
      });
    });
  });
});

Event.observe(window, 'load', function() {
  var form = document.forms['form1'];
  var radios = $$('input.radio_trader');
  if (!radios.length) radios = [radios];
  $A(radios).each(function(radio) {
    Event.observe(radio, 'click', function(e) {
      var retailer_id = radio.id.split('_')[2];
      //console.log(retailer_id);
      var id = "delivery_time_" + retailer_id
      var params = $H({
        delivery_trader_id: this.value
      });
      new Ajax.Updater({success: id}, '/cart/select_delivery_time_with_delivery_trader_id_ajax', {
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




// 数値入力欄 <input class="number"> にカンマを付加する 
Event.observe(window, 'load', function() {
  function insertDelimiters(element) {
    element.value = addFigure(element.value);
  }

  function removeDelimiters(element) {
    element.value = removeFigure(element.value);
  }

  $$('input.number').each(function(element) {
    removeDelimiters(element);
    insertDelimiters(element);
    Event.observe(element, 'blur', function(ev) {
      insertDelimiters(ev.target);
    });
    Event.observe(element, 'focus', function(ev) {
      removeDelimiters(ev.target);
      Prototype.Browser.IE && ev.target.select();
    });
    Event.observe(element.form, 'submit', function() {
      removeDelimiters(element);
    });
  });
});

function addFigure(str) {
  var num = new String(str).replace(/,/g, "");
  while(num != (num = num.replace(/^([-\+]?\d+)(\d{3})/, "$1,$2")));
  return num;
}

function removeFigure(str) {
  return new String(str).replace(/,/g, "");
}

var ROUNDING_FUNCTIONS = { 0: Math.round, 1: Math.floor, 2: Math.ceil };
// 税込み価格
function includingTaxPrice(basePrice, percentage, taxRule) {
  var f = ROUNDING_FUNCTIONS[taxRule];
  if (!f) return null;
  basePrice = Number(basePrice);
  return basePrice + f(basePrice * Number(percentage) / 100);
}

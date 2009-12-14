if (window.opener) {
  opener.location.reload();
}
else {
  window.opener = {};
}
window.close();

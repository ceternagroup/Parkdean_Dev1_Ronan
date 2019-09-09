({
  getCountdown: function($C, $E, $H, stop) {
    $H.runLoad($C, $E, $H);
  },
  // refresh the component when the record changes
  refreshFrame: function($C, $E, $H) {
    setTimeout(function() {
      console.log('call refresh');
      $H.runLoad($C, $E, $H, true);
    }, 1000);
  }
})
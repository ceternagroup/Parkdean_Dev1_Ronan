({
  // get the quote name for the UI
  loadQuote: function($C, $E, $H) {
    var params = {
      quoteId: $C.get('v.quoteId')   
    }
    $H.runAction($C, 'c.getQuote', params, function(response) {
      $C.set('v.quote', response);
      $C.set('v.loaded', true);
    }); 
  },
  // go back to the quote
  goBack: function($C, $E, $H) {
    window.location.href = '/' + $C.get('v.quoteId');
  }
})
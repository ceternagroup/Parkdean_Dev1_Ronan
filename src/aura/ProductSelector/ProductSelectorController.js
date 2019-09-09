({
  // update the selected product id when it's emitted from ProductCatalogue
  handleSelection: function($C, $E, $H) {
    var params = {
      productId: $E.getParam('recordId')
    }
    var id = $E.getParam('recordId');
    console.log('passed', id);
    var overide = $E.getParam('overideAmount');
    $C.set('v.overideAmount', overide ? overide : null);
    $H.runAction($C, 'c.getProduct', params, function(response) {
      console.log('res?', JSON.stringify(response));
      $C.set('v.selectedProduct', response);
    });
  },
  // get the quote name for the UI
  loadQuote: function($C, $E, $H) {
    var url = window.location.href;
    if (url.indexOf('quoteId=') != -1) {
      $C.set('v.quoteId', url.split('quoteId=')[1]);
    }
    var params = {
      quoteId: $C.get('v.quoteId')   
    }
    $H.runAction($C, 'c.getQuote', params, function(response) {
      console.log('?', response, $C.get('v.quoteId'));
      $C.set('v.quote', response);
      $C.set('v.loaded', true);
    }); 
  },
  // go back to the quote
  goBack: function($C, $E, $H) {
    window.location.href = '/' + $C.get('v.quoteId');
  }
})
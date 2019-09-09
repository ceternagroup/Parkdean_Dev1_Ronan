({
  sendSLA: function($C, $E, $H) {
    var params = {
      quoteId: $C.get('v.recordId')
    };
    $H.runAction($C, 'c.checkQuote', params, function(response) {
      console.log(response);
      if (response != 'Ready') {
        $C.set('v.error', response);
        $C.set('v.loading', false);
      } else {
        $H.runAction($C, 'c.sendQuote', params, function(response) {
          console.log(response);
          if (response != 'Success') {
            $C.set('v.error', response); 
            $C.set('v.loading', false); 
          } else {
            try {
              $A.get("e.force:closeQuickAction").fire();
              $A.get('e.force:refreshView').fire();
            } catch(e) { console.error(e); }
          }
        })
      }
    });
  }
})
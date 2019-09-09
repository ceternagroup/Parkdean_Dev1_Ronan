({
  setPrivateSeller: function($C, $E, $H) {
    var params = {
      oppId: $C.get('v.recordId')
    };
    $H.runAction($C, 'c.sendPrivateSeller', params, function(response) {
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
    });
  }
})
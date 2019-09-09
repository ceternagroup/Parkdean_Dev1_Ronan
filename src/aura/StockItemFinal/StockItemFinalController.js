({
  setFinal: function($C, $E, $H) {
    var params = {
      recordId: $C.get('v.recordId')
    }
    $H.runAction($C, 'c.updateItem', params, function(message) {
      if (message.indexOf('Error') != -1) {
        $C.set('v.error', true);
        $C.set('v.message', message);
      } else {
        $A.get('e.force:refreshView').fire();
		$A.get("e.force:closeQuickAction").fire();
      }
    })
  }
})
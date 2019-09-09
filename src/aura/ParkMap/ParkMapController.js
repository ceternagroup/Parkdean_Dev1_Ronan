({
  loadMap: function($C) {
    var action = $C.get('c.getMap');
    action.setParams({
      recordId: $C.get('v.recordId')
    });
    action.setCallback(this, function(response) {
      var res = response.getReturnValue();
      console.log(res);
      if (res.indexOf('Error') != -1) {
        $C.set('v.error', res);
      } else {
        $C.set('v.parkMap', res);
      }
    });
    $A.enqueueAction(action);  
  }
})
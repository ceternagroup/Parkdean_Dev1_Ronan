({
  runAction: function($C, action, parameters, callback) {
    var action = $C.get(action);
    action.setParams(parameters);
    action.setCallback(this, function(res) {
      var response = res.getReturnValue();
      callback(response);
    });
    $A.enqueueAction(action);  
  },
})
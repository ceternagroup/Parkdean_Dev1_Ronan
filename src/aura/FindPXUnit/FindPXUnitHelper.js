({
  runAction: function($C, action, parameters, callback) {
    var action = $C.get(action);
    action.setParams(parameters);
    console.log('calling', action);
    console.log(action.getError());
    action.setCallback(this, function(res) {
      console.log(res, res.getReturnValue());
      var response = res.getReturnValue();
      console.log(response);
      callback(response);
    });
    $A.enqueueAction(action);  
  },
})
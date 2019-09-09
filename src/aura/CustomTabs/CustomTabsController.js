({
  loadColours: function(component) {
    var action = component.get('c.getTabs');
    action.setCallback(this, function(response) {
      var res = response.getReturnValue();
      console.log(res);
      window.setObjects(res);
    });
    $A.enqueueAction(action);
  }
})
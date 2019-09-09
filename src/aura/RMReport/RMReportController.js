({
    
  // get the report data and process it in the helper
  getReports: function($C, $E, $H) {
    var action = $C.get("c.getReportData");
    action.setCallback(this, function(response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var res = response.getReturnValue();
        res = JSON.parse(res);
        if (res.error) return $H.throwError($C, res.error);
        $H.processData($C, $H, res);
      } else if (state === "ERROR") {
        var errors = response.getError();
        $H.throwError($C, errors);
      }
    });
    $A.enqueueAction(action);
  }
    
})
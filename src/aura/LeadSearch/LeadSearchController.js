({
    
  runSearch: function($C, $E, $H) {
    $C.set('v.loading', true);
    var action = $C.get('c.runFullSearch');
    var params = {
      firstName: $C.get('v.firstName'),
      lastName: $C.get('v.lastName'),
      email: $C.get('v.email'),
      postcode: $C.get('v.postcode'),
      phone: $C.get('v.phone'),
      mobilePhone: $C.get('v.mobile')
    }
    console.log(params);
    action.setParams(params);
    action.setCallback(this, function(response) {
      var results = response.getReturnValue();
      console.log(results);
      if (results != null) {
        $C.set('v.holidayMakers', results.holiday_makers);
        $C.set('v.leads', results.leads);
        $C.set('v.contacts', results.contacts);
        $C.set('v.holidayMakersCount', results.holiday_makers.length);
        $C.set('v.leadsCount', results.leads.length);
        $C.set('v.contactsCount', results.contacts.length);
        $C.set('v.loading', false);
        $C.set('v.searched', true);    
      } else {
        alert('no results??');
      }
    });
    $A.enqueueAction(action);
  },
    
  goBack: function($C, $E, $H) {
    $H.resetApp($C);
  },
    
  openRecord: function($C, $E, $H) {
    var recordId = $E.getSource().get('v.name');
    var navigation = $A.get("e.force:navigateToSObject");
    navigation.setParams({
      "recordId": recordId,
    });
    navigation.fire();
    $H.closeTab($C);
  },
    
  createLead: function($C, $E, $H) {
    var createRecordEvent = $A.get("e.force:createRecord");
    createRecordEvent.setParams({
        "entityApiName": "Lead"
    });
    createRecordEvent.fire();
    $H.closeTab($C);
  },
    
  convertLead: function($C, $E, $H) {
    $C.set('v.loading', true);
    var recordId = $E.getSource().get('v.name');
    console.log(recordId);
    var action = $C.get('c.changeRT');
    action.setParams({
        recordId: recordId
    });
    action.setCallback(this, function(response) {
      var result = response.getReturnValue();
      console.log(result);
      $H.resetApp($C);
      if (result == 'Success') {
        var navigation = $A.get("e.force:navigateToSObject");
        navigation.setParams({
          "recordId": recordId,
        });
        navigation.fire();
        $H.closeTab($C);
      } else {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
          "title": "Error!",
          "message": result
        });
        toastEvent.fire();
      }
    });
    $A.enqueueAction(action);
  }
    
})
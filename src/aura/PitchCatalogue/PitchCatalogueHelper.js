({
  // set a specific product as selected
  setSelected: function($C, $H, id) {
    $C.set('v.selectedPitch', null);
    $C.set('v.pitches', $C.get('v.pitches').map(function(a) {
      if (a.Id == id) {
        a.User_Selection__c = true;
        $C.set('v.selectedPitch', a);
      } else {
        a.User_Selection__c = false;
      }
      return a;
    }));
    $H.updateFilters($C);
  },
  // run action
  runAction: function($C, action, parameters, callback) {
    var action = $C.get(action);
    action.setParams(parameters);
    action.setCallback(this, function(res) {
      var response = res.getReturnValue();
      callback(response);
    });
    $A.enqueueAction(action);  
  },
  // update filters
  updateFilters: function($C) {
    $C.set('v.loading', true);
    var pitches = $C.get('v.pitches');
    var fStatus = $C.get('v.filterStatus');
    var fType = $C.get('v.filterType');
    var filtered = pitches.filter(function(a) {
      var aStatus = a.Pitch_Status__c || 'Any';
      var aType = a.Pitch_Type__c || 'Any';
      if (fStatus != 'Any' && aStatus != fStatus) { return false;}
      if (fType != 'Any' && aType != fType) { return false;}
      return true;
    });
    filtered = filtered.sort(function(a, b) {
      var aVal = a.Area_Name__c + a.Pitch_Number__c;
      var bVal = b.Area_Name__c + b.Pitch_Number__c;
      if (aVal > bVal) return 1;
      if (bVal > aVal) return -1;
      return 0;
    });
    $C.set('v.filteredPitches', filtered);
    $C.set('v.loading', false);
  },
  // show errors
  showError: function($C, error) {
    $C.set('v.error', error);
    $C.set('v.loading', false);
    $C.set('v.saving', false);
  },
  // save pitches
  savePitches: function($C, $H, goBack) {
    $C.set('v.saving', true);
    var quoteId = $C.get('v.quoteId');
    var hasFinal = false;
    var pitchs = $C.get('v.pitches');
    var pitches = JSON.parse(JSON.stringify(pitchs)).filter(function(a) {
      return a.View_Option__c == true || a.Final_Selection__c == true 
    }).map(function(a) {
      delete a.User_selection__c;
      delete a.Id;
      a.View_Product__c = a.View_Option__c;
      a.Quote__c = quoteId;
      a.Park__c = $C.get('v.parkId');
      if (a.Final_Selection__c == true) hasFinal = true;
      delete a.View_Option__c;
      return a;
    });
    console.log('SELECTION: ', pitches);
    var params = {
      quoteId: quoteId,
      jsonString: JSON.stringify(pitches)
    };
    $H.runAction($C, 'c.updateSelected', params, function(response) {
      console.log(response); 
      if (response == null || response.indexOf('Error') != -1) {
        $H.showError(response);
      } else {
        $C.set('v.saving', false);
        $C.set('v.loading', true);
        params = { quoteId: quoteId, hasPitch: hasFinal };
        $H.runAction($C, 'c.checkAncillaries', params, function(response) {
      	  console.log(response); 
          if (response.indexOf('Error') != -1) {
        	$H.showError(response);
          } else {
        	$C.set('v.toast', 'Your selections have been saved.');
        	$C.set('v.saving', false);
        	$C.set('v.loading', false);
            if (goBack == true) window.location.href = '/' + $C.get('v.quoteId');
        	setTimeout(function(a) {
          	  $C.set('v.toast', '');
        	}, 1000);
          }
        });
      }
    });
        
  }
})
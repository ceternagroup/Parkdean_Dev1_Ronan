({
  // search for units
  runSearch: function($C, $E, $H) {
    $C.set('v.loading', true);
    var params = {
      modelYear: $C.get('v.modelYear'),
      modelMake: $C.get('v.modelMake')
    };
    $H.runAction($C, 'c.getUnits', params, function(response) {
      console.log(response);
      if (response == null) response = [];
      if (response.indexOf('Error:') != -1) return console.error(response);
      $C.set('v.pxUnits', response);
      $C.set('v.filteredPXUnits', response);
      $C.set('v.searched', true);
      $C.set('v.loading', false);
    });
  },
  // run local search
  runLocalSearch: function($C, $E, $H) {
    var query = $C.get('v.search').toLowerCase();
    $C.set('v.filteredPXUnits', $C.get('v.pxUnits').filter(function(a) {
      return a.Model__c.toLowerCase().indexOf(query) != -1;  
    }));
  },
  // go back
  goBack: function($C, $E, $H) {
    $C.set('v.searched', false);
  },
  // save selected unit
  saveUnit: function($C, $E, $H) {
    $C.set('v.loading', true);
    var name = $E.getSource().get('v.name');
    var selected = $C.get('v.pxUnits').filter(function(a) {
      return a.Name == name;   
    })[0];
    console.log(selected);
    var params = {
      quoteId: $C.get('v.recordId'),
      unit: selected
    };
    $H.runAction($C, 'c.saveUnits', params, function(response) {
      console.log(response);
      if (response.indexOf('Error:') != -1) return console.error(response);
      $C.set('v.loading', false);
      try {
        $A.get("e.force:closeQuickAction").fire();
        $A.get('e.force:refreshView').fire();
      } catch(e) { console.error(e); }
    });
  }
})
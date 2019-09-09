({
  // load the items
  loadApp: function($C, $E, $H) {
    var params = { quoteId: $C.get('v.quoteId') };
    $H.runAction($C, 'c.getQuote', params, function(quote) {
      // handle missing values
      if (!quote.Line_Items__r || quote.Line_Items__r.length == 0) return $H.showError($C, 'You have yet to make a final selection on Holiday homes');
      if (!quote.Expected_handover_date__c) return $H.showError($C, 'You have yet to specify an expected handover date');
      if (!quote.Park__r) return $H.showError($C, 'You have not set the park for this Sales Example');
      // set the park id
      $C.set('v.parkId', quote.Park__c);    
      $H.runAction($C, 'c.getSelected', params, function(response) {
        var existing = response;
        params = {
          stockxId: quote.Line_Items__r[0].Stock_Id__c,
          parkId: '' + quote.Park__r.Park_ID__c,
          expectedDate: quote.Expected_handover_date__c,
          accountId: quote.Opportunity.Wizard_Account_Id__c
        };
        $H.runAction($C, 'c.getCatalogue', params, function(response) {
          console.log(response);
          var res = JSON.parse(response);
          if (res.Error != null) return $H.showError($C, 'WIZARD_ERROR: ' + res.Error);
          if (res.Errors.length > 0) {
            return $H.showError($C, 'WIZARD_ERROR: ' + res.Errors[0].Message);
          }
          for (var a = 0; a < res.data.length; a++) {
            res.data[a].Id = res.data[a].Pitch_Id__c;
            res.data[a].View_Option__c = false;
            res.data[a].Final_Selection__c = false;
            res.data[a].User_Selection__c = false;
            for (var b = 0; b < existing.length; b++) {
              if (existing[b].Pitch_Id__c == res.data[a].Pitch_Id__c) {
                res.data[a].View_Option__c = existing[b].View_Product__c;
                res.data[a].Final_Selection__c = existing[b].Final_Selection__c;
              } 
            }
          }
          console.log(res.data);
          $C.set('v.pitches', res.data);
          $H.updateFilters($C);
          $C.set('v.loading', false);
        });
      });
    });
  },
  // reset all items so none are selected
  resetItems: function($C, $E, $H) {
    $C.set('v.pitches', $C.get('v.pitches').map(function(a) {
      a.User_Selection__c = false;
      return a;
    }));
    $H.updateFilters($C);
  },
  // set the check for an item
  setCheck: function($C, $E, $H) {
    var value = $E.getSource().get('v.name');
    var field = value.split('::')[0];
    var id = value.split('::')[1];
    $C.set('v.pitches', $C.get('v.pitches').map(function(a) {
      if (a.Id == id) a[field] = !a[field];
      return a;
    }));
    $H.updateFilters($C);
  },
  // change from list to detail
  changeMode: function($C, $E, $H) {
    var value = $E.getSource().get('v.name');
    var mode = value.split('::')[0];
    var id = value.split('::')[1];
    var detailMode = mode == 'detail' ? true : false;
    $C.set('v.detailMode', detailMode);
    $C.set('v.selectedTab', 1);
    $H.setSelected($C, $H, id);
  },
  // change tab
  changeTab: function($C, $E, $H) {
    var tab = Number($E.getSource().get('v.name'));
    $C.set('v.selectedTab', tab);
  },
  // save selected views / finals
  saveSelected: function($C, $E, $H) {
    $H.savePitches($C, $H, false);
  },
  // update the filtered list
  updateFilters: function($C, $E, $H) {
    $H.updateFilters($C);
  },
  // reset all filters
  resetFilters: function($C, $E, $H) {
    $C.set('v.filterStatus', 'Any');
    $C.set('v.filterType', 'Any');
    $H.updateFilters($C);
  },
  // go back to the quote
  goBack: function($C, $E, $H) {
    $H.savePitches($C, $H, true);
  }
})
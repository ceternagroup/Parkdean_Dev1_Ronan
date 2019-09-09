({
  resetApp: function($C) {
    $C.set('v.holidayMakers', []);
    $C.set('v.leads', []);
    $C.set('v.contacts', []);
    $C.set('v.holidayMakersCount', 0);
    $C.set('v.leadsCount', 0);
    $C.set('v.contactsCount', 0);
    $C.set('v.loading', false);
    $C.set('v.searched', false);
  },
  closeTab: function($C) {
    var utilityAPI = $C.find("utilitybar");
    utilityAPI.minimizeUtility();
  }
})
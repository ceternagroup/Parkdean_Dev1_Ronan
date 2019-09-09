({
    
  // process data into park / global / region rows
  processData: function($C, $H, data) {
    if (data.error != null) return $H.throwError($C, data.error);
    console.log(data);
    var rows = [];
    // order parks
    var parks = data.parks.split(',').map(function(p) {
      return p.trim();
    }).sort(function(a, b) {
      return a - b;
    });
    // order regions
    var regions = data.regions.split(',').map(function(r) {
      return r.trim();
    }).sort(function(a, b) {
      return a - b;
    });
    // add global if allowed
    if (data.globel == true) parks.push('Global');
    // add regions if any
    if (regions.length > 0) parks = parks.concat(regions);
    console.log(parks);
    // for each 'park' create a row
    for (var p = 0; p < parks.length; p++) {
      var park = parks[p];
      var row = {
        name: park,
        park: {
          leads: $H.getLeads(data.leads, park, 'Park'),
          appointments: $H.getAppointments(data.appointments, park, 'Park'),
          visits: $H.getQuotes(data.visits, park, 'Park'),
          signups: $H.getQuotes(data.signups, park, 'Park'),
          sales: $H.getQuotes(data.sales, park, 'Park')
        },
        central: { 
          leads: $H.getLeads(data.leads, park, 'Central'),
          appointments: $H.getAppointments(data.appointments, park, 'Central'),
          visits: $H.getQuotes(data.visits, park, 'Central'),
          signups: $H.getQuotes(data.signups, park, 'Central'),
          sales: $H.getQuotes(data.sales, park, 'Central')
        },
        total: {
          leads: $H.getLeads(data.leads, park),
          appointments: $H.getAppointments(data.appointments, park),
          visits: $H.getQuotes(data.visits, park),
          signups: $H.getQuotes(data.signups, park),
          sales: $H.getQuotes(data.sales, park)
        }
      }
      // add conversions
      row = $H.getConversions(row);
      rows.push(row);
    }
    console.log(rows);
    $C.set('v.parks', rows);
    $C.set('v.loading', false);
  },
    
  // filter for lead checks
  getLeads: function(data, park, type) {
    return data.filter(function(l) {
      if (type != null) return l.Park_Bucket__c == park && l.Record_type_formua__c == type;
      return l.Park_Bucket__c == park;
    }).length;
  },
    
  // filter for appointment checks
  getAppointments: function(data, park, type) {
    return data.filter(function(a) {
      if (type != null) return a.Park__r.Name == park && a.Created_by_Team__c == type;
      return a.Park__r.Name == park;
    }).length;   
  },
    
  // filter for quote type checks
  getQuotes: function(data, park, type) {
    return data.filter(function(q) {
      if (type != null) return q.Park_Name__c == park && q.Appointment_booking_team__c == type;
      return q.Park_Name__c == park;
    }).length;
  },
    
  // add conversion fields
  getConversions: function(row) {
    for (var key in row) {
      if (key != 'name') {
        var type = row[key];   
        type.leadToAppointment = Math.round(type.appointments / type.leads * 100);
        type.appointmentToVisit = Math.round(type.visits / type.appointments * 100);
        type.visitToSignup = Math.round(type.signups / type.visits * 100);
        type.signupToSale = Math.round(type.sales / type.signups * 100);
        if (isNaN(type.leadToAppointment) || !isFinite(type.leadToAppointment)) type.leadToAppointment = 0;
        if (isNaN(type.appointmentToVisit) || !isFinite(type.appointmentToVisit)) type.appointmentToVisit = 0;
        if (isNaN(type.visitToSignup) || !isFinite(type.visitToSignup)) type.visitToSignup = 0;
        if (isNaN(type.signupToSale) || !isFinite(type.signupToSale)) type.signupToSale = 0;
      }   
    }
    return row;
  },
    
  // throw error and show message
  throwError: function($C, error) {
    console.error(error);
    $C.set('v.error', error);
    $C.set('v.loading', false);
  } 
    
})
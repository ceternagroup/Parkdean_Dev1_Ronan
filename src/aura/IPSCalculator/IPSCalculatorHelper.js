({
  // set total incomes
  setTotals: function(products, dates, fresh) {
    products.forEach(function(p, i) {
      var gross = 0;
      var selected = 0;
      dates.forEach(function(d) {
        if (!isNaN(parseFloat(d.pricing[i].Price__c))){
          var price = parseFloat(d.pricing[i].Price__c);
          if (d.available) gross += price;
          if (d.selected) selected += price;
        }
      });

      // console.log('when setting totals selected is ');
      // console.log(selected);

      p.Gross__c  = gross;
      p.Total__c  = selected;
      var split   = selected / 2;

      p.IPS_to_Rent__c = fresh ? split : p.IPS_to_Rent__c || split;
      p.IPS_on_deposit__c = fresh ? split : p.IPS_on_deposit__c || split;
    });
    return products;
  },
  // set peak seasons
  setPeaks: function($C) {
    var dates = $C.get('v.dates');
    var peaks = 0;
    var summers = 0;
    dates.forEach(function(d) {
      if (d.selected && d.pricing[0].Peak__c === 'SEASON') peaks++;
      if (d.selected && d.pricing[0].Peak__c === 'SUMMER') summers++;
    });
    $C.set('v.peaks', peaks);
    $C.set('v.summers', summers);
  },
  // set adjacents
  setAdjacents: function($C) {
    var dates = $C.get('v.dates');
    var adjs = 0;
    dates.forEach(function(d, i) {
      var type = d.weekday == 'Friday' || d.weekday == 'Saturday' || d.weekday == 'Sunday' ? 'Weekend' : 'Weekday';
      if (d.selected == true && type == 'Weekday') {
        if (dates[i + 1].selected == true) adjs++;
      }
    });
    $C.set('v.adjacents', adjs);

  },
  // run action
  runAction: function($C, action, parameters, callback) {
    var action = $C.get(action);
    action.setParams(parameters);
    action.setCallback(this, function(res) {

      var response = res.getReturnValue();
      var errors = res.getError();
      if (errors && errors[0]) {
        return console.error(JSON.stringify(errors));
      }
      callback(response);
    });
    $A.enqueueAction(action);
  },
  // get weekday
  getWeekday: function(day) {
    var days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    return days[day];
  },
  // get month
  getMonth: function(month) {
    var months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
    return months[month];
  },
  // get suffix
  getSuffix: function(date) {
    if (date == 1 || date == 21 || date == 31) return 'st';
    if (date == 2 || date == 22) return 'nd';
    if (date == 3 || date == 23) return 'rd';
    return 'th';
  },
  // get a list of dates
  getDates: function($H, start, end) {



    var today = new Date();

    // var year = today.getFullYear();


    var year = new Date(start).getFullYear();

    console.log(year);
    start = start.split('-');
    end = end.split('-');
    var startDate = new Date(year, Number(start[1]) - 1, start[2]);
    var endDate = new Date(year, Number(end[1]) - 1, end[2]);
    console.log(start, startDate, end, endDate);
    var dates = [];
    var days = Math.round((endDate - startDate) / 1000 / 60 / 60 / 24);

    console.log('number of days determined is ' + days);

    // for (var a = 0; a < days; a++) {
    for (var a = -5; a < days; a++) {
      var date = new Date(year, Number(start[1]) - 1, Number(start[2]) + a);
      var weekday = date.getDay();
      var month = date.getMonth();
      var year = date.getFullYear();
      var day = date.getDate();

      console.log('the week date day is ' + weekday);

      if (weekday == 1 || weekday == 5) {
        dates.push({
          date: date,
          weekday: $H.getWeekday(weekday),
          month: $H.getMonth(month),
          suffix: $H.getSuffix(day),
          year: year,
          day: day
        });
      }
    }

    console.log('we are about to return:');
    console.log(dates);

    return dates;
  },
  // process dates with the rules and features
  processDates: function($H, products, rules, features, existing) {

    var dates = $H.getDates($H, rules[0].Week_Start__c, rules[rules.length - 1].Week_Start__c);

    console.log('first date sent is ' + rules[0].Week_Start__c);
    console.log('last date sent is ' + rules[rules.length - 1].Week_Start__c);

    console.log('rules are');
    console.log(rules);

    console.log(dates);
    console.log(products, rules, features);
    var matches = [];

    console.log('existing collection is ');
    console.log(existing);

    existing.forEach(function(a) {

      console.log('processing a date');
      console.log(a);

      if (a.IPS_Days__r) {
        a.IPS_Days__r.forEach(function(i) {
          var match = i.Match__c;
          if (matches.indexOf(match) == -1) {
            matches.push(match);

            console.log('pushing the following match to matches[]' + match);

          }
        })
      }
    });
    console.log(matches);
    dates.forEach(function(d) {
      d.available = true;
      d.match = d.day + '-' + d.month + '-' + d.year;

      console.log('trying to find selected property');

      d.selected = matches.indexOf(d.match) !== -1 ? true : false;


      console.log('found property');

      d.pricing = [];
      products.forEach(function(p, pi) {
        var matchRules = rules.filter(function(a) {
          return a.Stock_Grade_New__c === p.Stock_Grade_New__c;
        });
        var match = '';
        var price = '';
        var pseason = false;
        var psummer = false;
        for (var a = 0; a < matchRules.length; a++) {
          var rule = matchRules[a];
          var ruleDate = new Date(rule.Week_Start__c + ' 00:00:00');
          if (d.date.getTime() >= ruleDate.getTime()) {
            match = rule.Week_Start__c;
            d.available = rule.Do_not_Allow__c;
            if (d.weekday === 'Friday' || d.weekday === 'Saturday' || d.weekday === 'Sunday') {
              price = rule.Weekend_Price__c;
            } else {
              price = rule.Week_Price__c;
            }
            pseason = rule.Peak_season__c;
            psummer = rule.Peak_summer__c;
          }
        }
        d.rule = match;
        d.pricing.push({
          Price__c: price,
          Final_Selection__c: p.Final_Selection__c,
          Class__c: p.Class__c,
          Peak__c: psummer ? 'SUMMER' : pseason ? 'SEASON' : ''
        });
      });
    });
    return dates;
  }
})
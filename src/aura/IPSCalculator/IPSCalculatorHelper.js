({
    /**********************************************************************************************
    * @Author:      Phase1
    * @Date:        
    * @Description: Set Total Incomes
    * @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]   
    ***********************************************************************************************/             
    setTotals: function(products, dates, fresh) {
        products.forEach(function(p, i) {
            var gross = 0;
            var selected = 0;
            dates.forEach(function(d) {
                var price = d.pricing[i].Price__c;
                if (d.available == true) gross += price;
                if (d.selected == true) selected += price;
            });
            p.Gross__c = gross;
            p.Total__c = selected;
            var split = selected / 2;
            p.IPS_to_Rent__c = fresh ? split : p.IPS_to_Rent__c || split;
            p.IPS_on_deposit__c = fresh ? split : p.IPS_on_deposit__c || split;
        });
        return products;
    },
    
    /**********************************************************************************************
    * @Author:      Phase1
    * @Date:        
    * @Description: Set Peak Seasons
    * @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]   
    ***********************************************************************************************/
    setPeaks: function($C) {
        var dates = $C.get('v.dates');
        var peaks = 0;
        var summers = 0;
        dates.forEach(function(d) {
            if (d.selected == true && d.pricing[0].Peak__c == 'SEASON') peaks ++;
            if (d.selected == true && d.pricing[0].Peak__c == 'SUMMER') summers ++;
        });
        $C.set('v.peaks', peaks);
        $C.set('v.summers', summers);
    },
    /**********************************************************************************************
    * @Author:      Phase1
    * @Date:        
    * @Description: Set Adjacents
    * @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]   
    ***********************************************************************************************/ 
    setAdjacents: function($C) {
        var dates = $C.get('v.dates');
        var adjs = 0;
        dates.forEach(function(d, i) {
            var type = d.weekday == 'Friday' || d.weekday == 'Saturday' || d.weekday == 'Sunday' ? 'Weekend' : 'Weekday';
            if (d.selected == true && type == 'Weekday') {
                if (dates[i+1].selected == true) adjs ++;
            }
        });
        $C.set('v.adjacents', adjs);
        
    },
    
     /**********************************************************************************************
    * @Author:      Phase1
    * @Date:        
    * @Description: Run action
    * @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]   
    ***********************************************************************************************/ 
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
    /**********************************************************************************************
    * @Author:      Phase1
    * @Date:        
    * @Description: Get Weekday
    * @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]   
    ***********************************************************************************************/ 
  getWeekday: function(day) {
    var days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    return days[day];
  },
    /**********************************************************************************************
    * @Author:      Phase1
    * @Date:        
    * @Description: Get Month
    * @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]   
    ***********************************************************************************************/ 
  getMonth: function(month) {
    var months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
    return months[month];
  },
    /**********************************************************************************************
    * @Author:      Phase1
    * @Date:        
    * @Description: Get Suffix
    * @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]   
    ***********************************************************************************************/ 
  getSuffix: function(date) {
    if (date == 1 || date == 21 || date == 31) return 'st';
    if (date == 2 || date == 22) return 'nd';
    if (date == 3 || date == 23) return 'rd';
    return 'th';
  },
  
    /**********************************************************************************************
    * @Author:      Phase1
    * @Date:        
    * @Description: generate list of dates from available price rule data
    * @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]   
    * 	21/08/2019	-	B0140	-	Susanna Taylor	-	changed end date and date increment rules to accommodate
    * 			multiple years
    ***********************************************************************************************/             
    getDates: function($H, start, end) {
        var today = new Date();
        var year = today.getFullYear();
        console.log(year);
        start = start.split('-');
        end = end.split('-');
        var startDate = new Date(year, Number(start[1]) - 1, start[2]);
        //    var endDate = new Date(year, Number(end[1]) - 1, end[2]);
        var endDate = new Date(end[0], Number(end[1]) - 1, end[2]);
        console.log(start, startDate, end, endDate);
        var dates = [];
        var days = Math.round((endDate - startDate) / 1000 / 60 / 60 / 24);
        
        var dateToMatch = new Date(start[0], Number(start[1]) - 1, start[2] );
        for (var a = 0; a < days; a++) {
            //      var date = new Date(year, Number(start[1]) - 1, Number(start[2]) + a);
            
            dateToMatch = this.addDays(dateToMatch,1);
            var date = dateToMatch;
            var weekday = date.getDay();
            var month = date.getMonth();
            var year = date.getFullYear();
            var day = date.getDate();
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
        return dates;
    },
    /**********************************************************************************************
    * @Author:      Phase1
    * @Date:        
    * @Description: Process dates with the rules and features
    * @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]   
    ***********************************************************************************************/ 
    processDates: function($H, products, rules, features, existing) {
        var dates = $H.getDates($H, rules[0].Week_Start__c, rules[rules.length - 1].Week_Start__c);
        console.log(dates);
        //    console.log(products, rules, features);
        var matches = [];
        existing.forEach(function(a) {
            if (a.IPS_Days__r) {
                a.IPS_Days__r.forEach(function(i) {
                    var match = i.Match__c;
                    if (matches.indexOf(match) == -1) {
                        matches.push(match);   
                    }
                }) 
            }
        });
        
        dates.forEach(function(d) {
            d.available = true;
            d.match = d.day + '-' + d.month + '-' + d.year;
            d.selected = matches.indexOf(d.match) != -1 ? true : false;
            d.pricing = [];
            products.forEach(function(p, pi) {
                var matchRules = rules.filter(function(a) {
                    return a.Stock_Grade_New__c == p.Stock_Grade_New__c;   
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
                        if (d.weekday == 'Friday' || d.weekday == 'Saturday' || d.weekday == 'Sunday') {
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
            /*for (var a = 0; a < features.length; a++) {
              var f = new Date(features[a].Date__c + ' 00:00:00');
              if (d.day == f.getDate() && d.year == f.getFullYear() && d.date.getMonth() == f.getMonth()) {
                d.available = false; break;
              }
            }*/
    });
      return dates;
  },
    /**********************************************************************************************
    * @Author:      Susanna Taylor
    * @Date:        21/08/2019
    * @Description: add days to a date
    * @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]   
    ***********************************************************************************************/         
    addDays: function (date, days) {
        var result = new Date(date);
        result.setDate(result.getDate() + days);
        return result;
    },
    /**********************************************************************************************
    * @Author:      Susanna Taylor
    * @Date:        21/08/2019
    * @Description: return true if all selected dates are in the same calendar year
    * @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]   
    ***********************************************************************************************/             
    validateYears: function($C, $H) {
        var years = [];
        $C.get('v.dates').forEach(function(d) {
            
            if (d.selected == true && !years.includes(d.year)) {
                years.push(d.year);
            }
            
        });
        // return years.length == 1;
        return true;
    }
})
({
  runAction: function($C, action, parameters, callback) {
    var action = $C.get(action);
    if (action != null && action != undefined) {
      action.setParams(parameters);
      action.setCallback(this, function(res) {
        var response = res.getReturnValue();
        callback(response);
      });
      $A.enqueueAction(action);
    }
  },
  runTimer: function($C, $H, responded) {
    function loop() {
      var now = new Date();
      var deadline = new Date($C.get('v.deadlineDate'));
      if ($C.get('v.respondDate') != undefined) {
        now = new Date($C.get('v.respondDate'));
      }
      var businessHours = $C.get('v.businessHours');
      // within BH
      var timeb = $H.getTimeBetweenDates($C, $H, now, deadline, businessHours);
      if (timeb != null) {
	  // real time
      //var timeb = deadline - now;
      var remaining = Math.round(timeb / 1000);
      console.log(remaining);
      var missed = timeb == null ? true : false;
      var days = ('' + remaining / 86400);
      var hours = (Number('0.' + days.split('.')[1]) * 24) + '';
      var minutes = (Number('0.' + hours.split('.')[1]) * 60) + '';
      var seconds = (Number('0.' + minutes.split('.')[1]) * 60) + '';
      var d = days.split('.')[0];
      var h = hours.split('.')[0];
      var m = minutes.split('.')[0];
      var s = '' + Math.round(Number(seconds));
      d = d.length == 1 ? '0' + d : d;
      h = h.length == 1 ? '0' + h : h;
      m = m.length == 1 ? '0' + m : m;
      s = s.length == 1 ? '0' + s : s;
      h = h == 'NaN' ? '00': h;
      m = m == 'NaN' ? '00' : m;
      s = s == 'NaN' ? '00' : s;
      if (remaining < 0) {
        $C.set('v.deadlineState', 'Error');
      } else if (Number(h) <= 1 && Number(d) == 0) {        
        $C.set('v.deadlineState', 'Warning');
      } 
      var timer = d + ':' + h + ':' + m + ':' + s;
      var response = $C.get('v.respondDate');
      console.log('setting', timer);
      $C.set('v.deadlineTimer', timer);
      setTimeout(function() {
        loop();
      }, 1000);
      }
    }
    loop();
  },
  getTimeBetweenDates: function($C, $H, startDate, endDate, businessHours) {
    var difference = Math.round((endDate - startDate) / (1000 * 60 * 60 * 24));
    if (isNaN(difference)) return null;
    console.log(difference + ' days between');
    if (difference < 0) {
      $C.set('v.hasError', true);
      $C.set('v.errorMessage', 'Deadline Missed');
      return null;
    }
    var dates = [];
    for (var a = 0; a <= difference; a++) {
      var date = a == difference && difference !== 0 ? new Date(endDate) : new Date(startDate);
      if (a !== 0 && a != difference) {
        date.setDate(startDate.getDate() + a);
        date.setHours(0);
      }
      dates.push(date);
    }
    console.log(difference, dates);
    var ms = 0;
    if (difference > 0) {
      dates.forEach(function(a, i) {
        var type = i === 0 ? 'start' : i == dates.length - 1 ? 'end' : null;
        console.log(a.toISOString() + ' ' + type);
        ms += $H.getTimeForDate($H, a, type, businessHours);
      });
    } else {
      console.log('1 day only');
      var startTime = startDate.toISOString().split('T')[1];
      var endTime = endDate.toISOString().split('T')[1];
      ms += $H.getSecondsBetweenTimes($H, startTime, endTime);
    }
    var tz = new Date();
    var timezone = tz.getTimezoneOffset();
    console.log('TZ:' + timezone);
    console.log(ms + 'ms (' + (ms / (1000 * 60 * 60)) + ' hours)');
    return ms;
  },
  getTimeForDate: function($H, date, type, businessHours) {
    var days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    var day = days[date.getDay()];
    var time = date.toISOString().split('T')[1];
    var dayStart = type == 'start' ? time : $H.getTimeFromDate(businessHours[day + 'StartTime']);
    var dayEnd = type == 'end' ? time : $H.getTimeFromDate(businessHours[day + 'EndTime']);
    return $H.getSecondsBetweenTimes($H, dayStart, dayEnd);
  },
  getTimeFromDate: function(date) {
    if (date == null) return null;
    return new Date(date).toISOString().split('T')[1];
  },
  getSecondsBetweenTimes: function($H, startTime, endTime) {
    console.log(startTime, endTime);
    if (startTime == null || endTime == null) return 0;
    return $H.getDateFromTime(endTime) - $H.getDateFromTime(startTime);
  },
  getDateFromTime: function(timeString) {
    timeString = timeString.split('.')[0].split(':');
    var date = new Date();
    date.setSeconds(timeString[2]);
    date.setMinutes(timeString[1]);
    date.setHours(timeString[0]);
    return date;
  },
    runLoad: function($C, $E, $H, stop) {
        var params = {
      recordId: $C.get('v.recordId')
    };
    $H.runAction($C, 'c.getLead', params, function(response) {
      if (response.indexOf('Error') != -1) {
        $C.set('v.hasError', true);
        $C.set('v.errorMessage', response);
      } else {
        var lead = JSON.parse(response);
        console.log(lead);
        $C.set('v.respondDate', lead.First_Responded__c);
          $C.set('v.showRespondDate', lead.First_Responded__c ? new Date(lead.First_Responded__c) : null);
        $C.set('v.deadlineDate', lead.SLA_Deadline__c);
        $C.set('v.showDeadlineDate', new Date(lead.SLA_Deadline__c));
        console.log($C.get('v.deadlineDate'));
        params = { 
          hourId: lead.Business_Hours__c 
        };
        $H.runAction($C, 'c.getHours', params, function(hours) {
          if (hours == null) {
            $C.set('v.hasError', true);
            $C.set('v.errorMessage', 'No Business Hours set');
          } else {
            $C.set('v.businessHours', hours);
            var responded = lead.First_Responded__c == null ? false : true;
            if (stop !== true) {
              console.log('running timer', stop);
              $H.runTimer($C, $H, responded);
            }
            if (responded == true) {
                $C.set('v.deadlineTitle', 'SLA Responded: ' + $C.get('v.deadlineDate'));
            }
          }
        });
      }
    });
    }
})
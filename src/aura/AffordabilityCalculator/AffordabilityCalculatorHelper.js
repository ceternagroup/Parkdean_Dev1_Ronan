({
  // rerun final calculations
  getPayments: function($C) {
    var rate = $C.get('v.installmentRate');
    var payments = $C.get('v.totalPayments');
    var deposit = $C.get('v.totalDeposit');
    var quote = $C.get('v.quote');
    var amount = $C.get('v.productAmount');
    $C.set('v.changeCost', ((amount - quote.PX_Value__c) + quote.Finance_settlement__c).toFixed(2));
    var recordType = quote.Record_type_formula__c;
    var partEx = recordType ? recordType.indexOf('Part_Ex') != -1 : false;
    console.log(recordType, partEx);
    var equity = quote.Inbound_PX_Price__c;
    var ips = quote.IPS_to_sale2__c;
    var total;
    if (partEx) {
      if (equity >= 0) total = amount - deposit - ips - equity;
      if (equity < 0) total = amount - deposit - ips + Math.abs(equity);
    } else {
      total = amount - deposit - ips;
    }
    $C.set('v.loanAmount', total);
    var repayment = rate * total * (Math.pow(1 + rate, payments) / (1 - Math.pow(1 + rate, payments)));
    $C.set('v.paymentAmount', Math.abs(repayment).toFixed(2));
    var credit = (Math.abs(repayment) * payments) - total;
    $C.set('v.totalCredit', Math.abs(credit).toFixed(2));
    var term = $C.get('v.totalPayments') / 12;
    var interest = (credit - 10) / term / total;
    $C.set('v.interestRate', interest);
    var tot = Number(credit + total);
    if (!isNaN(tot)) tot = tot.toFixed(2);
    $C.set('v.totalRepayment', tot);
    $C.set('v.totalPayable', $C.get('v.productAmount') + credit);    
    if ($C.find('amountRange')) {
      $C.find('amountRange').set('v.value', $C.get('v.productAmount'));
    }
    $C.find('depositRange').set('v.value', $C.get('v.totalDeposit'));
    $C.set('v.loading', false);
  },
  // get deposit
  getDeposit: function($C, minimum) {
    var current = $C.get('v.totalDeposit');
    var quote = $C.get('v.quote');
    var equity = quote.Inbound_PX_Price__c || 0;
    var ips = quote.IPS_to_sale2__c || 0;
    console.log('GET DEPOSIT', current, minimum);
    var final = quote.Number_of_final_products__c > 0 && quote.number_of_final_pitches__c > 0;
    var amountp = $C.get('v.minimumDeposit') * $C.get('v.productAmount');
    console.log('NEW DEPOSIT', amountp);
    var recordType = quote.Record_type_formula__c;
    var partEx = recordType ? recordType.indexOf('Part_Ex') != -1 : false;
    console.log(recordType, partEx);
    var deposit;
    if (partEx) {
      if (equity >= 0) deposit = amountp - ips - equity;
      if (equity < 0) deposit = amountp - ips + Math.abs(equity);
    } else {
      deposit = amountp;
    }
    console.log('PRE 1000', deposit);
    if (deposit < 1000) deposit = 1000;
    deposit = Number(deposit.toFixed(2));
    console.log(equity, ips, final, amountp, deposit);
    //if (current > deposit && !minimum) deposit = current;
    console.log('HELPER DEPOSIT', deposit);
    return deposit;
  },
  // run action
  runAction: function($C, action, parameters, callback) {
    var action = $C.get(action);
    action.setParams(parameters);
    action.setCallback(this, function(res) {
      var response = res.getReturnValue();
      console.log(response);
      callback(response);
    });
    $A.enqueueAction(action);  
  }
})
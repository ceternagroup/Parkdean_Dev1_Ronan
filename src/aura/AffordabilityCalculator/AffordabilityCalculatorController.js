({
  // gets the initial values
  getValues: function($C, $E, $H) {
	var quote = $C.get('v.quoteId');
    var params = {
      recordId: $C.get('v.recordId') || quote
    };
    console.log('PARAMS', params);
    $H.runAction($C, 'c.getPrice', params, function(res) {
      console.log(res);
      var quote = res.Quote;
      console.log(quote.Record_type_formula__c);
      var item = res.Line_Item__c;
      quote.IPS_to_sale2__c = quote.IPS_to_sale2__c || 0;
      quote.IPS_to_rent2__c = quote.IPS_to_rent2__c || 0;
      $C.set('v.equity', (quote.Inbound_PX_Price__c) || 0);
      console.log(quote.Inbound_PX_Price__c);
      $C.set('v.quote', quote);
      // new overides
      var mindep = item != null && item.Product__r != null ? item.Product__r.Deposit_Minimum__c : quote != null ? quote.Deposit_Minimum__c : '0.1';
      if (mindep == null) mindep = '0.1';
      var unavailable = item != null && item.Product__r != null ? !item.Product__r.Finance_Allowed__c : quote != null ? !quote.Finance_Allowed__c : false;
      if (unavailable == null) unavailable = false;
      var term = item != null && item.Product__r != null ? item.Product__r.Max_Length_of_Term_Allowed__c : quote != null ? quote.Max_Length_of_Term_Allowed__c : 84;
      if (term == null) term = 84;
      console.log(mindep, unavailable, term);
      $C.set('v.minimumDeposit', Number(mindep));
      $C.set('v.unavailable', unavailable);
      $C.set('v.maximumTerm', term);
      $C.set('v.totalPayments', term);
      // if no products yet, reset to finance mode
      if (quote.Number_of_final_products__c == 0) {
        $C.set('v.minimumDeposit', 0.1);
        $C.set('v.unavailable', false);
        $C.set('v.maximumTerm', 84);
        $C.set('v.totalPayments', 84);
      }
      // if on a form, reset to finance mode
      if (res.Form != null) {
        $C.set('v.minimumDeposit', 0.1);
        $C.set('v.unavailable', false);
        $C.set('v.maximumTerm', 84);
        $C.set('v.totalPayments', 84);
      }
      var price = item.Unit_Price__c != null ? item.Unit_Price__c : quote.Total_Package_Price__c != null ? quote.Total_Package_Price__c : 10000;
      var px = quote.Inbound_PX_Price__c;
      var apr = 1+ ($C.get('v.representativeAPR') / 100);
      var rate = (Math.pow(apr, (1/12)) - 1);
      $C.set('v.installmentRate', rate);
      var overide = $C.get('v.overideAmount');
      // if there is an overide use it
      if (overide != null) {
        console.log(overide);
        $C.set('v.productAmount', overide);   
      }
      // if final product & pitch
      if (quote.Number_of_final_products__c > 0 && quote.number_of_final_pitches__c > 0) {
        $C.set('v.lock', true);
      }
      // if this is a line item set it
      if (item.Unit_Price__c != null) {
        $C.set('v.quoteId', item.Quote__c);
        $C.set('v.lineItem', true);
        $C.set('v.productId', item.Product__c);
        $C.set('v.productAmount', price);
        $C.set('v.lock', true);
      }
      if (item.Unit_Price__c == null) {        
        $C.set('v.productAmount', price);    
      }
      // if there is px toggle it
      if (px != null && px != 0) {
        $C.set('v.quotePx', px);
        $C.set('v.hasPx', true);
      }
      // set deposit
      $C.set('v.totalDeposit', $H.getDeposit($C, false));
      $H.getPayments($C);
    });
  },
  // changes values based on selection
  selectedProduct: function($C, $E, $H) {
	var selected = $C.get('v.selectedProduct');
    var oldValue = $E.getParam('oldValue');
    var newValue = $E.getParam('value');
    var overide = $C.get('v.overideAmount');
    if (overide != null) {
      console.log('overide:', overide);
      var mindep = selected != null ? selected.Deposit_Minimum__c: '0.1';
      if (mindep == null) mindep = '0.1';
      var unavailable = selected != null ? !selected.Finance_Allowed__c : false;
      if (unavailable == null) unavailable = false;
      var term = selected != null ? selected.Max_Length_of_Term_Allowed__c : 84;
      if (term == null) term = 84;
      console.log(mindep, unavailable, term);
      $C.set('v.minimumDeposit', Number(mindep));
      $C.set('v.unavailable', unavailable);
      $C.set('v.maximumTerm', term);
      $C.set('v.totalPayments', term);
      $C.set('v.productAmount', overide);
      $C.set('v.totalDeposit', $H.getDeposit($C, true));
    }
    console.log('CHANGED', newValue);
    $H.getPayments($C);
  },
  // changes the amount values
  changeAmount: function($C, $E, $H) {
    var type = $E.getSource().get('v.name');
    var amount = $C.get('v.productAmount');
    var newAmount = Number($C.get('v.productAmount'));
    if (type == 'add') newAmount += 500;
    if (type == 'subtract') newAmount -= 500;
    if (type == undefined) newAmount = Number($C.find('amountRange').get('v.value'));
    if (newAmount < 0) newAmount = 0;
    if (newAmount > 500000) newAmount = 500000;
    $C.set('v.productAmount', newAmount);
    $C.set('v.totalDeposit', $H.getDeposit($C, false));
    $H.getPayments($C);
  },
  // changes the deposit values
  changeDeposit: function($C, $E, $H) {
    var type = $E.getSource().get('v.name');
    var quote = $C.get('v.quote');
    var minimumDeposit = $H.getDeposit($C, true);
    var newDeposit = $C.get('v.totalDeposit');
    var maxDeposit = $C.get('v.productAmount');
    if (type == 'add') newDeposit += 500;
    if (type == 'subtract') newDeposit -= 500;
    if (type == undefined) newDeposit = $C.find('depositRange').get('v.value');
    if (newDeposit < minimumDeposit) newDeposit = minimumDeposit;
    if (newDeposit > maxDeposit) newDeposit = maxDeposit;
    newDeposit = Number(newDeposit);
    if (!isNaN(newDeposit)) newDeposit = Number(newDeposit.toFixed(2));
    $C.set('v.totalDeposit', newDeposit);
    var amount = $C.get('v.productAmount');
    var total = amount - newDeposit;
    $H.getPayments($C);
  },
  // changes the term values
  changeTerm: function($C, $E, $H) {
    var type = $E.getSource().get('v.name');
    var maximumTerm = $C.get('v.maximumTerm') * 12;
    var newTerm = $C.get('v.totalPayments');
    if (type == 'add') newTerm += 12;
    if (type == 'subtract') newTerm -= 12;
    if (newTerm > maximumTerm) newTerm = maximumTerm;
    if (newTerm < 12) newTerm = 12;
    $C.set('v.totalPayments', newTerm);
    $H.getPayments($C);
  },
  // save calculation result
  saveResult: function($C, $E, $H) {
    $C.set('v.loading', true);
    var product = $C.get('v.selectedProduct');
    var record = $C.get('v.recordId');
    var quote = $C.get('v.quoteId');
    var lock = $C.get('v.lock');
    var lineItem = $C.get('v.lineItem');
    var productId = $C.get('v.productId');
    if (record == null || record == undefined) record = null;
    var calculation = {
      Quote__c: lineItem == true ? quote : record == null ? quote : record.indexOf('0Q0') == 0 ? record : null,
	  Customer_Requirements_Form__c: lineItem == true ? null : record != null && record.indexOf('0Q0') == 0 ? null : record,
      Product__c: lineItem == true ? productId : product ? product.Id : null,
      Type__c: product || lock ? 'Finance' : 'Affordability',
      Amount_To_Borrow__c: Number($C.get('v.productAmount')),
      Deposit__c: Number($C.get('v.totalDeposit')),
      Months_To_Pay_Back__c: Number($C.get('v.totalPayments')),
      APR__c: Number($C.get('v.representativeAPR')),
      Total_Repayment__c: Number($C.get('v.totalRepayment')),
      Total_Cost_Of_Credit__c: Number($C.get('v.totalCredit')),
      Monthly_Repayment__c: Number($C.get('v.paymentAmount')),
      Balance_to_Finance__c: Number($C.get('v.loanAmount')),
      Interest_Rate__c: Number((Number($C.get('v.interestRate')) * 100).toFixed(2))
    };
    console.log(calculation);
    var params = {
      result: calculation    
    };
    $H.runAction($C, 'c.saveCalculation', params, function(response) {
      console.log(response);
      $C.set('v.loading', false);
    });
  }
})
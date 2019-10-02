({
  getData: function($C, $E, $H) {
    var params = {
      quoteId: $C.get('v.quoteId')   
    };
    $H.runAction($C, 'c.getQuote', params, function(quote) {
      $C.set('v.quote', quote);
      $H.runAction($C, 'c.getItems', params, function(existing) {
        $H.runAction($C, 'c.getRules', params, function(rules) {
          rules = rules.sort(function(a, b) {
            return new Date(a.Week_Start__c) - new Date(b.Week_Start__c);
          });
          console.log('RULES:');
          console.log(rules);
          $H.runAction($C, 'c.getFeatures', params, function(features) {
            $H.runAction($C, 'c.getProducts', params, function(products) {
              if (products.length == 0) return alert('None of your products are available for IPS.');
              console.log(products);
              var grades = [];
              products.forEach(function(a) {
                var grade = a.Stock_Grade_New__c ? a.Stock_Grade_New__c : null;
                if (grade != null && grades.indexOf(grade) == -1) grades.push(grade); 
              });
              if (rules.length == 0 && grades.length == 0) return alert('No stock grade for your chosen stock.');
          	  if (rules.length == 0) return alert("No Rules found for this park for the given stock grades. (" + grades.join(', ') + ')');
              products.forEach(function(p) {
                var c = '';
                if (p.Final_Selection__c == true) c = 'FINAL'; 
                if (p.Not_available_for_IPS__c == true) c = 'NA';
                p.Class__c = c;
              });
              var dates = $H.processDates($H, products, rules, features, existing);
              // process product totals
              products = $H.setTotals(products, dates, false);
              $C.set('v.products', products);
              $C.set('v.dates', dates);
              $H.setPeaks($C);
              $H.setAdjacents($C);
              $C.set('v.loading', false);
            });
          });
        });  
      });
    });
  },
  // update selected totals
  updateTotals: function($C, $E, $H) {
    var products = $C.get('v.products');
    var dates = $C.get('v.dates');
    products = $H.setTotals(products, dates, true);
    $H.setPeaks($C);
    $H.setAdjacents($C);
    $C.set('v.products', products);
  },
  // update deposit when rent changes
  updateDeposit: function($C, $E, $H) {
    var index = Number($E.getSource().get('v.name'));
    var products = $C.get('v.products');
    var product = products[index];
    var gross = Number(product.Total__c);
    var deposit = Number(product.IPS_on_deposit__c);
    if (deposit > gross) {
      product.IPS_on_deposit__c = gross;
      product.IPS_to_Rent__c = 0;
    } else {
      product.IPS_to_Rent__c = gross - deposit;
    }
    products[index] = product;
    console.log(product);
    $C.set('v.products', products);
  },
  // update rent when deposit changes
  updateRent: function($C, $E, $H) {
    var index = Number($E.getSource().get('v.name'));
    var products = $C.get('v.products');
    var product = products[index];
    var gross = Number(product.Total__c);
    var rent = Number(product.IPS_to_Rent__c);
    if (rent > gross) {
      product.IPS_to_Rent__c = gross;
      product.IPS_on_deposit__c = 0;
    } else {
      product.IPS_on_deposit__c = gross - rent;
    }
    products[index] = product;
    console.log(product);
    $C.set('v.products', products);
  },
  // go back to the quote
  goBack: function($C, $E, $H) {
    window.location.href = '/' + $C.get('v.quoteId');
  },
  // save selections so we can reload them in next time
  saveSelections: function($C, $E, $H) {
    $C.set('v.saving', true);
    var items = [];
    var days = [];
    $C.get('v.products').forEach(function(a, i) {
      if (a.Not_available_for_IPS__c === false) {
      var item = {
        Quote__c: $C.get('v.quoteId'),
        Product__c: a.Product__c,
        IPS_on_deposit__c: a.IPS_on_deposit__c,
        IPS_to_Rent__c: a.IPS_to_Rent__c,
        Final_Selection__c: a.Final_Selection__c,
        Opportunity__c: null
      };
      $C.get('v.dates').forEach(function(b) {

        console.log('in forEach date has property');
        console.log(b.date);

        var recordDate = new Date(b.date);
        recordDate.setHours(recordDate.getHours() + 3);

        var month = (b.date.getMonth() + 1) < 10 ? '0' + (b.date.getMonth() + 1) : (b.date.getMonth() + 1);
        var day = b.date.getDate() < 10 ? '0' + b.date.getDate() : b.date.getDate();


        days.push({
          Date__c : b.date.getFullYear() + '-' + month + '-' + day ,
          Value__c: b.pricing[i].Price__c,
          Selected__c: b.selected,
          Available__c: b.available,
          Match__c: b.match,
          Product__c: a.Product__c,
          Peak_season__c: b.pricing[i].Peak__c === 'SEASON',
          Peak_summer__c: b.pricing[i].Peak__c === 'SUMMER'
        });
      });
      items.push(item);
            
      }
    });
    var products = $C.get('v.products').filter(function(a) {
      return a.Not_available_for_IPS__c === false;
    });
    console.log(days);
    console.log(JSON.stringify(products));
    var params = {
      items: JSON.stringify(items),
      days: JSON.stringify(days),
      quoteId: $C.get('v.quoteId'),
      products: products
    };
    console.log(params);
    $H.runAction($C, 'c.saveIPSItems', params, function(res) {
      $C.set('v.saving', false);
      console.log(res);
      if (res.indexOf('Error') != -1) alert(res);
    });
  }
})
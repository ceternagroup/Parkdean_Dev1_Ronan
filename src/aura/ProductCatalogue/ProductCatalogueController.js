({
  // load the items
  loadApp: function($C, $E, $H) {
    var params = {
      quoteId: $C.get('v.quoteId')
    };
      $H.runAction($C, 'c.getQuote', params, function(quote) {
	console.log(quote);
      $C.set('v.parkId', quote.Park__c);
    $H.runAction($C, 'c.getSelected', params, function(response) {
      var existing = response;
      console.log('Existing', existing);
      params = {
        parkId: $C.get('v.parkId'),
        lineItemId: null
      };
      $H.runAction($C, 'c.getCatalogue', params, function(response) {
        var products = response.products;
        var prices = response.prices;
        var images = response.images;
        for (var a = 0; a < products.length; a++) {
          var p = products[a];
          p.Prices__c = [];
          p.Previews__c = [];
          p.View_Option__c = false;
          p.Final_Selection__c = false;
          p.User_Selection__c = false;
          prices.forEach(function(pr) {
            if (pr.Stock__c == p.Id) p.Prices__c.push(pr); 
          });
          p.Prices__c = p.Prices__c.sort(function(a, b) {
            return a.Total_Price__c - b.Total_Price__c;    
          })
          images.forEach(function(i) {
            if (i.Product__c == p.Id) p.Previews__c.push(i); 
          });
          if (p.Prices__c && p.Prices__c.length > 0) {
            p.Price__c = p.Prices__c[0].Discount_Price__c ? p.Prices__c[0].Discount_Price__c : p.Prices__c[0].Total_Price__c;
          }
          // update existing selection fields
          existing.forEach(function(e) {
            if (e.Product__c == p.Id) {
              p.View_Option__c = e.View_Product__c;
              p.Final_Selection__c = e.Final_Selection__c;
              p.Price__c = e.Unit_Price__c; // unit price on line item is total price from stock price
              p.Order__c = e.Order__c;
            }  
          });
          p.Preview_Selection__c = p.Previews__c.length > 0 ? p.Previews__c[0].Image_URL__c : '';
        }
        console.log(products);
        $C.set('v.products', products.filter(function(a) {
          return a.Prices__c && a.Prices__c.length > 0;    
        }));
    	$H.updateFilters($C);
        setTimeout(function() {
          $C.set('v.loading', false);
        }, 1000);
      });
    }); 
    });
  },
  // select an item, to emit the id outwards
  selectItem: function($C, $E, $H) {
    $E.stopPropagation();
    var id = $E.getSource().get('v.name');
    console.log('fffselecting', id);
    var product = $C.get('v.products').filter(function(a) {
      return a.Id == id   
    })[0];
    console.log(product);
    var ev = $C.getEvent('ProductSelection');
    ev.setParams({
      recordId: id,
      overideAmount: product.Price__c
    });
    console.log('sending event', product.Price__c);
    ev.fire();
    $H.setSelected($C, $H, id);
  },
  // reset all items so none are selected
  resetItems: function($C, $E, $H) {
    $C.set('v.products', $C.get('v.products').map(function(a) {
      a.User_Selection__c = false;
      return a;
    })); 
    var ev = $C.getEvent('ProductSelection');
    ev.setParams({
      recordId: '',
      overideAmount: ''
    });
    ev.fire();
    $H.updateFilters($C);
  },
  // set the check for an item
  setCheck: function($C, $E, $H) {
    $E.stopPropagation();
    var value = $E.getSource().get('v.name');
    var field = value.split('::')[0];
    var id = value.split('::')[1];
    var products = $C.get('v.products').map(function(a) {
      if (a.Id == id) a[field] = !a[field];
      return a;
    });
    $C.set('v.products', products);
    $H.updateFilters($C);
  },
  // stop an event
  stopEvent: function($C, $E, $H) {
    $E.stopPropagation();
    var value = $E.getSource().get('v.name');
    var field = value.split('::')[0];
    var id = value.split('::')[1];
    var products = $C.get('v.products').map(function(a) {
      if (a.Id == id) a[field] = !a[field];
      return a;
    });
    $C.set('v.products', products);
    $H.updateFilters($C);
  },
  // set final selection and save
  setFinal: function($C, $E, $H) {
    $E.stopPropagation();
    var id = $E.getSource().get('v.name');
    $C.set('v.products', $C.get('v.products').map(function(a) {
      if (a.Id == id) a.Final_Selection__c = true;
      return a;
    }));
    $H.updateFilters($C);
    $H.saveSelected($C, $E, $H);
  },
  // change from list to detail
  changeMode: function($C, $E, $H) {
    var value = $E.getSource().get('v.name');
    var mode = value.split('::')[0];
    var id = value.split('::')[1];
    console.log('detail', id);
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
  // set selected preview image
  setPreview: function($C, $E, $H) {
    var url = $E.getSource().get('v.name');
    var selected = $C.get('v.selectedProduct');
    selected.Preview_Selection__c = url;
    $C.set('v.selectedProduct', selected);
  },
  // save selected views / finals
  saveSelected: function($C, $E, $H) {
    $H.saveSelected($C, $E, $H);
  },
  // update the filtered list
  updateFilters: function($C, $E, $H) {
    $H.updateFilters($C);
  },
  // reset all filters
  resetFilters: function($C, $E, $H) {
    $C.set('v.filterPrice', 1000000);
    $C.set('v.filterBedroom', 1);
    $C.set('v.filterBirths', 1);
    $C.set('v.filterWidth', 1000);
    $C.set('v.filterHeight', 1000);
    $C.set('v.filterAccessible', false);
    $C.set('v.filterType', 'Any');
    $C.set('v.filterYear', 'Any');
    $C.set('v.filterStatus', 'Any');
    $H.updateFilters($C);
  }
})
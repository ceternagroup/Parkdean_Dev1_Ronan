({
  // set a specific product as selected
  setSelected: function($C, $H, id) {
    $C.set('v.selectedProduct', null);
    $C.set('v.products', $C.get('v.products').map(function(a) {
      if (a.Id == id) {
        a.User_Selection__c = true;
        $C.set('v.selectedProduct', a);
        console.log('SELECTED: ', a);
      } else {
        a.User_Selection__c = false;
      }
      return a;
    }));
    $H.updateFilters($C);
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
  },
  // update filters
  updateFilters: function($C) {
    var products = $C.get('v.products');
    var fPrice = Number($C.get('v.filterPrice'));
    var fBedrooms = Number($C.get('v.filterBedroom'));
    var fBirths = Number($C.get('v.filterBirths'));
    var fWidth = $C.get('v.filterWidth');
    var fHeight = $C.get('v.filterHeight');
    var fAccessible = $C.get('v.filterAccessible');
    var fType = $C.get('v.filterType');
    var fYear = $C.get('v.filterYear');
    var fStatus = $C.get('v.filterStatus');
    var filtered = products.filter(function(a) {
      var aPrice = a.Price__c;
      var aBedrooms = Number(a.Number_of_bedrooms__c) || 1;
      var aBirths = Number(a.Births__c) || 1;
      var aWidth = a.Width__c || 1;
      var aHeight = a.Length__c || 1;
      var aAccessible = a.Accessible_Unit__c || false;
      var aType = a.Unit_Type__c || 'Any';
      var aYear = a.Model_Year__c || 'Any';
      var aStatus = a.Stock_status__c || 'Any';
      if (aPrice > fPrice) {console.log('failed price', a); return false;}
      if (aBedrooms < fBedrooms) {console.log('failed bedrooms', a); return false;}
      if (aBirths < fBirths) {console.log('failed births', a); return false;}
      if (aWidth > fWidth) {console.log('failed width', a); return false;}
      if (aHeight > fHeight) {console.log('failed height', a); return false;}
      if (fAccessible == true && aAccessible != true) {console.log('failed access', a); return false;}
      if (fType != 'Any' && aType != fType) {console.log('failed type', a); return false;}
      if (fYear != 'Any') {
        if (fYear == 'Pre-2008' && aYear >= 2008) {console.log('failed year pre', a); return false;}
        if (fYear == 'Post-2008' && aYear < 2008) {console.log('failed year post', a); return false;}
      }
      if (fStatus != 'Any' && aStatus != fStatus) {console.log('failed status', a); return false;}
      return true;
    }).sort(function(a, b) {
      return a.Price__c - b.Price__c;  
    });
    $C.set('v.filteredProducts', filtered);
  },
  // save
  saveSelected: function($C, $E, $H) {
    $C.set('v.loading', true);
    var quoteId = $C.get('v.quoteId');
    console.log('prods', $C.get('v.products'));
    var products = JSON.parse(JSON.stringify($C.get('v.products'))).filter(function(a) {
      return a.View_Option__c == true || a.Final_Selection__c == true 
    }).map(function(a) {
      a.Product__c = a.Id;
      a.Quote__c = quoteId;
      a.Product_Code__c = a.ProductCode;
      a.View_Product__c = a.View_Option__c;
      a.Final_Selection__c = a.Final_Selection__c;
      // unit price only is the unit price from stock price record
      var check = a.Prices__c.filter(function(p) {
        var pri = p.Discount_Price__c || p.Total_Price__c;
        return pri == a.Price__c;
      });
      a.Unit_Price_only__c = check.length > 0 ? check[0].Unit_Price__c : null;
      a.Pitch_Price__c = check.length > 0 ? check[0].Pitch_Price__c : null;
      a.Ancillary_Price__c = check.length > 0 ? check[0].Mandatory_Ancillary_Price__c : null;
      a.Unit_Price__c = a.Price__c; // total price from stock price record is unit price field
      delete a.Id;
      delete a.Park_Name__c;
      delete a.ProductCode;
      delete a.Prices__c;
      delete a.Previews__c;
      delete a.Preview_Selection__c;
      delete a.Births__c;
      delete a.Stock_status__c;
      delete a.View_Option__c;
      delete a.Mandatory_Ancillary_Price__c;
      return a;
    });
    console.log(products);
    var params = {
      quoteId: quoteId,
      jsonString: JSON.stringify(products)
    };
    $H.runAction($C, 'c.updateSelected', params, function(response) {
      console.log(response);
      if (response.indexOf('Error') != -1) {
        alert(response);   
      } else {
        $C.set('v.toast', 'Your selections have been saved.');
        $C.set('v.loading', false);
        setTimeout(function(a) {
          $C.set('v.toast', '');
        }, 1000);
      }
    });   
  }
})
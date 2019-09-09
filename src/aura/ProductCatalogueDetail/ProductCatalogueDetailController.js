({
// load the items
  loadApp: function($C, $E, $H) {
    var params = {
      parkId: null,
      lineItemId: $C.get('v.recordId')
    };
    console.log('CATALOGUE: ', params);
    $H.runAction($C, 'c.getCatalogue', params, function(response) {
        console.log('CATALOGUE: ', response);
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
          p.Price__c = p.Prices__c[0].Discount_Price__c ? p.Prices__c[0].Discount_Price__c : p.Prices__c[0].Total_Price__c;
          p.Preview_Selection__c = p.Previews__c.length > 0 ? p.Previews__c[0].Image_URL__c : '';
        }
        console.log(products);
        $C.set('v.products', products);
        $C.set('v.selectedProduct', products[0]);
        setTimeout(function() {
          $C.set('v.loading', false);
        }, 1000);
    });
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
})
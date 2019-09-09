public class ProductCatalogue {
    
  @AuraEnabled
  public static Map<String, List<sObject>> getCatalogue(String parkId, String lineItemId) {
    Map<String, List<sObject>> catalogue = new Map<String, List<sObject>>();
    List<Product2> products = new List<Product2>();
    String productId;
    if (parkId != null && lineItemId == null) {
    products = [
      SELECT Id, Name, Park_Name__c,
        Births__c, Stock_status__c, Accessible_Unit__c,
        Account__c, Bath_Tub__c, Bed_Types__c, Colour__c, Cooker__c, 
        Fire__c, Free_standing_furniture__c, Heaters__c, Length__c, 
        Make__c, Manufacturer__c, Master_Ensuite__c, Master_Walkin_Wardrobe__c, 
        Model__c, Model_Year__c, Number_of_bathrooms__c, Number_of_bedrooms__c,
		Park__c, ProductCode, Purchase_purpose__c, Ramtech__c, Ramtech_ID__c,
		Range__c, Seperate_WC__c, Serial_Number__c, Shower_Unit__c, Source__c, 
        Stock_Grade__c, Unit_Type__c, Water_heater__c, Width__c, Holiday_Home_description__c, 
        Bedrooms__c, Central_Heating__c, Central_Heating_Yes_No__c, 
        CSN__c, Days_on_Sale__c, Double_Glazing__c, Double_Glazing_Yes_No__c, Features__c, 
        Fixed_Asset__c, IsNew__c, Letting_Cat_ID__c, Line_Van__c, New_or_Used__c, New_Yes_No__c,
        Pitch_Status_Code__c, Pitch_Status_Description__c, Pitch_Status_Enum__c, Rental_Product__c,
        SIV__c, Stock_Grade_New__c, Stock_Request_ID__c, Suitable_for_retail__c, ThumbnailImage__c,
        Trade_Stock__c, Twin_Unit__c, Van_Type_Enum__c, YearOfManufacture__c,
        Not_available_for_IPS__c, Deposit_Minimum__c, Finance_Allowed__c, Max_Length_of_Term_Allowed__c
      FROM Product2
      WHERE Park__c =: parkId
      AND Suitable_for_retail__c = 'Yes'
    ];
    }
    if (parkId == null && lineItemId != null) {
      productId = [SELECT Product__c FROM Line_Item__c WHERE Id = :lineItemId LIMIT 1].Product__c;
    products = [
      SELECT Id, Name, Park_Name__c,
        Births__c, Stock_status__c, Accessible_Unit__c,
        Account__c, Bath_Tub__c, Bed_Types__c, Colour__c, Cooker__c, 
        Fire__c, Free_standing_furniture__c, Heaters__c, Length__c, 
        Make__c, Manufacturer__c, Master_Ensuite__c, Master_Walkin_Wardrobe__c, 
        Model__c, Model_Year__c, Number_of_bathrooms__c, Number_of_bedrooms__c,
		Park__c, ProductCode, Purchase_purpose__c, Ramtech__c, Ramtech_ID__c,
		Range__c, Seperate_WC__c, Serial_Number__c, Shower_Unit__c, Source__c, 
        Stock_Grade__c, Unit_Type__c, Water_heater__c, Width__c, Holiday_Home_description__c,
        Bedrooms__c, Central_Heating__c, Central_Heating_Yes_No__c, 
        CSN__c, Days_on_Sale__c, Double_Glazing__c, Double_Glazing_Yes_No__c, Features__c, 
        Fixed_Asset__c, IsNew__c, Letting_Cat_ID__c, Line_Van__c, New_or_Used__c, New_Yes_No__c,
        Pitch_Status_Code__c, Pitch_Status_Description__c, Pitch_Status_Enum__c, Rental_Product__c,
        SIV__c, Stock_Grade_New__c, Stock_Request_ID__c, Suitable_for_retail__c, ThumbnailImage__c,
        Trade_Stock__c, Twin_Unit__c, Van_Type_Enum__c, YearOfManufacture__c, Deposit_Minimum__c, Finance_Allowed__c, Max_Length_of_Term_Allowed__c
      FROM Product2
      WHERE Id =: productId
      AND Suitable_for_retail__c = 'Yes'
    ];
    }
    Set<Id> productIds = new Set<Id>();
    for (Integer i = 0; i < products.size(); i++) {
      productIds.add(products[i].Id);
    }
    List<Price__c> prices = getPrices(productIds);
    List<Stock_Image__c> images = getImages(productIds);
    catalogue.put('products', products);
    catalogue.put('prices', prices);
    catalogue.put('images', images);
    return catalogue;
  }
    
  @AuraEnabled 
  public static List<Line_Item__c> getSelected(String quoteId) {
    String recordTypeId = getRecordTypeId();
    List<Line_Item__c> items = new List<Line_Item__c>();
    items = [
      SELECT Product__c, View_Product__c, Final_Selection__c, Unit_Price__c, Unit_Price_Only__c, Order__c
      FROM Line_Item__c
      WHERE Quote__c = :quoteId
      AND RecordTypeId = :recordTypeId
    ];
    if (items == null || items.size() == 0) return new List<Line_Item__c>();
    return items;
  }
    
  @AuraEnabled 
  public static String updateSelected(String quoteId, String jsonString) {
    try {
      String recordTypeId = getRecordTypeId();
      List<Line_Item__c> updates = (List<Line_Item__c>) JSON.deserialize(jsonString, List<Line_Item__c>.class);
      List<Line_Item__c> existing = getSelected(quoteId);
      if (existing.size() > 0) delete existing;
      for (Integer i = 0; i < updates.size(); i++) {
        updates[i].RecordTypeId = recordTypeId;
      }
      insert updates;
      return 'Success';
    } catch(DMLException e) {
      return 'Error: ' + e;        
    }
  }
    
  @AuraEnabled
  public static Quote getQuote(String quoteId) {
    Quote q = new Quote();
    q = [
      SELECT Id, Name, Park__c, Park_Name__c
      FROM Quote
      WHERE Id = :quoteId
      LIMIT 1
    ];
    return q;
  }
    
  @AuraEnabled
  public static Product2 getProduct(String productId) {
    System.debug(productId);
    if (productId == null || productId == '') return null;
    Product2 product = new Product2();
    product = [
      SELECT Name, Park_Name__c, Model_Year__c, Unit_Type__c, Deposit_Minimum__c, Finance_Allowed__c, Max_Length_of_Term_Allowed__c
      FROM Product2
      WHERE Id = :productId
      LIMIT 1
    ];
    return product;
  }
    
  private class ProductItem {
    private Product2 product;
    private List<Price__c> prices;
  }
    
  // returns a map where a key is the product id and the value is the pricebook entry unit price
  private static List<Price__c> getPrices(Set<Id> productIds) {
    List<Price__c> prices = new List<Price__c>();
    prices = [
      SELECT Pitch_Type__c, Pitch_Price__c, Discount_Price__c, Stock__c,
        Mandatory_Ancillary_Price__c, Total_Price__c, Unit_Price__c
      FROM Price__c
      WHERE Stock__c IN :productIds
    ];
    return prices;
  }
    
  // returns a map where a key is a product id and the value are the possible images
  private static List<Stock_Image__c> getImages(Set<Id> productIds) {
    List<Stock_Image__c> stock = new List<Stock_Image__c>();
    stock = [
      SELECT Product__c, Image_URL__c
      FROM Stock_Image__c
      WHERE Product__c IN :productIds
    ];
    return stock;
  }
    
  private static String getRecordTypeId() {
    String recordTypeId = [
      SELECT Id 
      FROM RecordType 
      WHERE SobjectType = 'Line_Item__c' 
      AND DeveloperName = 'Product_Line_Item'
      LIMIT 1
    ].Id;
    return recordTypeId;
  }

}
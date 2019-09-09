public class IPSCalculator {
   
  @AuraEnabled
  public static List<Price_Rule__c> getRules(String quoteId) {
    List<Price_Rule__c> rules = new List<Price_Rule__c>();
    String parkId = getParkId(quoteId);
    Set<String> grades = new Set<String>();
    List<Line_Item__c> products = getProducts(quoteId);
    for (Integer i = 0; i < products.size(); i++) {
      String grade = products[i].Stock_Grade_New__c;
      if (grade != null) grades.add(grade);
    }
/*    rules = [
      SELECT Week_Start__c, Week_Price__c, Weekend_Price__c,
        Stock_Grade_New__c, Park__c, Peak_season__c, Peak_summer__c, Do_not_Allow__c
      FROM Price_Rule__c
      WHERE Park__c = :parkId
      AND Stock_Grade_New__c IN :grades
    ];*/
     List<Price_Rule__c> prList = [SELECT Week_Start__c, 
                             		Week_Price__c, 
                             		Weekend_Price__c,
        							Stock_Grade_New__c, 
                             		Park__c, 
                             		Peak_season__c, 
                             		Peak_summer__c, 
                             		Do_not_Allow__c
      						FROM Price_Rule__c
      						WHERE Park__c = :parkId
      						AND Stock_Grade_New__c IN :grades];
      
    Date latestDate = System.today();  
      
      for (Price_Rule__c pr : prList) {
          if (pr.Week_Start__c >= System.today()) {
              rules.add(pr); 
          }
          if (pr.Week_start__c > latestDate) {
              latestDate = pr.Week_Start__c;
          }                       
      }
      if (latestDate.addYears(-1) < system.today()) {
          for (Price_Rule__c pr : prList) {
              if (pr.Week_Start__c >= latestDate.addYears(-1) 
                 && pr.Week_Start__c < System.today()
                 ) {
                  rules.add(pr); 
              }                      
          }          
      }
    return rules;
  }
    
  @AuraEnabled
  public static List<Park_Feature__c> getFeatures(String quoteId) {
    List<Park_Feature__c> features = new List<Park_Feature__c>();
    String parkId = getParkId(quoteId);
    features = [
      SELECT Park__c, Date__c, Not_Allowed__c
      FROM Park_Feature__c
      WHERE Park__c = :parkId
    ];
    return features;
  }
    
  @AuraEnabled
  public static List<Line_Item__c> getProducts(String quoteId) {
    List<Line_Item__c> products = new List<Line_Item__c>();
    String recordType = getRecordTypeId();
    products = [
      SELECT Product__c, Product__r.Name, Stock_Grade_New__c, Final_Selection__c, IPS_to_Rent__c,
        IPS_on_deposit__c, Not_available_for_IPS__c
      FROM Line_Item__c
      WHERE RecordTypeId = :recordType
      AND Not_available_for_IPS__c = false
      AND Quote__c = :quoteId
    ];
    return products;
  }
    
  @AuraEnabled
  public static Quote getQuote(String quoteId) { 
    Quote quote = [
      SELECT Id, Name, Park__c, Park_Name__c
      FROM Quote 
      WHERE Id = :quoteId
      LIMIT 1
    ];
    return quote;
  }
    
  @AuraEnabled
  public static List<IPS_Line_Item__c> getItems(String quoteId) {
    List<IPS_Line_Item__c> items = new List<IPS_Line_Item__c>();
    items = [
      SELECT Id, 
        (
         SELECT Match__c 
         FROM IPS_Days__r
         WHERE Selected__c = true
        )
      FROM IPS_Line_Item__c
      WHERE Quote__c = :quoteId
    ];
    return items;
  }
    
  @AuraEnabled
  public static String saveIPSItems(String items, String days, String quoteId, List<Line_Item__c> products) {
    //List<IPS_Line_Item__c> existing = getItems(quoteId);
    //delete existing;
    try {
      List<IPS_Line_Item__c> lines = (List<IPS_Line_Item__c>) JSON.deserialize(items, List<IPS_Line_Item__c>.class);
      insert lines;
      List<IPS_Day__c> linedays = (List<IPS_Day__c>) JSON.deserialize(days, List<IPS_Day__c>.class);
      for (Integer i = 0; i < linedays.size(); i++) {
        for (Integer l = 0; l < lines.size(); l++) {
          if (lines[l].Product__c == linedays[i].Product__c) {
            linedays[i].IPS_Line_Item__c = lines[l].Id;
          } 
        }    
      }
      insert linedays;
      update products;
      return 'Success';
    } catch(Exception e) {
      return 'Error: ' + e;
    }
  }
    
  private static String getParkId(String quoteId) {
    if (quoteId == null) return null;
    Quote quote = [
      SELECT Park__c 
      FROM Quote 
      WHERE Id = :quoteId
      LIMIT 1
    ];
    return quote.Park__c;
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
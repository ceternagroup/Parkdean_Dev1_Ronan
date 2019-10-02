/**********************************************************************************************
* @Author: Ceterna
* @Date:
* @Description: Helper class to store the various methods we run from the LeadTriggerHandler.
*	If it affects the Leads in a trigger, the logic will be here.
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]
***********************************************************************************************/
public class IPSCalculator {

  /**********************************************************************************************
  * @Author: Ceterna
  * @Date: 22/07/2019
  * @Description: sets the Park_IDs__c field based on the park names given in the
  * 	Park_Codes__c multiselect picklist. Called in both beforeInsert and beforeUpdate
  * @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]
  *               7.08.2019 - B0119 - Ronan Williams - update to ensure the correct Id field (Park_ID__c) is retrieved from
  *               parks and allocated to lead records
  ***********************************************************************************************/
  @AuraEnabled
  public static List<Price_Rule__c> getRules(String quoteId) {
    List<Price_Rule__c> rules = new List<Price_Rule__c>();

    if (Label.Current_IPS_Year != null && Label.Current_IPS_Year.length() == 4 && Label.Current_IPS_Year.isNumeric()) {

      Integer year = Integer.valueOf(Label.Current_IPS_Year);

      String parkId = getParkId(quoteId);
      Set<String> grades = new Set<String>();

      for (Line_item__c item : getProducts(quoteId)){
        if (item.Stock_Grade_New__c != null){
          grades.add(item.Stock_Grade_New__c);
        }
      }

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
                                    AND CALENDAR_YEAR(Week_Start__c) = : year
                                    AND Stock_Grade_New__c IN :grades];


      rules.addAll(prList);
    }
      return rules;
  }
    
  @AuraEnabled
  public static List<Park_Feature__c> getFeatures(String quoteId) {

    return [SELECT Park__c, Date__c, Not_Allowed__c
            FROM Park_Feature__c
            WHERE Park__c = :getParkId(quoteId)];
  }
    
  @AuraEnabled
  public static List<Line_item__c> getProducts(String quoteId) {

    return [SELECT Product__c, Product__r.Name, Stock_Grade_New__c, Final_Selection__c, IPS_to_Rent__c,
                IPS_on_deposit__c, Not_available_for_IPS__c
            FROM Line_item__c
            WHERE RecordTypeId = :getRecordTypeId()
            AND Not_available_for_IPS__c = FALSE
            AND Quote__c = :quoteId];
  }
    
  @AuraEnabled
  public static Quote getQuote(String quoteId) { 

    return [SELECT Id, Name, Park__c, Park_Name__c
            FROM Quote
            WHERE Id = :quoteId LIMIT 1];
  }
    
  @AuraEnabled
  public static List<IPS_Line_Item__c> getItems(String quoteId) {

    system.debug([SELECT Id,
    (SELECT Match__c
    FROM IPS_Days__r
    WHERE Selected__c = TRUE)
    FROM IPS_Line_Item__c
    WHERE Quote__c = :quoteId]);


    return [SELECT Id,
                (SELECT Match__c
                FROM IPS_Days__r
                WHERE Selected__c = TRUE)
            FROM IPS_Line_Item__c
            WHERE Quote__c = :quoteId
            ORDER BY CreatedDate DESC LIMIT 1];
  }
    
  @AuraEnabled
  public static String saveIPSItems(String items, String days, String quoteId, List<Line_item__c> products) {
//    List<IPS_Line_Item__c> existing = getItems(quoteId);
//    delete existing;

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
    Quote quote = [SELECT Park__c
                  FROM Quote
                  WHERE Id = :quoteId
                  LIMIT 1];
    return quote.Park__c;
  }
    
  private static String getRecordTypeId() {
    String recordTypeId = [SELECT Id
                          FROM RecordType
                          WHERE SobjectType = 'Line_Item__c'
                          AND DeveloperName = 'Product_Line_Item'
                          LIMIT 1].Id;
    return recordTypeId;
  }

}
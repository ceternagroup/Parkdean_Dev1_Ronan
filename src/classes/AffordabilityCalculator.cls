public without sharing class AffordabilityCalculator {
    
  @AuraEnabled
  public static Map<String, sObject> getPrice(Id recordId) {
    Schema.SObjectType sObjectType = recordId.getSObjectType();
    String sObjectName = sObjectType.getDescribe().getName();
    System.debug(sObjectName);
    String quoteId = '';
    String lineItemId = '';
    sObject form = null;
    Quote q = new Quote();
    if (sObjectName == 'Quote') {
      quoteId = recordId;
    }
    if (sObjectName == 'Line_Item__c') {
      lineItemId = recordId;
      Line_Item__c l = [
        SELECT Quote__c 
        FROM Line_Item__c 
        WHERE Id = :lineItemId
        LIMIT 1
      ];
      quoteId = l.Quote__c;
    }
    if (sObjectName == 'Form__c') {
      Form__c f = [
        SELECT Sales_Example__c
        FROM Form__c
        WHERE Id = :recordId
        LIMIT 1
      ];
      form = f;
      quoteId = f.Sales_Example__c;
    }
    if (quoteId != null) {
      q = [
        SELECT Id, Total_Package_Price__c, PX_Value__c, 
          Finance_settlement__c, Inbound_PX_Price__c, 
          Cost_to_Change__c, IPS_to_rent2__c, IPS_to_sale2__c,
          Number_of_final_products__c, number_of_final_pitches__c,
          Finance_Allowed__c, Max_Length_of_Term_Allowed__c, Deposit_Minimum__c, Record_type_formula__c
        FROM Quote
        WHERE Id = :quoteId
        LIMIT 1
      ];
    }
    Line_Item__c lineItem = new Line_Item__c();
    if (sObjectName == 'Line_Item__c') {
      lineItem = [
        SELECT Id, Unit_Price__c, Quote__c, Product__c, Product__r.Finance_Allowed__c,
          Product__r.Max_Length_of_Term_Allowed__c, Product__r.Deposit_Minimum__c
        FROM Line_Item__c 
        WHERE Id = :lineItemId
        LIMIT 1
      ];
    }
    Map<String, sObject> records = new Map<String, sObject>();
    records.put('Quote', q);
    records.put('Line_Item__c', lineItem);
    records.put('Form', form);
    return records;
  }
    
  @AuraEnabled
  public static String saveCalculation(Calculator__c result) {
    String quoteId = (String) result.get('Quote__c');
    String recordId = (String) result.get('Customer_Requirements_Form__c');
    if (quoteId != null && quoteId.indexOf('0Q0') == 0) {
      Quote quote = [
        SELECT OpportunityId
        FROM Quote
        WHERE Id = :quoteId
        LIMIT 1
      ];
      result.Opportunity__c = quote.OpportunityId;
    }
    try {
      insert result;
      return 'Success';
    } catch(DMLException e) {
      return 'Error: ' + e;
    }
  }

}
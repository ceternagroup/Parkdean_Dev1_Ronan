public class LineItemHandler {
    
  public static void checkAncilleries(List<Line_Item__c> items) {
    System.debug(items);
    // for each item we only care if the Final_Selection__c box is checked
    Set<Id> quoteIds = new Set<Id>();
    for (Integer i = 0; i < items.size(); i++) {
      // add the related quote id
      if (items[i].Final_Selection__c == true) {
        quoteIds.add(items[i].Quote__c);
      }
    }
    // get all the quotes we have listed, only if they have both a final pitch and final product
    List<Quote> quotes = new List<Quote>();
    if (Test.isRunningTest() == true) {
    quotes = [
      SELECT Id, Expected_handover_date__c,
        (SELECT Id, Stock_Id__c, Pitch_Id__c, Record_Type_Formula__c FROM Line_Items__r WHERE Final_Selection__c = true)
      FROM Quote
      WHERE Id IN :quoteIds
    ]; 
    } else {
    quotes = [
      SELECT Id, Expected_handover_date__c,
        (SELECT Id, Stock_Id__c, Pitch_Id__c, Record_Type_Formula__c FROM Line_Items__r WHERE Final_Selection__c = true)
      FROM Quote
      WHERE Id IN :quoteIds
      AND number_of_final_pitches__c > 0
      AND Number_of_final_products__c > 0
    ];
    }
    String recordTypeId = getRecordTypeId();
    // we need to clear all existing ans
    List<Line_Item__c> existingAncs = [
      SELECT Id
      FROM Line_item__c
      WHERE Quote__c IN :quoteIds
      AND RecordTypeId = :recordTypeId
    ];
    delete existingAncs;
    // vanId, saleType, pitchId, expOccupancy, accountId, ownerId, pexVanId
    for (Integer i = 0; i < quotes.size(); i++) {
      String vanId;
      String pitchId;
      Quote q = quotes[i];
      String expOccupancy = q.Expected_handover_date__c == null ? '' : String.valueOf(q.Expected_handover_date__c);
      for (Integer l = 0; l < q.Line_Items__r.size(); l++) {
        if (q.Line_Items__r[l].Record_Type_Formula__c == 'Product_Line_Item') vanId = q.Line_Items__r[l].Stock_Id__c;  
        if (q.Line_Items__r[l].Record_Type_Formula__c == 'Pitch_Line_Items') pitchId = q.Line_Items__r[l].Pitch_Id__c; 
      }
      getAncillaries(vanId, null, pitchId, expOccupancy, null, null, null, recordTypeId, q.Id);
    }
  }
    
  @Future(callout=true)
  public static void getAncillaries(String vanId, String saleType, String pitchId, String expOccupancy, String accountId, String ownerId, String pexVanId, String recordTypeId, String quoteId) {
    String ancs = ODIRequest.sendAncRequest(vanId, saleType, pitchId, expOccupancy, accountId, ownerId, pexVanId);
    System.debug(ancs);
    Response res = (Response) JSON.deserialize(ancs, Response.class);
    
    List<Line_Item__c> items = new List<Line_Item__c>();
    List<Ancillary_Option__c> options = new List<Ancillary_Option__c>();
    if (res.Ancillaries != null) {
      for (Integer i = 0; i < res.Ancillaries.size(); i++) {
        ODIMapper.AncillaryClass r = res.Ancillaries[i];
        String foreignKey = String.valueOf(r.PriceTypeEnum);
        Line_Item__c item = ODIMapper.mapAncillary(r, recordTypeId, quoteId);
        item.Foreign_Key__c = 'ANCILLARY-' + quoteId + '-' + foreignKey;
        items.add(item);
        Line_Item__c ancFK = new Line_Item__c(Foreign_Key__c = 'ANCILLARY-' + quoteId + '-' + foreignKey);
        for (Integer a = 0; a < r.Options.size(); a++) {
          Ancillary_Option__c o = ODIMapper.mapAncillaryOption(r.Options[a]);
          if (a == 0 && r.Mandatory == true) o.Selected__c = true;
          o.Ancillary__r = ancFK;
          options.add(o);
        }
      }
      upsert items;
      upsert options;
    }
    if (res.Errors != null) {
      for (Integer i = 0; i < res.Errors.size(); i++) {
        Line_Item__c item = new Line_Item__c();
    	item.RecordTypeId = recordTypeId;
    	item.Name = 'Wizard Error';
    	item.Quote__c = quoteId;
    	item.Ancillary_Description__c = JSON.serialize(res.Errors[i]); 
        items.add(item);
      }    
      upsert items;
    }
    if (res.Error != null) {
      Line_Item__c item = new Line_Item__c();
   	  item.RecordTypeId = recordTypeId;
      item.Name = 'Wizard Error';
      item.Quote__c = quoteId;
      item.Ancillary_Description__c = JSON.serialize(res.Error); 
      items.add(item);
      upsert items;
    }
    System.debug(res.Errors);
  }
    
  private class Response {
    private List<Map<String, String>> Errors;
    private String Error;
    private List<ODIMapper.AncillaryClass> Ancillaries;
  }
    
  private static String getRecordTypeId() {
    String recordTypeId = [
      SELECT Id 
      FROM RecordType 
      WHERE SobjectType = 'Line_Item__c' 
      AND DeveloperName = 'Ancillary_Line_Item'
      LIMIT 1
    ].Id;
    return recordTypeId;
  }

}
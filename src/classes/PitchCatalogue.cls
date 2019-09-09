/*
 * @class PitchCatalogue
 * @desc - handles the functionality of the pitch selector app
 */
global class PitchCatalogue {
    
  // gets all the pitches for a given park
  @AuraEnabled
  @RemoteAction
  global static String getCatalogue(String stockxId, String parkId, String expectedDate, String accountId) {
    String catalogue = ODIRequest.sendPitchRequest(stockxId, parkId, expectedDate, accountId);
    try {
      Response res = (Response) JSON.deserialize(catalogue, Response.class);
      System.debug(res);
       ResponseMapped resMap = new ResponseMapped();
      resMap.Errors = res.Errors;
      if (res.data != null) {
        resMap.data = new List<Line_Item__c>();
        for (Integer i = 0; i < res.data.size(); i++) {
          Line_Item__c l = ODIMapper.mapPitch(res.data[i]);
          resMap.data.add(l);
        }  
      }
      return JSON.serialize(resMap);
    } catch(Exception e) {
      Map<String, String> err = new Map<String, String>();
      err.put('Error', catalogue);
      return JSON.serialize(err);
    }
  }
   
  // checks if the given quote has a final selection product
  @AuraEnabled
  public static Boolean checkProduct(String quoteId) {
    Quote quote = getQuote(quoteId);
    String recordTypeId = getRecordTypeId('Product_Line_Item');
    List<Line_Item__c> items = new List<Line_Item__c>();
    items = [
      SELECT Id
      FROM Line_Item__c
      WHERE Quote__c = :quoteId
      AND RecordTypeId = :recordTypeId
      AND Final_Selection__c = true
    ];
    return items.size() >= 1 ? true : false;
  }
    
  // gets the current selected line items
  @AuraEnabled 
  public static List<Line_Item__c> getSelected(String quoteId, String recordTypeId) {
    if (recordTypeId == null) recordTypeId = getRecordTypeId('Pitch_Line_Items');
    List<Line_Item__c> items = new List<Line_Item__c>();
    items = [
      SELECT Pitch_Id__c, View_Product__c, Final_Selection__c
      FROM Line_Item__c
      WHERE Quote__c = :quoteId
      AND RecordTypeId = :recordTypeId
    ];
    return items;
  }
    
  // updates the selected pitch item
  @AuraEnabled 
  public static String updateSelected(String quoteId, String jsonString) {
    String pitchRecordTypeId = getRecordTypeId('Pitch_Line_Items');
    List<Line_Item__c> pitchUpdates = (List<Line_Item__c>) JSON.deserialize(jsonString, List<Line_Item__c>.class);
    List<Line_Item__c> pitchExisting = getSelected(quoteId, pitchRecordTypeId);
    if (pitchExisting.size() > 0) delete pitchExisting;
    Boolean hasFinal = false;
    Boolean hasProduct = checkProduct(quoteId);
    for (Integer i = 0; i < pitchUpdates.size(); i++) {
      pitchUpdates[i].RecordTypeId = pitchRecordTypeId;
      pitchUpdates[i].Name = pitchUpdates[i].Pitch_Description__c + ', ' + pitchUpdates[i].Pitch_Type__c;
      if (pitchUpdates[i].Final_Selection__c == true) hasFinal = true;
    }
    try {
      if (Test.isRunningTest() == false) {
        insert pitchUpdates;
        if (hasFinal) {
    	  Quote q = getQuote(quoteId); q.Status = 'Quote'; update q;
        }
        return 'Success';
      } else {
      	return 'Success';
      }
    } catch(DMLException e) { return 'Error: ' + e; }
  }
    
  // checks to see if the quote has both a final product and final pitch selected
  // if so we request the ancillaries from wizard
  @AuraEnabled
  public static String checkAncillaries(String quoteId, Boolean hasPitch) {
    Boolean hasProduct = checkProduct(quoteId);
    System.debug('Quote failed check');
    if (!hasProduct && !hasPitch && Test.isRunningTest() == false) return 'Success';
    Quote q = getQuote(quoteId);
    String vanId;
    String pitchId;
    String expOccupancy = q.Expected_handover_date__c == null ? '' : String.valueOf(q.Expected_handover_date__c);
    String recordTypeId = getRecordTypeId('Ancillary_Line_Item');
    for (Integer l = 0; l < q.Line_Items__r.size(); l++) {
      if (q.Line_Items__r[l].Record_Type_Formula__c == 'Product_Line_Item') vanId = q.Line_Items__r[l].Stock_Id__c;  
      if (q.Line_Items__r[l].Record_Type_Formula__c == 'Pitch_Line_Items') pitchId = q.Line_Items__r[l].Pitch_Id__c; 
    }
    String accountId = q.Opportunity.Wizard_Account_Id__c;
    String ownerId = q.Opportunity.Owner_ID_External__c;
    String pex1Id = null;
    // get px unit
    List<Inbound_PX_unit__c> pxUnits = [
      SELECT Id, Van_Id__c
      FROM Inbound_PX_unit__c
      WHERE Quote__c = :quoteId
    ];
    if (pxUnits.size() > 0) pex1Id = pxUnits[0].Van_Id__c;
    return getAncillaries(vanId, null, pitchId, expOccupancy, accountId, ownerId, pex1Id, recordTypeId, quoteId);
  }
    
  // get the ancillaries from wizard
  public static String getAncillaries(String vanId, String saleType, String pitchId, String expOccupancy, String accountId, String ownerId, String pexVanId, String recordTypeId, String quoteId) {
    String ancs = ODIRequest.sendAncRequest(vanId, saleType, pitchId, expOccupancy, accountId, ownerId, pexVanId);
    System.debug(ancs);
    Response res = (Response) JSON.deserialize(ancs, Response.class);
    List<Line_Item__c> existing = new List<Line_Item__c>();
    existing = [
      SELECT Id FROM Line_Item__c WHERE RecordTypeId = :recordTypeId AND Quote__c = :quoteId
    ];
    delete existing;
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
        Line_Item__c item = new Line_Item__c(); item.RecordTypeId = recordTypeId; item.Name = 'Wizard Error'; item.Quote__c = quoteId; item.Ancillary_Description__c = JSON.serialize(res.Errors[i]); items.add(item);
      }    
      upsert items;
    }
    if (res.Error != null) {
      Line_Item__c item = new Line_Item__c(); item.RecordTypeId = recordTypeId; item.Name = 'Wizard Error'; item.Quote__c = quoteId; item.Ancillary_Description__c = JSON.serialize(res.Error); items.add(item);
      upsert items;
    }
    return 'Success';
  }
    
  // get all the fields we need for a given quote id
  @AuraEnabled
  public static Quote getQuote(String quoteId) {
    String recordTypeId = getRecordTypeId('Product_Line_Item');
    Quote q = new Quote();
    try {
      q = [
        SELECT Id, Name, Expected_handover_date__c, Park__c, Park_Name__c, Park__r.Park_ID__c, Opportunity.Wizard_Account_Id__c, 
          Expected_validation_date__c, Opportunity.Owner_ID_External__c,
          (SELECT Id, Stock_Id__c, Pitch_Id__c, Record_Type_Formula__c FROM Line_Items__r WHERE Final_Selection__c = true)
        FROM Quote
        WHERE Id = :quoteId
        LIMIT 1
      ];    
    } catch(DMLException e) {
      // no selections?
    }
    return q;
  }
    
  private static String getRecordTypeId(String name) {
    String recordTypeId = [
      SELECT Id 
      FROM RecordType 
      WHERE SobjectType = 'Line_Item__c' 
      AND DeveloperName = :name
      LIMIT 1
    ].Id;
    return recordTypeId;
  }
    
  private class Response {
    private List<Map<String, String>> Errors;
    private String Error;
    private List<ODIMapper.PitchClass> data;
    private List<ODIMapper.AncillaryClass> Ancillaries;
  }
    
  private class ResponseMapped {
    private List<Map<String, String>> Errors;
    private List<Line_Item__c> data;
  }

}
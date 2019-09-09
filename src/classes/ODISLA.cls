public class ODISLA {
    
  @RemoteAction
  public static String sendSLA(String quoteId) {
    // get selected van and pitch
    String vanId;
    String pitchId;
    List<Line_Item__c> ancItems = new List<Line_Item__c>();
    List<Line_Item__c> selectedItems = [
      SELECT Stock_Id__c, Pitch_Id__c, Record_Type_Formula__c, 
        Ancillary_Option_Price__c, Price_Type__c, Final_Selection__c,
        (SELECT Price_Default_Id__c 
         FROM Ancillary_Options__r 
         WHERE Selected__c = true 
         LIMIT 1)
      FROM Line_Item__c
      WHERE Quote__c = :quoteId
      AND (Final_Selection__c = true OR Record_Type_Formula__c = 'Ancillary_Line_Item')
    ];
    for (Integer i = 0; i < selectedItems.size(); i++) {
      String recordType = selectedItems[i].Record_Type_Formula__c;
      Boolean selected = selectedItems[i].Final_Selection__c;
      if (recordType == 'Product_Line_Item') vanId = selectedItems[i].Stock_Id__c;
      if (recordType == 'Pitch_Line_Items') pitchId = selectedItems[i].Pitch_Id__c;
      if (recordType == 'Ancillary_Line_Item') ancItems.add(selectedItems[i]);
    }
    // get quote
    Quote q = new Quote();
    q = [
      SELECT IPS_to_sale2__c, IPS_to_rent2__c, Initial_deposit_taken__c, Deposit_due_date__c,
		Expected_handover_date__c, Expected_validation_date__c, Sublet_amount__c, Finance_Amount__c,
		Finance_Agreement_Number__c, Park__r.Park_ID__c, AccountId, Opportunity.Foreign_Key__c,
        Wizard_User_Id__c, Total_deposit_required__c, Finance_Lender_Selected__c, Cash_due_date__c,
        Monthly_Payment__c, OpportunityId, Opportunity.Wizard_Account_Id__c, Opportunity.Owner_ID_External__c, 
        Finance_Company_ID__c, Payment_Method_Code__c, Balance_to_Finance__c, APR__c, Admin_Fee__c, Finance_settlement__c, 
        Term__c, Cash_deposit_paid__c, 	Invoice_Date__c, PEX_1_Create_New_Unit_YN__c, Discount__c, Trade_Sale_Amount__c, CSV_Number__c
      FROM Quote
      WHERE Id = :quoteId
      LIMIT 1
    ];
    // get contact
    Account personAccount = new Account();
    if (q.AccountId != null) personAccount = [SELECT Id, Name, tradeAccount__c, Foreign_Key__c, PersonContactId FROM Account WHERE Id = :q.AccountId LIMIT 1];
    // get px units
    List<Inbound_PX_unit__c> pxUnits = [
      SELECT Id, Name, Van_Id__c, Stand_In_Value__c, Write_Down__c, Settlement__c,
        GGOModelID__c, GGModelID__c, GGQualifyModelID__c, Make__c, Year__c
      FROM Inbound_PX_unit__c
      WHERE Quote__c = :quoteId
    ];
    // map ancillaries
    List<ODIMapper.AncillaryAltClass> ancillaries = new List<ODIMapper.AncillaryAltClass>();
    for (Integer i = 0; i < ancItems.size(); i++) {
      ODIMapper.AncillaryAltClass a = new ODIMapper.AncillaryAltClass();
      a.Price = String.valueOf(ancItems[i].Ancillary_Option_Price__c);
      a.PriceDefaultId = ancItems[i].Ancillary_Options__r.size() > 0 ? String.valueOf(ancItems[i].Ancillary_Options__r[0].Price_Default_Id__c) : null;
      a.PriceTypeEnum = String.valueOf(ancItems[i].Price_Type__c);
      if (a.Price != '0.00' && a.Price != '0' && a.Price != '0.0'&& a.Price != '' && a.Price != null) ancillaries.add(a);
    }
    // create sla
    Map<String, Object> sla = ODIMapper.mapSLA(q, vanId, pitchId, pxUnits, personAccount, ancillaries);
    System.debug(JSON.serialize(sla));
    try {
      String r = ODIRequest.sendSLARequest(sla);
      System.debug(r);
      Response res = (Response) JSON.deserialize(r, Response.class);
      System.debug(res);
      if (res.Error != null && res.Error != '') return 'WIZARD_ERROR: ' + res.Error;
      if (res.Errors != null && res.Errors.size() > 0) return 'WIZARD_ERROR: ' + JSON.serialize(res.Errors);
      if (res.NewSaleId == null) return 'No Sale Id returned, but also no errors?';
      // update the quote
      q.SLA__c = res.NewSlaNo;
      q.Status = 'SLA pending with Wizard';
      q.Foreign_Key__c = String.valueOf(res.NewSaleId);
      Opportunity o = [
        SELECT Id, Foreign_Key__c
        FROM Opportunity
        WHERE Id = :q.OpportunityId
        LIMIT 1
      ];
      o.Foreign_Key__c = o.Id;
      update q;  
      update o;
      if (Test.isRunningTest()) return 'Success';
      return 'Success: ' + JSON.serialize(sla); 
    } catch(DMLException e) {
      q.Status = 'SLA Rejected';
      update q;  
      return 'Error: ' + e;
    }
  }
    
  private class Response {
    private List<Map<String, String>> Errors;
    private String Error;
    private Integer NewSaleId;
    private String NewSlaNo;
    private Integer NewAccountId;
  }
    
  

}
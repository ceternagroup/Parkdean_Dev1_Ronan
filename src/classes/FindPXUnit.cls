public class FindPXUnit {
    
  @AuraEnabled
  public static List<Inbound_PX_unit__c> getUnits(String modelYear, String modelMake) {
    String catalogue = ODIRequest.sendPXRequest(modelYear, modelMake);
    System.debug(catalogue);
    Response res = (Response) JSON.deserialize(catalogue, Response.class);
    List<Inbound_PX_unit__c> units = new List<Inbound_PX_unit__c>();
    for (Integer i = 0; i < res.data.size(); i++) {
      units.add(ODIMapper.mapPX(res.data[i]));
    }
    return units;
  }
    
  @AuraEnabled
  public static String saveUnits(String quoteId, Inbound_PX_unit__c unit) {
    unit.Quote__c = quoteId;
    Quote q = [SELECT Id, OpportunityId FROM Quote WHERE Id =: quoteId LIMIT 1];
    unit.Opportunity__c = q.OpportunityId;
    try {
      insert unit;
      return 'Success';
    } catch(DMLException e) {
      return 'Error: ' + e;
    }
  }
    
  private class Response {
    private List<String> Errors;
    private List<ODIMapper.PXUnitClass> data;
  }

}
@RestResource(urlMapping='/ODI/v1/convert')
global class ODIConvert {

  @HttpPost
  global static String doPost() {
    RestRequest req = RestContext.request;
    List<String> leadIds = (List<String>) JSON.deserialize(req.requestBody.toString(), List<String>.class);
    LeadStatus convertStatus = [
      SELECT Id, MasterLabel, ApiName
      FROM LeadStatus 
      WHERE IsConverted=true LIMIT 1
    ];
    List<Map<String, String>> converted = convertLeads(leadIds, convertStatus);
    return JSON.serialize(converted);
  }
    
  public static List<Map<String, String>> convertLeads(List<String> leadIds, LeadStatus convertStatus) {
    List<Database.LeadConvert> leads = new List<Database.LeadConvert>();
    for (Integer l = 0; l < leadIds.size(); l++) {
      Database.LeadConvert lc = new Database.LeadConvert();
      lc.setLeadId(leadIds[l]);
      lc.setConvertedStatus(convertStatus.ApiName);
      lc.setDoNotCreateOpportunity(true);
      leads.add(lc);
    }
    List<Map<String, String>> results = new List<Map<String, String>>();
    try {
      List<Database.LeadConvertResult> converts = Database.convertLead(leads);
      for (Integer l = 0; l < converts.size(); l++) {
        Map<String, String> result = new Map<String, String>();
        result.put('LeadId', converts[l].getLeadId()); result.put('ContactId', converts[l].getAccountId());
        result.put('Error', converts[l].getErrors() != null && converts[l].getErrors().size() > 0 ? converts[l].getErrors()[0].getMessage() : null);
        results.add(result);
      }
    } catch(DmlException err) {
      Map<String, String> result = new Map<String, String>();
      result.put('Error', err.getMessage());
      results.add(result);
    }
    return results;
  }
    
}
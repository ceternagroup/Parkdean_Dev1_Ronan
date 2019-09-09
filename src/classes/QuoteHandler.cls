public class QuoteHandler {
    
  public static void linkOrphans(List<Quote> quotes) {
    Map<String, String> oppMap = new Map<String, String>();
    Set<String> oppIds = new Set<String>();
    // get opp links
    for (Integer i = 0; i < quotes.size(); i++) {
      oppIds.add(quotes[i].OpportunityId);
    }
    // get related opps
    List<Opportunity> opps = new List<Opportunity>();
    opps = [
      SELECT Id, Foreign_Key__c
      FROM Opportunity
      WHERE Id IN :oppIds
    ];
    // update the foreign key
    List<Opportunity> updateOpps = new List<Opportunity>();
    for (Integer i = 0; i < opps.size(); i++) {
      String oppId = opps[i].Id;
      if (opps[i].Foreign_Key__c != oppId) {
        opps[i].Foreign_Key__c = oppId;
        updateOpps.add(opps[i]);
      }
    }
    // update the opps
    update updateOpps;
  }

}
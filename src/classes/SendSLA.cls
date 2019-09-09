public class SendSLA {
    
  @AuraEnabled
  public static String checkQuote(String quoteId) {
    Quote quote = getQuote(quoteId);
    String res = 'Ready';
    if (quote.Status == 'SLA pending with Wizard') res = 'This Quote has already been sent to Wizard.';
    if (quote.Expected_handover_date__c == null) res = 'You must set an expected handover date';
    if (quote.Record_type_formula__c != 'Private_Sale' && quote.Record_type_formula__c != 'Trade_Sale') {
      if (quote.Number_of_final_products__c == 0 || quote.Number_of_pitches_selected__c == 0) res = 'You must set a final product and final pitch.';
    }
    return res; 
  }
    
  @AuraEnabled
  public static String sendQuote(String quoteId) {
    return ODISLA.sendSLA(quoteId);
  }
    
  private static Quote getQuote(String quoteId) {
    Quote quote = [
      SELECT Id, Status, Expected_handover_date__c, Number_of_final_products__c, Number_of_pitches_selected__c, Record_type_formula__c
      FROM Quote
      WHERE Id = :quoteId
      LIMIT 1
    ];
    return quote;
  }

}
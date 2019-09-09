public class PrivateSeller {
    
  @AuraEnabled
  public static String sendPrivateSeller(String oppId) {
    Opportunity o = [
      SELECT Id, Wizard_Account_Id__c
      FROM Opportunity
      WHERE Id =: oppId
      LIMIT 1
    ];
    if (o.Wizard_Account_Id__c == null) return 'Error: You do not have a Wizard Account Id for this Presentation.';
    return ODIRequest.sendPrivateSeller(o.Wizard_Account_Id__c);
  }

}
public class StockItemFinal {
    
  @AuraEnabled
  public static String updateItem(String recordId) {
    Line_Item__c li = [
      SELECT Final_Selection__c
      FROM Line_Item__c
      WHERE Id = :recordId
      LIMIT 1
    ];
    li.Final_Selection__c = true;
    try {
      update li;
      return 'Success';
    } catch(DMLException e) { return 'Error: ' + e; }
  }

}
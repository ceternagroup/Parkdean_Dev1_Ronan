global class ODICleaner implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {
    
  private final List<sObject> records;
    
  global ODICleaner(List<sObject> extras) {
    records = extras == null ? new List<sObject>() : extras;
  }
    
  global List<sObject> start(Database.BatchableContext bc) {
    List<sObject> doomedRecords = new List<sObject>();
    List<sObject> orphanImages = [SELECT Id FROM Stock_Image__c WHERE Product__c = null];
    List<sObject> orphanPrices = [SELECT Id FROM Price__c WHERE Stock__c = null];
    doomedRecords.addAll(orphanImages);
    doomedRecords.addAll(orphanPrices);
    doomedRecords.addAll(records);
    return doomedRecords;
  }
    
  global void execute(Database.BatchableContext bc, List<sObject> scope) {
    Database.delete(scope, false);
  }
    
  global void finish(Database.BatchableContext bc) {}
    
  public static String runCleaner(String query) {
    List<sObject> records = Database.query(query);
    return Database.executeBatch(new ODICleaner(records), 2000);
  }
  
}
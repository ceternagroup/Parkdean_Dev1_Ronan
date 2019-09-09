public without sharing class TaskHandler {
    
  public static void setOwner(List<Task> tasks) {
    String recordTypeId1 = getRecordTypeId('Enquiry', 'Task');
    String recordTypeId2 = getRecordTypeId('New_Enquiries_Exisitng_Leads', 'Task');
    List<Task> enquiries = new List<Task>();
    for (Integer t = 0; t < tasks.size(); t++) {
      String recordType = tasks[t].RecordTypeId;
      if (recordType == recordTypeId1 || recordType == recordTypeId2) enquiries.add(tasks[t]); 
    }
    Map<String, String> ownerMap = new Map<String, String>();
    List<sObject> leads = new List<sObject>();
    Set<Id> leadIds = new Set<Id>();
    List<sObject> contacts = new List<sObject>();
    Set<Id> contactIds = new Set<Id>();
    for (Integer t = 0; t < enquiries.size(); t++) {
      String whoId = enquiries[t].WhoId;
      if (whoId != null) {
        String recordObject = getRecordObject(whoId);
        if (recordObject == 'Lead') leadIds.add(whoId);
        if (recordObject == 'Contact') contactIds.add(whoId);
      }
    }
    if (leadIds.size() > 0) leads = [SELECT Id, OwnerId FROM Lead WHERE Id IN :leadIds];
    if (contactIds.size() > 0) contacts = [SELECT Id, OwnerId FROM Contact WHERE Id IN :contactIds];
    leads.addAll(contacts);
    for (Integer i = 0; i < leads.size(); i++) {
      ownerMap.put(String.valueOf(leads[i].Id), (String) leads[i].get('OwnerId'));    
    }
    for (Integer t = 0; t < enquiries.size(); t++) {
      String whoId = enquiries[t].WhoId;
      String whoObj = getRecordObject(whoId);
      if (whoObj == 'User') {
        enquiries[t].OwnerId = ownerMap.get(whoId); 
      }
    }
  }
    
  private static String getRecordTypeId(String name, String obj) {
    String recordTypeId = [
      SELECT Id 
      FROM RecordType 
      WHERE SobjectType = :obj 
      AND DeveloperName = :name
      LIMIT 1
    ].Id;
    return recordTypeId;
  }
    
  private static String getRecordObject(String recordId) {
    if (recordId == null) return null;
    String code = recordId.substring(0, 3);
    if (code == '003') return 'Contact';
    if (code == '00Q') return 'Lead';
    if (code == '005') return 'User';
    return null;
  }
    
}
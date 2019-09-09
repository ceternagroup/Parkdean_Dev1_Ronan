trigger LineItemTrigger on Line_item__c (after insert, after update) {
    
  LineItemTriggerHandler handler = new LineItemTriggerHandler();
    
  if (Trigger.isInsert && Trigger.isAfter){
    handler.afterInsert();
  }
    
  if (Trigger.isUpdate && Trigger.isAfter){
    handler.afterUpdate();
  }

}
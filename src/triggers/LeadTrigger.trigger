trigger LeadTrigger on Lead (before insert, before update, after insert, after update) {
    
  LeadTriggerHandler handler = new LeadTriggerHandler();
    
  if (Trigger.isInsert && Trigger.isBefore) {
    handler.beforeInsert();
  }
    
  if (Trigger.isInsert && Trigger.isAfter) {
    handler.afterInsert();
  }
    
  if (Trigger.isUpdate && Trigger.isBefore) {
    handler.beforeUpdate();
  }
    
  if (Trigger.isUpdate && Trigger.isAfter) {
    handler.afterUpdate();
  }
    
}
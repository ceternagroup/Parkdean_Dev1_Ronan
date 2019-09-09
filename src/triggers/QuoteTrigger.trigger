trigger QuoteTrigger on Quote (after insert) {
    
  QuoteTriggerHandler handler = new QuoteTriggerHandler();
    
  if (Trigger.isInsert && Trigger.isAfter) {
    handler.afterInsert();
  }

}
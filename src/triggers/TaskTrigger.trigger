trigger TaskTrigger on Task (before insert) {
    
  TaskTriggerHandler handler = new TaskTriggerHandler();
    
  if (Trigger.isInsert && Trigger.isBefore) {
    handler.beforeInsert();
  }

}
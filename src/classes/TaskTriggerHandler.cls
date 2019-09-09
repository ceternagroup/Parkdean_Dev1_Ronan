/*
 * @class TaskTriggerHandler
 * @desc Example custom trigger handler class that extends the TriggerHandler 
 *   class. You must keep the extends attribute for this class to work.
 */
public without sharing class TaskTriggerHandler extends TriggerHandler {
    
  // after leads are inserted
  public override void beforeInsert() {
    // send changes to ODI
    TaskHandler.setOwner(Trigger.new);
  }

}
/*
 * @class LineItemTriggerHandler
 * @desc Example custom trigger handler class that extends the TriggerHandler 
 *   class. You must keep the extends attribute for this class to work.
 */
public with sharing class LineItemTriggerHandler extends TriggerHandler {
    
  // after line items are inserted
  public override void afterInsert() {
    //LineItemHandler.checkAncilleries(Trigger.new);
  }
    
  // after line items are update
  public override void afterUpdate() {
    //LineItemHandler.checkAncilleries(Trigger.new);
  }

}
/*
 * @class BookingTriggerHandler
 * @desc Example custom trigger handler class that extends the TriggerHandler 
 *   class. You must keep the extends attribute for this class to work.
 */
public without sharing class BookingTriggerHandler extends TriggerHandler {
    
  // after leads are inserted
  public override void afterInsert() {
    // send changes to ODI
    BookingHandler.checkHotLeads(Trigger.new);
  }
    
  // after leads are updated
  public override void afterUpdate() {
    // send changes to ODI
    BookingHandler.checkHotLeads(Trigger.new);
  }  

}
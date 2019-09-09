/*
 * @class QuoteTriggerHandler
 * @desc Example custom trigger handler class that extends the TriggerHandler 
 *   class. You must keep the extends attribute for this class to work.
 */
public class QuoteTriggerHandler extends TriggerHandler {
    
  // after leads are inserted
  public override void afterInsert() {
    // send changes to ODI
    //QuoteHandler.linkOrphans(Trigger.new);
  }

}
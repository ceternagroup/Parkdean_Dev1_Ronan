/**********************************************************************************************
* @Author: Ceterna
* @Date:        
* @Description: Account Trigger for Account/Contact (PersonAccount) changes. All logic 
*	handled through the AccountTriggerHandler class.
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description] 
***********************************************************************************************/  
trigger AccountTrigger on Account (before insert, before update, after insert, after update) {
    
  AccountTriggerHandler handler = new AccountTriggerHandler();
    
  if (Trigger.isInsert && Trigger.isBefore) {
    handler.beforeInsert();
  }
    
  if (Trigger.isUpdate && Trigger.isBefore) {
    handler.beforeUpdate();
  }
    
  if (Trigger.isInsert && Trigger.isAfter) {
    handler.afterInsert();
  }
    
  if (Trigger.isUpdate && Trigger.isAfter) {
    handler.afterUpdate();
  }

}
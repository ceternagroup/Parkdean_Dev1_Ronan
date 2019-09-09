trigger BookingTrigger on Holiday_Booking__c (after insert, after update) {
    
  BookingTriggerHandler handler = new BookingTriggerHandler();
    
//  if (Trigger.isInsert && Trigger.isAfter) {
//    handler.afterInsert();
//  }
//
//  if (Trigger.isUpdate && Trigger.isAfter) {
//    handler.afterUpdate();
//  }
//
//

}
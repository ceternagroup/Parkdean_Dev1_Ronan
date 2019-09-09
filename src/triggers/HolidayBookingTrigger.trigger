/**********************************************************************************************
* @Author: Ceterna
* @Date: 07/08/2019
* @Description: Holiday Booking Trigger for HolidayBooking/Lead changes. All logic
*	handled through the HolidayBookingTriggerHandler class.
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]
***********************************************************************************************/

trigger HolidayBookingTrigger on Holiday_Booking__c (
        before insert,
        before update,
        before delete,
        after insert,
        after update,
        after delete,
        after undelete) {

    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
        }
        if (Trigger.isUpdate) {
        }
    }

    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            HolidayBookingTriggerHandler.afterInsert(Trigger.newMap);
        }
        if (Trigger.isUpdate) {
            HolidayBookingTriggerHandler.afterUpdate(Trigger.newMap, Trigger.oldMap);
        }
    }
}
public class LeadSLACountdown {
    
  @AuraEnabled
  public static String getLead(String recordId) {
    List<Lead> leads = new List<Lead>();
    leads = [
      SELECT SLA_Deadline__c, First_Responded__c, Business_Hours__c
      FROM Lead
      WHERE Id =: recordId
    ];
    if (leads.size() == 0) 
      return 'Error: No Lead found with this Id';
    if (leads[0].SLA_Deadline__c == null) 
      return 'Error: No SLA Deadline set for this Lead';
    return JSON.serialize(leads[0]);
  }
    
  @AuraEnabled
  public static BusinessHours getHours(String hourId) {
    List<BusinessHours> bh = new List<BusinessHours>();
    bh = [
      SELECT MondayStartTime, MondayEndTime,
        TuesdayStartTime, TuesdayEndTime,
        WednesdayStartTime, WednesdayEndTime,
        ThursdayStartTime, ThursdayEndTime,
        FridayStartTime, FridayEndTime,
        SaturdayStartTime, SaturdayEndTime,
        SundayStartTime, SundayEndTime
      FROM BusinessHours
      WHERE Id = :hourId
    ];
    return hourId == null ? null : bh.size() == 0 ? null : bh[0];
  }

}
/**********************************************************************************************
  * @Author: Ceterna
  * @Date:    
  * @Description: Runs the 5 queries used to build the custom report component RMReport
  * @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description] 
  ***********************************************************************************************/ 
public without sharing class RMReportClass {
    
  /**********************************************************************************************
  * @Author: Ceterna
  * @Date:    
  * @Description: Runs the 5 different queries used in the component
  * @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description] 
  * 			  25/07/2019 - B0108 - Elliott TN - Lead query was missing required fields
  ***********************************************************************************************/ 
  @AuraEnabled
  public static String getReportData() {
    // get user id
    String userId = UserInfo.getUserId();
    String errorMessage;
    ResultsClass results = new ResultsClass();
    // get user mapping
    List<RM_Report_Mapping__mdt> mappings = [
      SELECT Global_Access__c, Parks__c, Regions__c, RM_User_Id__c
      FROM RM_Report_Mapping__mdt
      WHERE RM_User_Id__c = :userId
    ];
    if (mappings.size() == 0) errorMessage = 'You have not created a mapping for this user. (' + userId + ')';
    // set current user's mapping
    RM_Report_Mapping__mdt mapping = mappings.size() == 0 ? null : mappings[0];
    if (mapping == null) {
      results.error = errorMessage;
      return JSON.serialize(results);
    } 
    // set buckets
    List<String> parkBuckets = new List<String>();
    parkBuckets.addAll(mapping.Parks__c.replaceAll(', ', ',').split(','));
    parkBuckets.addAll(mapping.Regions__c.replaceAll(', ', ',').split(','));
    if (mapping.Global_Access__c == true) parkBuckets.add('Global');
    // set park names
    List<String> parkNames = new List<String>();
    parkNames.addAll(mapping.Parks__c.replaceAll(', ', ',').split(','));
    // set park ids
    List<String> parkIds = new List<String>();
    List<Park__c> parks = [
      SELECT Id 
      FROM Park__c
      WHERE Name IN :parkNames
    ];
    for (Integer p = 0; p < parks.size(); p++) {
      parkIds.add(parks[p].Id);    
    }
    System.debug(parkBuckets);
    System.debug(parkNames);
    System.debug(parkIds);
    // run lead query
    List<Lead> leads = new List<Lead>();
    // check year as this changes the query
    // in 2019 data was loaded at a set point and needed to be ignored
    Integer currentYear = System.today().year();
    if (currentYear == 2019) {
      leads = [
        SELECT Id, Park_Bucket__c, Record_type_formua__c, Enquiry_Date__c, CreatedDate
        FROM Lead
	    WHERE Park_Bucket__c IN :parkBuckets
	    AND Record_type_formua__c IN ('Central', 'Park')
	    AND (Enquiry_Date__c > 2019-04-09 OR CreatedDate > 2019-04-09T23:00:00Z)
      ];   
    } else {
      leads = [
        SELECT Id, Park_Bucket__c, Record_type_formua__c, Enquiry_Date__c, CreatedDate
        FROM Lead
	    WHERE Park_Bucket__c IN :parkBuckets
	    AND Record_type_formua__c IN ('Central', 'Park')
	    AND (Enquiry_Date__c > THIS_YEAR OR CreatedDate > THIS_YEAR)
      ];  
    }
    // run appointment query
    List<Event> appointments = new List<Event>();
    appointments = [
      SELECT Id, Created_by_Team__c, Park__r.Name, Record_Type_Formula__c
      FROM Event 
      WHERE Record_Type_Formula__c IN ('Pre - Appointment', 'Walk In Appointment') 
      AND Part_Exchange_Appointment__c = false 
      AND Park__c IN :parkIds
      AND CreatedDate = THIS_YEAR
    ];
    // run visit query
    List<Quote> visits = new List<Quote>();
    visits = [
      SELECT Id, Appointment_booking_team__c, Park_Name__c, Record_Type_Formula__c, CreatedDate
      FROM Quote 
      WHERE Record_Type_Formula__c IN ('New_Biz' , 'Part_Ex_New_Biz' , 'Read_Only_New_Customer' , 'Read_Only_New_Customer_Part_Exchange_WITHOUT_BUTTONS') 
      AND Include_in_funnel_Report__c = true 
      AND CreatedDate = THIS_YEAR 
      AND Park_Name__c IN :parkNames
    ];
    // run signup query
    List<Quote> signups = new List<Quote>();
    signups = [
      SELECT Id, Appointment_booking_team__c, Park_Name__c, Record_Type_Formula__c, Signup_Date__c
      FROM Quote 
      WHERE Record_Type_Formula__c IN ('New_Biz' , 'Part_Ex_New_Biz' , 'Read_Only_New_Customer' , 'Read_Only_New_Customer_Part_Exchange_WITHOUT_BUTTONS') 
      AND Include_in_funnel_Report__c = true 
      AND Signup_Date__c = THIS_YEAR 
      AND Park_Name__c IN :parkNames
    ];
    // run sales query
    List<Quote> sales = new List<Quote>();
    sales = [
      SELECT Id, Appointment_booking_team__c, Park_Name__c, Record_Type_Formula__c, Completed_date__c
      FROM Quote 
      WHERE Record_Type_Formula__c IN ('New_Biz' , 'Part_Ex_New_Biz' , 'Read_Only_New_Customer' , 'Read_Only_New_Customer_Part_Exchange_WITHOUT_BUTTONS') 
      AND Include_in_funnel_Report__c = true 
      AND Completed_date__c = THIS_YEAR 
      AND Park_Name__c IN :parkNames
    ];
    // return reports and mapping
    results.error = errorMessage;
    results.leads = leads;
    results.appointments = appointments;
    results.visits = visits;
    results.signups = signups;
    results.sales = sales;
    results.parks = mapping.Parks__c;
    results.regions = mapping.Regions__c;
    results.globel = mapping.Global_Access__c;
    return JSON.serialize(results);
  }
    
  // stores results class sent to the component
  public class ResultsClass {
    String error;
    List<Lead> leads;
    List<Event> appointments;
    List<Quote> visits;
    List<Quote> signups;
    List<Quote> sales;
    String parks;
    String regions;
    Boolean globel;
  }

}
/**********************************************************************************************
 * @Author: Ceterna
 * @Date:
 * @Description: Class for LEadSearch component
 * @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]
 ***********************************************************************************************/
public without sharing class LeadSearch {
    
  /**********************************************************************************************
 * @Author: Ceterna
 * @Date:
 * @Description: Runs a search using the gigven parameters as query criteria (AND)
 * @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]
 *  			 07/08/2019 - E0061/B0063 - Ell - Changed so we can search on phone/mobile, and so we use the Postcode_No_Spaces field
 ***********************************************************************************************/
  @AuraEnabled
  public static Map<String, Object> runFullSearch(String firstName, String lastName, String email, String postcode, String phone, String mobilePhone) {
    // remove spaces from postcode
    if (postcode != null) postcode = postcode.replaceAll(' ', '');
    RecordType holidayMakerRT = new RecordType();
    if (!Test.isRunningTest()) {
      holidayMakerRT = [SELECT Id FROM RecordType WHERE sObjectType = 'Lead' AND DeveloperName = 'Holiday_Maker' LIMIT 1];
    } else {
      holidayMakerRT = [SELECT Id FROM RecordType WHERE sObjectType = 'Lead' LIMIT 1];
    }
    // get holiday makers
    List<Lead> holidayMakers = new List<Lead>();
    String holidayQuery = 'SELECT Id, FirstName, LastName, Email, Postcode_No_Spaces__c, Phone, MobilePhone FROM Lead WHERE RecordTypeId = \'' + holidayMakerRT.Id + '\' ';
    holidayQuery = addQuery('Lead', holidayQuery, firstName, lastName, email, postcode, phone, mobilePhone);
    holidayMakers = Database.query(holidayQuery);
    // get leads
    List<Lead> leads = new List<Lead>();
    String leadQuery = 'SELECT Id, FirstName, LastName, Email, Postcode_No_Spaces__c, Phone, MobilePhone FROM Lead WHERE RecordTypeId != \'' + holidayMakerRT.Id + '\' ';
    leadQuery = addQuery('Lead', leadQuery, firstName, lastName, email, postcode, phone, mobilePhone);
    leads = Database.query(leadQuery);
    // get contacts
    List<Contact> contacts = new List<Contact>();
    String contactQuery = 'SELECT Id, FirstName, LastName, Email, Postcode_No_Spaces__c, Phone, MobilePhone FROM Contact WHERE Id != null ';
    contactQuery = addQuery('Contact', contactQuery, firstName, lastName, email, postcode, phone, mobilePhone);
    contacts = Database.query(contactQuery);
    Map<String, Object> results = new Map<String, Object>();
    results.put('holiday_makers', holidayMakers);
    results.put('leads', leads);
    results.put('contacts', contacts);
    return results;
  }
    
  @AuraEnabled
  public static String changeRT(String recordId) {
    String userId = UserInfo.getUserId();
    User u = [
      SELECT Id, Team__c
      FROM User
      WHERE Id =: userId
    ];
    String team = u.Team__c == 'Park' ? 'Park' : 'Central';
    RecordType rt = new RecordType();
    if (!Test.isRunningTest()) {
      rt = [SELECT Id FROM RecordType WHERE sObjectType = 'Lead' AND DeveloperName =: team LIMIT 1];
    } else {
      rt = [SELECT Id FROM RecordType WHERE sObjectType = 'Lead' LIMIT 1];
    }
    Lead l = [
      SELECT Id, RecordTypeId
      FROM Lead
      WHERE Id =: recordId
      LIMIT 1
    ];
    l.RecordTypeId = rt.Id;
    l.OwnerId = u.Id;
    try {
      update l;
      return 'Success';
    } catch(DMLException e) {
      return 'Error: ' + e;
    }
  }
    
  private static String addQuery(String obj, String query, String firstName, String lastName, String email, String postcode, String phone, String mobilePhone) {
    if (firstName != '' && firstName != null) query += ' AND FirstName LIKE \'%' + firstName + '%\'';
    if (lastName != '' && lastName != null) query += ' AND LastName LIKE \'%' + LastName + '%\'';
    if (email != '' && email != null) query += ' AND Email LIKE \'%' + email + '%\'';
    if (postcode != '' && postcode != null) query += ' AND Postcode_No_Spaces__c LIKE \'%' + postcode + '%\'';
    if (postcode != '' && postcode != null) query += ' AND Postcode_No_Spaces__c LIKE \'%' + postcode.replaceAll(' ', '') + '%\'';
    if (phone != '' && phone != null) query += ' AND Phone LIKE \'%' + phone + '%\'';
    if (mobilePhone != '' && mobilePhone != null) query += ' AND MobilePhone LIKE \'%' + mobilePhone + '%\'';
    return query;
  }
    

}
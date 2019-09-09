/**********************************************************************************************
* @Author:      Susanna Taylor
* @Date:     20/08/2019   
* @Description: Test Class for Event object process automation
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]   
***********************************************************************************************/  
@isTest
public class EventCharacterisationTest {

    /**********************************************************************************************
    * @Author:      Susanna Taylor
    * @Date:     20/08/2019   
    * @Description: Insert pre-appointment
    * @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]   
    ***********************************************************************************************/      
    public static testMethod void insertPreAppointment(){
        Lead testLead = New Lead();
        Id centralLeadRt = getRecordTypeId('Lead','Central');
        testLead.RecordTypeId = centralLeadRt;
        testLead.lastName = 'test';
        testLead.LeadSource = 'Digital - Direct';
        testLead.Lead_source_Level_2__c = 'PDR website';
        testLead.Enquiry_Method__c = 'Email';
        insert testLead;
        
        user testUser = createUser('Standard User', 'Central');
        
        Park__c testPark = New Park__c();
        testPark.name = 'Test';
		insert testPark;

		dateTime appointmentEnd = datetime.newInstanceGMT(system.today(), time.newInstance(12, 0, 0, 0)); 
        
        Event testEvent = New Event();
        Id preApptEventRt = getRecordTypeId('Event','Pre_Appointment');
        testEvent.RecordTypeId = preApptEventRt;
        testEvent.Park__c = testPark.id;
        testEvent.StartDateTime = datetime.newInstanceGMT(system.today(), time.newInstance(8, 0, 0, 0)); 
        testEvent.EndDateTime = appointmentEnd;
        testEvent.whoId = testLead.id;
        insert testEvent;
        
        Event resultEvent = [SELECT Id,
                            Subject,
                            lead__c,
                            whoId,
                             enddatetime
                             FROM Event
                             WHERE Id = :testEvent.Id
                            ];
        System.assertEquals(appointmentEnd.addHours(2),resultEvent.EndDateTime);
        System.assertEquals('Appointment - Test', resultEvent.Subject);
        System.assertEquals(testEvent.whoId, resultEvent.Lead__c);
        
        Lead resultLead = [SELECT id,
                          first_responded__c,
                          number_of_appointments__c
                          FROM LEAD
                          where Id = : testLead.id];
        System.assertEquals(1, resultLead.Number_of_appointments__c);
        System.assert(resultLead.First_Responded__c !=  null);
    } 
    
    /**********************************************************************************************
    * @Author:      Susanna Taylor
    * @Date:     20/08/2019   
    * @Description: Insert pre-appointment
    * @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]   
    ***********************************************************************************************/      
    public static testMethod void insertWalkIn(){
        Lead testLead = New Lead();
        Id centralLeadRt = getRecordTypeId('Lead','Central');
        testLead.RecordTypeId = centralLeadRt;
        testLead.lastName = 'test';
        testLead.LeadSource = 'Digital - Direct';
        testLead.Lead_source_Level_2__c = 'PDR website';
        testLead.Enquiry_Method__c = 'Email';
        insert testLead;
        
        user testUser = createUser('Standard User', 'Central');
        
        Park__c testPark = New Park__c();
        testPark.name = 'Test';
		insert testPark;

		dateTime appointmentEnd = datetime.newInstanceGMT(system.today(), time.newInstance(12, 0, 0, 0)); 
        
        Event testEvent = New Event();
        Id walkInEventRt = getRecordTypeId('Event','Walk_in_Appointment');
        testEvent.RecordTypeId = walkInEventRt;
        testEvent.Park__c = testPark.id;
        testEvent.StartDateTime = datetime.newInstanceGMT(system.today(), time.newInstance(8, 0, 0, 0)); 
        testEvent.EndDateTime = appointmentEnd;
        testEvent.whoId = testLead.id;
        insert testEvent;
        
        Lead resultLead = [SELECT id,
                          first_responded__c,
                          number_of_appointments__c
                          FROM LEAD
                          where Id = : testLead.id];
        System.assertEquals(1, resultLead.Number_of_appointments__c);
        System.assert(resultLead.First_Responded__c !=  null);
    }     
    
    /**********************************************************************************************
    * @Author:      Susanna Taylor
    * @Date:     20/08/2019   
    * @Description: Insert pre-appointment
    * @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]   
    ***********************************************************************************************/      
    public static testMethod void insertWalkInFirstResponded(){
        Lead testLead = New Lead();
        Id centralLeadRt = getRecordTypeId('Lead','Central');
        dateTime firstResponded = system.now();
        testLead.RecordTypeId = centralLeadRt;
        testLead.lastName = 'test';
        testLead.LeadSource = 'Digital - Direct';
        testLead.Lead_source_Level_2__c = 'PDR website';
        testLead.Enquiry_Method__c = 'Email';
        testLead.First_Responded__c = firstResponded;
        insert testLead;
        
        user testUser = createUser('Standard User', 'Central');
        
        Park__c testPark = New Park__c();
        testPark.name = 'Test';
		insert testPark;

		dateTime appointmentEnd = datetime.newInstanceGMT(system.today(), time.newInstance(12, 0, 0, 0)); 
        
        Event testEvent = New Event();
        Id walkInEventRt = getRecordTypeId('Event','Walk_in_Appointment');
        testEvent.RecordTypeId = walkInEventRt;
        testEvent.Park__c = testPark.id;
        testEvent.StartDateTime = datetime.newInstanceGMT(system.today(), time.newInstance(8, 0, 0, 0)); 
        testEvent.EndDateTime = appointmentEnd;
        testEvent.whoId = testLead.id;
        insert testEvent;
        
        Lead resultLead = [SELECT id,
                          first_responded__c,
                          number_of_appointments__c
                          FROM LEAD
                          where Id = : testLead.id];
        System.assertEquals(1, resultLead.Number_of_appointments__c);
        System.assertEquals(firstResponded, resultLead.First_Responded__c);
    }     
    /**********************************************************************************************
    * @Author:      Susanna Taylor
    * @Date:     20/08/2019   
    * @Description: create user
    * @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]   
    ***********************************************************************************************/      
    public static user createUser(String profileName, String team){
        
        Profile p = [SELECT Id FROM Profile WHERE Name = :profileName];
        
        
        User u = new User(Alias = 't',
                          Email='testuser@test.com',
                          EmailEncodingKey='UTF-8', 
                          LastName='Testing', 
                          LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', 
                          ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles', 
                          UserName='testuser@test.com',
                          Team__c = team);
        
        return u;
    }   
    
    /**********************************************************************************************
    * @Author:      Susanna Taylor
    * @Date:     20/08/2019   
    * @Description: get record type id
    * @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]   
    ***********************************************************************************************/         
    public static id getRecordTypeId(String sobjectType, String recordTypeDeveloperName) {
        return Schema.getGlobalDescribe().get(sobjectType).getDescribe().getRecordTypeInfosByDeveloperName().get(recordTypeDeveloperName).getRecordTypeId();
    }
}
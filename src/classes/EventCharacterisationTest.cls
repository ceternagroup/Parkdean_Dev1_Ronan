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

        Park__c testPark = [SELECT id
                           FROM Park__c
                           LIMIT 1
                           ];

        Lead testLead = [SELECT Id 
                        FROM Lead
                        LIMIT 1
                        ];
        
        user testUser = createUser('Standard User', 'Central');
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
                          number_of_appointments__c,
                           Status
                          FROM LEAD
                          where Id = : testLead.id];
        System.assertEquals(1, resultLead.Number_of_appointments__c);
        System.assertEquals('Appointment Booked', resultLead.Status);
        System.assert(resultLead.First_Responded__c !=  null);
        System.assertEquals(resultEvent.whoId, resultEvent.Lead__c);
    } 

    /**********************************************************************************************
    * @Author:      Susanna Taylor
    * @Date:     20/08/2019   
    * @Description: Insert pre-appointment
    * @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]   
    ***********************************************************************************************/      
    public static testMethod void insertPreAppointmentContact(){

        Park__c testPark = [SELECT id
                           FROM Park__c
                           LIMIT 1
                           ];

        Account testContact = [SELECT Id,
                               PersonContactId
                            FROM Account
                            LIMIT 1
                            ];
        
        user testUser = createUser('Standard User', 'Central');
		dateTime appointmentEnd = datetime.newInstanceGMT(system.today(), time.newInstance(12, 0, 0, 0)); 
        
        Event testEvent = New Event();
        Id preApptEventRt = getRecordTypeId('Event','Pre_Appointment');
        testEvent.RecordTypeId = preApptEventRt;
        testEvent.Park__c = testPark.id;
        testEvent.StartDateTime = datetime.newInstanceGMT(system.today(), time.newInstance(8, 0, 0, 0)); 
        testEvent.EndDateTime = appointmentEnd;
        testEvent.whoId = testContact.PersonContactid;
        insert testEvent;
        
        Event resultEvent = [SELECT Id,
                            Subject,
                            lead__c,
                            contact__c,
                            whoId,
                             enddatetime
                             FROM Event
                             WHERE Id = :testEvent.Id
                            ];
        System.assertEquals(appointmentEnd.addHours(2),resultEvent.EndDateTime);
        System.assertEquals('Appointment - Test', resultEvent.Subject);

        System.assertEquals(testContact.PersonContactId, resultEvent.Contact__c);
    }     
    /**********************************************************************************************
    * @Author:      Susanna Taylor
    * @Date:     20/08/2019   
    * @Description: Insert pre-appointment
    * @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]   
    ***********************************************************************************************/      
    public static testMethod void insertWalkIn(){
        
        Park__c testPark = [SELECT id
                           FROM Park__c
                           LIMIT 1
                           ];

        Lead testLead = [SELECT Id 
                        FROM Lead
                        LIMIT 1
                        ];
        
        user testUser = createUser('Standard User', 'Central');

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
    * @Description: Validate park populated on lead
    * @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]   
    ***********************************************************************************************/      
    public static testMethod void validateParkPopulatedOnLead(){

        Lead testLead = [SELECT Id, 
                         park_codes__c
                        FROM Lead
                        LIMIT 1
                        ];
        testLead.park_codes__c = null;
        update testLead;
        user testUser = createUser('Standard User', 'Central');

		dateTime appointmentEnd = datetime.newInstanceGMT(system.today(), time.newInstance(12, 0, 0, 0)); 
        
        Event testEvent = New Event();
        Id preApptEventRt = getRecordTypeId('Event','Pre_Appointment');
        testEvent.RecordTypeId = preApptEventRt;
        testEvent.StartDateTime = datetime.newInstanceGMT(system.today(), time.newInstance(8, 0, 0, 0)); 
        testEvent.EndDateTime = appointmentEnd;
        testEvent.whoId = testLead.id;
        
        try {
        	insert testEvent;            
        }
        catch (Exception ex) {
            system.assert(ex.getmessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
        }
        
        Lead resultLead = [SELECT id,
                          first_responded__c,
                          number_of_appointments__c
                          FROM LEAD
                          where Id = : testLead.id];
        System.assertEquals(0, resultLead.Number_of_appointments__c);
    }   
    /**********************************************************************************************
    * @Author:      Susanna Taylor
    * @Date:     20/08/2019   
    * @Description: Insert pre-appointment
    * @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]   
    ***********************************************************************************************/      
    public static testMethod void updateAppointment(){
        
        Park__c testPark = [SELECT id
                           FROM Park__c
                           LIMIT 1
                           ];

        Lead testLead = [SELECT Id 
                        FROM Lead
                        LIMIT 1
                        ];
        
        user testUser = createUser('Standard User', 'Central');

		dateTime appointmentEnd = datetime.newInstanceGMT(system.today(), time.newInstance(12, 0, 0, 0)); 
        
        Event testEvent = New Event();
        Id walkInEventRt = getRecordTypeId('Event','Walk_in_Appointment');
        testEvent.RecordTypeId = walkInEventRt;
        testEvent.Park__c = testPark.id;
        testEvent.StartDateTime = datetime.newInstanceGMT(system.today(), time.newInstance(8, 0, 0, 0)); 
        testEvent.EndDateTime = appointmentEnd;
        testEvent.whoId = testLead.id;
        insert testEvent;
        
        test.startTest();
        testEvent.Appointment_Status__c = 'Pending with Park';
        update testEvent;
        test.stopTest();
        
        Lead resultLead = [SELECT id,
                          first_responded__c,
                          number_of_appointments__c
                          FROM LEAD
                          where Id = : testLead.id];
        System.assertEquals(1, resultLead.Number_of_appointments__c);
    }     

    /**********************************************************************************************
    * @Author:      Susanna Taylor
    * @Date:     20/08/2019   
    * @Description: Insert pre-appointment
    * @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]   
    ***********************************************************************************************/      
    public static testMethod void updateAppointment_changeWhoId(){
        
        Park__c testPark = [SELECT id
                           FROM Park__c
                           LIMIT 1
                           ];

        Lead testLead = [SELECT Id,
                         FirstName,
                         LastName
                        FROM Lead
                        LIMIT 1
                        ];
        
        user testUser = createUser('Standard User', 'Central');

		dateTime appointmentEnd = datetime.newInstanceGMT(system.today(), time.newInstance(12, 0, 0, 0)); 
        
        Event testEvent = New Event();
        Id walkInEventRt = getRecordTypeId('Event','Walk_in_Appointment');
        testEvent.RecordTypeId = walkInEventRt;
        testEvent.Park__c = testPark.id;
        testEvent.StartDateTime = datetime.newInstanceGMT(system.today(), time.newInstance(8, 0, 0, 0)); 
        testEvent.EndDateTime = appointmentEnd;
        testEvent.whoId = testLead.id;
        insert testEvent;
        
        Lead lead2 = testLead.clone(false, false, false, false);
        insert lead2;
        
        test.startTest();
        testEvent.whoId = lead2.Id;
        update testEvent;
        test.stopTest();
        
        Lead resultLead = [SELECT id,
                           first_responded__c,
                           number_of_appointments__c
                           FROM Lead
                           where Id = : testLead.id];
        System.assertEquals(0, resultLead.Number_of_appointments__c);
        
        
        Event resultEvent = [SELECT Id,
                             Subject,
                             lead__c,
                             contact__c,
                             whoId,
                             enddatetime
                             FROM Event
                             WHERE Id = :testEvent.Id
                            ];
        
        System.assertEquals(lead2.Id, resultEvent.lead__c);
    }    
    
    /**********************************************************************************************
    * @Author:      Susanna Taylor
    * @Date:     20/08/2019   
    * @Description: Insert pre-appointment
    * @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]   
    ***********************************************************************************************/      
    public static testMethod void deleteAppointment(){
        
        Park__c testPark = [SELECT id
                           FROM Park__c
                           LIMIT 1
                           ];

        Lead testLead = [SELECT Id 
                        FROM Lead
                        LIMIT 1
                        ];
        
        user testUser = createUser('Standard User', 'Central');

		dateTime appointmentEnd = datetime.newInstanceGMT(system.today(), time.newInstance(12, 0, 0, 0)); 
        
        Event testEvent = New Event();
        Id walkInEventRt = getRecordTypeId('Event','Walk_in_Appointment');
        testEvent.RecordTypeId = walkInEventRt;
        testEvent.Park__c = testPark.id;
        testEvent.StartDateTime = datetime.newInstanceGMT(system.today(), time.newInstance(8, 0, 0, 0)); 
        testEvent.EndDateTime = appointmentEnd;
        testEvent.whoId = testLead.id;
        
        insert testEvent;
        
        test.startTest();
        delete testEvent;
        test.stopTest();
        
        List<Event> resultEventList = [SELECT id
                                      FROM Event
                                      WHERE id = :testEvent.Id];
        system.assertEquals(0,resultEventList.size());
        Lead resultLead = [SELECT id,
                          first_responded__c,
                          number_of_appointments__c
                          FROM LEAD
                          where Id = : testLead.id];
        System.assertEquals(0, resultLead.Number_of_appointments__c);
    }     
    
    /**********************************************************************************************
    * @Author:      Susanna Taylor
    * @Date:     20/08/2019   
    * @Description: Insert pre-appointment
    * @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]   
    ***********************************************************************************************/      
    public static testMethod void insertWalkInFirstResponded(){

        dateTime firstResponded = system.now();

        Park__c testPark = [SELECT id
                           FROM Park__c
                           LIMIT 1
                           ];

        Lead testLead = [SELECT Id 
                        FROM Lead
                        LIMIT 1
                        ];

		testLead.First_Responded__c = firstResponded;
		update testLead;        
        
        user testUser = createUser('Standard User', 'Central');

		dateTime appointmentEnd = datetime.newInstanceGMT(system.today(), time.newInstance(12, 0, 0, 0)); 
        
        test.startTest();
            Event testEvent = New Event();
            Id walkInEventRt = getRecordTypeId('Event','Walk_in_Appointment');
            testEvent.RecordTypeId = walkInEventRt;
            testEvent.Park__c = testPark.id;
            testEvent.StartDateTime = datetime.newInstanceGMT(system.today(), time.newInstance(8, 0, 0, 0)); 
            testEvent.EndDateTime = appointmentEnd;
            testEvent.whoId = testLead.id;
            insert testEvent;
        test.stopTest();
        
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
    * @Description: Insert pre-appointment
    * @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]   
    ***********************************************************************************************/      
    public static testMethod void insertPreAppointmentSetPark(){

        Park__c testPark = [SELECT id
                           FROM Park__c
                           LIMIT 1
                           ];

        Lead testLead = [SELECT Id 
                        FROM Lead
                        LIMIT 1
                        ];
        
        user testUser = createUser('Standard User', 'Central');
		dateTime appointmentEnd = datetime.newInstanceGMT(system.today(), time.newInstance(12, 0, 0, 0)); 
        
        Park_Employees__c testPe = new Park_Employees__c(name = 'Test', user__c = testUser.Id, Park__c = testPark.Id);
        insert testPe;
        
        LeadShare lShare = new LeadShare(leadAccessLevel='Edit', leadId = testLead.Id, userOrGroupId = testUser.Id);
        insert lShare;
        
        System.runAs(testUser) {
            Event testEvent = New Event();
            Id preApptEventRt = getRecordTypeId('Event','Pre_Appointment');
            testEvent.RecordTypeId = preApptEventRt;
            testEvent.StartDateTime = datetime.newInstanceGMT(system.today(), time.newInstance(8, 0, 0, 0)); 
            testEvent.EndDateTime = appointmentEnd;
            testEvent.whoId = testLead.id;
            insert testEvent;
        }
        Event resultEvent = [SELECT Id,
                             Subject,
                             lead__c,
                             park__c,
                             whoId,
                             enddatetime
                             FROM Event
                             WHERE CreatedById = :testUser.Id
                             LIMIT 1
                            ];
        
        System.assertEquals(appointmentEnd.addHours(2),resultEvent.EndDateTime);
        System.assertEquals('Appointment - Test', resultEvent.Subject);
        System.assertEquals(testPark.Id, resultEvent.Park__c);
    }     

    /**********************************************************************************************
    * @Author:      Susanna Taylor
    * @Date:     20/08/2019   
    * @Description: Insert pre-appointment
    * @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]   
    ***********************************************************************************************/      
    public static testMethod void insertPreAppointmentSetPark_negative(){

        Park__c testPark = [SELECT id
                           FROM Park__c
                           LIMIT 1
                           ];

        Lead testLead = [SELECT Id 
                        FROM Lead
                        LIMIT 1
                        ];
        
        user testUser = createUser('Standard User', 'Central');
		dateTime appointmentEnd = datetime.newInstanceGMT(system.today(), time.newInstance(12, 0, 0, 0)); 

        LeadShare lShare = new LeadShare(leadAccessLevel='Edit', leadId = testLead.Id, userOrGroupId = testUser.Id);
        insert lShare;
        
        System.runAs(testUser) {
            Event testEvent = New Event();
            Id preApptEventRt = getRecordTypeId('Event','Pre_Appointment');
            testEvent.RecordTypeId = preApptEventRt;
            testEvent.StartDateTime = datetime.newInstanceGMT(system.today(), time.newInstance(8, 0, 0, 0)); 
            testEvent.EndDateTime = appointmentEnd;
            testEvent.whoId = testLead.id;
            
            try {
                insert testEvent;
            }
            catch (Exception ex) {
                system.assert(ex.getmessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
            }            
        }
        List<Event> resultEvent = [SELECT Id,
                             Subject,
                             lead__c,
                             park__c,
                             whoId,
                             enddatetime
                             FROM Event
                             WHERE CreatedById = :testUser.Id
                            ];
        
        System.assertEquals(0,resultEvent.Size());
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
                          UserName='testuser@pdrtest.com',
                          Team__c = team);
        insert u;
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

    /**********************************************************************************************
    * @Author:      Susanna Taylor
    * @Date:     20/08/2019   
    * @Description: get record type id
    * @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]   
    ***********************************************************************************************/             
    @testSetup
    public static void createData() {
        
    	Test.setMock(HttpCalloutMock.class, new ODIRequestMock());
        Park__c testPark = New Park__c();
        testPark.name = 'Test';
        insert testPark;
        
        Lead testLead = New Lead();
        Id centralLeadRt = getRecordTypeId('Lead','Central');
        testLead.RecordTypeId = centralLeadRt;
        testLead.lastName = 'test';
        testLead.LeadSource = 'Digital - Direct';
        testLead.Lead_source_Level_2__c = 'PDR website';
        testLead.Enquiry_Method__c = 'Email';
        testLead.Park_Codes__c = testPark.Name;
        insert testLead;
        
        Account testPdrContact = new Account();
        testPdrContact.lastName = 'test';
        insert testPdrContact;
    }
}
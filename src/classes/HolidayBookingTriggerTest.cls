/**********************************************************************************************
* @Author: Ceterna
* @Date: 09/08/2019
* @Description: Test class for the Holiday Booking Trigger which checks if bookings have been updated/inserted
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]
*				09/08/2019
***********************************************************************************************/

@IsTest
public with sharing class HolidayBookingTriggerTest {

    //testSetup used for creating common test records that are available for all test methods in this class.
    @testSetup
    public static void doTestSetup(){
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'Standard User'];

        User testUser = new User(
                Alias               = 'testuser',
                Email               = 'testuser@myexample.com',
                EmailEncodingKey    = 'UTF-8',
                FirstName           = 'SalesManager',
                LastName            = 'Testing',
                LanguageLocaleKey   = 'en_US',
                LocaleSidKey        = 'en_US',
                ProfileId           =  profile.Id,
                TimeZoneSidKey      = 'America/New_York',
                Username            = 'testuser@myexample.com'
        );
        insert testUser;

        //insert 1 park
        Park__c p          = new Park__c();
        p.Name             = 'Test Park';
        p.Sales_Manager__c = testUser.Id;
        insert p;

        //insert 1 campaign
        Campaign c      = new Campaign();
        c.Name          = 'Test Campaign';
        c.Park__c       = p.Id;
        c.RecordTypeId  = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Hot Holiday Campaign').getRecordTypeId();
        insert c;

        //used to mock the callback from ODI when a request is given
        Test.setMock(HttpCalloutMock.class, new ODIRequestMock());

        //insert 1 lead
        Lead l = new Lead();
        l.Salutation    = 'Mr';
        l.FirstName     = 'Test';
        l.LastName      = 'Test';
        l.RecordTypeId  = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Holiday Maker').getRecordTypeId();
        insert l;
    }

    @IsTest
    public static void insertHotHolidayBooking(){

        //is HotHol
        Holiday_Booking__c b   = new Holiday_Booking__c();
        b.Lead__c              = [SELECT Id FROM Lead LIMIT 1].Id;
        b.Park__c              = [SELECT Id FROM Park__c WHERE Name = 'Test Park' LIMIT 1].Id;
        b.Hot_Hols_Campaign__c = 1;
        insert b;

        //checks if a SalesManager gets added and if the holiday is hot
        System.assertEquals('SalesManager', [SELECT Owner.FirstName FROM Lead WHERE Id = :[SELECT Id FROM Lead LIMIT 1].Id].Owner.FirstName);
        System.assertEquals(1, [SELECT Id FROM CampaignMember WHERE Campaign.Name = 'Test Campaign'].size());
    }

    @IsTest
    public static void insertColdHolidayBooking(){

        //is !HotHol
        Holiday_Booking__c b   = new Holiday_Booking__c();
        b.Lead__c              = [SELECT Id FROM Lead LIMIT 1].Id;
        b.Park__c              = [SELECT Id FROM Park__c WHERE Name = 'Test Park' LIMIT 1].Id;
        b.Hot_Hols_Campaign__c = 0;
        insert b;

        //checks that SalesManager is not equal to LeadOwner and if the holiday is not hot
        System.assertNotEquals('SalesManager', [SELECT Owner.FirstName FROM Lead WHERE Id = :[SELECT Id FROM Lead LIMIT 1].Id].Owner.FirstName);
        System.assertEquals(0, [SELECT Id FROM CampaignMember WHERE Campaign.Name = 'Test Campaign'].size());
    }

    @IsTest
    public static void updateHotHolidayBooking(){

        //is !HotHol
        Holiday_Booking__c b   = new Holiday_Booking__c();
        b.Lead__c              = [SELECT Id FROM Lead LIMIT 1].Id;
        b.Park__c              = [SELECT Id FROM Park__c WHERE Name = 'Test Park' LIMIT 1].Id;
        b.Hot_Hols_Campaign__c = 0;
        insert b;

        b.Hot_Hols_Campaign__c = 1;

        update b;

        //checks if a SalesManager gets added and if the holiday is hot
        System.assertEquals('SalesManager', [SELECT Owner.FirstName FROM Lead WHERE Id = :[SELECT Id FROM Lead LIMIT 1].Id].Owner.FirstName);
        System.assertEquals(1, [SELECT Id FROM CampaignMember WHERE Campaign.Name = 'Test Campaign'].size());
    }

    @IsTest
    public static void updateColdHolidayBooking(){

        //is HotHol
        Holiday_Booking__c b   = new Holiday_Booking__c();
        b.Lead__c              = [SELECT Id FROM Lead LIMIT 1].Id;
        b.Park__c              = [SELECT Id FROM Park__c WHERE Name = 'Test Park' LIMIT 1].Id;
        b.Hot_Hols_Campaign__c = 1;
        insert b;

        b.Hot_Hols_Campaign__c = 0;

        update b;

        //checks if the holiday is not hot anymore
        System.assertEquals(0, [SELECT Id FROM CampaignMember WHERE Campaign.Name = 'Test Campaign'].size());
    }

    @IsTest
    public static void bulkInsertHolidays(){

        List<Lead> leads = new List<Lead>();

        //create 200 leads
        for(Integer i = 0; i<200; i++){
            leads.add(
                    new Lead(
                            LastName      = 'Test ' + i,
                            RecordTypeId  = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Holiday Maker').getRecordTypeId()
                    )
            );
        }

        insert leads;

        List<Holiday_Booking__c> bookings = new List<Holiday_Booking__c>();
        String parkId          = [SELECT Id FROM Park__c WHERE Name = 'Test Park' LIMIT 1].Id;

        //create 200 bookings that are hot
        for(Integer i = 0; i<200; i++){
            bookings.add(
                    new Holiday_Booking__c(
                            Park__c = parkId,
                            Lead__c = leads[i].Id,
                            Hot_Hols_Campaign__c = 1
                    )
            );
        }
        insert bookings;

        System.assertEquals(200, [SELECT Id FROM CampaignMember WHERE Campaign.Name = 'Test Campaign'].size());

    }

    @IsTest
    public static void bulkUpdateHolidays(){

        List<Lead> leads = new List<Lead>();

        //creates 200 leads
        for(Integer i = 0; i<200; i++){
            leads.add(
                    new Lead(
                            LastName      = 'Test ' + i,
                            RecordTypeId  = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Holiday Maker').getRecordTypeId()
                    )
            );
        }

        insert leads;

        List<Holiday_Booking__c> bookings = new List<Holiday_Booking__c>();
        String parkId          = [SELECT Id FROM Park__c WHERE Name = 'Test Park' LIMIT 1].Id;

        //creates 200 bookings that are cold
        for(Integer i = 0; i<200; i++){
            bookings.add(
                    new Holiday_Booking__c(
                            Park__c = parkId,
                            Lead__c = leads[i].Id,
                            Hot_Hols_Campaign__c = 0
                    )
            );
        }
        insert bookings;

        //updating the booking to be hot
        for(Holiday_Booking__c booking :bookings){
            booking.Hot_Hols_Campaign__c = 1;
        }
        update bookings;

        //checks if there's 200 campaign members
        System.assertEquals(200, [SELECT Id FROM CampaignMember WHERE Campaign.Name = 'Test Campaign'].size());

    }
}
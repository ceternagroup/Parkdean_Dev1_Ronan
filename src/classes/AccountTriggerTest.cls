/**********************************************************************************************
* @Author:      Ceterna
* @Date:        
* @Description: Test Class for Account Trigger
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]   
***********************************************************************************************/  
@IsTest
public class AccountTriggerTest {

/**********************************************************************************************
* @Author:      Ceterna
* @Date:        
* @Description: check that the trigger is called and a person account is inserted
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]  
*	22/07/2019	-	E0070	-	Susanna Taylor	-	changed test method to create person account
***********************************************************************************************/    
  @IsTest
    public static void testAccountTrigger() {
        // check the trigger is called, we test the logic through the AccountHandler
        Id customerRtId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId();
        Account a = new Account(recordTypeId=customerRtId);
        a.firstName = 'Test';
        a.lastName = 'Insert';
        Test.setMock(HttpCalloutMock.class, new ODIRequestMock());
        
        Test.startTest();
            insert a;
            a.lastName = 'Update';
            update a;
        Test.stopTest();
        
        System.assertNotEquals(null, a.Id);
    }

}
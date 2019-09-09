/**********************************************************************************************
* @Author:      Susanna Taylor
* @Date:     26/07/2019   
* @Description: Test Class for AccountHandler class
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]   
***********************************************************************************************/  
@IsTest
public class AccountHandlerTest {
/**********************************************************************************************
* @Author:     Susanna Taylor
* @Date:       26/07/2019 
* @Description: insert mobile number in phone field. Assert that mobile and mcMobile are updated
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]  
***********************************************************************************************/    
    public static testMethod void insertMobileAsPhone() {
        // check a mobile format phone number is mapped to mobile
       Test.setMock(HttpCalloutMock.class, new ODIRequestMock());
        Account testAccount = new Account ();
        testAccount.LastName = 'Test';
        testAccount.Phone = '07717';
        test.startTest();
        	insert testAccount;
        test.stopTest();
        Account resultAccount = [SELECT id,
                                	Name,
                                	phone,
                                	PersonMobilePhone,
                                	MC_Contact_Mobile_Phone__pc
                                FROM Account
                                WHERE id =: testAccount.id];
        
        system.assertequals(testAccount.Phone, resultAccount.PersonMobilePhone);
        system.assertEquals('447717', resultAccount.MC_Contact_Mobile_Phone__pc);
    }
    
    /**********************************************************************************************
    * @Author:     Susanna Taylor
    * @Date:       26/07/2019 
    * @Description: insert mobile number in phone field. Assert that mobile and mcMobile are updated
    * @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]  
    ***********************************************************************************************/    
    public static testMethod void insertMobileAsPhone_negative() {
        // check a mobile format phone number does not overwrite existing mobile
       Test.setMock(HttpCalloutMock.class, new ODIRequestMock());
        Account testAccount = new Account ();
        testAccount.LastName = 'Test';
        testAccount.Phone = '07717';
        testAccount.PersonMobilePhone = '07722';
        test.startTest();
        	insert testAccount;
        test.stopTest();
        Account resultAccount = [SELECT id,
                                	Name,
                                	phone,
                                	PersonMobilePhone,
                                	MC_Contact_Mobile_Phone__pc
                                FROM Account
                                WHERE id =: testAccount.id];
        
        system.assertequals(testAccount.PersonMobilePhone, resultAccount.PersonMobilePhone);
        system.assertEquals('447722', resultAccount.MC_Contact_Mobile_Phone__pc);
    }   
    
    /**********************************************************************************************
    * @Author:     Susanna Taylor
    * @Date:       26/07/2019 
    * @Description: update a mobile number and check the mcmobile is updated too
    * @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]  
    ***********************************************************************************************/    
    public static testMethod void updateMobileTest() {
        
       Test.setMock(HttpCalloutMock.class, new ODIRequestMock());
        Account testAccount = new Account ();
        testAccount.LastName = 'Test';
        testAccount.Phone = '07717';
        testAccount.PersonMobilePhone = '07722';
        insert testAccount;
        testAccount.PersonMobilePhone = '07733';
        
        test.startTest();
        	update testAccount;
        test.stopTest();
        
        Account resultAccount = [SELECT id,
                                	Name,
                                	phone,
                                	PersonMobilePhone,
                                	MC_Contact_Mobile_Phone__pc
                                FROM Account
                                WHERE id =: testAccount.id];
        
        system.assertequals(testAccount.PersonMobilePhone, resultAccount.PersonMobilePhone);
        system.assertEquals('447733', resultAccount.MC_Contact_Mobile_Phone__pc);
    }    
    /**********************************************************************************************
    * @Author:     Susanna Taylor
    * @Date:       26/07/2019 
    * @Description: update a mobile number to empty and check the mcmobile is updated too
    * @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]  
    ***********************************************************************************************/    
    public static testMethod void updateMobile_emptytest() {
        
       Test.setMock(HttpCalloutMock.class, new ODIRequestMock());
        Account testAccount = new Account ();
        testAccount.LastName = 'Test';
        testAccount.Phone = '07717';
        testAccount.PersonMobilePhone = '07722';
        insert testAccount;
        testAccount.PersonMobilePhone = '';
        
        test.startTest();
        	update testAccount;
        test.stopTest();
        
        Account resultAccount = [SELECT id,
                                	Name,
                                	phone,
                                	PersonMobilePhone,
                                	MC_Contact_Mobile_Phone__pc
                                FROM Account
                                WHERE id =: testAccount.id];
        
        system.assertequals(null, resultAccount.PersonMobilePhone);
        system.assertEquals(null, resultAccount.MC_Contact_Mobile_Phone__pc);
    }   

    /**********************************************************************************************
    * @Author:     Susanna Taylor
    * @Date:       26/07/2019 
    * @Description: update a mobile number to an invalid number and check the mcmobile is updated too
    * @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]  
    ***********************************************************************************************/    
    public static testMethod void updateMobile_invalidtest() {
        
       Test.setMock(HttpCalloutMock.class, new ODIRequestMock());
        Account testAccount = new Account ();
        testAccount.LastName = 'Test';
        testAccount.Phone = '07717';
        testAccount.PersonMobilePhone = '07722';
        insert testAccount;
        testAccount.PersonMobilePhone = '07722sometext';
        
        test.startTest();
        	update testAccount;
        test.stopTest();
        
        Account resultAccount = [SELECT id,
                                	Name,
                                	phone,
                                	PersonMobilePhone,
                                	MC_Contact_Mobile_Phone__pc
                                FROM Account
                                WHERE id =: testAccount.id];
        
        system.assertequals(testAccount.PersonMobilePhone, resultAccount.PersonMobilePhone);
        system.assertEquals(null, resultAccount.MC_Contact_Mobile_Phone__pc);
    }     
}
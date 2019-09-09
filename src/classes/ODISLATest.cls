@IsTest
public class ODISLATest {

    /**********************************************************************************************
    * @Author:      Ceterna
    * @Date:        
    * @Description: Test Class for ODI SLA call
    * @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description] 
    * 		22/07/2019	-	E0070	-	Susanna Taylor	-	update account "name" to "lastname" to
    * 														create person account
    ***********************************************************************************************/    
  private static Account createAccount() {
    Account acc = new Account();
    acc.lastName = 'Test';
    insert acc;
    return acc;
  }
    
  private static Opportunity createOpp(String accId) {
    Opportunity opp = new Opportunity();
    opp.Name = 'Test Opp';
    opp.CloseDate = Date.today();
    opp.StageName = 'Scoping';
    opp.AccountId = accId;
    String otherTypeId = getRecordTypeId('Other', 'Opportunity');
    opp.RecordTypeId = otherTypeId;
    insert opp;
    return opp;
  }
    
  private static Quote createQuote(String oppId) {
    Quote quote = new Quote();
    quote.Name = 'Test Quote';
    quote.OpportunityId = oppId;   
    quote.Status = 'Paperwork';
    insert quote;
    return quote;
  }
    
  private static Line_Item__c createLineItem(String quoteId, String recordtype) {
    Line_Item__c testLine = new Line_Item__c();
    testLine.Name = 'Test';
    testLine.Quote__c = quoteId;
    testLine.RecordTypeId = getRecordTypeId(recordType, 'Line_Item__c');
    insert testLine;  
    return testLine;
  }
    
  private static String getRecordTypeId(String name, String objName) {
    String recordTypeId = [
      SELECT Id 
      FROM RecordType 
      WHERE SobjectType = :objName
      AND DeveloperName = :name
      LIMIT 1
    ].Id;
    return recordTypeId;
  }
    
  private static String createTestQuote() {
    Account testAccount = createAccount();
    Opportunity testOpp = createOpp(testAccount.Id);
    Quote testQuote = createQuote(testOpp.Id);
    createLineItem(testQuote.Id, 'Product_Line_Item');
    createLineItem(testQuote.Id, 'Ancillary_Line_Item');
    return testQuote.Id;
  }
    
  @IsTest
  private static void testSendSLA() {
    Test.setMock(HttpCalloutMock.class, new ODIRequestMock());
    String quoteId = createTestQuote();
    Test.startTest();
      String res = ODISLA.sendSLA(quoteId);
    Test.stopTest();
    System.assertEquals('Success', res);
  }

}
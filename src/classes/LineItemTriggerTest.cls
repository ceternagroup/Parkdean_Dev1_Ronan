@IsTest
public class LineItemTriggerTest {
    
  private static Park__c createPark() {
    Park__c p = new Park__c();
    p.Name = 'Test Park';
    insert p;
    return p;
  }
    
  private static Opportunity createOpp() {
    Opportunity opp = new Opportunity();
    opp.Name = 'Test Opp';
    opp.CloseDate = Date.today();
    opp.StageName = 'Scoping';
    String otherTypeId = getRecordTypeId('Other', 'Opportunity');
    opp.RecordTypeId = otherTypeId;
    insert opp;
    return opp;
  }
    
  private static Quote createQuote(String oppId, String parkId) {
    Quote quote = new Quote();
    quote.Name = 'Test Quote';
    quote.OpportunityId = oppId;   
    quote.Status = 'Paperwork';
    quote.Park__c = parkId;
    insert quote;
    return quote;
  }
    
  private static Line_Item__c createLineItem(String quoteId, String recordtype) {
    Line_Item__c testLine = new Line_Item__c();
    testLine.Name = 'Test';
    testLine.Quote__c = quoteId;
    testLine.Final_Selection__c = true;
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
    Opportunity testOpp = createOpp();
    Park__c testPark = createPark();
    Quote testQuote = createQuote(testOpp.Id, testPark.Id);
    createLineItem(testQuote.Id, 'Product_Line_Item');
    return testQuote.Id;
  }
    
  @IsTest
  public static void testLineItemTrigger() {
    // check the trigger is called, we test the logic through the LineItemHandler
    Line_Item__c a = new Line_Item__c();
    a.Name = 'Test Insert';
    a.Final_Selection__c = true;
    a.RecordTypeId = getRecordTypeId('Optional_Ancillary_Line_Item', 'Line_Item__c');
    Test.setMock(HttpCalloutMock.class, new ODIRequestMock());
    Test.startTest();
      insert a;
      a.Name = 'Test Update';
      update a;
    Test.stopTest();
    System.assertNotEquals(null, a.Id);
  }
    
  @IsTest 
  public static void testLineItemTriggerItems() {
    Test.setMock(HttpCalloutMock.class, new ODIRequestMock());
    Test.startTest();
      String quoteId = createTestQuote();
    Test.stopTest();
    System.assertNotEquals(null, quoteId);
  }

}
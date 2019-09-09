@IsTest
public class SendSLATest {
    
  private static Opportunity newOpp() {
    Opportunity o = new Opportunity();
    o.Name = 'Test';
    o.RecordTypeId = getRecordTypeId('Other', 'Opportunity');
    o.StageName = 'Open';
    o.CloseDate = Date.today();
    insert o;
    return o;
  }
    
  private static Quote newQuote(Boolean valid, String oppId) {
    Quote q = new Quote();
    q.Name = 'Test';
    q.RecordTypeId = getRecordTypeId('New_Biz', 'Quote');
    q.OpportunityId = oppId;
    q.Status = 'Paperwork';
    if (valid == true) {
      q.Status = 'SLA pending with Wizard';
      q.Expected_handover_date__c = Date.today();
    }
    insert q;
    return q;
  }
    
  private static String getRecordTypeId(String name, String obj) {
    String recordTypeId = [
      SELECT Id 
      FROM RecordType 
      WHERE SobjectType = :obj 
      AND DeveloperName = :name
      LIMIT 1
    ].Id;
    return recordTypeId;
  }
    
  @IsTest
  private static void testCheckQuote() {
    Test.setMock(HttpCalloutMock.class, new ODIRequestMock());
    Opportunity o = newOpp();
    Quote invalidQuote = newQuote(false, o.Id);
    Test.startTest();
      String valid = SendSLA.checkQuote(invalidQuote.Id);
    Test.stopTest();
    system.assertNotEquals('Ready', valid);
  }
    
  @IsTest
  private static void testSendQuote() {
    Test.setMock(HttpCalloutMock.class, new ODIRequestMock());
    Opportunity o = newOpp();
    Quote q = newQuote(true, o.Id);
    Test.startTest();
      String res = SendSLA.sendQuote(q.Id);
    Test.stopTest();
    System.assertNotEquals(null, res);
  }

}
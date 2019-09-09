@IsTest
public class FindPXUnitTest {
    
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
    
  private static Quote createQuote(String oppId) {
    Quote quote = new Quote();
    quote.Name = 'Test Quote';
    quote.OpportunityId = oppId;   
    quote.Status = 'Paperwork';
    insert quote;
    return quote;
  }
    
  @IsTest
  public static void testGetUnits() {
    Test.setMock(HttpCalloutMock.class, new ODIRequestMock());
    Test.startTest();
      List<Inbound_PX_unit__c> units = FindPXUnit.getUnits('2008', 'ABI');
    Test.stopTest();
    System.assertEquals(0, units.size());
  }
    
  @IsTest
  public static void testSaveUnits() {
    Opportunity testOpp = createOpp();
    Quote testQuote = createQuote(testOpp.Id);
    Inbound_PX_unit__c unit = new Inbound_PX_unit__c();
    unit.Name = 'Test';
    Test.startTest();
      String checkInsert = FindPXUnit.saveUnits(testQuote.Id, unit);
    Test.stopTest();
    System.assertEquals('Success', checkInsert);
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

}
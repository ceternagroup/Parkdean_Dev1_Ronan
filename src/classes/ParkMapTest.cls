@IsTest
public class ParkMapTest {
    
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
    
  @IsTest
  public static void testGetMap() {
    Opportunity o = createOpp();
    Quote q = createQuote(o.Id);
    String park = ParkMap.getMap(q.Id);
    System.assertEquals(q.Map_Image_URL__c, park);
  }

}
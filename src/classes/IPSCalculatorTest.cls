@IsTest
public class IPSCalculatorTest {
    
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
    
  private static Line_Item__c createLineItem(String quoteId) {
    Line_Item__c testLine = new Line_Item__c();
    testLine.Name = 'Test';
    testLine.Quote__c = quoteId;
    testLine.RecordTypeId = getRecordTypeId('Product_Line_Item', 'Line_Item__c');
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
    createLineItem(testQuote.Id);
    return testQuote.Id;
  }
    
  @IsTest
  public static void testGetRules() {
    String quoteId = createTestQuote();
    List<Price_Rule__c> rules = IPSCalculator.getRules(quoteId);
    System.assertEquals(0, rules.size());
  }
    
  @IsTest
  public static void testGetFeatures() {
    String quoteId = createTestQuote();
    List<Park_Feature__c> features = IPSCalculator.getFeatures(quoteId);
    System.assertEquals(0, features.size());
  }
    
  @IsTest
  public static void testGetProducts() {
    String quoteId = createTestQuote();
    List<Line_Item__c> products = IPSCalculator.getProducts(quoteId);
    System.assertEquals(1, products.size());
  }
    
  @IsTest
  public static void testGetQuote() {
    String quoteId = createTestQuote();
    Quote getQuote = IPSCalculator.getQuote(quoteId);
    System.assertEquals(quoteId, getQuote.Id);
  }
    
  @IsTest
  public static void testGetItems() {
    String quoteId = createTestQuote();
    List<IPS_Line_Item__c> items = IPSCalculator.getItems(quoteId);
    System.assertEquals(0, items.size());
  }
    
  @IsTest
  public static void testSaveIPSItems() {
    String quoteId = createTestQuote();
    List<Line_Item__c> products = IPSCalculator.getProducts(quoteId);
    List<IPS_Line_Item__c> lines = new List<IPS_Line_Item__c>();
    List<IPS_Day__c> days = new List<IPS_Day__c>();
    String res1 = IPSCalculator.saveIPSItems(JSON.serialize(lines), JSON.serialize(days), quoteId, products);
    String res2 = IPSCalculator.saveIPSItems('INVALID JSON', 'INVALID JSON', quoteId, products);
    System.assertEquals('Success', res1);
    System.assertNotEquals('Success', res2);
  }

}
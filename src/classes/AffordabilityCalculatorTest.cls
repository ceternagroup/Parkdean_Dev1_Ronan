@IsTest
public class AffordabilityCalculatorTest {
    
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
  public static void testGetPrice() {
    Opportunity testOpp = createOpp();
    Quote testQuote = createQuote(testOpp.Id);
    Form__c testForm = new Form__c();
    testForm.Sales_Example__c = testQuote.Id;
    insert testForm;
    Line_Item__c testLine = new Line_Item__c();
    testLine.Name = 'Test';
    testLine.Quote__c = testQuote.Id;
    testLine.RecordTypeId = getRecordTypeId('Product_Line_Item', 'Line_Item__c');
    insert testLine;
    Map<String, sObject> quotePrice = AffordabilityCalculator.getPrice(testQuote.Id);
    Map<String, sObject> formPrice = AffordabilityCalculator.getPrice(testForm.Id);
    Map<String, sObject> linePrice = AffordabilityCalculator.getPrice(testLine.Id);
    System.assertNotEquals(null, quotePrice);
    System.assertNotEquals(null, formPrice);
    System.assertNotEquals(null, linePrice);
  }
    
  @IsTest
  public static void testSaveCalculation() {
    Opportunity testOpp = createOpp();
    Quote testQuote = createQuote(testOpp.Id);
    Calculator__c testCalculation = new Calculator__c();
    testCalculation.Amount_To_Borrow__c = 10000;
    testCalculation.Quote__c = testQuote.Id;
    AffordabilityCalculator.saveCalculation(testCalculation);
    Calculator__c checkCalculation = new Calculator__c();
    checkCalculation = [
      SELECT Id, Opportunity__c
      FROM Calculator__c
      WHERE Quote__c = :testQuote.Id
      LIMIT 1
    ];
    System.assertEquals(testOpp.Id, checkCalculation.Opportunity__c);
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
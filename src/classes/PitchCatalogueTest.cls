@IsTest
public class PitchCatalogueTest {
    
  private static Opportunity newOpp() {
    Opportunity o = new Opportunity();
    o.Name = 'Test';
    o.RecordTypeId = getRecordTypeId('Other', 'Opportunity');
    o.StageName = 'Open';
    o.CloseDate = Date.today();
    insert o;
    return o;
  }
    
  private static Quote newQuote(String oppId) {
    Quote q = new Quote();
    q.Name = 'Test';
    q.RecordTypeId = getRecordTypeId('New_Biz', 'Quote');
    q.OpportunityId = oppId;
    q.Status = 'Paperwork';
    insert q;
    return q;
  }
    
  private static Product2 createProduct() {
    Product2 product = new Product2();
    product.Name = 'Test Product';
    product.IsActive = true;
    product.Suitable_for_retail__c = 'Yes';
    insert product;
    return product;
  }
    
  private static Line_Item__c createItem(String quoteId) {
    Product2 product = createProduct();
    Line_Item__c item = new Line_Item__c();
    item.Name = 'Test Item';
    item.Quote__c = quoteId;
    item.RecordTypeId = getRecordTypeId('Product_Line_Item', 'Line_Item__c');
    item.Product__c = product.Id;
    insert item;
    return item;
  } 
    
  private static Line_Item__c createShellItem(String quoteId) {
    Product2 product = createProduct();
    Line_Item__c item = new Line_Item__c();
    item.Name = 'Test Item';
    item.Quote__c = quoteId;
    item.RecordTypeId = getRecordTypeId('Pitch_Line_Items', 'Line_Item__c');
    item.Product__c = product.Id;
    return item;
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
  private static void testGetCatalogue() {
    Test.setMock(HttpCalloutMock.class, new ODIRequestMock());
    Test.startTest();
      String res = PitchCatalogue.getCatalogue('', '', '', '');
    Test.stopTest();
    System.assertNotEquals(null, res);
  }
    
  @IsTest
  private static void testCheckProduct() {
    Opportunity o = newOpp();
    Quote q = newQuote(o.Id);
    Test.startTest();
      Boolean pass = PitchCatalogue.checkProduct(q.Id);
    Test.stopTest();
    System.assertEquals(false, pass);
  }
    
  @IsTest
  private static void testGetSelected() {
    Opportunity o = newOpp();
    Quote q = newQuote(o.Id);
    Test.startTest();
      List<Line_Item__c> items = PitchCatalogue.getSelected(q.Id, null);
    Test.stopTest();
    System.assertEquals(0, items.size());
  }
    
  @IsTest
  private static void testUpdateSelected() {
    Opportunity o = newOpp();
    Quote q = newQuote(o.Id);
    List<Line_Item__c> items = new List<Line_Item__c>();
    Line_Item__c l1 = createItem(q.Id);
    Line_Item__c l2 = createShellItem(q.Id);
    items.add(l2);
    Test.startTest();
      String res = PitchCatalogue.updateSelected(q.Id, JSON.serialize(items));
    Test.stopTest();
    System.assertEquals('Success', res);
  }
    
  @IsTest
  private static void testGetQuote() {
    Opportunity o = newOpp();
    Quote q = newQuote(o.Id);
    Test.startTest();
      Quote res = PitchCatalogue.getQuote(q.Id);
    Test.stopTest();
    System.assertEquals(q.Id, res.Id);
  }
    
  @IsTest
  private static void testCheckAncillaries() {
    Test.setMock(HttpCalloutMock.class, new ODIRequestMock());
    Opportunity o = newOpp();
    Quote q = newQuote(o.Id);
    Test.startTest();
      String res = PitchCatalogue.checkAncillaries(q.Id, true);
    Test.stopTest();
    System.assertEquals('Success', res);
  }

}
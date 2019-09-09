@IsTest
public class ProductCatalogueTest {
    
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
    
  private static Park__c createPark() {
    Park__c park = new Park__c();
    park.Name = 'Test Park';
    insert park;
    return park;
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
    item.RecordTypeId = getRecordTypeId('Product_Line_Item', 'Line_Item__c');
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
    Park__c park = createPark();
    Line_Item__c item = createItem(null);
    Test.startTest();
      Map<String, List<sObject>> catalogue1 = ProductCatalogue.getCatalogue(park.Id, null);
      Map<String, List<sObject>> catalogue2 = ProductCatalogue.getCatalogue(null, item.Id);
    Test.stopTest();
    System.assertNotEquals(null, catalogue1);
    System.assertNotEquals(null, catalogue2);
  }
    
  @IsTest
  private static void testGetSelected() {
	Opportunity o = newOpp();
    Quote q = newQuote(o.Id);
    Line_Item__c item = createItem(q.Id);
    Test.startTest();
      List<Line_Item__c> items = ProductCatalogue.getSelected(q.Id);
    Test.stopTest();
    System.assertEquals(item.Id, items[0].Id);
  }
    
  @IsTest
  private static void testUpdateSelected() {
	Opportunity o = newOpp();
    Quote q = newQuote(o.Id);
    List<Line_Item__c> items = new List<Line_Item__c>();
    Line_Item__c item1 = createShellItem(q.Id);
    Line_Item__c item2 = createItem(q.Id);
    items.add(item1);
    Test.startTest();
      String res = ProductCatalogue.updateSelected(q.Id, JSON.serialize(items));
    Test.stopTest();
    System.assertEquals('Success', res);
  }
    
  @IsTest
  private static void testGetQuote() {
	Opportunity o = newOpp();
    Quote q = newQuote(o.Id);
    Test.startTest();
      Quote res = ProductCatalogue.getQuote(q.Id);
    Test.stopTest();
    System.assertEquals(q.Id, res.Id);
  }
    
  @IsTest
  private static void testGetProduct() {
    Product2 product = createProduct();
    Test.startTest();
      Product2 res = ProductCatalogue.getProduct(product.Id);
    Test.stopTest();
    System.assertEquals(product.Id, res.Id);
  }

}
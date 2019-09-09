@IsTest
public class StockItemFinalTest {
    
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
  public static void testUpdateItem() {
    Line_Item__c l = new Line_Item__c();
    l.Name = 'Test';
    l.RecordTypeId = getRecordTypeId('Optional_Ancillary_Line_Item', 'Line_Item__c');
    insert l;
    Test.startTest();
      String change = StockItemFinal.updateItem(l.Id);
    Test.stopTest();
    Line_Item__c u = [
      SELECT Id, Final_Selection__c
      FROM Line_Item__c
      WHERE Id = :l.Id
    ];
    System.assertEquals('Success', change);
    System.assertEquals(true, u.Final_Selection__c);
  }

}
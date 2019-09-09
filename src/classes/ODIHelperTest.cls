@IsTest
public class ODIHelperTest {
    
  @IsTest
  private static void testDirectUpsert() {
    Test.setMock(HttpCalloutMock.class, new ODIRequestMock());
    List<Batch_Log__c> logs = new List<Batch_Log__c>();
    for (Integer i = 0; i < 100; i++) {
      Batch_Log__c log = new Batch_Log__c();
      log.Object_Type__c = 'TEST';
      log.Job_Id__c = 'TEST_CLASS_LOG_' + i;
      logs.add(log);
    }
    Test.startTest();
      ODIHelper.ReadWrite rw = ODIHelper.handleRecords(logs, 'Job_Id__c', 'UPSERT', 'Batch_Log__c', Batch_Log__c.Fields.Job_Id__c, 9001, 1);
    Test.stopTest();
    System.assertNotEquals(null, rw);
    List<Batch_Log__c> res = [
      SELECT Id
      FROM Batch_Log__c
      WHERE Job_Id__c LIKE 'TEST_CLASS_LOG%'
    ];
    System.assertEquals(100, res.size());
  }
    
  @IsTest
  private static void testBatchUpsert() {
    Test.setMock(HttpCalloutMock.class, new ODIRequestMock());
    List<Batch_Log__c> logs = new List<Batch_Log__c>();
    for (Integer i = 0; i < 500; i++) {
      Batch_Log__c log = new Batch_Log__c();
      log.Object_Type__c = 'TEST';
      log.Job_Id__c = 'TEST_CLASS_LOG_' + i;
      logs.add(log);
    }
    Test.startTest();
      ODIHelper.ReadWrite rw = ODIHelper.handleRecords(logs, 'Job_Id__c', 'UPSERT', 'Batch_Log__c', Batch_Log__c.Fields.Job_Id__c, 9001, 1);
    Test.stopTest();
    System.assertNotEquals(null, rw);
    List<Batch_Log__c> res = [
      SELECT Id
      FROM Batch_Log__c
      WHERE Job_Id__c LIKE 'TEST_CLASS_LOG%'
    ];
    System.assertEquals(100, res.size());
  }
    
  @IsTest
  private static void testDirectDelete() {
    Test.setMock(HttpCalloutMock.class, new ODIRequestMock());
    List<Batch_Log__c> logs = new List<Batch_Log__c>();
    for (Integer i = 0; i < 100; i++) {
      Batch_Log__c log = new Batch_Log__c();
      log.Object_Type__c = 'TEST';
      log.Job_Id__c = 'TEST_CLASS_LOG_' + i;
      logs.add(log);
    }
    insert logs;
    Test.startTest();
      ODIHelper.ReadWrite rw = ODIHelper.handleRecords(logs, 'Job_Id__c', 'DELETE', 'Batch_Log__c', Batch_Log__c.Fields.Job_Id__c, 9001, 1);
    Test.stopTest();
    System.assertNotEquals(null, rw);
    List<Batch_Log__c> res = [
      SELECT Id
      FROM Batch_Log__c
      WHERE Job_Id__c LIKE 'TEST_CLASS_LOG%'
    ];
    System.assertEquals(0, res.size());
  }
    
  @IsTest
  private static void testBatchDelete() {
    Test.setMock(HttpCalloutMock.class, new ODIRequestMock());
    List<Batch_Log__c> logs = new List<Batch_Log__c>();
    for (Integer i = 0; i < 500; i++) {
      Batch_Log__c log = new Batch_Log__c();
      log.Object_Type__c = 'TEST';
      log.Job_Id__c = 'TEST_CLASS_LOG_' + i;
      logs.add(log);
    }
    insert logs;
    Test.startTest();
      ODIHelper.ReadWrite rw = ODIHelper.handleRecords(logs, 'Job_Id__c', 'DELETE', 'Batch_Log__c', Batch_Log__c.Fields.Job_Id__c, 9001, 1);
    Test.stopTest();
    System.assertNotEquals(null, rw);
    List<Batch_Log__c> res = [
      SELECT Id
      FROM Batch_Log__c
      WHERE Job_Id__c LIKE 'TEST_CLASS_LOG%'
    ];
    System.assertEquals(400, res.size());
  }

}
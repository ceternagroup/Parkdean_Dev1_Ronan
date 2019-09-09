@IsTest
public class ODIBatchTest {
    
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
      Id jobId = Database.executeBatch(new ODIBatch(logs, 'UPSERT', 'Batch_Log__c', Batch_Log__c.Fields.Job_Id__c, 9001, 'Job_Id__c', 1), 500);
    Test.stopTest();
    System.assertNotEquals(null, jobId);
    List<Batch_Log__c> res = [
      SELECT Id
      FROM Batch_Log__c
      WHERE Job_Id__c LIKE 'TEST_CLASS_LOG%'
    ];
    System.assertEquals(500, res.size());
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
      Id jobId = Database.executeBatch(new ODIBatch(logs, 'DELETE', 'Batch_Log__c', Batch_Log__c.Fields.Job_Id__c, 9001, 'Job_Id__c', 1), 500);
    Test.stopTest();
    System.assertNotEquals(null, jobId);
    List<Batch_Log__c> res = [
      SELECT Id
      FROM Batch_Log__c
      WHERE Job_Id__c LIKE 'TEST_CLASS_LOG%'
    ];
    System.assertEquals(0, res.size());
  }

}
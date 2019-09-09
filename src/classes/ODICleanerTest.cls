@IsTest
public class ODICleanerTest {
    
  @IsTest
  public static void testCleaner() {
    Test.startTest();
      ODICleanerScheduler.runSchedule('Test Scheduler');
    Test.stopTest();
  }
    
  @IsTest
  public static void testRunCleaner() {
    Batch_Log__c log = new Batch_Log__c();
    log.Object_Type__c = 'TEST'; 
    insert log;
    Test.startTest();
      ODICleaner.runCleaner('SELECT Id FROM Batch_Log__c WHERE Object_Type__c = \'TEST\'');
    Test.stopTest();
    List<Batch_Log__c> remaining = [
      SELECT Id
      FROM Batch_Log__c
      WHERE Object_Type__c = 'TEST'
    ];
    System.assertEquals(0, remaining.size());
  }

}
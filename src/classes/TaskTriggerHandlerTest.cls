@IsTest
public class TaskTriggerHandlerTest {
    
  private static Contact newContact(String ownerId) {
    Contact c = new Contact();
    c.Salutation = 'Mr';
    c.FirstName = 'Test';
    c.LastName = 'Test';
    c.OwnerId = ownerId;
    insert c;
    return c;
  }
    
  private static Lead newLead(String ownerId) {
    Lead l = new Lead();
    l.Salutation = 'Mr';
    l.FirstName = 'Test';
    l.LastName = 'Test';
    l.OwnerId = ownerId;
    insert l;
    return l;
  }
    
  private static Task newTask(String whoId, String recordTypeId) {
    Task t = new Task();
    t.Subject = 'Test';
    t.RecordTypeId = recordTypeId;
    t.WhoId = whoId;
    return t;
  }
    
  @IsTest
  private static void testTaskTrigger() {
    Test.setMock(HttpCalloutMock.class, new ODIRequestMock());
    String userId = UserInfo.getUserId();
    Contact c = newContact(userId);
    Lead l = newLead(userId);
    String recordTypeId = getRecordTypeId('Enquiry', 'Task');
    Task t1 = newTask(c.Id, recordTypeId);
    Task t2 = newTask(l.Id, recordTypeId);
    Test.startTest();
      insert t1;
      insert t2;
    Test.stopTest();
    System.assertNotEquals(null, t1.Id);    
    System.assertNotEquals(null, t2.Id);
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

}
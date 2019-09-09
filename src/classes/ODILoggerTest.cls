/*
 * @class ODILoggerTest
 * @desc - Test classes for ODILogger
 */
@IsTest
public class ODILoggerTest {
    
  @IsTest
  public static void testSendLog() {
    Test.setMock(HttpCalloutMock.class, new ODIRequestMock());
    ODILogger.sendLog('testSendLog()', 'Test Send');
  }
    
  @IsTest
  public static void testCreateLog() {
    ODILogger.Log l = ODILogger.createLog('testSendLog()', 'Test Send');
    System.assertEquals(l.method, 'testSendLog()'); 
    System.assertEquals(l.text, 'Test Send');
  }

}
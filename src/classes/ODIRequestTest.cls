/*
 * @class ODIRequestTest
 * @desc - Test classes for ODIRequest
 */
@IsTest
public class ODIRequestTest {
    
  
    
  @IsTest
  public static void testSendRequest() {
    Test.setMock(HttpCalloutMock.class, new ODIRequestMock());
    Map<String, Object> testParams = new Map<String, Object>();
    Test.startTest();
      String res = ODIRequest.sendRequest('saf.get.test', testParams);
    Test.stopTest();
    System.assertNotEquals(null, res);
  }
    
  @IsTest
  public static void testSendFutureRequest() {
    Test.setMock(HttpCalloutMock.class, new ODIRequestMock());
    Test.startTest();
      ODIRequest.sendFutureRequest('saf.get.test', '{}');
    Test.stopTest();
  }
    
  @IsTest
  public static void testSendPitchRequest() {
    Test.setMock(HttpCalloutMock.class, new ODIRequestMock());
    Test.startTest();
      String res = ODIRequest.sendPitchRequest('TEST_VAN', 'TEST_PARK', 'TEST_OCCUPANCY', 'ACCOUNT_ID');
    Test.stopTest();
    System.assertNotEquals(null, res);
  }
    
  @IsTest
  public static void testSendPXRequest() {
    Test.setMock(HttpCalloutMock.class, new ODIRequestMock());
    Test.startTest();
      String res = ODIRequest.sendPXRequest('1990', 'TEST_MAKE');
    Test.stopTest();
    System.assertNotEquals(null, res);
  }
    
  @IsTest
  public static void testSendSLARequest() {
    Test.setMock(HttpCalloutMock.class, new ODIRequestMock());
    Map<String, Object> sla = new Map<String, Object>();
    Test.startTest();
      String res = ODIRequest.sendSLARequest(sla);
    Test.stopTest();
    System.assertNotEquals(null, res);
  }
    
  @IsTest
  public static void testSendAncRequest() {
    Test.setMock(HttpCalloutMock.class, new ODIRequestMock());
    Test.startTest();
      String res = ODIRequest.sendAncRequest('TEST_VAN', 'TEST_SALE', 'TEST_PITCH', 'TEST_OCCUPANCY', 'ACCOUNT_ID', 'TEST_OWNER', 'TEST_PEX');
    Test.stopTest();
    System.assertNotEquals(null, res);
  }
    
}
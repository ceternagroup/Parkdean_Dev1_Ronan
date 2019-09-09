@IsTest
public class ODIQueryTest {
    
  @IsTest
  public static void testDoPost() {
    Test.setMock(HttpCalloutMock.class, new ODIRequestMock());
    RestRequest req = new RestRequest();
    req.requestBody = Blob.valueOf('SELECT Id FROM Lead LIMIT 10');
    RestContext.request = req;
    Test.startTest();
      String res = ODIQuery.doPost();
      System.debug(res);
    Test.stopTest();
    // we test main logic through the helper and batch tests
    // this is purely testing our requests go through successfully
    System.assertNotEquals(null, res);
  }

}
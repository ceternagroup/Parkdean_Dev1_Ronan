@IsTest
public class ODIConvertTest {
    
  @IsTest
  public static void testDoPost() {
    Test.setMock(HttpCalloutMock.class, new ODIRequestMock());
    Lead l = new Lead();
    l.LastName = 'Test';
    l.Street = '20 New Road';
    l.Country = 'UK';
    l.PostalCode = 'ME12';
    l.City = 'Minster';
    l.LeadSource = 'Digital - Direct';
    l.Lead_source_Level_2__c = 'TV';
    insert l;
    RestRequest req = new RestRequest();
    req.requestBody = Blob.valueOf('["' + l.Id + '"]');
    RestContext.request = req;
    Test.startTest();
      String res = ODIConvert.doPost();
      System.debug(res);
    Test.stopTest();
    // we test main logic through the helper and batch tests
    // this is purely testing our requests go through successfully
    System.assertNotEquals(null, res);
  }

}
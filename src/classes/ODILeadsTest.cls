@IsTest
public class ODILeadsTest {
    
  @IsTest
  public static void testDoPostLead() {
    Test.setMock(HttpCalloutMock.class, new ODIRequestMock());
    RestRequest req = new RestRequest();
    // lead
    req.requestBody = Blob.valueOf('{"Control":{"Changes":0,"LastChangeSyncSetId":1,"LinkSystem":"Test","Schema":null,"Model":"Test","NewSyncSetID":9001,"OwnerSchemeFeed":"Test"},"Errors":[],"Elements":[{"Element":{"PrimaryId":1706809018,"LeadId":null,"ContactId":null,"AccountId":null,"Salutation":"Mrs","FirstName":"S","LastName":"Chittock","Street":"6 Dalmatia Road","PostalCode":"SS12QQ","Country":"United Kingdom","Email":"","MobilePhone":"07702862997","IsOwner":false,"Compliance":[{"Preference":"Holidays","Methods":[{"Method":"Email","OptIn":null},{"Method":"Post","OptIn":null},{"Method":"SMS","OptIn":null},{"Method":"Telephone","OptIn":null}]},{"Preference":"Sales","Methods":[{"Method":"Email","OptIn":null},{"Method":"Post","OptIn":null},{"Method":"SMS","OptIn":null},{"Method":"Telephone","OptIn":null}]}]},"IsCreate":1,"IsUpdate":0,"IsDelete":0,"LinkID":0,"SyncItemID":0}]}');
    RestContext.request = req;
    Test.startTest();
      Response res = (Response) JSON.deserialize(ODILeads.doPost(), Response.class);
      System.debug(res);
    Test.stopTest();
    // we test main logic through the helper and batch tests
    // this is purely testing our requests go through successfully
    System.assertNotEquals(null, res);
  }
    
  @IsTest
  public static void testDoPostContact() {
    Test.setMock(HttpCalloutMock.class, new ODIRequestMock());
    RestRequest req = new RestRequest();
    // lead
    req.requestBody = Blob.valueOf('{"Control":{"Changes":0,"LastChangeSyncSetId":1,"LinkSystem":"Test","Schema":null,"Model":"Test","NewSyncSetID":9001,"OwnerSchemeFeed":"Test"},"Errors":[],"Elements":[{"Element":{"PrimaryId":1706834034,"LeadId":null,"ContactId":null,"AccountId":null,"Salutation":"Mrs","FirstName":"S","LastName":"Chittock","Street":"6 Dalmatia Road","PostalCode":"SS12QQ","Country":"United Kingdom","Email":"","MobilePhone":"07702862997","IsOwner":true,"Compliance":[{"Preference":"Holidays","Methods":[{"Method":"Email","OptIn":true},{"Method":"Post","OptIn":true},{"Method":"SMS","OptIn":true},{"Method":"Telephone","OptIn":true}]},{"Preference":"Sales","Methods":[{"Method":"Email","OptIn":null},{"Method":"Post","OptIn":null},{"Method":"SMS","OptIn":null},{"Method":"Telephone","OptIn":null}]}]},"IsCreate":1,"IsUpdate":0,"IsDelete":0,"LinkID":0,"SyncItemID":0}]}');
    RestContext.request = req;
    Test.startTest();
      Response res = (Response) JSON.deserialize(ODILeads.doPost(), Response.class);
      System.debug(res);
    Test.stopTest();
    // we test main logic through the helper and batch tests
    // this is purely testing our requests go through successfully
    System.assertNotEquals(null, res);
  }
    
  public class Response {
    public String DataType;
    public List<ReadWrite> ReadWrites;
  }
  
  public class ReadWrite {
    public List<String> Errors;
    public String Name;
    public String newSyncSetId;
  }

}
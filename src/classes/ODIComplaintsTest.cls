@IsTest
public class ODIComplaintsTest {
    
  @IsTest
  public static void testDoPost() {
    RestRequest req = new RestRequest();
    req.requestBody = Blob.valueOf('{"Control":{"Changes":0,"LastChangeSyncSetId":1,"LinkSystem":"Test","Schema":null,"Model":"Test","NewSyncSetID":9001,"OwnerSchemeFeed":"Test"},"Errors":[],"Elements":[{"Element":{"ComplaintID":1,"DateCreated":"2017-07-12T13:26:00","Method":"Reevoo","Category":"Food and Beverage","SubCategory":"Availability of Stock","Status":"Resolved","TotalGoodwillGiven":4,"Links":[{"ComplaintLinkID":1,"PrimaryId":null,"LeadID":null,"ContactID":null,"ClientID":4242249,"BookingID":null},{"ComplaintLinkID":2,"PrimaryId":null,"LeadID":null,"ContactID":null,"ClientID":null,"BookingID":6146766}]},"IsCreate":1,"IsUpdate":0,"IsDelete":0,"LinkID":0,"SyncItemID":0}]}');
    RestContext.request = req;
    Test.startTest();
      Response res = (Response) JSON.deserialize(ODIComplaints.doPost(), Response.class);
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
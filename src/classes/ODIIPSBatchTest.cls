@IsTest
public class ODIIPSBatchTest {
    
  @IsTest
  public static void testDoPost() {
    RestRequest req = new RestRequest();
    req.requestBody = Blob.valueOf('{"Control":{"Changes":0,"LastChangeSyncSetId":1,"LinkSystem":"Test","Schema":null,"Model":"Test","NewSyncSetID":9001,"OwnerSchemeFeed":"Test"},"Errors":[],"Elements":[{"Element":{"SchemeID":1,"SchemeName":"IPS","SupplierID":1,"ParkID":"a041t000005rmVf","Rules":[{"MinimumOfX":0,"DatesFrom":"2019-03-08T00:00:00","DatesTo":"2019-03-11T00:00:00","Options":0},{"MinimumOfX":8,"DatesFrom":"2019-01-01T00:00:00","DatesTo":"2019-12-31T00:00:00","Options":0},{"MinimumOfX":4,"DatesFrom":"2019-07-21T00:00:00","DatesTo":"2019-08-31T00:00:00","Options":1}],"Services":[{"ServiceID":67,"Breaks":[{"DateFrom":"2019-10-25T00:00:00","Duration":3,"Percentage":0.35,"Vat":1.2,"Peak":1,"Price":0,"Active":1},{"DateFrom":"2019-10-28T00:00:00","Duration":4,"Percentage":0.25,"Vat":1.2,"Peak":0,"Price":0,"Active":1}]}]},"IsCreate":1,"IsUpdate":0,"IsDelete":0,"LinkID":0,"SyncItemID":0}]}');
    RestContext.request = req;
    Test.startTest();
      Response res = (Response) JSON.deserialize(ODIIPSBatch.doPost(), Response.class);
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
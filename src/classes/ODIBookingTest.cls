@IsTest
public class ODIBookingTest {
    
  @IsTest
  public static void testDoPost() {
    RestRequest req = new RestRequest();
    req.requestBody = Blob.valueOf('{"Control":{"Changes":0,"LastChangeSyncSetId":1,"LinkSystem":"Test","Schema":null,"Model":"Test","NewSyncSetID":9001,"OwnerSchemeFeed":"Test"},"Errors":[],"Elements":[{"Element":{"PrimaryId":283211,"LeadID":null,"ContactID":null,"ParkID":"a051X000000FmL3","ID":516726,"BookingID":2403838,"ClientID":2130221,"BookingTypeID":600,"SupplierID":18,"SupplierTypeName":"Touring","ServiceTypeName":"Caravan","BookingTypeName":"Standard","AgentName":"Direct","BookingDepart":"2017-08-26T00:00:00","BookingNights":7,"BookingGross":50.75,"ReevooParkScore":null,"ReevooAccomScore":null,"HotHolsCampaign":null,"Adults":2,"Teenagers":0,"Children":1,"Infants":1},"IsCreate":1,"IsUpdate":0,"IsDelete":0,"LinkID":0,"SyncItemID":0}]}');
    RestContext.request = req;
    Test.startTest();
      Response res = (Response) JSON.deserialize(ODIBooking.doPost(), Response.class);
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
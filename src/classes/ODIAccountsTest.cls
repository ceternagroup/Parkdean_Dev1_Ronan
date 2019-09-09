@IsTest
public class ODIAccountsTest {
    
  @IsTest
  public static void testDoPost() {
    RestRequest req = new RestRequest();
    req.requestBody = Blob.valueOf('{"Control":{"Changes":0,"LastChangeSyncSetId":1,"LinkSystem":"Test","Schema":null,"Model":"Test","NewSyncSetID":9001,"OwnerSchemeFeed":"Test"},"Errors":[],"Elements":[{"Element":{"ACCOUNT_ID":1,"AccountId":"0011X000006Y8DLQA0","OWNER_ID":1,"LIMBO_YN":true,"PRE_COBRA_TENURE_END_DT":null,"PITCH_ID":null,"PITCH_NO":null,"PITCH_TYPE_ENUM":null,"PITCH_TYPE_DESC":null,"PITCH_STATUS_ENUM":null,"PITCH_STATUS_CODE":null,"PARK_ID":null,"PAZP":null,"AREA_DESC":null,"ZONE_DESC":null,"SERIAL_NO":null,"VAN_TYPE_ENUM":null,"VAN_TYPE_DESC":null,"YEAR_MADE":null,"WIDTH":null,"LENGTH":null,"GUIDE_COST_RETAIL":null,"Sales":[{"ACCOUNT_ID":1,"SALE_ID":4111,"VAN_ID":16619,"CSI_NO":"VA0126","POSTING_DATE":"2006-11-29T00:00:00","SALE_TYPE_ENUM":15,"SALE_STATUS_ENUM":3,"DATE_SOLD":"2006-11-25T13:51:37.233","QUALIFYING_DT":null,"EXPECTED_VALIDATION_DT":null,"VALIDATION_DATE":"2006-11-29T00:00:00","COMPLETION_DATE":"2006-12-15T00:00:00","CANCELLATION_DATE":null,"REASON_CANCELLED_ID":null,"EXPECTED_DT_OCCUPANCY":"2006-12-04T00:00:00","ACTUAL_DT_OCCUPANCY":"2006-12-04T00:00:00","SALESMAN":"RM","FINANCE_AMOUNT":9362.32,"GLB_AMOUNT":1500,"RL_AMOUNT":0,"SUBLET_AMOUNT":0,"DEPOSIT_AMOUNT":500,"DEPOSIT_DUE_DATE":"2006-11-25T13:51:37.233","NET_SALES_VALUE":0,"GROSS_PRICE_TOTAL":13362.32,"TENURE_END_DT":null,"DESTINATION_PITCH_ID":null,"DESTINATION_PITCH_NO":null,"PITCH_TYPE_ENUM":null,"PITCH_TYPE_DESC":null,"PITCH_STATUS_ENUM":null,"PITCH_STATUS_CODE":null,"PARK_ID":null,"PAZP":null,"AREA_DESC":null,"ZONE_DESC":null,"SALE_TYPE_CODE":"CU","SALE_TYPE_DESC":"Current Owner, Used Van","SALE_STATUS_CODE":"C","SALE_STATUS_DESC":"Completed","REASON_CANCELLED_CODE":null,"REASON_CANCELLED_DESC":null,"SERIAL_NO":null,"VAN_TYPE_ENUM":null,"VAN_TYPE_DESC":null,"YEAR_MADE":null,"WIDTH":null,"LENGTH":null}]},"IsCreate":1,"IsUpdate":0,"IsDelete":0,"LinkID":0,"SyncItemID":0}]}');
    RestContext.request = req;
    Test.startTest();
      Response res = (Response) JSON.deserialize(ODIAccounts.doPost(), Response.class);
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
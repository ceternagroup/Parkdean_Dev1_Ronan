@isTest
public class ODIStockBatchTest {
    
  @isTest
  public static void testDoPost() {
    RestRequest req = new RestRequest();
    req.requestBody = Blob.valueOf('{"Control":{"Changes":0,"LastChangeSyncSetId":1,"LinkSystem":"Test","Schema":null,"Model":"Test","NewSyncSetID":9001,"OwnerSchemeFeed":"Test"},"Errors":[],"Elements":[{"Element":{"ParkID":"a051X000000FmLD","Policy":{"FinanceAllowed":false,"FinanceMaxTerm":0,"FinanceMinDeposit":0},"ServiceName":null,"VAN_ID":74,"VAN_STOCK_NO":"VA0442","PARK_ID":31,"PARK_CODE":"VA","PARK_SHORT_DESC":"Valley Farm","MAKE":"Willerby","MODEL":"Granada","LENGTH":35,"WIDTH":12,"YEAR_MADE":1992,"DG":"No","CH":"No","NEWUSED":"Used","VAN_COLOUR_DESC":null,"NUMBER_BEDROOMS":2,"VAN_SOURCE_DESC":"Buy-In","VAN_PRICE_TOTAL":11700,"PROMOTIONAL_DISCOUNT":null,"STOCK_REQUEST_ID":null,"SIV":50,"PITCH_STATUS_CODE":"SA","PITCH_STATUS_DESC":"Sales Van 2","LETTING_CAT_ID":1,"REGION_ID":9,"VAN_TYPE_ENUM":1,"NO_OF_BERTHS":4,"LETTING_LINK_ID":null,"AVAILABLE_TO_ALL":true,"DAYS_ON_SALE":38,"DG_YN":false,"CH_YN":false,"NEW_YN":false,"PITCH_STATUS_ENUM":2,"RESERVED_FOR_PARK_ID":null,"VAN_TYPE_DESC":"Static","ACCESSIBLE_YN":false,"Bedrooms":"Double, Single Twins","COOKER_TYPE":"0","FIRE_TYPE":"0","FIXED_ASSET_YN":false,"HEATERS_YN":false,"LIEN_YN":false,"RAMTECH_YN":false,"RAMTECH_NO":"","SEPARATE_WC_YN":false,"SERIAL_NO":"541/039","SHOWER_YN":false,"SUITABLE_FOR_RETAIL_YN":true,"TRADE_STOCK_YN":false,"WATER_HEATER_TYPE":"0","MANUFACTURE_DT":null,"PAZP":"VA0810573","VAN_ORDER_REASON_DESC":null,"Description":null,"ThumbnailImage":null,"Images":["www.google.com/1","www.google.com/23"],"Features":["Feature 1","Feature 2","Feature 3"],"Content":null,"Prices":[{"CURRENT_PITCH":true,"PITCH_ID":1697,"PITCH_TYPE_DESC":"Standard","PRO_RATA":false,"STOCK_PRICE":11666,"STOCK_DISCOUNT":0,"INSURANCE_PRICE":313.6,"INSURANCE_DISCOUNT":0,"SITEFEE_PRICE":5211.22,"SITEFEE_DISCOUNT":0,"ADDITIONAL_CHARGES_PRICE":528.01,"ADDITIONAL_CHARGES_DISCOUNT":0,"ANCILLARIES_PRICE":3711,"ANCILLARIES_DISCOUNT":0,"TOTAL_PACKAGE_PRICE":21463.83,"TOTAL_PACKAGE_DISCOUNT":0},{"CURRENT_PITCH":true,"PITCH_ID":1697,"PITCH_TYPE_DESC":"Premium","PRO_RATA":true,"STOCK_PRICE":11700,"STOCK_DISCOUNT":0,"INSURANCE_PRICE":64.44,"INSURANCE_DISCOUNT":0,"SITEFEE_PRICE":5211.22,"SITEFEE_DISCOUNT":0,"ADDITIONAL_CHARGES_PRICE":88,"ADDITIONAL_CHARGES_DISCOUNT":0,"ANCILLARIES_PRICE":3711,"ANCILLARIES_DISCOUNT":0,"TOTAL_PACKAGE_PRICE":20774.66,"TOTAL_PACKAGE_DISCOUNT":0}]},"IsCreate":1,"IsUpdate":0,"IsDelete":0,"LinkID":0,"SyncItemID":0}]}');
    RestContext.request = req;
    Test.startTest();
      Response res = (Response) JSON.deserialize(ODIStockBatch.doPost(), Response.class);
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
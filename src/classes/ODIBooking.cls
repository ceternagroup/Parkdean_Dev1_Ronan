@RestResource(urlMapping='/ODI/v1/booking')
global with sharing class ODIBooking {
    
  global static List<Holiday_Booking__c> bookingsUpserts = new List<Holiday_Booking__c>();
  global static List<Holiday_Booking__c> bookingsDelete = new List<Holiday_Booking__c>();
    
  @HttpPost
  global static String doPost() {
    RestRequest req = RestContext.request;
    PostClass body = (PostClass) JSON.deserialize(req.requestBody.toString(), PostClass.class);
    Integer newSyncSetId = body.Control.NewSyncSetID;
    Integer syncDefinitionId = body.Control.SyncDefinitionID;
    // map bookings
    for (Integer i = 0; i < body.Elements.size(); i++) {
      ElementsClass el = body.Elements[i];
      String action = el.IsDelete == 1 ? 'DELETE' : 'UPSERT';
      ODIMapper.BookingClass b = el.Element;
      Holiday_Booking__c booking = ODIMapper.mapBooking(b);
      booking.Link_Id__c = String.valueOf(el.LinkID);
      if (action == 'DELETE') bookingsDelete.add(booking);
      if (action == 'UPSERT') bookingsUpserts.add(booking);
    }
    // create empty res
    ODIHelper.Message result = new ODIHelper.Message();
    result.DataType = 'json';
    result.ReadWrites = new List<ODIHelper.ReadWrite>();
    List<ODIHelper.ReadWrite> runs = new List<ODIHelper.ReadWrite>();
    // handle bookings
    ODIHelper.ReadWrite bookingsUpsertsRes = ODIHelper.handleRecords(bookingsUpserts, 'Booking_ID__c', 'UPSERT', 'Holiday_Booking__c', Holiday_Booking__c.Fields.Booking_ID__c, newSyncSetId, syncDefinitionId);
    ODIHelper.ReadWrite bookingsDeletesRes = ODIHelper.handleRecords(bookingsDelete, 'Booking_ID__c', 'DELETE', 'Holiday_Booking__c', Holiday_Booking__c.Fields.Booking_ID__c, newSyncSetId, syncDefinitionId);
    // add readwrites if not null
    if (bookingsUpsertsRes != null) result.ReadWrites.add(bookingsUpsertsRes);
    if (bookingsDeletesRes != null) result.ReadWrites.add(bookingsDeletesRes);
    return JSON.serialize(result);
  }
      
  public class PostClass {
    public ControlClass Control;
    public List<ElementsClass> Elements;
    public List<Object> Errors;
  }
    
  public class ControlClass {
    public Integer Changes;
    public Integer LastChangeSyncSetID;
    public Integer SyncDefinitionID;
    public String LinkSystem;
    public String Model;
    public Integer NewSyncSetID;
    public String OwnerSchemeFeed;
  }
    
  public class ElementsClass {
    public ODIMapper.BookingClass Element;
    public Integer IsCreate;
    public Integer IsDelete;
    public Integer IsUpdate;
    public Integer LinkID;
    public Integer SyncItemID;
  }
  

}
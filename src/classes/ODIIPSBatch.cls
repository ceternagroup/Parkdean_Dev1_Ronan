@RestResource(urlMapping='/ODI/v1/ips')
global with sharing class ODIIPSBatch {
  
  global static List<Park__c> parkUpserts = new List<Park__c>();
    
  global static List<Price_Rule__c> ipsUpserts = new List<Price_Rule__c>();
  global static List<Price_Rule__c> ipsDeletes = new List<Price_Rule__c>();
    
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
      ODIMapper.IPSClass ips = el.Element;
      Park__c park = ODIMapper.mapPark(ips);
      if (action == 'UPSERT') parkUpserts.add(park);
      for (Integer s = 0; s < ips.Services.size(); s++) {
        ODIMapper.IPSService service = ips.Services[s];
        for (Integer b = 0; b < service.Breaks.size(); b++) {
          Price_Rule__c rule = ODIMapper.mapIPS(service.Breaks[b], ips.ParkID, service.ServiceID);
          if (action == 'UPSERT') ipsUpserts.add(rule);
          if (action == 'DELETE') ipsDeletes.add(rule);
        }
      }
    }
    // create empty res
    ODIHelper.Message result = new ODIHelper.Message();
    result.DataType = 'json';
    result.ReadWrites = new List<ODIHelper.ReadWrite>();
    List<ODIHelper.ReadWrite> runs = new List<ODIHelper.ReadWrite>();
    // handle park and ips
    ODIHelper.ReadWrite parkUpsertsRes = ODIHelper.handleRecords(parkUpserts, 'Id', 'UPSERT', 'Park__c', Park__c.Fields.Id, newSyncSetId, syncDefinitionId);
    ODIHelper.ReadWrite ipsUpsertsRes = ODIHelper.handleRecords(ipsUpserts, 'Foreign_Key__c', 'UPSERT', 'Price_Rule__c', Price_Rule__c.Fields.Foreign_Key__c, newSyncSetId, syncDefinitionId);
    ODIHelper.ReadWrite ipsDeletesRes = ODIHelper.handleRecords(ipsDeletes, 'Foreign_Key__c', 'DELETE', 'Price_Rule__c', Price_Rule__c.Fields.Foreign_Key__c, newSyncSetId, syncDefinitionId);
    // add readwrites if not null
    if (parkUpsertsRes != null) result.ReadWrites.add(parkUpsertsRes);
    if (ipsUpsertsRes != null) result.ReadWrites.add(ipsUpsertsRes);
    if (ipsDeletesRes != null) result.ReadWrites.add(ipsDeletesRes);
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
    public ODIMapper.IPSClass Element;
    public Integer IsCreate;
    public Integer IsDelete;
    public Integer IsUpdate;
    public Integer LinkID;
    public Integer SyncItemID;
  }
    
  

}
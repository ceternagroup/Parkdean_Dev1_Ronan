@RestResource(urlMapping='/ODI/v1/accounts')
global with sharing class ODIAccounts {
    
  global static List<Opportunity> oppUpserts = new List<Opportunity>();
  global static List<Opportunity> oppDeletes = new List<Opportunity>();
    
  global static List<Quote> saleUpserts = new List<Quote>();
  global static List<Quote> saleDeletes = new List<Quote>();
    
  @HttpPost
  global static String doPost() {
    RestRequest req = RestContext.request;
    PostClass body = (PostClass) JSON.deserialize(req.requestBody.toString(), PostClass.class);
    Integer newSyncSetId = body.Control.NewSyncSetID;
    Integer syncDefinitionId = body.Control.SyncDefinitionID;
    String otherTypeId = getRecordTypeId('Other', 'Opportunity');
    String quoteTypeId = getRecordTypeId('Other', 'Quote');
    // map opps
    for (Integer i = 0; i < body.Elements.size(); i++) {
      ElementsClass el = body.Elements[i];
      String action = el.IsDelete == 1 ? 'DELETE' : 'UPSERT';
      ODIMapper.AccountClass opp = el.Element;
      Opportunity o = ODIMapper.mapAccount(opp, otherTypeId, el.SyncItemID);
      o.Link_Id__c = String.valueOf(el.LinkID);
      //String foreignKey = opp.OpportunityId != null ? opp.OpportunityId : String.valueOf(el.SyncItemID);
      //Opportunity oppFK = new Opportunity(Foreign_Key__c = foreignKey);
      if (action == 'UPSERT') oppUpserts.add(o);
      if (action == 'DELETE') oppDeletes.add(o);
      if (opp.Sales != null) {
        for (Integer j = 0; j < opp.Sales.size(); j++) {
          Quote q = ODIMapper.mapSale(opp.Sales[j], quoteTypeId, opp);
          q.OpportunityId = opp.OpportunityId;
          if (action == 'UPSERT') saleUpserts.add(q);
          if (action == 'DELETE') saleDeletes.add(q);
        }   
      }
    }
    // create empty res
    ODIHelper.Message result = new ODIHelper.Message();
    result.DataType = 'json';
    result.ReadWrites = new List<ODIHelper.ReadWrite>();
    List<ODIHelper.ReadWrite> runs = new List<ODIHelper.ReadWrite>();
    // handle opps (wiz accounts)
    ODIHelper.ReadWrite oppUpsertsRes = ODIHelper.handleRecords(oppUpserts, 'Id', 'UPSERT', 'Opportunity', Opportunity.Fields.Id, newSyncSetId, syncDefinitionId);
    ODIHelper.ReadWrite oppDeletesRes = ODIHelper.handleRecords(oppDeletes, 'Id', 'DELETE', 'Opportunity', Opportunity.Fields.Id, newSyncSetId, syncDefinitionId);
    // handle quotes (sales)
    ODIHelper.ReadWrite saleUpsertsRes = ODIHelper.handleRecords(saleUpserts, 'Foreign_Key__c', 'UPSERT', 'Quote', Quote.Fields.Foreign_Key__c, newSyncSetId, syncDefinitionId);
    ODIHelper.ReadWrite saleDeletesRes = ODIHelper.handleRecords(saleDeletes, 'Foreign_Key__c', 'DELETE', 'Quote', Quote.Fields.Foreign_Key__c, newSyncSetId, syncDefinitionId);
    // add readwrites if not null
    if (oppUpsertsRes != null) result.ReadWrites.add(oppUpsertsRes);
    if (oppDeletesRes != null) result.ReadWrites.add(oppDeletesRes);
    if (saleUpsertsRes != null) result.ReadWrites.add(saleUpsertsRes);
    if (saleDeletesRes != null) result.ReadWrites.add(saleDeletesRes);
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
    public ODIMapper.AccountClass Element;
    public Integer IsCreate;
    public Integer IsDelete;
    public Integer IsUpdate;
    public Integer LinkID;
    public Integer SyncItemID;
  }
    
  
  private static String getRecordTypeId(String name, String objName) {
    String recordTypeId = [
      SELECT Id 
      FROM RecordType 
      WHERE SobjectType = :objName
      AND DeveloperName = :name
      LIMIT 1
    ].Id;
    return recordTypeId;
  }
    
  private static void sleep(integer milliseconds) {
    Long timeDiff = 0;
    DateTime firstTime = System.now();
    do {
      timeDiff = System.now().getTime() - firstTime.getTime();
    }
    while(timeDiff <= milliseconds);
  }

}
@RestResource(urlMapping='/ODI/v1/complaints')
global with sharing class ODIComplaints {
    
  global static List<Complaint__c> complaintUpserts = new List<Complaint__c>();
  global static List<Complaint__c> complaintDeletes = new List<Complaint__c>();
    
  global static List<Complaint_Junction__c> complaintLinkUpserts = new List<Complaint_Junction__c>();
    
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
      ODIMapper.ComplaintClass c = el.Element;
      Complaint__c complaint = ODIMapper.mapComplaint(c);
      complaint.Link_Id__c = String.valueOf(el.LinkID);
      if (action == 'UPSERT') complaintUpserts.add(complaint);
      if (action == 'DELETE') complaintDeletes.add(complaint);
      String foreignKey = String.valueOf(c.ComplaintID);
      Complaint__c complaintFK = new Complaint__c(Complaint_Id__c = foreignKey);
      for (Integer l = 0; l < c.Links.size(); l++) {
        Complaint_Junction__c link = ODIMapper.mapComplaintLink(c.Links[l], foreignKey);
        link.Complaint__r = complaintFK;
        if (action == 'UPSERT') complaintLinkUpserts.add(link);
      }
    }
    // create empty res
    ODIHelper.Message result = new ODIHelper.Message();
    result.DataType = 'json';
    result.ReadWrites = new List<ODIHelper.ReadWrite>();
    List<ODIHelper.ReadWrite> runs = new List<ODIHelper.ReadWrite>();
    // handle complaints
    ODIHelper.ReadWrite complaintUpsertsRes = ODIHelper.handleRecords(complaintUpserts, 'Complaint_Id__c', 'UPSERT', 'Complaint__c', Complaint__c.Fields.Complaint_Id__c, newSyncSetId, syncDefinitionId);
    ODIHelper.ReadWrite complaintDeletesRes = ODIHelper.handleRecords(complaintDeletes, 'Complaint_Id__c', 'DELETE', 'Complaint__c', Complaint__c.Fields.Complaint_Id__c, newSyncSetId, syncDefinitionId);
    // handle complaint links
    ODIHelper.ReadWrite complaintLinkUpsertsRes = ODIHelper.handleRecords(complaintLinkUpserts, 'Complaint_Link_Id__c', 'UPSERT', 'Complaint_Junction__c', Complaint_Junction__c.Fields.Complaint_Link_Id__c, newSyncSetId, syncDefinitionId);
    // add readwrites if not null
    if (complaintUpsertsRes != null) result.ReadWrites.add(complaintUpsertsRes);
    if (complaintDeletesRes != null) result.ReadWrites.add(complaintDeletesRes);
    if (complaintLinkUpsertsRes != null) result.ReadWrites.add(complaintLinkUpsertsRes);
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
    public ODIMapper.ComplaintClass Element;
    public Integer IsCreate;
    public Integer IsDelete;
    public Integer IsUpdate;
    public Integer LinkID;
    public Integer SyncItemID;
  }

}
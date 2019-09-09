@RestResource(urlMapping='/ODI/v1/leads')
global class ODILeads {
    
  global static List<Lead> leadUpserts = new List<Lead>();
  global static List<Lead> leadDeletes = new List<Lead>();
  
  global static List<Account> contactUpserts = new List<Account>();
  global static List<Account> contactDeletes = new List<Account>();
    
  global static List<Task> enquiryUpserts = new List<Task>();
    
  @HttpPost
  global static String doPost() {
    RestRequest req = RestContext.request;
    PostClass body = (PostClass) JSON.deserialize(req.requestBody.toString(), PostClass.class);
    Integer newSyncSetId = body.Control.NewSyncSetID;
    Integer syncDefinitionId = body.Control.SyncDefinitionID;
    String enquiryRecordTypeId1 = getRecordTypeId('Enquiry', 'Task');
    String enquiryRecordTypeId2 = getRecordTypeId('New_Enquiries_Exisitng_Leads', 'Task');
    String leadRecordTypeId1 = getRecordTypeId('Holiday_Maker', 'Lead');
    String leadRecordTypeId2 = getRecordTypeId('Central', 'Lead');
    String leadRecordTypeId3 = getRecordTypeId('Park', 'Lead');
    String contactRecordTypeId = getRecordTypeId('Customer', 'Account');
    BusinessHours centralHours = [
      SELECT Id, Name 
      FROM BusinessHours
      WHERE Name = 'Central Team'
      LIMIT 1
    ];
    // map contacts / leads
    for (Integer i = 0; i < body.Elements.size(); i++) {
      ElementsClass el = body.Elements[i];
      String action = el.IsDelete == 1 ? 'DELETE' : 'UPSERT';
      ODIMapper.LeadClass x = el.Element;
      String whoId;
      String whatId;
      // if we have the contact id, or we are an owner, create a contact
      if (x.ContactId != null || x.IsOwner == true) {
        Account c = ODIMapper.mapToContact(x, contactRecordTypeId);
        c.Link_Id__pc = String.valueOf(el.LinkID);
        c.Id = x.ContactId;
        whatId = c.Id;
        if (x.Enquiries != null && x.Enquiries.size() > 0) c = ODIMapper.setEnquiryContact(c, x.Enquiries[0]);
        if (action == 'UPSERT') contactUpserts.add(c);
        if (action == 'DELETE') contactDeletes.add(c);
      } else {
        // else create a lead
        Lead l = ODIMapper.mapToLead(x);
        l.Link_Id__c = String.valueOf(el.LinkID);
        l.Id = x.LeadId;
        l.Business_Hours__c = centralHours.Id;
        // central if qneuiries, otherwise hm
        l.RecordTypeId = x.Enquiries != null && x.Enquiries.size() > 0 ? leadRecordTypeId2 : leadRecordTypeId1;
        if (x.RecordTypeName == 'Park') l.RecordTypeId = leadRecordTypeId3;
        if (x.RecordTypeName == 'Central') l.RecordTypeId = leadRecordTypeId2;
        whoId = l.Id;
        if (x.Enquiries != null && x.Enquiries.size() > 0) l = ODIMapper.setEnquiryLead(l, x.Enquiries[0]);
        if (action == 'UPSERT') leadUpserts.add(l);
        if (action == 'DELETE') leadDeletes.add(l);
      }
      // set record type based on if we have an id?
      String recordTypeId = x.LeadId != null || x.ContactId != null ? enquiryRecordTypeId2 : enquiryRecordTypeId1;
      if (x.Enquiries != null && x.Enquiries.size() > 0) {
        List<Task> enquiries = ODIMapper.mapEnquiries(x, recordTypeId, whoId, whatId);
        if (action == 'UPSERT') enquiryUpserts.addAll(enquiries);   
      }
    }
    // create empty res
    ODIHelper.Message result = new ODIHelper.Message();
    result.DataType = 'json';
    result.ReadWrites = new List<ODIHelper.ReadWrite>();
    List<ODIHelper.ReadWrite> runs = new List<ODIHelper.ReadWrite>();
    // handle leads / contacts
    ODIHelper.ReadWrite leadUpsertsRes = ODIHelper.handleRecords(leadUpserts, 'Id', 'UPSERT', 'Lead', Lead.Fields.Id, newSyncSetId, syncDefinitionId);
    ODIHelper.ReadWrite leadDeletesRes = ODIHelper.handleRecords(leadDeletes, 'Id', 'DELETE', 'Lead', Lead.Fields.Id, newSyncSetId, syncDefinitionId);
    ODIHelper.ReadWrite contactUpsertsRes = ODIHelper.handleRecords(contactUpserts, 'Id', 'UPSERT', 'Account', Account.Fields.Id, newSyncSetId, syncDefinitionId);
    ODIHelper.ReadWrite contactDeletesRes = ODIHelper.handleRecords(contactDeletes, 'Id', 'DELETE', 'Account', Account.Fields.Id, newSyncSetId, syncDefinitionId);
    // handle enquiries
    ODIHelper.ReadWrite enquiryUpsertsRes = ODIHelper.handleRecords(enquiryUpserts, 'Id', 'UPSERT', 'Task', Task.Fields.Id, newSyncSetId, syncDefinitionId);
    // add readwrites if not null
    if (leadUpsertsRes != null) result.ReadWrites.add(leadUpsertsRes);
    if (leadDeletesRes != null) result.ReadWrites.add(leadDeletesRes);
    if (contactUpsertsRes != null) result.ReadWrites.add(contactUpsertsRes);
    if (contactDeletesRes != null) result.ReadWrites.add(contactDeletesRes);
    if (enquiryUpsertsRes != null) result.ReadWrites.add(enquiryUpsertsRes);
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
    public ODIMapper.LeadClass Element;
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

}
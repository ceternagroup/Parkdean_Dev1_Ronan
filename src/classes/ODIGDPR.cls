@RestResource(urlMapping='/ODI/v1/gdpr')
global with sharing class ODIGDPR {
    
  global static List<Id> leadIDs = new List<Id>();
  global static List<Id> contactIDs = new List<Id>();
    
  @HttpPost
  global static String doPost() {
    RestRequest req = RestContext.request;
    PostClass body = (PostClass) JSON.deserialize(req.requestBody.toString(), PostClass.class);
    List<String> fields = new List<String>{
      'Email_Opt_In__c', 'Holidays_Email_Opt_In__c', 'Holidays_Post_Opt_In__c', 
      'Holidays_SMS_Opt_In__c', 'Holidays_Telephone_Opt_In__c', 'Post_Opt_In__c', 'SMS_Opt_In__c',
      'Telephone_Opt_In__c'
    };
    Map<String, Object> res = new Map<String, Object>();
    for (Integer i = 0; i < body.Elements.size(); i++) {
      PersonClass p = body.Elements[i].Element;
      if (p.ContactID != null && contactIDs.indexOf(p.ContactID) == -1) contactIDs.add(p.ContactID);
      if (p.LeadID != null && p.ContactID == null && leadIDs.indexOf(p.LeadID) == -1) leadIDs.add(p.LeadID);
    }
    List<Map<String, Object>> results = new List<Map<String, Object>>();
    List<sObject> records = getRecords('Lead', leadIDs, fields);
    records.addAll(getRecords('Contact', contactIDs, fields));
    for (Integer i = 0; i < records.size(); i++) {
      sObject record = records[i];
      Map<String, Object> result = new Map<String, Object>();
      result.put('SF_ID', record.Id);
      for (Integer f = 0; f < fields.size(); f++) {
        result.put(fields[f], (Boolean) record.get(fields[f]));   
      }
      results.add(result);
    }
    res.put('Results', results);
    res.put('Errors', null);
    Post post = createPost('saf.gdpr', res);
    return JSON.serialize(post);
  }
    
  private static List<sObject> getRecords(String obj, List<Id> recordIDs, List<String> fields) {
    List<sObject> records = new List<sObject>();
    if (recordIDs.size() == 0) return records;
    String query = 'SELECT Id, ' + String.join(fields, ',') + ' FROM ' + obj + ' WHERE Id IN (\'' + String.join(recordIDs, '\',\'') + '\')';
    records = Database.query(query);
    return records;
  }
    
  public class PostClass {
    public ControlClass Control;
    public List<ElementsClass> Elements;
    public List<Object> Errors;
  }
    
  public class ControlClass {
    public Integer Changes;
    public Integer LastChangeSyncSetID;
    public String LinkSystem;
    public String Model;
    public Integer NewSyncSetID;
    public String OwnerSchemeFeed;
  }
    
  public class ElementsClass {
    public PersonClass Element;
    public Integer IsCreate;
    public Integer IsDelete;
    public Integer IsUpdate;
    public Integer LinkID;
    public Integer SyncItemID;
  }
    
  public class PersonClass {
    public String ContactID;
    public String LeadID;
  }
    
  private static Post createPost(String name, Map<String, Object> params) {
    Post post = new Post();
    post.DataType = 'json';
    List<Map<String, Object>> readWrites = new List<Map<String, Object>>();
    Map<String, Object> readWrite = new Map<String, Object>();
    readWrite.put('Name', name);
    readWrite.put('Parameters', params);
    readWrites.add(readWrite);
    post.ReadWrites = readWrites;
    return post;
  }
    
  private class Post {
    private String DataType;
    private List<Map<String, Object>> ReadWrites;
  }

}
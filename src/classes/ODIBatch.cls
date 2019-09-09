/*
 * @class ODIBatch
 * @desc - takes a set of records from ODI and upserts or deletes 
 *   them as a batch job
 */
global class ODIBatch implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {
    
  // set variables for collections across batches within a job
  private final List<sObject> records;
  private final Set<Id> recordIds;
  private final String actionType; // UPSERT, DELETE
  private final String sObjectType;
  private final String externalId;
  private final Schema.SObjectField sObjectKey;
  private final Integer newSyncSetId;
  private final Integer syncDefinitionId;
  private final Boolean ignore;
  private final List<Map<String, String>> results = new List<Map<String, String>>();
  private final List<Map<String, String>> errors = new List<Map<String, String>>();
  private final DateTime timeStarted;
    
  // when we init a batch we need to pass in some variables to set globally
  global ODIBatch(List<sObject> records, String actionType, String sObjectType, Schema.SObjectField sObjectKey, Integer newSyncSetId, String externalId, Integer syncDefinitionId) {
    this.records = records;
    this.actionType = actionType;
    this.sObjectType = sObjectType;
    this.sObjectKey = sObjectKey;
    this.newSyncSetId = newSyncSetId;
    this.syncDefinitionId = syncDefinitionId;
    this.externalId = externalId;
    this.ignore = ignore;
    this.timeStarted = DateTime.now();
  }
    
  // return the records we initiated with
  global List<sObject> start(Database.BatchableContext bc) {
    return records;    
  }
    
  // based on action type we either need to upsert or delete
  global void execute(Database.BatchableContext bc, List<sObject> scope) {
    // if upsert, run the upsert and set the results
    if (actionType == 'UPSERT') {
      List<Database.UpsertResult> dml;
      // if blocks to get around this issue: https://success.salesforce.com/ideaView?id=08730000000E1eZAAS
      // we need this so we can use false on the allOrNothing flag
      if (sObjectType == 'Product2') dml = Database.upsert((List<Product2>) scope, sObjectKey, false);
      if (sObjectType == 'Price__c') dml = Database.upsert((List<Price__c>) scope, sObjectKey, false);
      if (sObjectType == 'Stock_Image__c') dml = Database.upsert((List<Stock_Image__c>) scope, sObjectKey, false);
      if (sObjectType == 'Holiday_Booking__c') dml = Database.upsert((List<Holiday_Booking__c>) scope, sObjectKey, false);
      if (sObjectType == 'Price_Rule__c') dml = Database.upsert((List<Price_Rule__c>) scope, sObjectKey, false);
      if (sObjectType == 'Complaint__c') dml = Database.upsert((List<Complaint__c>) scope, sObjectKey, false);
      if (sObjectType == 'Complaint_Junction__c') dml = Database.upsert((List<Complaint_Junction__c>) scope, sObjectKey, false);
      if (sObjectType == 'Opportunity') dml = Database.upsert((List<Opportunity>) scope, sObjectKey, false);
      if (sObjectType == 'Quote') dml = Database.upsert((List<Quote>) scope, sObjectKey, false);
      if (sObjectType == 'Lead') dml = Database.upsert((List<Lead>) scope, sObjectKey, false);
      if (sObjectType == 'Task') dml = Database.upsert((List<Task>) scope, sObjectKey, false);
      if (sObjectType == 'Account') dml = Database.upsert((List<Account>) scope, sObjectKey, false);
      if (sObjectType == 'Park__c') dml = Database.upsert((List<Park__c>) scope, sObjectKey, false);
      if (sObjectType == 'Batch_Log__c') dml = Database.upsert((List<Batch_Log__c>) scope, sObjectKey, false);
      setUpsertResults(dml, scope);
    }
    // if delete, delete the scope and set the results
    if (actionType == 'DELETE') {
      List<String> recordIds = new List<String>();
      // get records by external id
      for (Integer r = 0; r < scope.size(); r++) {
        recordIds.add((String) scope[r].get(externalId));
      }
      String query = 'SELECT ' + getFields(externalId, sObjectType) + ' FROM ' + sObjectType + ' WHERE ' + externalId + ' IN (\'' + String.join(recordIds, '\', \'') + '\')'; 
      List<sObject> delScope = Database.query(query);
      List<Database.DeleteResult> dml = Database.delete(delScope);
      setDeleteResults(dml, scope);
    }
  }
    
  // when we finish we need to return the results to ODI, and create a batch log
  global void finish(Database.BatchableContext bc) {
    // get finished job
    AsyncApexJob job = [
      SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email
      FROM AsyncApexJob
      WHERE Id = :bc.getJobId()
    ];
    // create the ODI request
    Map<String, Object> res = new Map<String, Object>();
    res.put('newSyncSetId', newSyncSetId);
    res.put('SyncDefinitionID', syncDefinitionId);
    res.put('resultType', 'JOB_END');
    res.put('jobId', job.Id);
    res.put('SF_JOB_ID', job.Id);
    res.put('Name', 'sf.batch.' + sObjectType.toLowerCase() + '.' + actionType.toLowerCase());
    res.put('Results', results);
    res.put('Errors', errors);
    Post post = createPost('saf.job.end', res);
    String body = JSON.serialize(post);
    // set the request
    Http h = new Http();
    HttpRequest req = new HttpRequest();
	req.setEndpoint(Label.ODI_URL);
    req.setHeader('Authorization', Label.ODI_Auth);
    req.setTimeout(120000);
    req.setMethod('POST');
    req.setBody(body);
    // some ODI calls will timeout with it's response, but still send the records
    // because of this we need to try/catch the result assignment so we can still make a log
    try {
      HttpResponse result = h.send(req);
      String response = result.getBody();
      createLog(job, response);
    } catch(System.CalloutException e) {
      createLog(job, 'The response from ODI timed out.');
    }
  }
    
  /*
   * @method createLog()
   * @desc - Creates a log in SF for a given job, with more details
   *   than the standard apex jobs (and don't get expired)
   * 
   * @param {AsyncApexJob} job - job to set log for
   * @param {String} response - response from ODI, if any
   *
   * @return null
   */
  public void createLog(AsyncApexJob job, String response) {
    // in case we can't manage to create a log, we try catch it and
    // attempt to make an error log, shouldnt happen but best to be safe
    try {
      Batch_Log__c log = new Batch_Log__c();
      log.Action_Type__c = actionType;
      log.Job_Id__c = job == null ? null : job.Id;
      log.Status__c = job == null ? null : job.Status;
      log.Object_Type__c = sObjectType;
      log.Time_Started__c = timeStarted;
      log.Time_Finished__c = DateTime.now();
      log.Total_Successes__c = results.size();
      log.Total_Errors__c = errors.size();
      log.ODI_Response__c = response;
      log.Sync_Set_Id__c = newSyncSetId;
      log.External_ID__c = externalId;
      String errorDetails = JSON.serialize(errors);
      log.Error_Messages__c = errorDetails.length() > 130000 ? errorDetails.substring(0, 130000) : errorDetails;
      insert log;
    } catch(DMLException e) {
      Batch_Log__c log = new Batch_Log__c();
      log.Job_Id__c = job.Id;
      log.Error_Messages__c = 'Error: ' + e;
      insert log;
    }
  }
    
  /*
   * @method setUpsertResults()
   * @desc - For our upsert results, we need to set the values for ODI to help link them back up
   * 
   * @param {List<Database.UpsertResult>} dml - our upsert results
   * @param {List<sObject>} scope - the records that were used for the upsert
   *
   * @return null
   */
  global void setUpsertResults(List<Database.UpsertResult> dml, List<sObject> scope) {
    for (Integer i = 0; i < dml.size(); i++) {
      if (dml[i].isSuccess() == true) {
        Map<String, String> r = setResultMap(sObjectType, scope[i], dml[i].getId(), externalId);
        results.add(r);
      } else {
        Map<String, String> r = setResultMap(sObjectType, scope[i], dml[i].getId(), externalId);
        List<Database.Error> errs = dml[i].getErrors();
        r.put('DatabaseError', JSON.serialize(errs));
        errors.add(r);
      }
    } 
  }
    
  /*
   * @method setDeleteResults()
   * @desc - For our Delete results, we need to set the values for ODI to help link them back up
   * 
   * @param {List<Database.DeleteResult>} dml - our Delete results
   * @param {List<sObject>} scope - the records that were used for the Delete
   *
   * @return null
   */
  global void setDeleteResults(List<Database.DeleteResult> dml, List<sObject> scope) {
    for (Integer i = 0; i < dml.size(); i++) {
      if (dml[i].isSuccess() == true) {
        Map<String, String> r = setResultMap(sObjectType, scope[i], dml[i].getId(), externalId);
        results.add(r);
      } else {
        Map<String, String> r = setResultMap(sObjectType, scope[i], dml[i].getId(), externalId);
        List<Database.Error> errs = dml[i].getErrors();
        r.put('Errors', JSON.serialize(errs));
        errors.add(r);
      }
    } 
  }
    
  /*
   * @method createPost()
   * @desc - Creates an post and sets the params to be sent to ODI
   * 
   * @param {String} name - name to give the post
   * @param {Map<String, Object>} params - params to be sent to ODI
   *
   * @return null
   */
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
    
  // post class
  private class Post {
    private String DataType;
    private List<Map<String, Object>> ReadWrites;
  }
    
  private static String getFields(String externalId, String sObjectType) {
    Set<String> fields = new Set<String>();
    fields.add('Id');
    fields.add(externalId);
    if (sObjectType == 'Opportunity') {
      fields.add('Post_Sync_Link_Id__c');
      fields.add('Wizard_Account_Id__c');
    }
    if (sObjectType == 'Quote') fields.add('Foreign_Key__c');
    if (sObjectType == 'Product2') fields.add('Foreign_Key__c');
    if (sObjectType == 'Holiday_Booking__c') fields.add('Booking_ID__c');
    if (sObjectType == 'Complaint__c') fields.add('Complaint_Id__c');
    if (sObjectType == 'Lead') fields.add('Primary_Id__c');
    if (sObjectType == 'Account') fields.add('Primary_Id__pc');
    if (sObjectType == 'Park__c') fields.add('Park_ID__c');
    if (sObjectType == 'Batch_Log__c') fields.add('CreatedDate');
    String f = String.join(new List<String>(fields), ', ');
    return f;
  }
    
  /*
   * @method setResultMap()
   * @desc - Creates a result for ODI with all the external keys we use based on the object
   * 
   * @param {String} sObjectType - object name for the job
   * @param {sObject} record - record to set
   * @param {String} recordId - DML new record ID
   * @param {String} externalId - foreign key
   *
   * @return {Map<String, String>} - returns the result map for that record
   */
  private static Map<String, String> setResultMap(String sObjectType, sObject record, String recordId, String externalId) {      
    Map<String, String> r = new Map<String, String>();
    r.put('SF_ID', recordId);
    r.put(externalId, (String) record.get(externalId));  
    r.put('LinkID', (String) record.get('Link_Id__c')); 
    if (sObjectType == 'Opportunity') r.put('ACCOUNT_ID', (String) record.get('Wizard_Account_Id__c'));
    if (sObjectType == 'Opportunity') r.put('SYNC_ID', (String) String.valueOf(record.get('Post_Sync_Link_Id__c')));
    if (sObjectType == 'Quote') r.put('SALE_ID', (String) record.get('Foreign_Key__c'));
    if (sObjectType == 'Product2') r.put('VAN_ID', (String) record.get('Foreign_Key__c'));
    if (sObjectType == 'Holiday_Booking__c') r.put('BookingID', (String) record.get('Booking_ID__c'));
    if (sObjectType == 'Complaint__c') r.put('ComplaintID', (String) record.get('Complaint_Id__c'));
    if (sObjectType == 'Lead') r.put('PrimaryID', (String) record.get('Primary_Id__c'));
    if (sObjectType == 'Lead') r.put('LeadID', (String) recordId);
    if (sObjectType == 'Account') r.put('PrimaryID', (String) record.get('Primary_Id__pc'));
    if (sObjectType == 'Account') r.put('ContactID', (String) recordId);
    if (sObjectType == 'Park__c') r.put('SupplierID', (String) String.valueOf(record.get('Park_ID__c'))); 
    if (sObjectType == 'Batch_Log__c') r.put('JOB_ID', (String) record.get('Job_Id__c'));
    return r;
  }

}
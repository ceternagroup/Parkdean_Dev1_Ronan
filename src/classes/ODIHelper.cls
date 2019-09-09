/*
 * @class ODIHelper
 * @desc - takes a set of records from ODI and upserts or deletes them,
 *   batching up the records if over 500
 */
global class ODIHelper {
    
  /*
   * @method handleRecords()
   * @desc - Either runs a DML on the records or starts a batch job
   * 
   * @param {List<sObject>} records - records to process
   * @param {String} externalId - Id to use as upsert / delete key
   * @param {String} actionType - either UPSERT or DELETE
   * @param {String} objectType - SF Object API name
   * @param {Schema.SObjectField} - the external Id field but as a schema class
   * @param {Integer} newSyncSetId - Sync set identifyer from ODI
   *
   * @return {ReadWrite} - returns a ReadWrite in the ODI style
   */
  global static ReadWrite handleRecords(List<sObject> records, String externalId, String actionType, String sObjectType, Schema.SObjectField sObjectKey, Integer newSyncSetId, Integer syncDefinitionId) {
    // no records, ignore
    if (records == null || records.size() == 0) return null;
      // under limit run dml
    if (records.size() < 500) return directManipulation(records, externalId, actionType, sObjectType, sObjectKey, newSyncSetId, syncDefinitionId);
    // over limit run batches
    ReadWrite rw = new ReadWrite();
    rw.Name = 'sf.batch.' + sObjectType.toLowerCase() + '.' + actionType.toLowerCase();
    Result res = new Result();
    res.newSyncSetId = newSyncSetId;
    res.SyncDefinitionID = syncDefinitionId;
    res.resultType = 'JOB_START';
    List<Map<String, String>> jobs = new List<Map<String, String>>();
    // create the batch and send it
    try {
      if (Test.isRunningTest() == true) {
        List<sObject> chunk = new List<sObject>();
        for (Integer i = 0; i < 100; i++) {
          chunk.add(records[i]);   
        }
        records = chunk;
      }
      String batchLabel = Label.ODI_Batch_Size;
      Integer batchSize = batchLabel == null || batchLabel == '' ? 500 : Integer.valueOf(batchLabel);
      Id jobId = Database.executeBatch(new ODIBatch(records, actionType, sObjectType, sObjectKey, newSyncSetID, externalId, syncDefinitionId), batchSize);
      Map<String, String> job = new Map<String, String>();
      job.put('SF_JOB_ID', jobId);
      jobs.add(job);
      res.Results = jobs;
      res.Errors = null;
      rw.Parameters = res;
      return rw;
    } catch(DMLException e) {
      // otherwise return the errors to ODI as job creation failed
      List<Map<String, String>> errs = new List<Map<String, String>>();
      Map<String, String> r = new Map<String, String>();
      r.put('Message', '' + e); errs.add(r); res.Results = null; res.Errors = errs; rw.Parameters = res; return rw;
    }
  }
    
  /*
   * @method directManipulation()
   * @desc - Runs a DML operation for either UPSERT or DELETE
   * 
   * @param {List<sObject>} records - records to process
   * @param {String} externalId - Id to use as upsert / delete key
   * @param {String} actionType - either UPSERT or DELETE
   * @param {String} objectType - SF Object API name
   * @param {Schema.SObjectField} - the external Id field but as a schema class
   * @param {Integer} newSyncSetId - Sync set identifyer from ODI
   *
   * @return {ReadWrite} - returns a ReadWrite in the ODI style
   */
  private static ReadWrite directManipulation(List<sObject> records, String externalId, String actionType, String sObjectType, Schema.SObjectField sObjectKey, Integer newSyncSetId, Integer syncDefinitionId) { 
    // init read write
  	ReadWrite rw = new ReadWrite();
    rw.Name = 'sf.dml.' + sObjectType.toLowerCase() + '.' + actionType.toLowerCase();
    Result res = new Result();
    res.newSyncSetId = newSyncSetId;
    res.SyncDefinitionID = syncDefinitionId;
    res.resultType = 'DML';
    // try upsert or delete and return the res
    try {
      if (actionType == 'UPSERT') res = directUpdate(res, records, externalId, sObjectType, sObjectKey);
      if (actionType == 'DELETE') res = directDelete(res, records, externalId, sObjectType);
      rw.Parameters = res;
      createLog(actionType, sObjectType, res.Results, res.Errors, newSyncSetId, externalId);
      return rw;
    } catch(DMLException e) {
      // otherwise if an unhandled exception occured, return it to ODI
      // record insert / delete failures would be in the normal res
      List<Map<String, String>> errs = new List<Map<String, String>>();
      Map<String, String> r = new Map<String, String>();
      r.put('Message', '' + e); errs.add(r); 
      createLog(actionType, sObjectType, null, errs, newSyncSetId, externalId);
      res.Results = null; res.Errors = errs; rw.Parameters = res; return rw;
    }
  }

  /*
   * @method directUpdate()
   * @desc - Runs an UPSERT DML operation
   * 
   * @param {Result} res - res to add the record success / errors to
   * @param {List<sObject>} records - records to process
   * @param {String} externalId - Id to use as upsert / delete key
   * @param {String} actionType - either UPSERT or DELETE
   * @param {String} objectType - SF Object API name
   * @param {Schema.SObjectField} - the external Id field but as a schema class
   *
   * @return {Result} - returns the updated result
   */
  private static Result directUpdate(Result res, List<sObject> records, String externalId, String sObjectType, Schema.SObjectField sObjectKey) {
    // cast the records
    List<Database.UpsertResult> dml;
    // if blocks to get around this issue: https://success.salesforce.com/ideaView?id=08730000000E1eZAAS
    // we need this so we can use false on the allOrNothing flag
    if (sObjectType == 'Product2') dml = Database.upsert((List<Product2>) records, sObjectKey, false);
    if (sObjectType == 'Price__c') dml = Database.upsert((List<Price__c>) records, sObjectKey, false);
    if (sObjectType == 'Stock_Image__c') dml = Database.upsert((List<Stock_Image__c>) records, sObjectKey, false);
    if (sObjectType == 'Holiday_Booking__c') dml = Database.upsert((List<Holiday_Booking__c>) records, sObjectKey, false);
    if (sObjectType == 'Price_Rule__c') dml = Database.upsert((List<Price_Rule__c>) records, sObjectKey, false);
    if (sObjectType == 'Complaint__c') dml = Database.upsert((List<Complaint__c>) records, sObjectKey, false);
    if (sObjectType == 'Complaint_Junction__c') dml = Database.upsert((List<Complaint_Junction__c>) records, sObjectKey, false);
    if (sObjectType == 'Opportunity') dml = Database.upsert((List<Opportunity>) records, sObjectKey, false);
    if (sObjectType == 'Quote') dml = Database.upsert((List<Quote>) records, sObjectKey, false);
    if (sObjectType == 'Lead') dml = Database.upsert((List<Lead>) records, sObjectKey, false);
    if (sObjectType == 'Account') dml = Database.upsert((List<Account>) records, sObjectKey, false);
    if (sObjectType == 'Park__c') dml = Database.upsert((List<Park__c>) records, sObjectKey, false);
    if (sObjectType == 'Batch_Log__c') dml = Database.upsert((List<Batch_Log__c>) records, sObjectKey, false);
    if (sObjectType == 'Task') dml = Database.upsert((List<Task>) records, sObjectKey, false);
    List<Map<String, String>> errors = new List<Map<String, String>>();
    List<Map<String, String>> results = new List<Map<String, String>>();
    // for each dml, check the res or error and add to the read write
    for (Integer i = 0; i < dml.size(); i++) {
      if (dml[i].isSuccess() == true) {
        results.add(setResultMap(sObjectType, records[i], dml[i].getId(), externalId));
      } else {
        Map<String, String> r = setResultMap(sObjectType, records[i], dml[i].getId(), externalId);
        List<Database.Error> errs = dml[i].getErrors();
        r.put('DatabaseError', JSON.serialize(errs));
        errors.add(r);
      }
    } 
    res.Results = results;
    res.Errors = errors;
    return res;
  }

  /*
   * @method directDelete()
   * @desc - Runs an DELETE DML operation
   * 
   * @param {Result} res - res to add the record success / errors to
   * @param {List<sObject>} records - records to process
   * @param {String} externalId - Id to use as upsert / delete ke
   * @param {String} objectType - SF Object API name
   *
   * @return {Result} - returns the updated result
   */
  private static Result directDelete(Result res, List<sObject> records, String externalId, String sObjectType) {
    List<String> recordIds = new List<String>();
    // get records by external id
    for (Integer r = 0; r < records.size(); r++) {
      recordIds.add((String) records[r].get(externalId));
    }
    String query = 'SELECT ' + getFields(externalId, sObjectType) + ' FROM ' + sObjectType + ' WHERE ' + externalId + ' IN (\'' + String.join(recordIds, '\', \'') + '\')'; 
    records = Database.query(query);
    // delete the records queries
    List<Database.DeleteResult> dml = Database.delete(records);
    List<Map<String, String>> errors = new List<Map<String, String>>();
    List<Map<String, String>> results = new List<Map<String, String>>();
    // for each dml, check the res or error and add to the read write
    for (Integer i = 0; i < dml.size(); i++) {
      if (dml[i].isSuccess() == true) {
        results.add(setResultMap(sObjectType, records[i], dml[i].getId(), externalId));
      } else {
        Map<String, String> r = setResultMap(sObjectType, records[i], dml[i].getId(), externalId);
        List<Database.Error> errs = dml[i].getErrors();
        r.put('DatabaseError', JSON.serialize(errs));
        errors.add(r);
      }
    } 
    res.Results = results;
    res.Errors = errors;
    return res;
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
  public static void createLog(String actionType, String sObjectType, List<Map<String, String>> results, List<Map<String, String>> errors, Integer newSyncSetId, String externalId) {
    // in case we can't manage to create a log, we try catch it and
    // attempt to make an error log, shouldnt happen but best to be safe
    try {
      Batch_Log__c log = new Batch_Log__c();
      log.Action_Type__c = actionType;
      log.Job_Id__c = 'DML';
      log.Status__c = 'Completed';
      log.Object_Type__c = sObjectType;
      log.Total_Successes__c = results.size();
      log.Total_Errors__c = errors.size();
      log.Time_Started__c = DateTime.now();
      log.Time_Finished__c = DateTime.now();
      log.Sync_Set_Id__c = newSyncSetId;
      log.External_ID__c = externalId;
      String errorDetails = JSON.serialize(errors);
      log.Error_Messages__c = errorDetails.length() > 130000 ? errorDetails.substring(0, 130000) : errorDetails;
      insert log;
    } catch(DMLException e) {
      Batch_Log__c log = new Batch_Log__c();
      log.Job_Id__c = 'DML';
      log.Error_Messages__c = 'Error: ' + e;
      insert log;
    }
  }

  // message structure
  global class Message {
    global String DataType;
    global List<ReadWrite> ReadWrites;
  }
  global class ReadWrite {
    global String Name;
    global Result Parameters;
  }
  global class Result {
    global Integer newSyncSetId;
    global Integer SyncDefinitionID;
    global String resultType; // standard / job
    global String jobId;
    global List<Map<String, String>> Errors;
    global List<Map<String, String>> Results;
  }
    
  public static String getFields(String externalId, String sObjectType) {
    Set<String> fields = new Set<String>();
    fields.add('Id');
    fields.add('Link_Id__c');
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
    
  // add the fields ODI needs for a DML record
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
    return r;
  }
    
  public static void testRunOpps() {
    List<Opportunity> opps = new List<Opportunity>();
    for (Integer i = 0; i < 50000; i++) {
      Opportunity o = new Opportunity();
      o.Name = 'TEST_BULK_' + i;
      o.RecordTypeId = '0121X0000004O9P';
      o.CloseDate = Date.valueOf(DateTime.now());
      o.StageName = 'Closed Won';
      opps.add(o);
    }
    ODIHelper.handleRecords(opps, 'Id', 'UPSERT', 'Opportunity', Opportunity.Fields.Id, 1, 1);
  }

}
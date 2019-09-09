/**********************************************************************************************
* @Author: Ceterna
* @Date:        
* @Description: Helper class to store the various methods we run from the LeadTriggerHandler.
*	If it affects the Leads in a trigger, the logic will be here.
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description] 
***********************************************************************************************/  
public class LeadHandler {

  /**********************************************************************************************
  * @Author: Ceterna
  * @Date: 22/07/2019      
  * @Description: sets the Park_IDs__c field based on the park names given in the 
  * 	Park_Codes__c multiselect picklist. Called in both beforeInsert and beforeUpdate
  * @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]
  *               7.08.2019 - B0119 - Ronan Williams - update to ensure the correct Id field (Park_ID__c) is retrieved from
  *               parks and allocated to lead records
  ***********************************************************************************************/  
  public static void setParkIds(List<Lead> leads) {
    // get all the park names from the leads
    List<String> parkNames = new List<String>();
    for (Integer l = 0; l < leads.size(); l++) {
      if (leads[l].Park_Codes__c != null) {
        List<String> values = leads[l].Park_Codes__c.split(';');
        for (Integer v = 0; v < values.size(); v++) {
          String parkName = values[v].trim();
          if (parkNames.indexOf(parkName) == -1) parkNames.add(parkName);
        }
      }   
    }
    // get park ids
    List<Park__c> parks = [
      SELECT Id, Park_ID__c, Name
      FROM Park__c
      WHERE Name IN :parkNames
    ];
    // map park name to id
    Map<String, String> parkNameToId = new Map<String, String>();
    for (Integer p = 0; p < parks.size(); p++) {
      parkNameToId.put(parks[p].Name, String.valueOf(parks[p].Park_ID__c));
    }
    // set comma id list
    for (Integer l = 0; l < leads.size(); l++) {
      List<String> pids = new List<String>();
      if (leads[l].Park_Codes__c != null) {
        List<String> values = leads[l].Park_Codes__c.split(';');
        for (Integer v = 0; v < values.size(); v++) {
          String parkName = values[v].trim();
          String pid = parkNameToId.get(parkName);
          if (pid != null && pids.indexOf(pid) == -1) {
            pids.add(pid);
          }
        }
      }
      leads[l].Park_IDs__c = String.join(pids, ',');
    }  
  }
    
  /**********************************************************************************************
  * @Author: Ceterna
  * @Date:    
  * @Description: Sets the park bucket field for the RM report component  
  * @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description] 
  ***********************************************************************************************/  
  public static void setPark(List<Lead> leads) {
    // get park region mapping, pass to region match
    List<RM_Park_Region_Mapping__mdt> parkRegionMappings = [
      SELECT Park_Name__c, Regions__c
      FROM RM_Park_Region_Mapping__mdt
    ];
    Map<String, String> parkRegionMap = new Map<String, String>();
    for (Integer i = 0; i < parkRegionMappings.size(); i++) {
      parkRegionMap.put(parkRegionMappings[i].Park_Name__c, parkRegionMappings[i].Regions__c);
    }
    // for each lead calculate the bucket
    for (Integer i = 0; i < leads.size(); i++) {
      List<String> parks = splitPicklist(leads[i].Park_Codes__c);
      List<String> regions = splitPicklist(leads[i].Region__c);
      String regionMatch = checkRegions(parks, parkRegionMap);
      // default to global
      String value = 'Global';
      // if 1 park, use park
      if (parks != null) {
        if (parks.size() == 1) {
          value = parks[0];
        // if +1 park and their regions match, use region
        } else if (parks.size() > 1 && regionMatch != null) {
          value = regionMatch;
        // if 0 park and 1 region, use region
        } else if (regions != null && parks.size() == 0 && regions.size() == 1) {
          value = regions[0];
        }
      } else {
        if (regions != null && regions.size() == 1) {
          value = regions[0];
        }
      }
      leads[i].Park_Bucket__c = value;
    }
  }

  /**********************************************************************************************
  * @Author: Ceterna
  * @Date:    
  * @Description: Splits a multi-select picklist field value into a list of strings
  * @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description] 
  ***********************************************************************************************/  
  private static List<String> splitPicklist(String picklist) {
    List<String> values = new List<String>();
    if (picklist == null || picklist == '') return null;
    values = picklist.split(';');
    return values;
  }
    
  /**********************************************************************************************
  * @Author: Ceterna
  * @Date:    
  * @Description: Checks to see if there is a common region between all parks, if
  * 	there is we return the region, otherwise null
  * @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description] 
  ***********************************************************************************************/ 
  public static String checkRegions(List<String> parks, Map<String, String> mapping) {
    String value;
    Map<String, Integer> regions = new Map<String, Integer>();
    if (parks == null) return null;
    for (Integer p = 0; p < parks.size(); p++) {
      String region = mapping.get(parks[p]);
      if (region != null) {
        if (regions.get(region) != null) {
          regions.put(region, regions.get(region) + 1);
        } else {
          regions.put(region, 1);
        }
      }
    }
    for (String region : regions.keySet()) {
      if (regions.get(region) == parks.size()) value = region; break;
    }
    return value;
  }

  /**********************************************************************************************
  * @Author: Ceterna
  * @Date:    
  * @Description: Checks a Lead to see what queue they will be assigned too based on the Custom 
  *		Metadata mapping set for SLA Response and Queue Assignment. also set's the SLA Response 
  *		time shown on the LeadSLAResponse component.
  * @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description] 
  ***********************************************************************************************/ 
  public static void assignToQueue(List<Lead> leads) {
    String recordTypeId = getRecordTypeId('Central', 'Lead');
    // get mapping settings for response
    Map<String, String> responseTimes = getSettingMap('Lead_SLA_Response__mdt', 'Source__c, Response_Time__c');
    // get mapping settings for business hours
    Map<String, String> businessHours = getSettingMap('Lead_Business_Hours__mdt', 'Record_Type__c, Business_Hours__c');
    // get mapping settings for queue assignements    
    Map<String, String> queueAssignments = getSettingMap('Lead_Queue_Assignment__mdt', 'Region__c, Source__c, Queue__c');
    String timeZone = [SELECT Id, TimeZoneSidKey FROM Organization LIMIT 1].TimeZoneSidKey;
    System.debug(timeZone);
    // for each lead, set the response time and queue Id
    List<Lead> updateLeads = new List<Lead>();
    for (Integer i = 0; i < leads.size(); i++) {
      Lead l = leads[i].clone(true, true, true, true);
      // set Business_Hours__c
      String recordType = l.Record_Type__c;
      // ONLY IF RECORD_TYPE = CENTRAL
      if (l.RecordTypeId == recordTypeId && l.SLA_Deadline__c == null) {
      String businessHour = businessHours.get(recordType);
      l.Business_Hours__c = businessHour;
      // set SLA_Deadline__c
      String source = l.Lead_source_Level_2__c; // Local partnership
      String responseTime = responseTimes.get(source);
      Integer responseHours = responseTime == null ? 0 : Integer.valueOf(responseTime);
      Integer responseMs = responseHours * 60 * 60 * 1000;
      Integer nowHour = System.now().hour();
      if (timeZone == 'BST' || timeZone == 'Europe/London') nowHour -= 1; // account for british summer time
      Datetime now = Datetime.newInstanceGmt(System.now().year(), System.now().month(), System.now().day(), nowHour, System.now().minute(), System.now().second());
      Datetime deadline = System.BusinessHours.add(businessHour, now, responseMs);
      Integer responseHour = responseMs - 3600000;
      Datetime onehour = System.BusinessHours.add(businessHour, now, responseHour);
      // only assign if auto-created
      if (leads[i].Auto_Created__c == true && leads[i].Phone == null && leads[i].MobilePhone == null) {
        System.debug('??');
        System.debug(leads[i]);
        // set queue assignment
        String region = l.Region__c;
        if (region == null || region == '') {
          region = 'NONE'; 
        } else {
          if (region.indexOf(';') != -1) {
            region = 'NONE';  
          }
        }
        String queue = queueAssignments.get(region + source);
        if (queue != '' && queue != null) {
          l.OwnerId = l.SLA_Deadline__c != null ? l.OwnerId : queue;
        }
      }
      // set calculated deadline + warning
      l.SLA_Deadline__c = l.SLA_Deadline__c != null ? l.SLA_Deadline__c : deadline;
      l.SLA_1hr_warning__c = l.SLA_1hr_warning__c != null ? l.SLA_1hr_warning__c : onehour;
      updateLeads.add(l);
      }
    }
    update updateLeads;
  }
    
  /**********************************************************************************************
  * @Author: Ceterna
  * @Date:    
  * @Description: Posts the field changes made in Salesforce to ODI, to keep both systems in sync.
  * 	Only sends the fields listed below.
  * @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]
  * 	deprecated 08/08/2019 
  ***********************************************************************************************
  public static void postChanges(List<Lead> records, String triggerType) {
    User u = [SELECT Id, Name, Wizard_ID__c FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
    String name = 'sync.upsert.contacts';
    Map<String, Object> data = new Map<String, Object>();
    List<Map<String, Object>> leads = new List<Map<String, Object>>();
    for (Integer i = 0; i < records.size(); i++) {
      Lead record = records[i];
      Map<String, Object> l = new Map<String, Object>();
      l.put('PrimaryId', record.Primary_Id__c != null ? Integer.valueOf(record.Primary_Id__c) : null);
      l.put('LeadId', record.Id);
      l.put('ContactId', record.ConvertedAccountId);
      l.put('Salutation', record.Salutation);
      l.put('FirstName', record.FirstName);
      l.put('LastName', record.LastName);
      l.put('Street', record.Street);
      l.put('City', record.City);
      l.put('PostalCode', record.PostalCode);
      l.put('County', record.State);
      l.put('Country', record.Country);
      l.put('Email', record.Email);
      l.put('MobilePhone', record.MobilePhone);
      l.put('Phone', record.Phone);
      l.put('RecordTypeName', record.Record_type_formua__c);
      l.put('LeadSource', record.LeadSource);
      l.put('LeadSourceLevel2', record.Lead_source_Level_2__c);
      l.put('EnquiryMethod', record.Enquiry_Method__c);
      l.put('UserId', u.Id);
      l.put('UserName', u.Name);
      l.put('UserSalesmanId', u.Wizard_ID__c);
      l.put('objectName', 'LEAD');
      l.put('triggerType', triggerType);
      l.put('HolidayEmailOptIn', record.Holidays_Email_Opt_In__c);
      l.put('HolidayPostOptIn', record.Holidays_Post_Opt_In__c);
      l.put('HolidaySMSOptIn', record.Holidays_SMS_Opt_In__c);
      l.put('HolidayTelephoneOptIn', record.Holidays_Telephone_Opt_In__c);
      l.put('SalesEmailOptIn', record.Email_Opt_In__c);
      l.put('SalesPostOptIn', record.Post_Opt_In__c);
      l.put('SalesSMSOptIn', record.SMS_Opt_In__c);
      l.put('SalesTelephoneOptIn', record.Telephone_Opt_In__c);
      leads.add(l);
    }
    data.put('Results', leads);
    data.put('Errors', null);
	ODIRequest.Post post = ODIRequest.createPost(name, data);
    String body = JSON.serialize(post);
    If (!Test.isRunningTest()) ODIRequest.sendFutureRequest(name, body);
  }
 
  /**********************************************************************************************
  * @Author: Ceterna
  * @Date:    
  * @Description: Turns a custom metadata setting into a map to make it easier to reference values.
  * @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description] 
  ***********************************************************************************************/ 
  private static Map<String, String> getSettingMap(String customSetting, String fields) {
    String query = 'SELECT ' + fields + ' FROM ' + customSetting;
    List<sObject> settings = Database.query(query);
    Map<String, String> mappings = new Map<String, String>();
    for (Integer i = 0; i < settings.size(); i++) {
      sObject setting = settings[i];
      if (customSetting == 'Lead_SLA_Response__mdt') {
        mappings.put((String) setting.get('Source__c'), (String) String.valueOf(setting.get('Response_Time__c')));
      }
      if (customSetting == 'Lead_Business_Hours__mdt') {
        mappings.put((String) setting.get('Record_Type__c'), (String) setting.get('Business_Hours__c'));
      }
      if (customSetting == 'Lead_Queue_Assignment__mdt') {
        String park = (String) setting.get('Region__c');
        String source = (String) setting.get('Source__c');
        if (park == '' || park == null) park = 'NONE';
        mappings.put(park + source, (String) setting.get('Queue__c'));
      }
    }
    return mappings;
  }
    
  /**********************************************************************************************
  * @Author: Ceterna
  * @Date:    
  * @Description: Gets the Id of a RecordType based on the record type name and object
  * @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description] 
  ***********************************************************************************************/ 
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

    /**********************************************************************************************
    * @Author: Susanna Taylor
    * @Date: 08/08/2019
    * @Description: manipulates phone and mobile phone data formatting prior to save
    * @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description] 
    ***********************************************************************************************/  
    public static void processPhoneNumbersInsert(List<Lead> newLeadList)  {
        for (Lead l : newLeadList) {
            l.MobilePhone = UtilityHandler.mapPhoneToMobile('', l.phone, '', l.MobilePhone);  
            l.MC_Lead_Mobile_Phone__c = UtilityHandler.mapMobileToMarketing('', l.MobilePhone, l.MC_Lead_Mobile_Phone__c);                
        }
    }
    
    /**********************************************************************************************
    * @Author: Susanna Taylor
    * @Date: 26/07/2019
    * @Description: manipulates phone and mobile phone data formatting prior to save
    * @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description] 
    ***********************************************************************************************/  
    public static void processPhoneNumbersUpdate(List<Lead> newLeadList, Map<Id, Lead> oldLeadMap)  {
        for (Lead l : newLeadList) {
                l.mobilePhone = UtilityHandler.mapPhoneToMobile(oldLeadMap.get(l.Id).phone, l.phone, oldLeadMap.get(l.Id).mobilePhone, l.mobilePhone);
                l.MC_Lead_Mobile_Phone__c = UtilityHandler.mapMobileToMarketing(oldLeadMap.get(l.Id).mobilePhone, l.mobilePhone, l.MC_Lead_Mobile_Phone__c);             
        }
    }      
}
/**********************************************************************************************
* @Author: Ceterna
* @Date:        
* @Description: Helper class to store the various methods we run from the AccountTriggerHandler.
*	If it affects the Account in a trigger, the logic will be here.
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description] 
***********************************************************************************************/  
public class AccountHandler {
    
  /**********************************************************************************************
  * @Author: Ceterna
  * @Date: 22/07/2019      
  * @Description: Sets the Enquiry_Park_IDs__c field based on the park names given in the 
  * 	Enquiry_Parks__pc multiselect picklist. Called beforeInsert and beforeUpdate.
  * @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description] 
  ***********************************************************************************************/  
  public static void setParkIds(List<Account> accounts) {
    // get all the park names from the leads
    List<String> parkNames = new List<String>();
    for (Integer a = 0; a < accounts.size(); a++) {
      if (accounts[a].Enquiry_Parks__pc != null) {
        List<String> values = accounts[a].Enquiry_Parks__pc.split(';');
        for (Integer v = 0; v < values.size(); v++) {
          String parkName = values[v].trim();
          if (parkNames.indexOf(parkName) == -1) parkNames.add(parkName);
        }
      }   
    }
    // get park ids
    List<Park__c> parks = [
      SELECT Id, Name
      FROM Park__c
      WHERE Name IN :parkNames
    ];
    // map park name to id
    Map<String, String> parkNameToId = new Map<String, String>();
    for (Integer p = 0; p < parks.size(); p++) {
      parkNameToId.put(parks[p].Name, parks[p].Id);
    }
    // set comma id list
    for (Integer a = 0; a < accounts.size(); a++) {
      List<String> pids = new List<String>();
      if (accounts[a].Enquiry_Parks__pc != null) {
        List<String> values = accounts[a].Enquiry_Parks__pc.split(';');
        for (Integer v = 0; v < values.size(); v++) {
          String parkName = values[v].trim();
          String pid = parkNameToId.get(parkName);
          if (pid != null && pids.indexOf(pid) == -1) {
            pids.add(pid);
          }
        }
      }
      accounts[a].Enquiry_Park_IDs__c = String.join(pids, ',');
    }  
  }

  /**********************************************************************************************
  * @Author: Ceterna
  * @Date:
  * @Description: Posts the field changes made in Salesforce to ODI, to keep both systems in sync.
  * 	Only sends the fields listed below.
  * @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description] 
  ***********************************************************************************************  
  public static void postChanges(List<Account> records, String triggerType) {
    User u = [SELECT Id, Name, Wizard_ID__c FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
    String name = 'sync.upsert.contacts';
    Map<String, Object> data = new Map<String, Object>();
    List<Map<String, Object>> contacts = new List<Map<String, Object>>();
    for (Integer i = 0; i < records.size(); i++) {
      Account record = records[i];
      Map<String, Object> c = new Map<String, Object>();
      c.put('PrimaryId', record.Primary_Id__pc != null ? Integer.valueOf(record.Primary_Id__pc) : null);
      c.put('LeadId', null);
      c.put('ContactId', record.Id);
      c.put('Salutation', record.Salutation);
      c.put('FirstName', record.FirstName);
      c.put('LastName', record.LastName);
      c.put('Street', record.BillingStreet);
      c.put('City', record.BillingCity);
      c.put('PostalCode', record.BillingPostalCode);
      c.put('County', record.BillingState);
      c.put('Country', record.BillingCountry);
      c.put('Email', record.PersonEmail);
      c.put('MobilePhone', record.PersonMobilePhone);
      c.put('Phone', record.Phone);
      c.put('RecordTypeName', null);
      c.put('LeadSource', null);
      c.put('LeadSourceLevel2', record.Lead_Source_Level_2__c);
      c.put('EnquiryMethod', null);
      c.put('UserId', u.Id);
      c.put('UserName', u.Name);
      c.put('UserSalesmanId', u.Wizard_ID__c);
      c.put('objectName', 'CONTACT');
      c.put('triggerType', triggerType);
      c.put('tradeAccount', record.tradeAccount__c);
      c.put('HolidayEmailOptIn', record.Holidays_Email_Opt_In__pc);
      c.put('HolidayPostOptIn', record.Holidays_Post_Opt_In__pc);
      c.put('HolidaySMSOptIn', record.Holidays_SMS_Opt_In__pc);
      c.put('HolidayTelephoneOptIn', record.Holidays_Telephone_Opt_In__pc);
      c.put('SalesEmailOptIn', record.Email_Opt_In__pc);
      c.put('SalesPostOptIn', record.Post_Opt_In__pc);
      c.put('SalesSMSOptIn', record.SMS_Opt_In__pc);
      c.put('SalesTelephoneOptIn', record.Telephone_Opt_In__pc);
      c.put('OwnerStatus', record.Owner_Status__pc);
      contacts.add(c);
    }
    data.put('Results', contacts);
    data.put('Errors', null);
	ODIRequest.Post post = ODIRequest.createPost(name, data);
    String body = JSON.serialize(post);
    ODIRequest.sendFutureRequest(name, body);
  }

    /**********************************************************************************************
    * @Author: Susanna Taylor
    * @Date: 26/07/2019
    * @Description: manipulates phone and mobile phone data formatting prior to save
    * @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description] 
    ***********************************************************************************************/  
    public static void processPhoneNumbersInsert(List<Account> newAccountList)  {
        for (Account a : newAccountList) {
            if (a.isPersonAccount) {
                a.personMobilePhone = UtilityHandler.mapPhoneToMobile('', a.phone, '', a.personMobilePhone);  
                a.MC_Contact_Mobile_Phone__pc = UtilityHandler.mapMobileToMarketing('', a.personMobilePhone, a.MC_Contact_Mobile_Phone__pc);                
            }
        }
    }
    
    /**********************************************************************************************
    * @Author: Susanna Taylor
    * @Date: 26/07/2019
    * @Description: manipulates phone and mobile phone data formatting prior to save
    * @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description] 
    ***********************************************************************************************/  
    public static void processPhoneNumbersUpdate(List<Account> newAccountList, Map<Id, Account> oldAccountMap)  {
        for (Account a : newAccountList) {
            if (a.isPersonAccount) {
                a.personMobilePhone = UtilityHandler.mapPhoneToMobile(oldAccountMap.get(a.Id).phone, a.phone, oldAccountMap.get(a.Id).personMobilePhone, a.personMobilePhone);
                a.MC_Contact_Mobile_Phone__pc = UtilityHandler.mapMobileToMarketing(oldAccountMap.get(a.Id).personMobilePhone, a.personMobilePhone, a.MC_Contact_Mobile_Phone__pc);                
            }
        }
    }  
    


}
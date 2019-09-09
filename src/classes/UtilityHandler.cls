/**********************************************************************************************
* @Author: Susanna Taylor
* @Date:  08/08/2019      
* @Description: Helper class to store utility methods for primitive data types or generic sobjects
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description] 
***********************************************************************************************/  
public class UtilityHandler {

    /**********************************************************************************************
    * @Author: Susanna Taylor
    * @Date: 26/07/2019
    * @Description: map phone to mobile if mobile is blank and not changed and phone is changed and
    *  is formatted as a mobile number
    * @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description] 
    ***********************************************************************************************/  
    public static String mapPhoneToMobile(String oldPhone, String newPhone, String oldMobile, String newMobile) {
        if (string.isBlank(oldMobile)
           && string.isBlank(newMobile)
           && oldPhone != newPhone
           && mobileFormat(newPhone)
         ) {
                newMobile = newPhone;
            }
        return newMobile;
    }
    
    /**********************************************************************************************
    * @Author: Susanna Taylor
    * @Date: 26/07/2019
    * @Description: map mobile number to marketing and format - 
    * @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description] 
    ***********************************************************************************************/          
    public static string mapMobileToMarketing(String oldMobile, String newMobile, String marketingMobile) {
        if (oldMobile != newMobile
        ) {
            if (!string.isblank(newMobile)) {
                newMobile = cleanseMobile(newMobile);
                integer startStringLength = mobileFormat(newMobile) ? newMobile.indexOf('7') : -1;
                marketingMobile = startStringLength == -1 ? '' : '44' + newMobile.right(newMobile.Length() - startStringLength);                
            }
            else {
                marketingMobile = null;
            }

        }
        return marketingMobile;
    }
    
    /**********************************************************************************************
    * @Author: Susanna Taylor
    * @Date: 26/07/2019
    * @Description: test if a string meets mobile format conditions. Must start with an element in
    *  mobileStartString set and must be numbers only after spaces, dashes and brackets are removed
    * @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description] 
    ***********************************************************************************************/      
    public static Boolean mobileFormat(String testNumber) {
        boolean isMobileFormat = false;
        if (!string.isblank(testNumber)) {
            Set<String> mobileStartString = new Set<String>{'07', '7', '447', '00447', '4407'};
            testNumber = cleanseMobile(testNumber);
            
            for (String str : mobileStartString) {
                if (testNumber.startsWith(str)) {
                    isMobileFormat = true;
                    break;
                }
            }
            isMobileFormat = testNumber.isNumeric() ? isMobileFormat : false;            
        }
        return isMobileFormat;
    }

    /**********************************************************************************************
    * @Author: Susanna Taylor
    * @Date: 23/08/2019
    * @Description: remove spaces, dashes and special caracters
    * @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description] 
    ***********************************************************************************************/      
    public static String cleanseMobile(String testNumber) {
        if (!string.isblank(testNumber)) {
            testNumber = testNumber.replace(' ','');
            testNumber = testNumber.replace('-','');
            testNumber = testNumber.replace('(','');
            testNumber = testNumber.replace(')','');
            testNumber = testNumber.replace('+', '');
        }
            return testNumber;
    }    
        
  /**********************************************************************************************
  * @Author: Susanna Taylor
  * @Date:  08/08/2019  
  * @Ref:	B0114
  * @Description: Posts tracked changes to ODI
  * @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description] 
  ***********************************************************************************************/
    public static void postChanges(List<SObject> newSObjList, Map<Id, SObject> oldSObjMap, String triggerType, String sObjectType) {
        User u = [SELECT Id, 
                  	Name, 
                  	Wizard_ID__c 
                  FROM User 
                  WHERE Id = :UserInfo.getUserId() 
                  LIMIT 1];
        
        String name = 'sync.upsert.contacts';
        Map<String, Object> data = new Map<String, Object>();
        List<Map<String, Object>> recordsToUpdate = new List<Map<String, Object>>();
        List<ODI_Request_Mapping__mdt> mappingList = fetchMappings(sObjectType);
        
        for (SObject so : newSObjList) {
            Map<String, Object> valueMap = new Map<String, Object>();
            Boolean isTrackedFieldChanged = false;
            
            for (ODI_Request_Mapping__mdt mapping : mappingList) {
                
                String salesforceFieldName = mapping.Salesforce_Field_API_Name__c;
                String odiFieldName = mapping.ODI_Field_Name__c;
                system.debug(salesforceFieldName+', '+odiFieldName);
                Object fieldValue = mapping.convert_To_Integer__c ? integer.valueOf(so.get(salesforceFieldName)) : string.isBlank(salesforceFieldName) ? null : so.get(salesforceFieldName);
                
                if (triggerType == 'CREATE'
                    || (!string.isBlank(salesforceFieldName) && so.get(salesforceFieldName) != oldSobjMap.get(so.id).get(salesforceFieldName))
                ) {
                    isTrackedFieldChanged = true;
                }
                
                valueMap.put(odiFieldName, fieldValue);
            }
         
            if (isTrackedFieldChanged) {
                valueMap.put('UserId', u.Id);
                valueMap.put('UserName', u.Name);
                valueMap.put('UserSalesmanId', u.Wizard_ID__c);
                valueMap.put('objectName', sobjectType.toUpperCase());
                valueMap.put('triggerType', triggerType);
             
                recordsToUpdate.add(valueMap);
            }
        }
        
        if (!recordsToUpdate.isEmpty()) {
            data.put('Results', recordsToUpdate);
            data.put('Errors', null);
            ODIRequest.Post post = ODIRequest.createPost(name, data);
            String body = JSON.serialize(post);
            ODIRequest.sendFutureRequest(name, body);            
        }
    } 
    
  /**********************************************************************************************
  * @Author: Susanna Taylor
  * @Date: 08/08/2019   
  * @Description: fetch  mappings from metadata
  * @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description] 
  ***********************************************************************************************/ 
    private static List<ODI_Request_Mapping__mdt> fetchMappings(String sobjectType) {
        List<ODI_Request_Mapping__mdt> rmList = [SELECT Id,
                                                 	Salesforce_Field_API_Name__c,
                                                 	ODI_Field_Name__c,
                                                 	Convert_To_Integer__c
                                                 FROM ODI_Request_Mapping__mdt
                                                 WHERE SObject_Type_Picklist__c = :sobjectType
                                                 AND Is_Active__c = true
                                                 Order by ODI_Field_Name__c
                                                ];
        return rmList;
    } 
  
}
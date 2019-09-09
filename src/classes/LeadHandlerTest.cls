/**********************************************************************************************
* @Author: Ceterna
* @Date:        
* @Description: Test class for LeadHandler, also tests the LeadTriggerHandler by default
* @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description] 
***********************************************************************************************/  
@IsTest
public class LeadHandlerTest {
    
  /**********************************************************************************************
  * @Author: Ceterna
  * @Date:        
  * @Description: Creates some test leads
  * @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description] 
  * 			22/07/2019 - B0054 - Elliott TN - Updated test leads to include the Park_Codes__c field
  ***********************************************************************************************/  
  private static List<Lead> createLeads() {
    List<Lead> leads = new List<Lead>();
    for (Integer i = 0; i < 50; i++) {
      Lead l = new Lead();
      l.FirstName = 'Test';
      l.LastName = '' + i;
      l.Status = 'New';
      l.Auto_Created__c = true;
      l.Park_Codes__c = 'Whitley Bay';
      leads.add(l);
    }
    insert leads;
    return leads;
  }
    
  /**********************************************************************************************
  * @Author: Ceterna
  * @Date:        
  * @Description: Test outbound post class
  * @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description] 
  ***********************************************************************************************/
  @IsTest
  public static void testPostChanges() {    
    Test.setMock(HttpCalloutMock.class, new ODIRequestMock());
    List<Lead> records = createLeads();
    // can't test res as future method
  //  LeadHandler.postChanges(records, 'TEST');
  }

}
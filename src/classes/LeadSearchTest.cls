/**********************************************************************************************
 * @Author: Ceterna
 * @Date:
 * @Description: Test class for LeadSearch
 * @Revision(s): [Date] - [Change Reference] - [Changed By] - [Description]
 ***********************************************************************************************/
@isTest
public class LeadSearchTest {
    
  @isTest
  public static void runFullSearchTest() {
    Test.setMock(HttpCalloutMock.class, new ODIRequestMock());
    Lead newLead = new Lead();
    newLead.FirstName = 'Test';
    newLead.LastName = 'Test';
    newLead.Email = 'test@test.com';
    newLead.Company = 'Test';
    insert newLead;
    Map<String, Object> results = LeadSearch.runFullSearch(null, null, null, null, null, null);
    List<Object> leads = (List<Object>) results.get('leads');
  }
    
  @isTest
  public static void changeRTTest() {
    Test.setMock(HttpCalloutMock.class, new ODIRequestMock());
    Lead newLead = new Lead();
    newLead.FirstName = 'Test';
    newLead.LastName = 'Test';
    newLead.Email = 'test@test.com';
    newLead.Company = 'Test';
    insert newLead;
    String result = LeadSearch.changeRT(newLead.Id);
  }

}
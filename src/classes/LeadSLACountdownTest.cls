@isTest
public class LeadSLACountdownTest {

  @isTest
  public static void runTest() {
    Test.setMock(HttpCalloutMock.class, new ODIRequestMock());
    String noLeads = LeadSLACountdown.getLead('test');
    System.assertEquals('Error: No Lead found with this Id', noLeads);
    Lead newLead = new Lead();
    newLead.Salutation = 'Mr';
    newLead.FirstName = 'Test';
    newLead.LastName = 'Test';
    newLead.Company = 'Test';
    BusinessHours bhs = LeadSLACountdown.getHours(null);
    newLead.Business_Hours__c = bhs == null ? null : bhs.Id;
    insert newLead;
    String noDate = LeadSLACountdown.getLead(newLead.Id);
    newLead.SLA_Deadline__c = Date.today();
    update newLead;
    String pass = LeadSLACountdown.getLead(newLead.Id);
    System.assert(pass.indexOf('Error') == -1);
  }
    
}
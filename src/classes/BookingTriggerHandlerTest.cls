@IsTest
public class BookingTriggerHandlerTest {
    
  private static Contact newContact() {
    Contact c = new Contact();
    c.Salutation = 'Mr';
    c.FirstName = 'Test';
    c.LastName = 'Test';
    insert c;
    return c;
  }
    
  private static Lead newLead() {
    Lead l = new Lead();
    l.Salutation = 'Mr';
    l.FirstName = 'Test';
    l.LastName = 'Test';
    insert l;
    return l;
  }
    
  private static Park__c newPark() {
    Park__c p = new Park__c();
    p.Name = 'Test Park';
    insert p;
    return p;
  }
    
  private static Campaign newCampaign(String parkId) {
    Campaign c = new Campaign();
    c.Name = 'Test Campaign';
    c.Park__c = parkId;
    insert c;
    return c;
  }
    
  private static CampaignMember newMember(String campaignId, String leadId, String contactId) {
    CampaignMember m = new CampaignMember();   
    m.CampaignId = campaignId;
    m.LeadId = leadId;
    m.ContactId = contactId;
    insert m;
    return m;
  }
    
  private static Holiday_Booking__c newBooking(String leadId, String contactId, String parkId) {
    Holiday_Booking__c b = new Holiday_Booking__c();
    b.Lead__c = leadId;
    b.Contact__c = contactId;
    b.Park__c = parkId;
    b.Hot_Hols_Campaign__c = 1;
    return b;
  }
    
  @IsTest
  private static void testBookingTrigger() {
    Test.setMock(HttpCalloutMock.class, new ODIRequestMock());
    Park__c p = newPark();
    Campaign m = newCampaign(p.Id);
    Lead l = newLead();
    Contact c = newContact();
    Lead l2 = newLead();
    CampaignMember e = newMember(m.Id, l2.Id, null);
    Holiday_Booking__c b1 = newBooking(l.Id, null, p.Id);
    Holiday_Booking__c b2 = newBooking(null, c.Id, p.Id);
    Test.startTest();
      insert b1;
      insert b2;
      update b1;
      update b2;
    Test.stopTest();
    System.assertNotEquals(null, b1.Id);
    System.assertNotEquals(null, b2.Id);
  }

}
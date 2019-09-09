@IsTest
public class ODIMapperTest {
    
  @IsTest
  private static void testMapProduct() {
    ODIMapper.StockClass i = new ODIMapper.StockClass();
    i.Policy = new ODIMapper.PolicyClass();
    Product2 p = ODIMapper.mapProduct(i);
    System.assertNotEquals(null, p);
  }
    
  @IsTest
  private static void testMapPrice() {
    ODIMapper.PriceClass i = new ODIMapper.PriceClass();
    Price__c p = ODIMapper.mapPrice(i, 'x');
    System.assertNotEquals(null, p);
  }
    
  @IsTest
  private static void testMapImage() {
    Stock_Image__c s = ODIMapper.mapImage('www.google.com', 'x');
    System.assertNotEquals(null, s);
  }
  
  @IsTest
  private static void testMapPitch() {
    ODIMapper.PitchClass i = new ODIMapper.PitchClass();
    Line_Item__c  p = ODIMapper.mapPitch(i);
    System.assertNotEquals(null, p);
  }
    
  @IsTest
  private static void testMapPX() {
    ODIMapper.PXUnitClass i = new ODIMapper.PXUnitClass();
    Inbound_PX_Unit__c p = ODIMapper.mapPX(i);
    System.assertNotEquals(null, p);
  }
    
  @IsTest
  private static void testMapEnquiry() {
    ODIMapper.LeadClass i = new ODIMapper.LeadClass();
    i.Enquiries = new List<ODIMapper.EnquiryClass>();
    i.Enquiries.add(new ODIMapper.EnquiryClass());
    List<Task> p = ODIMapper.mapEnquiries(i, null, null, null);
    System.assertNotEquals(null, p);
  }
    
  @IsTest
  private static void testSetEnquiryLead() {
    Lead l = new Lead();
    ODIMapper.EnquiryClass e = new ODIMapper.EnquiryClass();
    l = ODIMapper.setEnquiryLead(l, e);
    System.assertNotEquals(null, l);
  }
    
  @IsTest
  private static void testSetEnquiryContact() {
    Account a = new Account();
    ODIMapper.EnquiryClass e = new ODIMapper.EnquiryClass();
    a = ODIMapper.setEnquiryContact(a, e);
    System.assertNotEquals(null, a);
  }

}
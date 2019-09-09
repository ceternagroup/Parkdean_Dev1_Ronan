@IsTest
public class RMReportClassTest {
    
  @IsTest
  public static void testGetReportData() {
    String data = RMReportClass.getReportData();
    System.assertNotEquals(null, data);
  }

}
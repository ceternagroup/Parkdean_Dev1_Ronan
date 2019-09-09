@IsTest
public class CustomTabsTest {
    
  @IsTest
  public static void testGetTabs() {
    Integer expectedTabs = [
      SELECT Id
      FROM CustomTab__mdt
    ].size();
    Integer actualTabs = CustomTabs.getTabs().size();
    System.assertEquals(expectedTabs, actualTabs);
  }

}
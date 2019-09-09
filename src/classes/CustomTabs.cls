public class CustomTabs {
    
  @AuraEnabled
  public static List<CustomTab__mdt> getTabs() {
    List<CustomTab__mdt> tabs = new List<CustomTab__mdt>();
    tabs = [
      SELECT Object_Label__c, Object_Name__c,
        Tab_Background_Colour__c, Tab_Text_Colour__c,
        Object_Plural__c
      FROM CustomTab__mdt
    ];
    return tabs;
  }

}
public class ParkMap {
    
  @AuraEnabled
  public static String getMap(String recordId) {
    String parkMap;
    Quote q = [
      SELECT Id, Map_Image_URL__c
      FROM Quote
      WHERE Id = :recordId
      LIMIT 1
    ];
    parkMap = q.Map_Image_URL__c;
    return parkMap;
  }

}
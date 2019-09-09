public without sharing class BookingHandler {
     
  public static void checkHotLeads(List<Holiday_Booking__c> bookings) {
    // get odi id
    String ODI = [SELECT Id FROM User WHERE Name = 'ODI' LIMIT 1].Id;
    String holidayMakerId = getRecordTypeId('Holiday_Maker', 'Lead');
    // for each booking, get the contact or lead id, and set the hot hols campaign level, 1 overriding all
    Map<String, Map<Id, Integer>> parkHotMap = new Map<String, Map<Id, Integer>>();
    Map<String, String> parkCampaignMap = new Map<String, String>();
    Map<String, String> campaignParkMap = new Map<String, String>();
    Map<String, String> campaignOwnerMap = new Map<String, String>();
    Set<Id> leadIds = new Set<Id>();
    Set<Id> contactIds = new Set<Id>();
    Set<Id> parkIds = new Set<Id>();
    SeT<Id> campaignIds = new Set<Id>();
    for (Integer i = 0; i < bookings.size(); i++) {
      Holiday_Booking__c b = bookings[i];
      Map<Id, Integer> existingMap = parkHotMap.get(b.Park__c);
      Map<Id, Integer> hotMap = existingMap != null ? existingMap : new Map<Id, Integer>();
      Integer hot = Integer.valueOf(b.Hot_Hols_Campaign__c);
      Id cid = b.Contact__c;
      Id lid = b.Lead__c;
      if (cid != null) {
        contactIds.add(cid);
        Integer existing = hotMap.get(cid);
        hot = existing == null ? hot : existing == 1 ? 1 : hot;
        hotMap.put(cid, hot);
      } else if (lid != null) {
		leadIds.add(lid);   
        Integer existing = hotMap.get(lid);
        hot = existing == null ? hot : existing == 1 ? 1 : hot;
        hotMap.put(lid, hot);
      }
      parkHotMap.put(b.Park__c, hotMap);
      parkIds.add(b.Park__c);
    }
    System.debug(parkHotMap);
    Map<String, String> holidayOwnerMap = new Map<String, String>();
    // get holiday makers to change owner
    List<Lead> holidayMakers = [
      SELECT Id, OwnerId
      FROM Lead
      WHERE RecordTypeId = :holidayMakerId
      AND Id IN :leadIds
    ];
    // for each park we have we need to get the relevant campaigns
    List<Campaign> campaigns = new List<Campaign>();
    String recordTypeId = getRecordTypeId('Hot_Holiday_Campaign', 'Campaign');
    campaigns = [
      SELECT Id, Park__c, OwnerId
      FROM Campaign
      WHERE Park__c IN :parkIds
      AND RecordTypeId = :recordTypeId
    ];
    for (Integer c = 0; c < campaigns.size(); c++) {
      campaignIds.add(campaigns[c].Id);
      parkCampaignMap.put(campaigns[c].Park__c, campaigns[c].Id);
      campaignParkMap.put(campaigns[c].Id, campaigns[c].Park__c);
      campaignOwnerMap.put(campaigns[c].Id, campaigns[c].OwnerId);
    }
    // get existing campaign members and decide who to remove if no longer hot
    List<CampaignMember> deleteMembers = new List<CampaignMember>();
    List<CampaignMember> existingMembers = new List<CampaignMember>();
    existingMembers = [
      SELECT Id, LeadId, ContactId, CampaignId
      FROM CampaignMember
      WHERE CampaignId IN :campaignIds
      AND (LeadId IN :leadIds OR ContactId IN :contactIds)
    ];
    for (Integer cm = 0; cm < existingMembers.size(); cm++) {
      CampaignMember member = existingMembers[cm];
      String whoId = member.ContactId != null ? member.ContactId : member.LeadId;
      String parkId = campaignParkMap.get(member.CampaignId);
      Integer hot = parkHotMap.get(parkId).get(whoId);
      if (hot == 0 || hot == null) {
        deleteMembers.add(member);
        if (member.LeadId != null) {
          holidayOwnerMap.put(member.LeadId, ODI);
        } 
      }
    }
    delete deleteMembers;
    // for each park in the hot map get the hot ones and create a member for them
    List<CampaignMember> newMembers = new List<CampaignMember>();
    for (String park : parkHotMap.keySet()) {
      for (Id who : parkHotMap.get(park).keySet()) {
        Integer hot = parkHotMap.get(park).get(who);
        if (hot == 1) {
          CampaignMember member = new CampaignMember();
          member.CampaignId = parkCampaignMap.get(park);
          String whoType = getRecordObject(String.valueOf(who));
          if (whoType == 'Lead') member.LeadId = who;
          if (whoType == 'Contact') member.ContactId = who;
          if (whoType != null && member.CampaignId != null) {
            newMembers.add(member); 
            if (whoType == 'Lead') {
              holidayOwnerMap.put(member.LeadId, campaignOwnerMap.get(member.CampaignId));    
            }
          }
        }
      }
    }
    System.debug(newMembers);
    Database.insert(newMembers, false);
    // for each holiday maker set, change the owner
    for (Integer i = 0; i < holidayMakers.size(); i++) {
      String newOwner = holidayOwnerMap.get(holidayMakers[i].Id);
      if (newOwner != null) holidayMakers[i].OwnerId = newOwner;
    }
    Database.update(holidayMakers, false);
  }
    
  private static String getRecordObject(String recordId) {
    String code = recordId.substring(0, 3);
    if (code == '003') return 'Contact';
    if (code == '00Q') return 'Lead';
    return null;
  }
    
  private static String getRecordTypeId(String name, String obj) {
    String recordTypeId = [
      SELECT Id 
      FROM RecordType 
      WHERE SobjectType = :obj 
      AND DeveloperName = :name
      LIMIT 1
    ].Id;
    return recordTypeId;
  }

}
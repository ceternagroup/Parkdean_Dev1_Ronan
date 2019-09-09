@isTest
public with sharing class PBBTestChatterPostWithFile {

	@IsTest(SeeAllData=true)
  public static void testChatterPost()
    {
        Integer recordCount = 1;
        List<Batch_Log__c> accts = new List<Batch_Log__c>();
        accts.add(new Batch_Log__c());
        upsert accts;
        System.assertEquals(recordCount, accts.size());

        ContentVersion contentVersion = new ContentVersion(
            Title = 'Penguins',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        upsert contentVersion;
        List<ContentDocument> docs = [SELECT Id FROM ContentDocument LIMIT 1];
        Id targetfileId = docs[0].Id;

        CollaborationGroup newGroup = new CollaborationGroup();
        newGroup.Name = 'Public Test Group';
        newGroup.CollaborationType = 'Public';
        upsert newGroup;

        List<PBBChatterPostWithFile.PostChatterWithFileRequest> reqs = new List<PBBChatterPostWithFile.PostChatterWithFileRequest>();

        for (Batch_Log__c acct : accts)
        {
            PBBChatterPostWithFile.PostChatterWithFileRequest req = new PBBChatterPostWithFile.PostChatterWithFileRequest();
            req.recordId = acct.id;
            req.fileId = targetfileId;
            req.groupId = newGroup.Id;
            req.message = 'Post in chatter with file';
            reqs.add(req);
        }

        List<PBBChatterPostWithFile.PostChatterWithFileResult> results = PBBChatterPostWithFile.postWithExistingFile(reqs);
        System.assert(results.size() > 0);
    }
}
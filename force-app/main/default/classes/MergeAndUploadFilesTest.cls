@IsTest
private class MergeAndUploadFilesTest {
    @IsTest
    static void testMergeAndUploadFiles() {
        Account acct = new Account(Name = 'Test Account', BillingCountry = 'Canada', Account_Language__c = 'French');
        insert acct;

        Case caseRecord = new Case();
        caseRecord.Subject = 'Test Case';
        caseRecord.AccountId = acct.Id;
        insert caseRecord;

        String json1 = '[{"fileName":"file1.png","fileBody":"aGVsbG8gd29ybGQ="}]';
        String json2 = '[{"fileName":"file2.jpg","fileBody":"aGVsbG8gd29ybGQ="}]';
        String json3 = '[{"fileName":"file3.pdf","fileBody":"aGVsbG8gd29ybGQ="}]';

        MergeAndUploadFiles.MergeAndUploadRequest req = new MergeAndUploadFiles.MergeAndUploadRequest();
        req.json1 = json1;
        req.json2 = json2;
        req.json3 = json3;
        req.recordId = caseRecord.Id;

        Test.startTest();
        MergeAndUploadFiles.mergeAndUploadSync(new List<MergeAndUploadFiles.MergeAndUploadRequest>{req});
        Test.stopTest();

        List<ContentVersion> versions = [SELECT Id FROM ContentVersion];
        System.assertEquals(3, versions.size(), 'Expected 3 ContentVersions to be created');
    }

@IsTest
    static void testUploadFiles() {
        Account acct = new Account(Name = 'Test Account', BillingCountry = 'Canada', Account_Language__c = 'French');
        insert acct;

        Case caseRecord = new Case();
        caseRecord.Subject = 'Test Case';
        caseRecord.AccountId = acct.Id;
        insert caseRecord;

        String json = '[{"fileName":"file1.png","fileBody":"aGVsbG8gd29ybGQ="}]';

        FileUploaderFromFlow.MultiFileUploadRequest req = new FileUploaderFromFlow.MultiFileUploadRequest();
        req.fileListJson = json;
        req.recordId = caseRecord.Id;

        Test.startTest();
        FileUploaderFromFlow.uploadFiles(new List<FileUploaderFromFlow.MultiFileUploadRequest>{req});
        Test.stopTest();

        List<ContentVersion> versions = [SELECT Id FROM ContentVersion];
        System.assertEquals(1, versions.size(), 'Expected 1 ContentVersion to be created');
    }
}

@IsTest
private class FileUploaderFromFlowTest {
    @IsTest
    static void testUploadFiles() {
        Account acct = new Account(Name = 'Test Account', BillingCountry = 'Canada', Account_Language__c = 'French');
        insert acct;

        String fileListJson = '[{"fileName":"file1.png","fileBody":"aGVsbG8gd29ybGQ="},{"fileName":"file2.jpg","fileBody":"aGVsbG8gd29ybGQ="}]';

        FileUploaderFromFlow.MultiFileUploadRequest req = new FileUploaderFromFlow.MultiFileUploadRequest();
        req.fileListJson = fileListJson;
        req.recordId = acct.Id;

        Test.startTest();
        FileUploaderFromFlow.uploadFiles(new List<FileUploaderFromFlow.MultiFileUploadRequest>{req});
        Test.stopTest();

        List<ContentVersion> versions = [SELECT Id FROM ContentVersion];
        System.assertEquals(2, versions.size(), 'Expected 2 ContentVersions to be created');
    }
}
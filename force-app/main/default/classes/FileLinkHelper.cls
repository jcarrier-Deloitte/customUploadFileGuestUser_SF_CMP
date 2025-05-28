public without sharing class FileLinkHelper {
    public class Request {
        @InvocableVariable(required=true)
        public Id recordId;
    }

    @InvocableMethod(label='Link Last 5 Uploaded Files')
    public static void linkRecentFiles(List<Request> requests) {
        if (requests.isEmpty()) return;
        Id recordId = requests[0].recordId;

        // Get the 5 most recently uploaded files
        List<ContentVersion> recentVersions = [
            SELECT Id, Title, ContentDocumentId, CreatedDate
            FROM ContentVersion
            ORDER BY CreatedDate DESC
            LIMIT 5
        ];

        List<ContentDocumentLink> links = new List<ContentDocumentLink>();
        for (ContentVersion version : recentVersions) {
            if (version.ContentDocumentId != null) {
                links.add(new ContentDocumentLink(
                    ContentDocumentId = version.ContentDocumentId,
                    LinkedEntityId = recordId,
                    ShareType = 'V',
                    Visibility = 'AllUsers'
                ));
                System.debug('✅ Linking file: ' + version.Title);
            }
        }

        if (!links.isEmpty()) {
            insert links;
            System.debug('✅ Linked ' + links.size() + ' files to record ' + recordId);
        } else {
            System.debug('⚠️ No valid links to insert');
        }
    }
}
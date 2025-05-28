public without sharing class FileUploaderFromFlow {

    @InvocableMethod(label='Upload Multiple Files From Flow')
    public static void uploadFiles(List<MultiFileUploadRequest> requests) {
        List<ContentVersion> versionsToInsert = new List<ContentVersion>();

        for (MultiFileUploadRequest request : requests) {
            if (String.isNotBlank(request.fileListJson) && String.isNotBlank(request.recordId)) {
                try {
                    List<FileMetadata> files = (List<FileMetadata>) JSON.deserialize(
                        request.fileListJson,
                        List<FileMetadata>.class
                    );

                    for (FileMetadata file : files) {
                        if (String.isNotBlank(file.fileName) && String.isNotBlank(file.fileBody)) {
                            versionsToInsert.add(new ContentVersion(
                                Title = file.fileName,
                                PathOnClient = '/' + file.fileName,
                                VersionData = EncodingUtil.base64Decode(file.fileBody),
                                FirstPublishLocationId = request.recordId
                            ));
                        }
                    }
                } catch (Exception e) {
                    throw new FlowException('Error parsing file JSON: ' + e.getMessage());
                }
            }
        }

        if (!versionsToInsert.isEmpty()) {
            insert versionsToInsert;
        }
    }

    public class MultiFileUploadRequest {
        @InvocableVariable(required=true)
        public String fileListJson;

        @InvocableVariable(required=true)
        public String recordId;
    }

    public class FileMetadata {
        public String fileName;
        public String fileBody;
    }
}
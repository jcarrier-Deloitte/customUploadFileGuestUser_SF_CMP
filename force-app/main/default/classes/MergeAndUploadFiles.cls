public without sharing class MergeAndUploadFiles {
    /**
     * Wrapper for Flow input: three JSON‐array strings to merge, plus the target record ID.
     * Each JSON array must be of the form:
     * [
     *   { "fileName":"file1.png", "fileBody":"<base64>" },
     *   { "fileName":"file2.jpg", "fileBody":"<base64>" }
     * ]
     */
    public class MergeAndUploadRequest {
        @InvocableVariable(required=true)
        public String json1;

        @InvocableVariable(required=true)
        public String json2;

        @InvocableVariable(required=true)
        public String json3;

        @InvocableVariable(required=true)
        public String recordId;
    }

    /**
     * Invocable action for Flow: merges json1/json2/json3 into one list of FileMetadata,
     * then immediately inserts a ContentVersion for each file, linking to recordId.
     *
     * Call this **after** your Flow’s “Create Case” element. Because both the Case
     * creation and this Apex run in the same transaction, recordId (the new Case ID)
     * is available in memory and ContentVersion can link to it without error.
     */
    @InvocableMethod(label='Merge Three JSON Arrays and Upload Files (Sync)')
    public static void mergeAndUploadSync(List<MergeAndUploadRequest> requests) {
        for (MergeAndUploadRequest req : requests) {
            // 1) Build one combined List<FileMetadata> from the three JSON inputs
            List<FileMetadata> combinedFiles = new List<FileMetadata>();
            mergeIntoList(req.json1, combinedFiles);
            mergeIntoList(req.json2, combinedFiles);
            mergeIntoList(req.json3, combinedFiles);

            // 2) Insert a ContentVersion record for each file, linking to req.recordId
            List<ContentVersion> versionsToInsert = new List<ContentVersion>();
            for (FileMetadata fm : combinedFiles) {
                if (fm.fileName != null && fm.fileName.trim().length() > 0
                    && fm.fileBody != null && fm.fileBody.trim().length() > 0) 
                {
                    Blob raw;
                    try {
                        raw = EncodingUtil.base64Decode(fm.fileBody.trim());
                    } catch (Exception ex) {
                        // Skip any file whose body isn't valid Base64
                        continue;
                    }
                    versionsToInsert.add(new ContentVersion(
                        Title                  = fm.fileName,
                        PathOnClient           = '/' + fm.fileName,
                        VersionData            = raw,
                        FirstPublishLocationId = req.recordId
                    ));
                }
            }
            if (!versionsToInsert.isEmpty()) {
                insert versionsToInsert;
            }
        }
    }

    /**
     * Helper: if oneJsonArray is non‐blank and valid JSON array, deserialize into
     * List<FileMetadata> and append all items into masterList. Otherwise, skip or throw.
     */
    private static void mergeIntoList(String oneJsonArray, List<FileMetadata> masterList) {
        if (String.isBlank(oneJsonArray)) {
            return;
        }
        String trimmed = oneJsonArray.trim();
        if (trimmed.equals('[]')) {
            return;
        }

        try {
            List<FileMetadata> parsed = 
                (List<FileMetadata>) JSON.deserialize(trimmed, List<FileMetadata>.class);
            if (parsed != null && !parsed.isEmpty()) {
                masterList.addAll(parsed);
            }
        } catch (Exception e) {
            throw new FlowException('Invalid JSON‐array format: ' + e.getMessage());
        }
    }

    /**
     * Inner class for each file entry: { "fileName":"…", "fileBody":"<base64>" }
     */
    public class FileMetadata {
        public String fileName;
        public String fileBody;
    }
}

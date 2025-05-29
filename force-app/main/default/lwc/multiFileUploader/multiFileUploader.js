import { LightningElement, api, track } from 'lwc';

export default class MultiFileUploader extends LightningElement {
    /** Allowed extensions (override via Flow if you like) */
    @api acceptedFormats = ['.pdf', '.png', '.jpg', '.jpeg', '.docx', '.txt'];

    @api recordId;
    @api fileListJson;

    @track isReady    = false;
    @track fileCount  = 0;
    @track errors     = [];

    /** e.g. ".pdf,.png,.jpg" */
    get acceptString() {
        return this.acceptedFormats.join(',');
    }

    handleFileChange(event) {
        const files = Array.from(event.target.files);
        if (!files.length) return;

        // Normalize extensions to lowercase
        const allowed = this.acceptedFormats.map(ext => ext.toLowerCase());
        const validFiles   = [];
        const invalidNames = [];

        // Separate valid/invalid
        files.forEach(file => {
            const idx = file.name.lastIndexOf('.');
            const ext = idx > 0 ? file.name.substring(idx).toLowerCase() : '';
            if (allowed.includes(ext)) {
                validFiles.push(file);
            } else {
                invalidNames.push(file.name);
            }
        });

        // If there were invalid ones, show errors and stop
        if (invalidNames.length) {
            this.errors = invalidNames.map(n => `"${n}" is not allowed`);
            this.isReady = false;
            this.fileCount = 0;
            this.fileListJson = null;
            return;
        } else {
            this.errors = [];
        }

        // Read only the valid files
        const list = [];
        const reads = validFiles.map(file => new Promise((res, rej) => {
            const reader = new FileReader();
            reader.onload = () => {
                list.push({
                    fileName: file.name,
                    fileBody: reader.result.split(',')[1]
                });
                res();
            };
            reader.onerror = rej;
            reader.readAsDataURL(file);
        }));

        Promise.all(reads)
            .then(() => {
                this.fileListJson = JSON.stringify(list);
                this.fileCount    = list.length;
                this.isReady      = true;
            })
            .catch(err => {
                console.error('Error reading files:', err);
            });
    }
}

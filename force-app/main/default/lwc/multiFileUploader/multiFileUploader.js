import { LightningElement, api, track } from 'lwc';

export default class MultiFileUploader extends LightningElement {
    @api acceptedFormats = ['.pdf', '.png', '.jpg', '.jpeg', '.docx', '.txt'];
    @api recordId;
    @api fileListJson = '[]'; // initialize to empty array

    @track isReady    = false;
    @track fileCount  = 0;
    @track errors     = [];
    @track fileList   = []; // <-- Stores { fileName, fileBody }

    get acceptString() {
        return this.acceptedFormats.join(',');
    }

    get fileNames() {
        return this.fileList.map(f => f.fileName);
    }

    handleFileChange(event) {
        const files = Array.from(event.target.files);
        if (!files.length) {
            // No files selected: reset state
            this.fileList = [];
            this.updateFileState();
            return;
        }

        const allowed = this.acceptedFormats.map(ext => ext.toLowerCase());
        const validFiles   = [];
        const invalidNames = [];

        files.forEach(file => {
            const idx = file.name.lastIndexOf('.');
            const ext = idx > 0 ? file.name.substring(idx).toLowerCase() : '';
            if (allowed.includes(ext)) {
                validFiles.push(file);
            } else {
                invalidNames.push(file.name);
            }
        });

        if (invalidNames.length) {
            this.errors = invalidNames.map(n => `"${n}" is not allowed`);
            this.isReady = false;
            this.fileCount = 0;
            this.fileListJson = '[]';
            this.fileList = [];
            return;
        } else {
            this.errors = [];
        }

        const newList = [];
        const reads = validFiles.map(file => new Promise((res, rej) => {
            const reader = new FileReader();
            reader.onload = () => {
                newList.push({
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
                this.fileList = [...this.fileList, ...newList]; // append new files
                this.updateFileState();
            })
            .catch(err => {
                console.error('Error reading files:', err);
            });
    }

    handleRemoveFile(event) {
        const nameToRemove = event.target.dataset.name;
        this.fileList = this.fileList.filter(f => f.fileName !== nameToRemove);
        this.updateFileState();
    }

    updateFileState() {
        this.fileCount = this.fileList.length;
        // Always produce a valid JSON array string, even if empty
        this.fileListJson = JSON.stringify(this.fileList);
        this.isReady = this.fileCount > 0;
    }
}

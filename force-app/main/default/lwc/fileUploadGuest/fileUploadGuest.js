import { LightningElement, api, track } from 'lwc';

export default class FileUploadGuest extends LightningElement {
    @api fileIds = [];    // Output to Flow
    @api fileNames = [];  // Output to Flow

    recordId = '500Hu00002I53QdIAJ';
    acceptedFormats = ['.pdf', '.jpg', '.png', '.txt'];

    token = this.generateToken(); // Shared token used in display

    generateToken() {
        const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
        return Array.from({ length: 10 }, () => chars[Math.floor(Math.random() * chars.length)]).join('');
    }

    handleUploadFinished(event) {
        const uploadedFiles = event.detail.files || [];
        this.fileIds = uploadedFiles.map(file => file.documentId);
        this.fileNames = uploadedFiles.map(file =>
            `guestFile-${this.token}-${file.name}`
        );

        console.log('📄 Uploaded files with token:', this.fileNames);
    }
}

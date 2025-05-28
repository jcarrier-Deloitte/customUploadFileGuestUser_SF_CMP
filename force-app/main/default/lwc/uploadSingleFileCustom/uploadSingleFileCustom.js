import { LightningElement, api, track } from 'lwc';

export default class UploadSingleFileCustom extends LightningElement {
    @api fileName;
    @api fileBody;

    @track isReady = false;

    handleFileChange(event) {
        const file = event.target.files[0];
        if (!file) return;

        const reader = new FileReader();

        reader.onload = () => {
            const base64 = reader.result.split(',')[1];
            this.fileName = file.name;
            this.fileBody = base64;
            this.isReady = true;

            this.dispatchEvent(new CustomEvent('fileready', {
                detail: {
                    fileName: this.fileName,
                    fileBody: this.fileBody
                }
            }));
        };

        reader.onerror = error => {
            console.error('File reading error:', error);
        };

        reader.readAsDataURL(file);
    }
}

import { LightningElement, api, track } from 'lwc';

export default class CustomUploader extends LightningElement {
    @api fileName;
    @api fileBody;
    @api recordId;

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

            this.dispatchEvent(new CustomEvent('filesready', {
                detail: {
                    fileName: this.fileName,
                    fileBody: this.fileBody
                }
            }));
        };

        reader.readAsDataURL(file);
    }
}

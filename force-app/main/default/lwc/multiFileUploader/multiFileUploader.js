import { LightningElement, api, track } from 'lwc';

export default class MultiFileUploader extends LightningElement {
    @api fileListJson;
    @api recordId;

    @track isReady = false;
    @track fileCount = 0;

    handleFileChange(event) {
        const files = event.target.files;
        if (!files.length) return;

        const fileList = [];
        const promises = [];

        for (let file of files) {
            const reader = new FileReader();

            const promise = new Promise((resolve, reject) => {
                reader.onload = () => {
                    const base64 = reader.result.split(',')[1];
                    fileList.push({
                        fileName: file.name,
                        fileBody: base64
                    });
                    resolve();
                };
                reader.onerror = reject;
            });

            reader.readAsDataURL(file);
            promises.push(promise);
        }

        Promise.all(promises).then(() => {
            this.fileListJson = JSON.stringify(fileList);
            this.fileCount = fileList.length;
            this.isReady = true;

            this.dispatchEvent(new CustomEvent('filesready', {
                detail: { fileListJson: this.fileListJson }
            }));
        }).catch(error => {
            console.error('Error reading files:', error);
        });
    }
}

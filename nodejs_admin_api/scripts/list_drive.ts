import * as dotenv from "dotenv";
import { GoogleDriveService } from "./src/modules/external/google_drive.service";
dotenv.config();

async function run() {
    const d = new GoogleDriveService();
    const r = await d.drive.files.list({
        q: "'1DleUW8e0NVE07aYAEQLo7oraDSYtBOZa' in parents and trashed = false",
        fields: "files(id, name)",
    });
    console.log(JSON.stringify(r.data.files, null, 2));
}
run();

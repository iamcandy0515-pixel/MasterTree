import * as dotenv from "dotenv";
import path from "path";
dotenv.config({ path: path.resolve(__dirname, "../.env") });
import { GoogleDriveService } from "../src/modules/external/google_drive.service";

async function run() {
    const gd = new GoogleDriveService();

    const folders = ["TreesQuiz", "TreesQuizThumbnail"];
    for (const name of folders) {
        console.log(`\n🔎 Inspecting Folder: ${name}`);
        const r = await gd.drive.files.list({
            q: `name = '${name}' and mimeType = 'application/vnd.google-apps.folder' and trashed = false`,
            fields: "files(id, name)",
            supportsAllDrives: true,
            includeItemsFromAllDrives: true,
        });

        const folder = r.data.files?.[0];
        if (folder) {
            console.log(`✅ ID: ${folder.id}`);
            const r2 = await gd.drive.files.list({
                q: `'${folder.id}' in parents and trashed = false`,
                fields: "files(id, name)",
                pageSize: 50,
                supportsAllDrives: true,
                includeItemsFromAllDrives: true,
            });
            console.log(`📄 Sample Files:`);
            r2.data.files?.forEach((f: any) =>
                console.log(`   - ${f.name} (${f.id})`),
            );
        } else {
            console.log(`❌ Folder not found`);
        }
    }
}

run().catch(console.error);

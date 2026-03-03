import { google } from "googleapis";
import dotenv from "dotenv";
import fs from "fs";

dotenv.config();

const GOOGLE_DRIVE_FOLDER_ID = "1GK_EJ3ZaJ8nzdH1JW7wD_bXn6RH6BxkT";
const API_KEY = process.env.GOOGLE_DRIVE_API_KEY || process.env.GEMINI_KEY;

function log(msg: string) {
    console.log(msg);
    fs.appendFileSync("drive_debug.log", msg + "\n");
}

async function testDrive() {
    log("🚀 Testing Google Drive API...");
    log(
        `Open Folder: https://drive.google.com/drive/folders/${GOOGLE_DRIVE_FOLDER_ID}`,
    );

    if (!API_KEY) {
        log("❌ No API KEY found!");
        return;
    }
    log(`🔑 API Key found (length): ${API_KEY.length}`);

    const drive = google.drive({
        version: "v3",
        auth: API_KEY,
    });

    const searchTerm = "가시나무_대표";
    const queries = [
        `'${GOOGLE_DRIVE_FOLDER_ID}' in parents and name contains '${searchTerm}' and trashed = false`,
        `name contains '${searchTerm}' and trashed = false`,
        `'${GOOGLE_DRIVE_FOLDER_ID}' in parents`,
    ];

    for (const q of queries) {
        log(`\n🔍 Query: ${q}`);
        try {
            const res = await drive.files.list({
                q: q,
                fields: "files(id, name, mimeType)",
                pageSize: 5,
            });
            const files = res.data.files;
            log(`✅ Result: ${files?.length || 0} files found.`);
            if (files && files.length > 0) {
                files.forEach((f) => log(`   - ${f.name} (${f.id})`));
            } else {
                log("   (No files)");
            }
        } catch (e: any) {
            log(`❌ Error: ${e.message}`);
            if (e.errors) log(JSON.stringify(e.errors, null, 2));
        }
    }
}

testDrive().catch(console.error);

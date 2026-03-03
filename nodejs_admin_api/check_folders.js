const fs = require("fs");
const http = require("http");
const https = require("https");
require("dotenv").config();

const API_KEY = process.env.GOOGLE_DRIVE_API_KEY;
const FOLDER_ID = "1GK_EJ3ZaJ8nzdH1JW7wD_bXn6RH6BxkT";

function fetchTrees() {
    return new Promise((resolve, reject) => {
        http.get("http://localhost:3000/api/trees?limit=200", (res) => {
            let chunks = [];
            res.on("data", (c) => chunks.push(c));
            res.on("end", () => {
                const data = Buffer.concat(chunks).toString("utf-8");
                resolve(JSON.parse(data).data || JSON.parse(data));
            });
            res.on("error", reject);
        });
    });
}

function fetchDriveFiles() {
    return new Promise((resolve, reject) => {
        const q = encodeURIComponent(
            `'${FOLDER_ID}' in parents and trashed=false`,
        );
        const url = `https://www.googleapis.com/drive/v3/files?q=${q}&key=${API_KEY}&fields=files(id,name,mimeType)&pageSize=1000`;
        https.get(url, (res) => {
            let chunks = [];
            res.on("data", (c) => chunks.push(c));
            res.on("end", () => {
                const data = Buffer.concat(chunks).toString("utf-8");
                resolve(JSON.parse(data));
            });
            res.on("error", reject);
        });
    });
}

async function run() {
    try {
        const trees = await fetchTrees();
        const driveRes = await fetchDriveFiles();
        if (driveRes.error) {
            console.error("Drive API Error:", driveRes.error);
            return;
        }

        // Normalize tree names: removing any non-Korean/English letters like spaces, special characters etc. and normalize to NFC
        const driveFiles = driveRes.files.map((f) => f.name.normalize("NFC"));
        const driveTreeNames = new Set();

        driveFiles.forEach((fileName) => {
            const parts = fileName.split("_");
            if (parts.length >= 2) {
                driveTreeNames.add(parts[0].trim());
            } else {
                const nameWithoutExt = fileName.replace(/\.[^/.]+$/, "");
                driveTreeNames.add(nameWithoutExt.trim());
            }
        });

        const standardTrees = trees
            .filter((t) => t.is_auto_quiz_enabled !== false)
            .map((t) => t.name_kr.normalize("NFC").trim());

        const missingInDrive = standardTrees.filter(
            (t) => !driveTreeNames.has(t),
        );
        const extraInDrive = Array.from(driveTreeNames).filter(
            (t) => !standardTrees.includes(t),
        );

        const result = {
            totalStandardDbTrees: standardTrees.length,
            totalUniqueDriveTrees: driveTreeNames.size,
            missingInDrive: missingInDrive,
            extraInDrive: extraInDrive,
        };

        fs.writeFileSync(
            "folder_check_result.json",
            JSON.stringify(result, null, 2),
            "utf-8",
        );
        console.log("Saved to folder_check_result.json");
    } catch (e) {
        console.error(e);
    }
}
run();

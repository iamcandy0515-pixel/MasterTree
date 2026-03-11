function extractFolderId(folderUrl: string) {
    let folderId = "";
    try {
        const urlObj = new URL(folderUrl);
        const idParam = urlObj.searchParams.get("id");
        if (idParam) {
            folderId = idParam;
        } else {
            const parts = urlObj.pathname.split("/");
            folderId = parts[parts.length - 1];
        }
    } catch (e) {
        folderId = folderUrl.split("/").pop() || "";
    }
    return folderId;
}

const quizUrl =
    "https://drive.google.com/drive/folders/1gYSZnnNi81acsFMDaF6VSwJcXkqOD6WC?usp=drive_link";
const extracted = extractFolderId(quizUrl);
console.log(`URL: ${quizUrl}`);
console.log(`Extracted ID: ${extracted}`);
console.log(`Is Correct: ${extracted === "1gYSZnnNi81acsFMDaF6VSwJcXkqOD6WC"}`);

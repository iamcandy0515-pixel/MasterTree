import { GoogleDriveService } from "./src/modules/external/google_drive.service";
import { QuizService } from "./src/modules/quiz/quiz.service";

async function testPdf() {
    console.log("Searching for pdf in Google Drive...");
    const driveService = new GoogleDriveService();
    // Folder ID from GoogleDriveService
    const files = await driveService.searchFilesInFolder(
        "1GK_EJ3ZaJ8nzdH1JW7wD_bXn6RH6BxkT",
        ".pdf",
    );
    if (!files || files.length === 0) {
        console.log("No pdf found");
        return;
    }
    const pdfFile = files[0];
    console.log(
        `Found PDF: ${pdfFile.name} (${pdfFile.id}) - size: ${pdfFile.size}`,
    );

    console.log("Downloading buffer...");
    const pdfBuffer = await driveService.downloadFileAsBuffer(pdfFile.id!);
    console.log(`Downloaded ${pdfBuffer.length} bytes`);

    const quizService = new QuizService();
    console.log("Extracting quiz from buffer...");
    try {
        const result = await quizService.extractQuizFromPdfBuffer(
            pdfBuffer,
            1,
            4,
        );
        console.log("Result:", JSON.stringify(result, null, 2));
    } catch (e: any) {
        console.error("Quiz Service Error:", e);
    }
}

testPdf().catch(console.error);

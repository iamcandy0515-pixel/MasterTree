import { Request, Response } from "express";
import { quizService } from "./quiz.service";
import { successResponse, errorResponse } from "../../utils/response";
import { GoogleDriveService } from "../external/google_drive.service";
import { settingsService } from "../settings/settings.service";
import { extractDriveFolderId } from "../../utils/drive-helper";

/**
 * Quiz Extraction Controller (Strategy F)
 * Handles heavy processing like Google Drive downloads and PDF batch extraction.
 * Optimized for Load Balancing and Rule 1-1.
 */
export class QuizExtractionController {
    /**
     * Validates PDF based on subject, year, round from Google Drive
     */
    async validateDriveFile(req: Request, res: Response): Promise<void> {
        try {
            const { fileId, subject, year, round } = req.body;
            if (!fileId) return errorResponse(res, "fileId is required.", 400);

            const driveService = new GoogleDriveService();
            const pdfBuffer = await driveService.downloadFileAsBuffer(fileId);

            const validation = await quizService.validateQuizPdfFile(pdfBuffer, subject, year, round);

            return successResponse(res, { validation }, "Successfully validated pdf.", 200);
        } catch (error: any) {
            console.error("[QuizExtract] Validate Drive File Error:", error);
            return errorResponse(res, error.message, 500);
        }
    }

    /**
     * Extracts single quiz from Google Drive PDF using questionNumber
     */
    async extractDriveFile(req: Request, res: Response): Promise<void> {
        try {
            const { fileId, questionNumber, optionsCount } = req.body;
            if (!fileId) return errorResponse(res, "fileId is required.", 400);

            const driveService = new GoogleDriveService();
            const pdfBuffer = await driveService.downloadFileAsBuffer(fileId);

            const extractedData = await quizService.extractQuizFromPdfBuffer(pdfBuffer, questionNumber || 1, optionsCount || 4);

            return successResponse(res, { extractedData }, "Successfully extracted quiz from PDF.", 200);
        } catch (error: any) {
            console.error("[QuizExtract] Single Extraction Error:", error);
            return errorResponse(res, error.message, 500);
        }
    }

    /**
     * Extracts multiple quizzes from Google Drive PDF (Batch)
     */
    async extractQuizBatch(req: Request, res: Response): Promise<void> {
        try {
            const { fileId, startNumber, endNumber, subject, year, round } = req.body;
            if (!fileId || !startNumber || !endNumber || !subject || !year || !round) {
                return errorResponse(res, "Missing required parameters for batch extraction.", 400);
            }

            const driveService = new GoogleDriveService();
            let effectiveFileId = await this._resolveFileId(fileId, driveService);

            const pdfBuffer = await driveService.downloadFileAsBuffer(effectiveFileId);
            const batchData = await quizService.extractQuizBatchFromPdf(
                pdfBuffer,
                Number(startNumber),
                Number(endNumber),
                subject,
                Number(year),
                Number(round),
            );

            return successResponse(res, { batchData }, "Successfully extracted quiz batch.", 200);
        } catch (error: any) {
            console.error("[QuizExtract] Batch Extraction Error:", error);
            const { message, status } = this._handleError(error);
            return errorResponse(res, message, status);
        }
    }

    /**
     * Resolves fileId by name search if it's not a typical ID
     */
    private async _resolveFileId(fileId: string, driveService: GoogleDriveService): Promise<string> {
        if (/^[a-zA-Z0-9_-]{25,45}$/.test(fileId.trim())) return fileId;

        const folderUrl = (await settingsService.getExamDriveUrl()) || (await settingsService.getGoogleDriveFolderUrl());
        if (!folderUrl) throw new Error("구글 드라이브 폴더가 설정되지 않았습니다.");

        const folderId = extractDriveFolderId(folderUrl);
        if (!folderId) throw new Error("설정된 구글 드라이브 폴더 URL이 올바르지 않습니다.");

        const files = await driveService.searchFilesInFolder(folderId, fileId.trim());
        if (!files || files.length === 0) throw new Error(`구글 드라이브 폴더 내에서 파일을 찾을 수 없습니다: '${fileId}'`);

        return files[0].id as string;

    }

    /**
     * Maps error messages to appropriate HTTP status codes
     */
    private _handleError(error: any) {
        let message = error.message;
        let status = 500;

        if (error.message.includes("PDF_MISMATCH")) {
            status = 400;
            message = error.message.replace("PDF_MISMATCH: ", "");
        } else if (error.response?.status === 404 || error.message.includes("404") || error.message.includes("not found")) {
            status = 404;
            message = "파일을 찾을 수 없습니다";
        }
        return { message, status };
    }
}

export const quizExtractionController = new QuizExtractionController();

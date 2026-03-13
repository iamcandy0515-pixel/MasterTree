import { Request, Response } from "express";
import { quizService } from "./quiz.service";
import { successResponse, errorResponse } from "../../utils/response";
import { GoogleDriveService } from "../external/google_drive.service";
import { settingsService } from "../settings/settings.service";
import { extractDriveFolderId } from "../../utils/drive-helper";

export class QuizController {
    /**
     * listQuizzes (Placeholder for DB read)
     */
    async listQuizzes(req: Request, res: Response) {
        return successResponse(res, [], "Quizzes retrieved");
    }

    /**
     * Parses raw PDF/Text source into structured quiz JSON blocks
     */
    async parseRawSource(req: Request, res: Response): Promise<void> {
        try {
            const { rawText } = req.body;

            if (!rawText) {
                return errorResponse(
                    res,
                    "rawText is required in the body.",
                    400,
                );
            }

            const parsedBlocks =
                await quizService.parseRawSourceToQuizBlocks(rawText);

            return successResponse(
                res,
                { parsedBlocks },
                "Raw source successfully parsed to quiz format.",
                200,
            );
        } catch (error: any) {
            console.error("Parse Error in Controller:", error.message);
            return errorResponse(
                res,
                "Failed to parse raw source: " + error.message,
                500,
            );
        }
    }

    /**
     * Gets new incorrect distractors via AI Assistant
     */
    async generateDistractor(req: Request, res: Response): Promise<void> {
        try {
            const { questionText, correctOption } = req.body;

            if (!questionText || !correctOption) {
                return errorResponse(
                    res,
                    "questionText and correctOption are required.",
                    400,
                );
            }

            const distractors = await quizService.generateDistractor(
                questionText,
                correctOption,
            );

            return successResponse(
                res,
                { distractors },
                "Distractors generated successfully.",
                200,
            );
        } catch (error: any) {
            console.error("Distractor Gen Error in Controller:", error.message);
            return errorResponse(
                res,
                "Failed to generate distractors: " + error.message,
                500,
            );
        }
    }

    /**
     * Gets new hints via AI Assistant
     */
    async generateHints(req: Request, res: Response): Promise<void> {
        try {
            const { questionText, explanation, count } = req.body;

            if (!questionText || !explanation) {
                return errorResponse(
                    res,
                    "questionText and explanation are required.",
                    400,
                );
            }

            const hints = await quizService.generateHints(
                questionText,
                explanation,
                count || 2,
            );

            return successResponse(
                res,
                { hints },
                "Hints generated successfully.",
                200,
            );
        } catch (error: any) {
            console.error("Hint Gen Error in Controller:", error.message);
            return errorResponse(
                res,
                "Failed to generate hints: " + error.message,
                500,
            );
        }
    }

    /**
     * Saves a quiz question to DB
     */
    async upsertQuizQuestion(req: Request, res: Response): Promise<void> {
        try {
            const data = req.body;
            const updated = await quizService.upsertQuizQuestion(data);
            return successResponse(
                res,
                updated,
                "Quiz question saved successfully.",
                200,
            );
        } catch (error: any) {
            console.error("Quiz Upsert Error in Controller:", error.message);
            return errorResponse(
                res,
                "Failed to save quiz question: " + error.message,
                500,
            );
        }
    }

    /**
     * Gets related questions via AI search based on current question
     */
    async recommendRelated(req: Request, res: Response): Promise<void> {
        try {
            const { questionText, limit } = req.body;

            if (!questionText) {
                return errorResponse(res, "questionText is required.", 400);
            }

            const related = await quizService.recommendRelated(
                questionText,
                limit || 3,
            );

            return successResponse(
                res,
                { related },
                "Related questions retrieved successfully.",
                200,
            );
        } catch (error: any) {
            console.error(
                "Recommend Related Error in Controller:",
                error.message,
            );
            return errorResponse(
                res,
                "Failed to recommend related questions: " + error.message,
                500,
            );
        }
    }

    /**
     * Reviews the alignment between original raw text and the edited quiz content
     */
    async reviewQuizAlignment(req: Request, res: Response): Promise<void> {
        try {
            const { rawText, currentQuizBlocks } = req.body;

            if (!rawText || !currentQuizBlocks) {
                return errorResponse(
                    res,
                    "rawText and currentQuizBlocks are required.",
                    400,
                );
            }

            const reviewResult = await quizService.reviewQuizAlignment(
                rawText,
                currentQuizBlocks,
            );

            return successResponse(
                res,
                { reviewResult },
                "Quiz alignment review complete.",
                200,
            );
        } catch (error: any) {
            console.error("Review Error in Controller:", error.message);
            return errorResponse(
                res,
                "Failed to review quiz alignment: " + error.message,
                500,
            );
        }
    }

    /**
     * Validates PDF based on subject, year, round from Google Drive
     */
    async validateDriveFile(req: Request, res: Response): Promise<void> {
        try {
            const { fileId, subject, year, round } = req.body;

            if (!fileId) {
                return errorResponse(res, "fileId is required.", 400);
            }

            const driveService = new GoogleDriveService();
            const pdfBuffer = await driveService.downloadFileAsBuffer(fileId);

            const validation = await quizService.validateQuizPdfFile(
                pdfBuffer,
                subject,
                year,
                round,
            );

            return successResponse(
                res,
                { validation },
                "Successfully validated pdf.",
                200,
            );
        } catch (error: any) {
            console.error("Validate Drive File Error:", error);
            return errorResponse(res, error.message, 500);
        }
    }

    /**
     * Extracts single quiz from Google Drive PDF using questionNumber
     */
    async extractDriveFile(req: Request, res: Response): Promise<void> {
        try {
            console.log("Extract Drive request body:", req.body);
            const { fileId, questionNumber, optionsCount } = req.body;

            if (!fileId) {
                return errorResponse(res, "fileId is required.", 400);
            }

            const driveService = new GoogleDriveService();
            const pdfBuffer = await driveService.downloadFileAsBuffer(fileId);

            const extractedData = await quizService.extractQuizFromPdfBuffer(
                pdfBuffer,
                questionNumber || 1,
                optionsCount || 4,
            );

            return successResponse(
                res,
                { extractedData },
                "Successfully extracted quiz from PDF.",
                200,
            );
        } catch (error: any) {
            console.error("Extract Drive File Error:", error);
            return errorResponse(res, error.message, 500);
        }
    }

    /**
     * Extracts multiple quizzes from Google Drive PDF (Batch)
     */
    async extractQuizBatch(req: Request, res: Response): Promise<void> {
        try {
            const { fileId, startNumber, endNumber, subject, year, round } =
                req.body;

            if (
                !fileId ||
                !startNumber ||
                !endNumber ||
                !subject ||
                !year ||
                !round
            ) {
                return errorResponse(
                    res,
                    "Missing required parameters for batch extraction.",
                    400,
                );
            }

            const driveService = new GoogleDriveService();
            let effectiveFileId = fileId;

            // 로직 검증: fileId가 전형적인 ID가 아닌 경우(파일명 등) 검색 시도
            const isTypicalId = /^[a-zA-Z0-9_-]{25,45}$/.test(fileId.trim());
            if (!isTypicalId) {
                // 설정에서 구글 드라이브 기출문제 폴더 URL 가져오기
                const folderUrl =
                    (await settingsService.getExamDriveUrl()) ||
                    (await settingsService.getGoogleDriveFolderUrl());

                if (!folderUrl) {
                    return errorResponse(
                        res,
                        "구글 드라이브 폴더가 설정되지 않았습니다. 관리자 설정에서 폴더 URL을 확인해주세요.",
                        400,
                    );
                }

                // URL에서 폴더 ID 추출
                const folderId = extractDriveFolderId(folderUrl);

                if (!folderId || folderId.length < 10) {
                    return errorResponse(
                        res,
                        "설정된 구글 드라이브 폴더 URL이 올바르지 않습니다.",
                        400,
                    );
                }

                console.log(
                    `🔍 [Drive] Input '${fileId}' doesn't look like an ID. Searching by name in folder: ${folderId}...`,
                );
                
                const files = await driveService.searchFilesInFolder(
                    folderId,
                    fileId.trim(),
                );

                if (files && files.length > 0) {
                    effectiveFileId = files[0].id;
                    console.log(
                        `✅ [Drive] Found file by name! Using ID: ${effectiveFileId} (Original name: ${files[0].name})`,
                    );
                } else {
                    return errorResponse(
                        res,
                        `구글 드라이브 폴더 내에서 파일을 찾을 수 없습니다: '${fileId}'. 폴더 공유 설정(링크가 있는 모든 사용자 권한 필요) 및 파일명을 확인해주세요.`,
                        404,
                    );
                }
            }

            const pdfBuffer =
                await driveService.downloadFileAsBuffer(effectiveFileId);

            const batchData = await quizService.extractQuizBatchFromPdf(
                pdfBuffer,
                Number(startNumber),
                Number(endNumber),
                subject,
                Number(year),
                Number(round),
            );

            return successResponse(
                res,
                { batchData },
                "Successfully extracted quiz batch.",
                200,
            );
        } catch (error: any) {
            console.error("Extract Batch Error:", error);
            let message = error.message;
            let status = 500;

            if (error.message.includes("PDF_MISMATCH")) {
                status = 400;
                message = error.message.replace("PDF_MISMATCH: ", "");
            } else if (
                error.response?.status === 404 ||
                error.message.includes("404") ||
                error.message.includes("not found")
            ) {
                status = 404;
                message = "파일을 찾을 수 없습니다";
            }

            return errorResponse(res, message, status);
        }
    }

    /**
     * Upserts a batch of quiz questions
     */
    async upsertQuizBatch(req: Request, res: Response): Promise<void> {
        try {
            const { quizItems, examFilter } = req.body;

            if (!quizItems || !examFilter) {
                return errorResponse(
                    res,
                    "quizItems and examFilter are required.",
                    400,
                );
            }

            const result = await quizService.upsertQuizBatch(
                quizItems,
                examFilter,
            );

            return successResponse(
                res,
                result,
                "Batch of quizzes saved successfully.",
                200,
            );
        } catch (error: any) {
            console.error("Batch Upsert Error in Controller:", error.message);
            const status = error.message.includes("DB_KEY_ERROR") ? 400 : 500;
            return errorResponse(res, error.message, status);
        }
    }

    /**
     * Upserts a batch of related quiz IDs
     */
    async upsertRelatedBulk(req: Request, res: Response): Promise<void> {
        try {
            const { relatedMap } = req.body;

            if (!relatedMap) {
                return errorResponse(res, "relatedMap is required.", 400);
            }

            await quizService.upsertRelatedBulk(relatedMap);

            return successResponse(
                res,
                { success: true },
                "Bulk related quizzes saved successfully.",
                200,
            );
        } catch (error: any) {
            console.error(
                "Bulk Related Upsert Error in Controller:",
                error.message,
            );
            return errorResponse(
                res,
                "Failed to save bulk related quizzes: " + error.message,
                500,
            );
        }
    }

    /**
     * Deletes a quiz question by ID
     */
    async deleteQuiz(req: Request, res: Response): Promise<void> {
        try {
            const { id } = req.params;
            if (!id) {
                return errorResponse(res, "Quiz ID is required.", 400);
            }

            await quizService.deleteQuiz(Number(id));
            return successResponse(
                res,
                { id },
                "Quiz deleted successfully.",
                200,
            );
        } catch (error: any) {
            console.error("Delete Quiz Error in Controller:", error.message);
            return errorResponse(
                res,
                "Failed to delete quiz: " + error.message,
                500,
            );
        }
    }
}

export const quizController = new QuizController();

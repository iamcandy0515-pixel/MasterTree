import { Request, Response } from "express";
import axios from "axios";
import { UploadService } from "./uploads.service";
import { successResponse, errorResponse } from "../../utils/response";

export class UploadController {
    /**
     * 이미지 업로드 처리
     */
    static async uploadImage(req: Request, res: Response): Promise<void> {
        try {
            if (!req.file) {
                errorResponse(res, "파일이 없습니다.", 400);
                return;
            }

            // Multer가 처리한 file 객체 전달 (기본: tree-images)
            const result = await UploadService.uploadToStorage(req.file);

            successResponse(res, result, "업로드 성공");
        } catch (error: any) {
            errorResponse(res, error.message || "업로드 실패", 500);
        }
    }

    /**
     * 퀴즈 이미지 전용 업로드
     */
    static async uploadQuizImage(req: Request, res: Response): Promise<void> {
        try {
            if (!req.file) {
                errorResponse(res, "파일이 없습니다.", 400);
                return;
            }

            // tree-images 버킷 내 quizzes 폴더로 업로드 (버킷 미존재 에러 방지)
            const result = await UploadService.uploadToStorage(
                req.file,
                "tree-images",
                "quizzes",
            );

            successResponse(res, result, "퀴즈 이미지 업로드 성공");
        } catch (error: any) {
            errorResponse(res, error.message || "퀴즈 이미지 업로드 실패", 500);
        }
    }

    /**
     * 외부 이미지 프록시 (CORS 우회용)
     */
    static async proxyImage(req: Request, res: Response): Promise<void> {
        try {
            const url = req.query.url as string;
            if (!url) {
                errorResponse(res, "URL이 필요합니다.", 400);
                return;
            }

            const response = await axios.get(url, {
                responseType: "stream",
                timeout: 15000, // 15 seconds for large Google Drive images
            });

            // 원본의 Content-Type 유지
            res.setHeader(
                "Content-Type",
                response.headers["content-type"] || "image/jpeg",
            );
            res.setHeader("Cache-Control", "public, max-age=86400"); // 1일 캐싱

            response.data.pipe(res);
        } catch (error: any) {
            errorResponse(res, "이미지 로딩 실패", 500);
        }
    }
}

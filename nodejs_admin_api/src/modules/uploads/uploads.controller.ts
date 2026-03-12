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
     * 외부 이미지 프록시 (CORS 우회용 및 실시간 리사이징 지원)
     */
    static async proxyImage(req: Request, res: Response): Promise<void> {
        const url = req.query.url as string;
        const width = req.query.w ? parseInt(req.query.w as string) : null;
        const height = req.query.h ? parseInt(req.query.h as string) : null;

        try {
            if (!url) {
                errorResponse(res, "URL이 필요합니다.", 400);
                return;
            }

            let imageStream;
            let contentType = "image/jpeg";

            // [1] 구글 드라이브 인증 스트림 시도
            if (url.includes("drive.google.com") && url.includes("id=")) {
                try {
                    const fileId = url.split("id=")[1].split("&")[0];
                    console.log(`📡 [Proxy] Authenticated Drive Stream: ${fileId} (Resizing: ${width}x${height})`);
                    
                    const { googleDriveFileService } = require("../external/google_drive_file.service");
                    const driveInstance = googleDriveFileService.getDrive();
                    
                    const driveResponse = await driveInstance.files.get(
                        { fileId, alt: "media" },
                        { responseType: "stream" }
                    );

                    imageStream = driveResponse.data;
                    contentType = driveResponse.headers["content-type"] || "image/jpeg";
                } catch (driveError: any) {
                    console.warn(`⚠️ [Proxy] Authenticated Drive failed: ${driveError.message}`);
                }
            }

            // [2] 일반 외부 이미지 또는 드라이브 폴백
            if (!imageStream) {
                console.log(`🌐 [Proxy] Public Proxying: ${url} (Resizing: ${width}x${height})`);
                const response = await axios.get(url, {
                    responseType: "stream",
                    timeout: 15000,
                    headers: {
                        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
                    }
                });
                imageStream = response.data;
                contentType = response.headers["content-type"] || "image/jpeg";
            }

            // [3] 공통 헤더 설정
            res.setHeader("Content-Type", contentType);
            res.setHeader("Cache-Control", "public, max-age=86400");

            // [4] 리사이징 적용 (sharp)
            if (width || height) {
                const sharp = require("sharp");
                const resizer = sharp().resize(width, height, {
                    fit: "inside",
                    withoutEnlargement: true
                });
                
                // 에러 핸들링 추가
                resizer.on("error", (err: any) => {
                    console.error("❌ [Proxy] Sharp Error:", err);
                });

                imageStream.pipe(resizer).pipe(res);
            } else {
                imageStream.pipe(res);
            }

        } catch (error: any) {
            console.error("❌ [Proxy] Critical error loading image:", url, error.message);
            if (!res.headersSent) {
                errorResponse(res, "이미지 로딩 실패", 500);
            }
        }
    }
}

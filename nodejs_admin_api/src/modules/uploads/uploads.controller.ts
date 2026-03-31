import { Request, Response } from "express";
import axios from "axios";
import { UploadService } from "./uploads.service";
import { successResponse, errorResponse } from "../../utils/response";
import { settingsService } from "../settings/settings.service";
import { extractDriveFolderId } from "../../utils/drive-helper";
import { googleDriveFileService } from "../external/google_drive_file.service";
import { Readable } from "stream";

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

            let imageBuffer;
            let sourceContentType = "image/jpeg";

            // [1] 구글 드라이브 인증 스트림 시도
            if (url.includes("drive.google.com") && url.includes("id=")) {
                try {
                    const fileId = url.split("id=")[1].split("&")[0];
                    console.log(`📡 [Proxy] Authenticated Drive: ${fileId} (Request: ${width}x${height})`);
                    
                    const { googleDriveFileService } = require("../external/google_drive_file.service");
                    const driveInstance = googleDriveFileService.getDrive();
                    
                    const driveResponse = await driveInstance.files.get(
                        { fileId, alt: "media" },
                        { responseType: "arraybuffer" } // 스트림 대신 버퍼로 안정적 확보
                    );

                    imageBuffer = Buffer.from(driveResponse.data);
                    sourceContentType = driveResponse.headers["content-type"] || "image/jpeg";
                } catch (driveError: any) {
                    console.warn(`⚠️ [Proxy] Authenticated Drive failed: ${driveError.message}`);
                }
            }

            // [2] 일반 외부 이미지 또는 드라이브 폴백
            if (!imageBuffer) {
                console.log(`🌐 [Proxy] Public Proxying: ${url} (Request: ${width}x${height})`);
                const response = await axios.get(url, {
                    responseType: "arraybuffer", // 버퍼로 확실하게 받음
                    timeout: 20000,
                    headers: {
                        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
                    }
                });
                imageBuffer = Buffer.from(response.data);
                sourceContentType = response.headers["content-type"] || "image/jpeg";
            }

            // [3] 공통 헤더 설정 (WebP 기반 강력한 캐싱)
            res.setHeader("Cache-Control", "public, max-age=31471200, immutable"); // 최장기 캐싱 유지

            // [4] 리사이징 및 WebP 변환 (sharp)
            if (width || height || sourceContentType !== "image/webp") {
                const sharp = require("sharp");
                let pipeline = sharp(imageBuffer);

                if (width || height) {
                    pipeline = pipeline.resize(width, height, {
                        fit: "inside",
                        withoutEnlargement: true
                    });
                }

                // 퀄리티 최적화된 WebP로 강제 전환 (최고 효율)
                const finalBuffer = await pipeline.webp({ quality: 80 }).toBuffer();
                
                res.setHeader("Content-Type", "image/webp");
                res.send(finalBuffer);
            } else {
                res.setHeader("Content-Type", sourceContentType);
                res.send(imageBuffer);
            }

        } catch (error: any) {
            console.error("❌ [Proxy] Critical error loading image:", url, error.message);
            if (!res.headersSent) {
                errorResponse(res, "이미지 로딩 실패", 500);
            }
        }
    }

    /**
     * 구글 드라이브 '원본 이미지 폴더'로 업로드
     */
    static async uploadToGoogleDrive(
        req: Request,
        res: Response,
    ): Promise<void> {
        try {
            if (!req.file) {
                return errorResponse(res, "파일이 없습니다.", 400);
            }

            // 1. 설정에서 폴더 URL 가져오기
            const folderUrl = await settingsService.getGoogleDriveFolderUrl();
            if (!folderUrl) {
                return errorResponse(
                    res,
                    "설정에서 구글 드라이브 폴더 URL이 지정되지 않았습니다.",
                    400,
                );
            }

            const folderId = extractDriveFolderId(folderUrl);
            if (!folderId) {
                return errorResponse(
                    res,
                    "유효하지 않은 구글 드라이브 폴더 URL입니다.",
                    400,
                );
            }

            // 2. 구글 드라이브 업로드
            const fileName =
                req.body.fileName ||
                `upload_${Date.now()}_${req.file.originalname}`;
            const uploadResponse = await googleDriveFileService.createFile(
                fileName,
                folderId,
                req.file.mimetype,
                Readable.from(req.file.buffer),
            );

            if (uploadResponse.data.id) {
                // view URL 생성
                const url = `https://drive.google.com/uc?export=view&id=${uploadResponse.data.id}`;
                return successResponse(
                    res,
                    { id: uploadResponse.data.id, url },
                    "구글 드라이브 업로드 성공",
                    201,
                );
            }

            throw new Error("구글 드라이브 업로드 실패");
        } catch (error: any) {
            console.error("❌ [GoogleDriveUpload] Error:", error.message);
            errorResponse(res, error.message || "구글 드라이브 업로드 실패", 500);
        }
    }
}

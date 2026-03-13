import express from "express";
import multer from "multer";

import { verifyAdmin } from "../../middleware/verifyAdmin";
import { UploadController } from "./uploads.controller";

const router = express.Router();

/** 메모리 업로드 방식 */
const upload = multer({ storage: multer.memoryStorage() });

/**
 * POST /api/uploads/image
 * FormData 기반 이미지 업로드
 */
router.post("/image", verifyAdmin, upload.single("file"), (req, res, next) => {
    UploadController.uploadImage(req, res).catch(next);
});

/**
 * POST /api/uploads/quiz-image
 * 퀴즈 전용 이미지 업로드
 */
router.post(
    "/quiz-image",
    verifyAdmin,
    upload.single("file"),
    (req, res, next) => {
        UploadController.uploadQuizImage(req, res).catch(next);
    },
);

/**
 * POST /api/uploads/google-drive
 * 구글 드라이브 지정 폴더로 이미지 업로드 (주로 원본 보관용)
 */
router.post(
    "/google-drive",
    verifyAdmin,
    upload.single("file"),
    (req, res, next) => {
        UploadController.uploadToGoogleDrive(req, res).catch(next);
    },
);

/**
 * GET /api/uploads/proxy?url=...
 * 외부 이미지 프록시 (CORS 대응)
 */
router.get("/proxy", (req, res, next) => {
    UploadController.proxyImage(req, res).catch(next);
});

export default router;

import { Router } from "express";
import { SettingsController } from "./settings.controller";
import { verifyAdmin } from "../../middleware/verifyAdmin";

const router = Router();

// GET /api/settings/entry-code (Public for User App check)
router.get("/entry-code", SettingsController.getEntryCode);

// POST /api/settings/entry-code
router.post("/entry-code", verifyAdmin, SettingsController.updateEntryCode);

// GET /api/settings/user-url
router.get("/user-url", verifyAdmin, SettingsController.getUserAppUrl);

// POST /api/settings/user-url
router.post("/user-url", verifyAdmin, SettingsController.updateUserAppUrl);

// GET /api/settings/drive-url
router.get(
    "/drive-url",
    verifyAdmin,
    SettingsController.getGoogleDriveFolderUrl,
);

// POST /api/settings/drive-url
router.post(
    "/drive-url",
    verifyAdmin,
    SettingsController.updateGoogleDriveFolderUrl,
);

// GET /api/settings/thumbnail-drive-url
router.get(
    "/thumbnail-drive-url",
    verifyAdmin,
    SettingsController.getThumbnailDriveUrl,
);

// POST /api/settings/thumbnail-drive-url
router.post(
    "/thumbnail-drive-url",
    verifyAdmin,
    SettingsController.updateThumbnailDriveUrl,
);

// GET /api/settings/exam-drive-url
router.get("/exam-drive-url", verifyAdmin, SettingsController.getExamDriveUrl);

// POST /api/settings/exam-drive-url
router.post(
    "/exam-drive-url",
    verifyAdmin,
    SettingsController.updateExamDriveUrl,
);

// POST /api/settings/validate-url
// 외부 URL 생존 검사 (CORS 회피형 백엔드 프록시 검증)
router.post(
    "/validate-url",
    SettingsController.validateUrl,
);

export default router;

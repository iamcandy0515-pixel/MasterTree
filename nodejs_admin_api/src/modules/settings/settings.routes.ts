import { Router } from "express";
import { SettingsController } from "./settings.controller";
import { SettingsDriveController } from "./settings_drive.controller";
import { verifyAdmin } from "../../middleware/verifyAdmin";

const router = Router();

// -----------------------------------------------------------------------------
// 핵심 설정 (Core Settings)
// -----------------------------------------------------------------------------

// GET /api/settings/entry-code (Public for User App check)
router.get("/entry-code", SettingsController.getEntryCode);

// POST /api/settings/entry-code
router.post("/entry-code", verifyAdmin, SettingsController.updateEntryCode);

// GET /api/settings/user-url
router.get("/user-url", verifyAdmin, SettingsController.getUserAppUrl);

// POST /api/settings/user-url
router.post("/user-url", verifyAdmin, SettingsController.updateUserAppUrl);

// -----------------------------------------------------------------------------
// 사용자 알림 정보 (Notification)
// -----------------------------------------------------------------------------

// GET /api/settings/notification
router.get("/notification", SettingsController.getUserNotification);

// POST /api/settings/notification
router.post("/notification", verifyAdmin, SettingsController.updateUserNotification);

// -----------------------------------------------------------------------------
// 구글 드라이브 영토 (Drive Settings - Dedicated Controller)
// -----------------------------------------------------------------------------

// GET /api/settings/drive-url
router.get("/drive-url", verifyAdmin, SettingsDriveController.getGoogleDriveFolderUrl);

// POST /api/settings/drive-url
router.post("/drive-url", verifyAdmin, SettingsDriveController.updateGoogleDriveFolderUrl);

// GET /api/settings/thumbnail-drive-url
router.get("/thumbnail-drive-url", verifyAdmin, SettingsDriveController.getThumbnailDriveUrl);

// POST /api/settings/thumbnail-drive-url
router.post("/thumbnail-drive-url", verifyAdmin, SettingsDriveController.updateThumbnailDriveUrl);

// GET /api/settings/exam-drive-url
router.get("/exam-drive-url", verifyAdmin, SettingsDriveController.getExamDriveUrl);

// POST /api/settings/exam-drive-url
router.post("/exam-drive-url", verifyAdmin, SettingsDriveController.updateExamDriveUrl);

// POST /api/settings/validate-url
router.post("/validate-url", SettingsDriveController.validateUrl);

export default router;

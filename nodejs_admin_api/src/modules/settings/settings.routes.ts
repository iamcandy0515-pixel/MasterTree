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

export default router;

import { Router } from "express";
import { GoogleDriveController } from "./controllers/google_drive.controller";
import { ImageManagementController } from "./controllers/image_management.controller";

const router = Router();

// Google Drive file search and link management
router.post("/google-images", GoogleDriveController.searchGoogleImage as unknown as any);
router.post("/drive-files/search", GoogleDriveController.searchGoogleDriveFiles as unknown as any);
router.post("/drive-links", GoogleDriveController.getDriveLinks as unknown as any);

// Image processing, thumbnail generation, and storage sync
router.post(
    "/google-images/download",
    ImageManagementController.searchAndDownloadGoogleImage as unknown as any,
);
router.post(
    "/google-images/attach",
    ImageManagementController.searchAndAttachGoogleImage as unknown as any,
);
router.post("/generate-thumbnail", ImageManagementController.generateThumbnail as unknown as any);

export default router;

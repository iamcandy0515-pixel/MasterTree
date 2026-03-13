import { Router } from "express";
import {
    searchGoogleImage,
    searchAndDownloadGoogleImage,
    searchAndAttachGoogleImage,
    searchGoogleDriveFiles,
    generateThumbnail,
    getDriveLinks,
} from "./external.controller";

const router = Router();

router.post("/google-images", searchGoogleImage as unknown as any);
router.post(
    "/google-images/download",
    searchAndDownloadGoogleImage as unknown as any,
);
router.post(
    "/google-images/attach",
    searchAndAttachGoogleImage as unknown as any,
);

router.post("/drive-files/search", searchGoogleDriveFiles as unknown as any);

router.post("/generate-thumbnail", generateThumbnail as unknown as any);
router.post("/drive-links", getDriveLinks as unknown as any);

export default router;

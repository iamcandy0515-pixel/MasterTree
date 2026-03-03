import { Router } from "express";
import {
    searchGoogleImage,
    searchAndDownloadGoogleImage,
    searchGoogleDriveFiles,
} from "./external.controller";

const router = Router();

router.post("/google-images", searchGoogleImage as unknown as any);
router.post(
    "/google-images/download",
    searchAndDownloadGoogleImage as unknown as any,
);

router.post("/drive-files/search", searchGoogleDriveFiles as unknown as any);

export default router;

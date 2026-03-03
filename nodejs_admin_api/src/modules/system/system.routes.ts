/* eslint-disable */
import { Router } from "express";
import { SystemController } from "./system.controller";
import { verifyAdmin } from "../../middleware/verifyAdmin";

const router = Router();

// Allow restart commands only for authenticated admins
// The middleware verifyAdmin is imported.

router.post(
    "/restart/admin",
    verifyAdmin,
    SystemController.restartAdmin as unknown as any,
);
router.post(
    "/restart/user",
    verifyAdmin,
    SystemController.restartUser as unknown as any,
);
router.get("/logs", SystemController.getLogs as unknown as any);
router.delete(
    "/logs",
    verifyAdmin,
    SystemController.clearLogs as unknown as any,
);

export default router;

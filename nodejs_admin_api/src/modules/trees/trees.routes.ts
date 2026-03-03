import { Router } from "express";
import { TreeController } from "./trees.controller";
import { verifyAdmin } from "../../middleware/verifyAdmin";

import multer from "multer";

const router = Router();
const upload = multer({ storage: multer.memoryStorage() });

// Public: Get random trees for distractors
router.get("/random", (req, res, next) => {
    TreeController.getRandom(req, res).catch(next);
});

// Public: Get Detailed Stats
router.get("/stats", (req, res, next) => {
    TreeController.getStats(req, res).catch(next);
});

// Protected: Bulk Export
router.get("/export", verifyAdmin, (req, res, next) => {
    TreeController.exportCsv(req, res).catch(next);
});

// Protected: Bulk Import
router.post("/import", verifyAdmin, upload.single("file"), (req, res, next) => {
    TreeController.importCsv(req, res).catch(next);
});

// Public: Get all trees
router.get("/", (req, res, next) => {
    TreeController.getAll(req, res).catch(next);
});

// Protected: Create new tree (requires admin auth)
router.post("/", verifyAdmin, (req, res, next) => {
    TreeController.create(req, res).catch(next);
});

// Protected: Update tree (requires admin auth)
router.put("/:id", verifyAdmin, (req, res, next) => {
    TreeController.update(req, res).catch(next);
});

// Protected: Delete tree (requires admin auth)
router.delete("/:id", verifyAdmin, (req, res, next) => {
    TreeController.delete(req, res).catch(next);
});

export default router;

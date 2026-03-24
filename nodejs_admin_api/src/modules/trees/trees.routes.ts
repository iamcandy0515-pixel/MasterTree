import { Router } from "express";
import { TreeManagementController } from "./controllers/tree-management.controller";
import { TreeDataController } from "./controllers/tree-data.controller";
import { verifyAdmin } from "../../middleware/verifyAdmin";

import multer from "multer";

const router = Router();
const upload = multer({ storage: multer.memoryStorage() });

/** 
 * Public: Get random trees for distractors 
 * Swagger note: Query params: count, category, excludeName
 */
router.get("/random", (req, res, next) => {
    TreeDataController.getRandom(req, res).catch(next);
});

/** 
 * Public: Get Detailed Stats 
 */
router.get("/stats", (req, res, next) => {
    TreeDataController.getStats(req, res).catch(next);
});

/** 
 * Protected: Bulk Export (Admin ONLY)
 */
router.get("/export", verifyAdmin, (req, res, next) => {
    TreeDataController.exportCsv(req, res).catch(next);
});

/** 
 * Protected: Bulk Import (Admin ONLY)
 */
router.post("/import", verifyAdmin, upload.single("file"), (req, res, next) => {
    TreeDataController.importCsv(req, res).catch(next);
});

/** 
 * Public: Get all trees 
 * Mobile optimized: ?minimal=true to prune large optional fields.
 */
router.get("/", (req, res, next) => {
    TreeManagementController.getAll(req, res).catch(next);
});

/** 
 * Protected: Create new tree (Admin Auth Required)
 */
router.post("/", verifyAdmin, (req, res, next) => {
    TreeManagementController.create(req, res).catch(next);
});

/** 
 * Protected: Update tree (Admin Auth Required)
 */
router.put("/:id", verifyAdmin, (req, res, next) => {
    TreeManagementController.update(req, res).catch(next);
});

/** 
 * Protected: Delete tree (Admin Auth Required)
 */
router.delete("/:id", verifyAdmin, (req, res, next) => {
    TreeManagementController.delete(req, res).catch(next);
});

export default router;

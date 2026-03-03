import { Router } from "express";
import { TreeGroupsController } from "./tree-groups.controller";
import { verifyAdmin } from "../../middleware/verifyAdmin";

const router = Router();

// Public: Anyone can view tree groups (used in User App)
router.get("/", TreeGroupsController.getAll);
router.get("/:id", TreeGroupsController.getOne);

// Protected: Management requiring admin auth
router.post("/", verifyAdmin, TreeGroupsController.create);
router.put("/:id", verifyAdmin, TreeGroupsController.update);
router.delete("/:id", verifyAdmin, TreeGroupsController.delete);

export default router;

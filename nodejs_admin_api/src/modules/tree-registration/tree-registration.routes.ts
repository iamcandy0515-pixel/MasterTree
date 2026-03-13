import { Router } from "express";
import { TreeRegistrationController } from "./tree-registration.controller";
import { verifyAdmin } from "../../middleware/verifyAdmin";

const router = Router();

// Protected: Create new tree via registration module
router.post("/", verifyAdmin, (req, res, next) => {
    TreeRegistrationController.register(req, res).catch(next);
});

export default router;

import { Router } from "express";
import { AuthController } from "./controllers/auth.controller";
import { UserManagementController } from "./controllers/user-management.controller";
import { verifyAdmin } from "../../middleware/verifyAdmin";

const router = Router();

/**
 * Public Authentication Routes
 */
router.post("/login", AuthController.login);

/**
 * Protected Personal Profile Routes
 */
router.get("/me", verifyAdmin, AuthController.getMe);

/**
 * Administrative User Management Routes
 */
router.get("/", verifyAdmin, UserManagementController.listUsers);

router.patch(
    "/:id/status",
    verifyAdmin,
    UserManagementController.updateUserStatus
);

router.delete(
    "/:id",
    verifyAdmin,
    UserManagementController.deleteUser
);

export default router;

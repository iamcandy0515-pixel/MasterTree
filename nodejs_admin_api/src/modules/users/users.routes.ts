import { Router } from "express";
import { usersController } from "./users.controller";
import { verifyAdmin } from "../../middleware/verifyAdmin";

const router = Router();

// Public Routes
router.post("/login", usersController.login.bind(usersController));

// Protected Routes
router.get("/me", verifyAdmin, usersController.getMe.bind(usersController));

// Admin List Users & Update Status
router.get("/", verifyAdmin, usersController.listUsers.bind(usersController));
router.patch(
    "/:id/status",
    verifyAdmin,
    usersController.updateUserStatus.bind(usersController),
);

export default router;

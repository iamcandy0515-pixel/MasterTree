import { Router } from "express";
import { usersController } from "./users.controller";
// import { verifyAdmin } from '../../middleware/verifyAdmin'; // Will be used for protected routes

const router = Router();

// Public Routes
router.post("/login", usersController.login.bind(usersController));

// Protected Routes (Example)
// router.get('/me', verifyAdmin, usersController.getMe.bind(usersController));

// Admin List Users
router.get("/", usersController.listUsers.bind(usersController));

export default router;

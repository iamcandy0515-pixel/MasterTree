import { Router } from "express";
import { quizUserController } from "./quiz_user.controller";
import { verifyUser } from "../../middleware/verifyUser";

const router = Router();

// Create session (generate questions)
router.post("/generate", verifyUser, (req, res, next) => {
    quizUserController.generateSession(req, res).catch(next);
});

// Submit entire session attempt array
router.post("/submit", verifyUser, (req, res, next) => {
    quizUserController.submitAttempts(req, res).catch(next);
});

// Dashboard Statistics Overview
router.get("/stats", verifyUser, (req, res, next) => {
    quizUserController.getStats(req, res).catch(next);
});

// Lazy-loaded Incorrect Quiz Notes
router.get("/incorrect-notes", verifyUser, (req, res, next) => {
    quizUserController.getIncorrectNotes(req, res).catch(next);
});

// Save single attempt
router.post("/attempt", verifyUser, (req, res, next) => {
    quizUserController.saveAttempt(req, res).catch(next);
});

// Save batch attempts
router.post("/batch", verifyUser, (req, res, next) => {
    quizUserController.saveBatchAttempts(req, res).catch(next);
});

// Debug DB
router.get("/debug-db", (req, res, next) => {
    quizUserController.debugDb(req, res).catch(next);
});

export default router;

import { Router } from "express";
import { quizController } from "./quiz.controller";
import { verifyAdmin } from "../../middleware/verifyAdmin";

const router = Router();

// Placeholder for DB operations
router.get("/", verifyAdmin, (req, res, next) => {
    quizController.listQuizzes(req, res).catch(next);
});

// AI Parsing Pipeline (Admin only)
router.post("/parse", verifyAdmin, (req, res, next) => {
    quizController.parseRawSource(req, res).catch(next);
});

// AI Distractor Generation (Admin only)
router.post("/distractors", verifyAdmin, (req, res, next) => {
    quizController.generateDistractor(req, res).catch(next);
});

// AI Hints Generation (Admin only)
router.post("/hints", verifyAdmin, (req, res, next) => {
    quizController.generateHints(req, res).catch(next);
});

// DB Upsert (Admin only)
router.post("/upsert", verifyAdmin, (req, res, next) => {
    quizController.upsertQuizQuestion(req, res).catch(next);
});

// AI Review Alignment (Admin only)
router.post("/review", verifyAdmin, (req, res, next) => {
    quizController.reviewQuizAlignment(req, res).catch(next);
});

// Validate quiz filters from Drive PDF
router.post("/validate-drive-file", verifyAdmin, (req, res, next) => {
    quizController.validateDriveFile(req, res).catch(next);
});

// Extract single quiz from Drive PDF
router.post("/extract-drive-file", verifyAdmin, (req, res, next) => {
    quizController.extractDriveFile(req, res).catch(next);
});

// Recommend related questions (Admin only)
router.post("/recommend-related", verifyAdmin, (req, res, next) => {
    quizController.recommendRelated(req, res).catch(next);
});

// Batch Extraction from Drive PDF
router.post("/extract-batch", verifyAdmin, (req, res, next) => {
    quizController.extractQuizBatch(req, res).catch(next);
});

// Batch DB Upsert
router.post("/upsert-batch", verifyAdmin, (req, res, next) => {
    quizController.upsertQuizBatch(req, res).catch(next);
});

// Bulk Upsert Related Quizzes
router.post("/upsert-related-bulk", verifyAdmin, (req, res, next) => {
    quizController.upsertRelatedBulk(req, res).catch(next);
});

// Delete a quiz question (Admin only)
router.delete("/:id", verifyAdmin, (req, res, next) => {
    quizController.deleteQuiz(req, res).catch(next);
});

export default router;

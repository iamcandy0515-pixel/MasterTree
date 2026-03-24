import { Router } from "express";
import { QuizManagementController } from "./controllers/quiz-management.controller";
import { QuizBulkController } from "./controllers/quiz-bulk.controller";
import { QuizSearchController } from "./controllers/quiz-search.controller";
import { quizAIController } from "./quiz-ai.controller";
import { quizExtractionController } from "./quiz-extraction.controller";
import { verifyAdmin } from "../../middleware/verifyAdmin";

const router = Router();

/**
 * Standard CRUD & Search
 */
router.get("/", verifyAdmin, (req, res, next) => {
    QuizSearchController.listQuizzes(req, res).catch(next);
});

router.post("/upsert", verifyAdmin, (req, res, next) => {
    QuizManagementController.upsertQuizQuestion(req, res).catch(next);
});

router.post("/upsert-batch", verifyAdmin, (req, res, next) => {
    QuizBulkController.upsertQuizBatch(req, res).catch(next);
});

router.post("/upsert-related-bulk", verifyAdmin, (req, res, next) => {
    QuizBulkController.upsertRelatedBulk(req, res).catch(next);
});

router.delete("/:id", verifyAdmin, (req, res, next) => {
    QuizManagementController.deleteQuiz(req, res).catch(next);
});

/**
 * AI Pipeline (Strategy E)
 */
router.post("/parse", verifyAdmin, (req, res, next) => {
    quizAIController.parseRawSource(req, res).catch(next);
});

router.post("/distractors", verifyAdmin, (req, res, next) => {
    quizAIController.generateDistractor(req, res).catch(next);
});

router.post("/hints", verifyAdmin, (req, res, next) => {
    quizAIController.generateHints(req, res).catch(next);
});

router.post("/review", verifyAdmin, (req, res, next) => {
    quizAIController.reviewQuizAlignment(req, res).catch(next);
});

router.post("/recommend-related", verifyAdmin, (req, res, next) => {
    quizAIController.recommendRelated(req, res).catch(next);
});

/**
 * Extraction & Drive (Strategy F)
 */
router.post("/validate-drive-file", verifyAdmin, (req, res, next) => {
    quizExtractionController.validateDriveFile(req, res).catch(next);
});

router.post("/extract-drive-file", verifyAdmin, (req, res, next) => {
    quizExtractionController.extractDriveFile(req, res).catch(next);
});

router.post("/extract-batch", verifyAdmin, (req, res, next) => {
    quizExtractionController.extractQuizBatch(req, res).catch(next);
});

export default router;

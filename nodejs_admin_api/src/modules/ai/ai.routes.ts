import express from "express";
import { verifyAdmin } from "../../middleware/verifyAdmin";
import { AiController } from "./ai.controller";

const router = express.Router();

router.post("/predict", verifyAdmin, AiController.predictTree);
router.post("/comparison-hint", AiController.getComparisonHint);

export default router;

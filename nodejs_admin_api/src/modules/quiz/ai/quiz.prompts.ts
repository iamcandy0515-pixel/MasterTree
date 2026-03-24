/**
 * Quiz AI Prompts Registry
 * Centralized location for all Gemini prompts used in Quiz module.
 * Following Rule 1-1 of DEVELOPMENT_RULES.md for source splitting.
 */

import { ExtractionPrompts } from './prompts/extraction';
import { RefinementPrompts } from './prompts/refinement';
import { UtilityPrompts } from './prompts/utility';

export const QuizPrompts = {
    // Extraction
    PARSE_RAW_SOURCE: ExtractionPrompts.PARSE_RAW_SOURCE,
    EXTRACT_SINGLE_QUIZ: ExtractionPrompts.EXTRACT_SINGLE_QUIZ,
    BATCH_EXTRACT: ExtractionPrompts.BATCH_EXTRACT,

    // Refinement
    GENERATE_DISTRACTOR: RefinementPrompts.GENERATE_DISTRACTOR,
    REVIEW_ALIGNMENT: RefinementPrompts.REVIEW_ALIGNMENT,
    GENERATE_HINTS: RefinementPrompts.GENERATE_HINTS,

    // Utility
    VALIDATE_PDF_FILTER: UtilityPrompts.VALIDATE_PDF_FILTER,
    RECOMMEND_RELATED: UtilityPrompts.RECOMMEND_RELATED,
};

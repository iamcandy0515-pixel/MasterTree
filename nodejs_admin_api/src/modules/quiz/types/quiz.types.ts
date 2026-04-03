/**
 * Core Domain Types for the Quiz Module
 * Adheres to strict typing to eliminate 'any' usage in the Service layer.
 */

export interface ContentBlock {
    type: "text" | "image" | "code" | "math";
    content: string;
    metadata?: Record<string, any>;
}

export interface QuizItem {
    id?: number;
    exam_id: number;
    category_id: number;
    question_number: number;
    content_blocks: ContentBlock[];
    explanation_blocks: ContentBlock[];
    hint_blocks: ContentBlock[];
    options: ContentBlock[];
    correct_option_indexIndex: number;
    difficulty: number;
    status: "draft" | "published" | "archived";
    created_at?: string;
    updated_at?: string;
    quiz_exams?: {
        year: number;
        round: number;
        title: string;
    };
}

export interface ExamFilter {
    subject: string;
    year: number;
    round: number;
}

export interface RecommendationCandidate {
    id: number;
    text: string;
    examStr: string;
}

export interface QuizRecommendation {
    id: number;
    score: number;
    reason: string;
}

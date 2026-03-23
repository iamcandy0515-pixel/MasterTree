import { quizAIService } from "./ai/quiz-ai.service";
import { quizRepository } from "./quiz.repository";
import { quizExtractionService } from "./quiz-extraction.service";
import { UploadService } from "../uploads/uploads.service";

/**
 * Quiz Service (Orchestrator)
 * Central logic for the Quiz module that coordinates between AI, Extraction, and Repository layers.
 * Following Rule 1-1 of DEVELOPMENT_RULES.md: Kept under 200-250 lines for clarity.
 */
export class QuizService {
    /**
     * Parses raw PDF text into structured quiz questions
     */
    async parseRawSourceToQuizBlocks(rawText: string) {
        return await quizAIService.parseRawSource(rawText);
    }

    /**
     * Re-generates distractors for a specific question
     */
    async generateDistractor(questionText: string, correctOption: string, optionsCount: number = 3) {
        return await quizAIService.generateDistractor(questionText, correctOption, optionsCount);
    }

    /**
     * Reviews the alignment between original raw text and the edited quiz content
     */
    async reviewQuizAlignment(rawText: string, currentQuizBlocks: any) {
        return await quizAIService.reviewAlignment(rawText, currentQuizBlocks);
    }

    /**
     * Validates PDF metadata match against subject/year/round
     */
    async validateQuizPdfFile(pdfBuffer: Buffer, subject?: string, year?: number, round?: number) {
        return await quizExtractionService.validatePdfMetadata(pdfBuffer, { subject, year, round });
    }

    /**
     * Extracts single quiz from PDF buffer
     */
    async extractQuizFromPdfBuffer(pdfBuffer: Buffer, questionNumber: number, optionsCount: number) {
        return await quizExtractionService.extractSingleFromBuffer(pdfBuffer, questionNumber, optionsCount);
    }

    /**
     * Re-generates hints using AI Assistant
     */
    async generateHints(questionText: string, explanation: string, count: number = 2) {
        return await quizAIService.generateHints(questionText, explanation, count);
    }

    /**
     * Upserts a quiz question to the database (Logic Orchestration)
     */
    async upsertQuizQuestion(data: any) {
        let categoryId = await this._ensureCategory(data.subject);
        let examId = await this._ensureExam(data.subject, data.year, data.round);

        const payload: any = {
            raw_source_text: data.raw_source_text,
            content_blocks: data.content_blocks,
            hint_blocks: data.hint_blocks,
            options: data.options,
            correct_option_index: data.correct_option_index,
            explanation_blocks: data.explanation_blocks,
            difficulty: data.difficulty || 1,
            status: "draft",
            category_id: categoryId,
            exam_id: examId,
            question_number: data.question_number,
            related_quiz_ids: data.related_quiz_ids,
        };

        // Generate AI Embedding
        const embedText = this._getEmbeddingSourceText(data);
        if (embedText) {
            const embedding = await quizAIService.generateEmbedding(embedText);
            if (embedding) payload.embedding = embedding;
        }

        if (data.id) {
            await quizRepository.updateQuiz(data.id, payload);
            return { id: data.id, ...payload };
        } else {
            const res = await quizRepository.insertQuiz(payload);
            if (res.error) throw res.error;
            return { id: (res.data as any).id, ...payload };
        }
    }


    /**
     * Recommends related questions from DB using AI & Vector Search
     */
    async recommendRelated(questionText: string, limitCount: number = 3) {
        const queryEmbedding = await quizAIService.generateEmbedding(questionText);
        let questions: any[] = [];

        if (queryEmbedding && queryEmbedding.length > 0) {
            const { data, error } = await quizRepository.matchQuestions(queryEmbedding, 0.5, 50);
            if (!error && data && (data as any[]).length > 0) {
                const { data: fullData } = await quizRepository.findQuizzesByIds((data as any[]).map((d: any) => d.id));
                questions = fullData || [];
            }
        }
        if (questions.length === 0) {
            const { data } = await quizRepository.findRecentQuizzes(50);
            questions = data || [];
        }

        const candidates = questions.map((q: any) => {
            const combinedText = (q.content_blocks as any[]).filter(b => b.type === "text").map(b => b.content || "").join(" ").substring(0, 150);
            const examStr = q.quiz_exams ? `${q.quiz_exams.year}년 ${q.quiz_exams.round}회 (${q.quiz_exams.title})` : "Unknown";
            return `ID: ${q.id} | [${examStr} | ${q.question_number}번] ${combinedText}`;
        }).join("\n");

        return await quizAIService.recommendRelated(questionText, candidates, limitCount);
    }

    /**
     * Extracts multiple quiz questions from a PDF buffer in batches
     */
    async extractQuizBatchFromPdf(pdfBuffer: Buffer, start: number, end: number, subject: string, year: number, round: number) {
        return await quizExtractionService.extractBatchFromBuffer(pdfBuffer, start, end, { subject, year, round });
    }

    /**
     * Upserts a batch of quiz questions with embedded logic
     */
    async upsertQuizBatch(quizItems: any[], examFilter: any) {
        const { subject, year, round } = examFilter;
        let categoryId = await this._ensureCategory(subject);
        let examId = await this._ensureExam(subject, year, round);

        const itemsToUpsert: any[] = [];
        for (const item of quizItems) {
            const payload: any = this._formatBatchItem(item, examId, categoryId);
            const embedText = this._getEmbeddingSourceText(payload);
            if (embedText) {
                const embedding = await quizAIService.generateEmbedding(embedText);
                if (embedding) payload.embedding = embedding;
            }
            itemsToUpsert.push(payload);
        }

        const { data, error } = await quizRepository.upsertBatch(itemsToUpsert);
        if (error) {
            // Fallback to individual upsert for precise logging
            const results: any[] = [];
            for (const item of itemsToUpsert) {
                const { data: qData, error: qErr } = await quizRepository.upsertSingle(item);
                if (qErr) throw new Error(`Q${item.question_number} failed: ${qErr.message}`);
                if (qData) results.push(...(qData as any[]));
            }
            return results;
        }
        return data;
    }

    /**
     * Deletes a quiz by ID and cleans up associated images
     */
    async deleteQuiz(id: number) {
        const { data: quiz } = await quizRepository.findQuizForDeletion(id) as any;
        if (quiz) {
            const imagePaths = this._extractImagePaths([...(quiz.content_blocks || []), ...(quiz.explanation_blocks || [])]);
            if (imagePaths.length > 0) {
                await UploadService.deleteFromStorage([...new Set(imagePaths)]).catch(e => console.warn(`[Cleanup] Failed for quiz ${id}:`, e));
            }
        }
        const { error } = await quizRepository.deleteQuizRecord(id);
        if (error) throw new Error("Failed to delete quiz: " + error.message);
    }

    /**
     * Upserts related quiz IDs in bulk
     */
    async upsertRelatedBulk(relatedMap: Record<string, number[]>) {
        await Promise.all(Object.entries(relatedMap).map(([quizId, ids]) => quizRepository.updateRelatedIds(Number(quizId), ids)));
    }

    // --- Private Helpers ---

    private async _ensureCategory(subject: string) {
        if (!subject) return null;
        const { data } = await quizRepository.findCategoryByName(subject);
        if (data && (data as any).id) return (data as any).id;
        const { data: newCat } = await quizRepository.createCategory(subject);
        return (newCat as any)?.id;
    }

    private async _ensureExam(subject: string, year: number, round: number) {
        if (!year || !round) return null;
        const examTitle = `${subject || "Unknown"} ${year}년 ${round}회`;
        const { data } = await quizRepository.findExam(examTitle, year, round);
        if (data && (data as any).id) return (data as any).id;
        const { data: newExam } = await quizRepository.createExam(year, round, examTitle);
        return (newExam as any)?.id;
    }

    private _extractImagePaths(blocks: any[]) {
        const paths: string[] = [];
        if (!Array.isArray(blocks)) return paths;
        blocks.forEach(b => {
            if (b && b.type === "image" && typeof b.content === "string") {
                const match = b.content.match(/quizzes\/[^?]+/);
                if (match) paths.push(match[0]);
            }
        });
        return paths;
    }

    private _getEmbeddingSourceText(data: any): string {
        const blocks = data.content_blocks || [];
        return (Array.isArray(blocks) ? blocks : []).filter(b => b.type === "text").map(b => b.content || "").join(" ").trim();
    }

    private _formatBatchItem(item: any, examId: any, categoryId: any) {
        const wrapBlock = (val: any) => Array.isArray(val) ? val : [{ type: "text", content: val || "" }];
        return {
            exam_id: examId,
            category_id: categoryId,
            question_number: parseInt(item.question_number.toString(), 10),
            content_blocks: wrapBlock(item.content_blocks),
            explanation_blocks: wrapBlock(item.explanation_blocks),
            hint_blocks: Array.isArray(item.hint_blocks) ? item.hint_blocks.map((h: any) => typeof h === "string" ? { type: "text", content: h } : h) : wrapBlock(item.hint_blocks),
            options: Array.isArray(item.options) ? item.options.map((o: any) => typeof o === "string" ? { type: "text", content: o } : o) : wrapBlock(item.options),
            correct_option_index: parseInt((item.correct_option_index ?? 0).toString(), 10),
            difficulty: item.difficulty || 2,
            status: "draft",
        };
    }
}

export const quizService = new QuizService();

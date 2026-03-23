import { quizAIService } from "./ai/quiz-ai.service";

/**
 * Quiz Extraction Service
 * Specializes in PDF processing, batching, and data cleaning.
 * Following Rule 1-1 of DEVELOPMENT_RULES.md (200-line limit).
 */
export class QuizExtractionService {
    /**
     * Validates PDF metadata against Subject/Year/Round filters
     */
    async validatePdfMetadata(pdfBuffer: Buffer, filter: any) {
        const { subject, year, round } = filter;
        const filterStr = subject && year && round
            ? `과목명: "${subject}", 년도: "${year}년", 회차: "${round}회"`
            : "";
            
        const pdfBase64 = pdfBuffer.toString("base64");
        const result = await quizAIService.validatePdfFilter(pdfBase64, filterStr);
        
        return {
            filter_matched: result.filter_matched,
            mismatch_reason: result.mismatch_reason,
            extracted_subject: result.extracted_subject,
            extracted_year: result.extracted_year,
            extracted_round: result.extracted_round,
        };
    }

    /**
     * Extracts a single quiz item from a PDF buffer
     */
    async extractSingleFromBuffer(pdfBuffer: Buffer, questionNumber: number, optionsCount: number) {
        const pdfBase64 = pdfBuffer.toString("base64");
        const result = await quizAIService.extractSingleQuiz(pdfBase64, questionNumber, optionsCount);
        
        // Backend validation logic to prevent AI hallucination
        if (result.data && result.data.length > 0) {
            const extNumRaw = result.data[0].extracted_question_number;
            const extNum = extNumRaw?.toString().replace(/[^0-9]/g, "");
            
            if (extNum == null || parseInt(extNum) !== questionNumber) {
                console.log(`[Validation Failed] Expected ${questionNumber}, but AI found ${extNumRaw}`);
                result.data = [];
                result.error = `AI 추출 오류: 요청한 ${questionNumber}번이 아닌 ${extNumRaw || "알 수 없는"}번 문제가 추출되었습니다. 해당 번호의 문제가 PDF에 명확히 존재하는지 확인해주세요.`;
            }
        } else if (!result.error) {
            result.error = `제공된 PDF에서 ${questionNumber}번 기출문제를 찾을 수 없습니다.`;
        }
        
        return { data: result.data || [], error: result.error };
    }

    /**
     * Processes PDF in chunks of 5 and aggregates clean results
     */
    async extractBatchFromBuffer(pdfBuffer: Buffer, start: number, end: number, filter: any) {
        // 1. Validate PDF metadata
        const validation = await this.validatePdfMetadata(pdfBuffer, filter);
        if (!validation.filter_matched) {
            throw new Error(`PDF_MISMATCH: 문서는 존재하나 해당 조건에 맞는 문서가 아니다 (${validation.mismatch_reason})`);
        }

        // 2. Chunking logic (Max 5 items per API call)
        const chunks: { start: number; end: number }[] = [];
        for (let i = start; i <= end; i += 5) {
            chunks.push({ start: i, end: Math.min(i + 4, end) });
        }

        const pdfBase64 = pdfBuffer.toString("base64");
        const allResults: any[] = [];

        // 3. Process chunks sequentially
        for (const chunk of chunks) {
            console.log(`[QuizExtraction] Processing chunk: ${chunk.start} ~ ${chunk.end}`);
            const result = await quizAIService.extractBatchItems(pdfBase64, chunk.start, chunk.end);
            
            if (result && result.data && Array.isArray(result.data)) {
                allResults.push(...this.cleanExtractedData(result.data));
            }
        }

        // 4. Hallucination check and filtering
        return allResults.filter((item: any) => {
            const qNum = Number(item.question_number);
            return qNum >= start && qNum <= end;
        });
    }

    /**
     * Cleans up junk lines from AI extraction results
     */
    private cleanExtractedData(data: any[]) {
        return data.map((item: any) => {
            const expl = item.explanation_blocks || item.explanation || "";
            let explStr = Array.isArray(expl)
                ? expl.map((b: any) => typeof b === "string" ? b : b.content || "").join("\n")
                : expl.toString();

            if (explStr) {
                item.explanation_blocks = explStr
                    .split("\n")
                    .filter((line: string) => !line.includes("해당사항 없음") && !line.includes("필요 없음"))
                    .join("\n")
                    .replace(/\n{3,}/g, "\n\n")
                    .trim();
            } else {
                item.explanation_blocks = "";
            }
            return item;
        });
    }
}

export const quizExtractionService = new QuizExtractionService();

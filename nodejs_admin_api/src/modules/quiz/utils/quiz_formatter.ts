/**
 * Utilities for formatting quiz data and extracting paths.
 */
export const QuizFormatter = {
    /**
     * Extracts Supabase storage image paths from content blocks.
     */
    extractImagePaths(blocks: any[]): string[] {
        const paths: string[] = [];
        if (!Array.isArray(blocks)) return paths;
        blocks.forEach(b => {
            if (b && b.type === "image" && typeof b.content === "string") {
                const match = b.content.match(/quizzes\/[^?]+/);
                if (match) paths.push(match[0]);
            }
        });
        return paths;
    },

    /**
     * Get searchable text for AI Embeddings from content blocks.
     */
    getEmbeddingSourceText(data: any): string {
        const blocks = data.content_blocks || [];
        return (Array.isArray(blocks) ? blocks : [])
            .filter(b => b.type === "text")
            .map(b => b.content || "")
            .join(" ")
            .trim();
    },

    /**
     * Standardizes individual batch items for DB insertion.
     */
    formatBatchItem(item: any, examId: any, categoryId: any) {
        const wrapBlock = (val: any) => Array.isArray(val) ? val : [{ type: "text", content: val || "" }];
        return {
            exam_id: examId,
            category_id: categoryId,
            question_number: parseInt(item.question_number.toString(), 10),
            content_blocks: wrapBlock(item.content_blocks),
            explanation_blocks: wrapBlock(item.explanation_blocks),
            hint_blocks: Array.isArray(item.hint_blocks) 
                ? item.hint_blocks.map((h: any) => typeof h === "string" ? { type: "text", content: h } : h) 
                : wrapBlock(item.hint_blocks),
            options: Array.isArray(item.options) 
                ? item.options.map((o: any) => typeof o === "string" ? { type: "text", content: o } : o) 
                : wrapBlock(item.options),
            correct_option_index: parseInt((item.correct_option_index ?? 0).toString(), 10),
            difficulty: item.difficulty || 2,
            status: "draft",
        };
    }
};

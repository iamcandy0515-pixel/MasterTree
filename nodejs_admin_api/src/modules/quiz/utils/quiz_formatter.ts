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
            if (b && b.type === "image") {
                const imgUrl = b.image_url || b.content;
                if (typeof imgUrl === "string") {
                    // Cloudinary public_id 추출 시도 (tree-images/quizzes/... 형태)
                    const cloudMatch = imgUrl.match(/(tree-images\/quizzes\/[^?./]+)/);
                    if (cloudMatch) {
                        paths.push(cloudMatch[1]);
                    } else {
                        // Legacy Supabase path 추출 시도
                        const supabaseMatch = imgUrl.match(/quizzes\/[^?]+/);
                        if (supabaseMatch) paths.push(supabaseMatch[0]);
                    }
                }
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
     * Standardizes individual batch items for DB insertion, merging existing images if found.
     */
    formatBatchItem(item: any, examId: any, categoryId: any, existingBlocks?: any[]) {
        const wrapBlock = (val: any) => Array.isArray(val) ? val : [{ type: "text", content: val || "" }];
        
        const newContentBlocks = wrapBlock(item.content_blocks);
        const mergedContentBlocks = this.mergeBlocks(newContentBlocks, existingBlocks || []);

        return {
            exam_id: examId,
            category_id: categoryId,
            question_number: parseInt(item.question_number.toString(), 10),
            content_blocks: mergedContentBlocks,
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
    },

    /**
     * Merges new text blocks with existing image blocks to prevent loss during re-extraction.
     */
    mergeBlocks(newBlocks: any[], existingBlocks: any[]): any[] {
        const existingImages = existingBlocks.filter(b => b && b.type === "image");
        const containsNewImage = newBlocks.some(b => b && b.type === "image");

        // [Strategy] If new data has NO images but old data HAS images, keep those images.
        if (existingImages.length > 0 && !containsNewImage) {
            return [...newBlocks, ...existingImages];
        }
        return newBlocks;
    }
};

import { QuizFormatter } from "../quiz_formatter";

describe("QuizFormatter (Unit Test)", () => {
    describe("mergeBlocks", () => {
        it("should preserve existing image blocks when new blocks have no images", () => {
            const existingBlocks = [
                { type: "text", content: "Old question text" },
                { type: "image", content: "https://.../storage/v1/object/public/quizzes/image1.jpg" }
            ];
            const newBlocks = [
                { type: "text", content: "New question text" }
            ];

            const result = QuizFormatter.mergeBlocks(newBlocks, existingBlocks);

            expect(result).toHaveLength(2);
            expect(result.some(b => b.type === "image" && b.content.includes("image1.jpg"))).toBe(true);
            expect(result[0].content).toBe("New question text");
        });

        it("should use new image blocks if present in new data", () => {
            const existingBlocks = [
                { type: "image", content: "https://.../old_image.jpg" }
            ];
            const newBlocks = [
                { type: "image", content: "https://.../new_image.jpg" }
            ];

            const result = QuizFormatter.mergeBlocks(newBlocks, existingBlocks);

            expect(result).toHaveLength(1);
            expect(result[0].content).toContain("new_image.jpg");
        });
    });

    describe("extractImagePaths", () => {
        it("should correctly extract Supabase storage paths from image blocks", () => {
            const blocks = [
                { type: "text", content: "Ignore this" },
                { type: "image", content: "https://.../storage/v1/object/public/quizzes/example.jpg" },
                { type: "image", content: "https://.../quizzes/another_one.png?v=123" }
            ];

            const paths = QuizFormatter.extractImagePaths(blocks);

            expect(paths).toHaveLength(2);
            expect(paths).toContain("quizzes/example.jpg");
            expect(paths).toContain("quizzes/another_one.png");
        });
    });

    describe("getEmbeddingSourceText", () => {
        it("should join all text blocks into a single search string", () => {
            const data = {
                content_blocks: [
                    { type: "text", content: "Hello" },
                    { type: "image", content: "Skip" },
                    { type: "text", content: "World" }
                ]
            };

            const result = QuizFormatter.getEmbeddingSourceText(data);

            expect(result).toBe("Hello World");
        });
    });
});

jest.mock("../../../../config/geminiClient", () => ({
    geminiGenerateText: jest.fn(),
    geminiExtractFromPdfBuffer: jest.fn(),
    geminiEmbedText: jest.fn(),
    geminiPredict: jest.fn()
}));

import { QuizAIService } from "../quiz-ai.service";
import * as geminiClient from "../../../../config/geminiClient";

describe("QuizAIService (Schema Test)", () => {
    let service: QuizAIService;

    beforeEach(() => {
        service = new QuizAIService();
    });

    afterEach(() => {
        jest.clearAllMocks();
    });

    describe("parseRawSource", () => {
        it("should return correctly structured content_blocks for text and images", async () => {
            const mockAiResponse = {
                questions: [
                    {
                        content_blocks: [
                            { type: "text", content: "What is this tree?" },
                            { type: "image", content: "STORAGE_PATH_PLACEHOLDER" }
                        ],
                        options: [
                            { type: "text", content: "Pine" },
                            { type: "text", content: "Oak" }
                        ],
                        correct_option_index: 0,
                        explanation_blocks: [
                            { type: "text", content: "It is a pine tree." }
                        ]
                    }
                ]
            };

            // Setup mock
            (geminiClient.geminiGenerateText as jest.Mock).mockResolvedValue(mockAiResponse);

            const result = await service.parseRawSource("raw text source");

            expect(result.questions).toHaveLength(1);
            const question = result.questions[0];
            
            // Check content blocks structure (The key to preventing UI breakage)
            expect(Array.isArray(question.content_blocks)).toBe(true);
            expect(question.content_blocks[1]).toMatchObject({
                type: "image",
                content: "STORAGE_PATH_PLACEHOLDER"
            });
            
            // Verify Gemini was called
            expect(geminiClient.geminiGenerateText).toHaveBeenCalled();
        });

        it("should handle error when AI returns malformed JSON", async () => {
            (geminiClient.geminiGenerateText as jest.Mock).mockRejectedValue(new Error("API Error"));

            await expect(service.parseRawSource("err")).rejects.toThrow("Failed to parse raw text into quiz format.");
        });
    });

    describe("extractBatchItems", () => {
        it("should call PDF extraction with correct parameters", async () => {
            const mockPdfBase64 = "fake-pdf-content";
            const mockResponse = { questions: [] };
            
            (geminiClient.geminiExtractFromPdfBuffer as jest.Mock).mockResolvedValue(mockResponse);

            await service.extractBatchItems(mockPdfBase64, 1, 5);

            expect(geminiClient.geminiExtractFromPdfBuffer).toHaveBeenCalledWith(
                mockPdfBase64,
                expect.any(String) // prompt
            );
        });
    });
});

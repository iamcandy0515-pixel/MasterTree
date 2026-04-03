import * as dotenv from "dotenv";
dotenv.config();

import { supabase } from "./src/config/supabaseClient";
import { geminiEmbedText } from "./src/config/geminiClient";

/**
 * Helper to collect text for embedding from quiz data
 */
function getEmbeddingSourceText(data: any): string {
    const textBlocks = (data.content_blocks as any[]) || [];
    return textBlocks
        .filter((b: any) => b.type === "text")
        .map((b: any) => b.content || "")
        .join(" ")
        .trim();
}

async function startBatchEmbedding() {
    console.log(
        "🚀 [Batch] Starting embedding process for existing questions...",
    );

    try {
        // 1. Fetch questions without embedding
        const { data: questions, error } = await supabase
            .from("quiz_questions")
            .select("id, content_blocks")
            .is("embedding", null);

        if (error) throw error;

        if (!questions || questions.length === 0) {
            console.log(
                "✅ [Batch] No pending questions found. All are already embedded.",
            );
            return;
        }

        console.log(`📦 [Batch] Found ${questions.length} questions to embed.`);

        // 2. Process in sequence to avoid rate limits
        for (let i = 0; i < questions.length; i++) {
            const q = questions[i];
            const text = getEmbeddingSourceText(q);

            if (!text) {
                console.log(`⚠️  [ID: ${q.id}] No text found, skipping.`);
                continue;
            }

            try {
                console.log(
                    `[${i + 1}/${questions.length}] Embedding ID: ${q.id}...`,
                );
                const embedding = await geminiEmbedText(text);

                const { error: updateErr } = await supabase
                    .from("quiz_questions")
                    .update({ embedding })
                    .eq("id", q.id);

                if (updateErr) throw updateErr;
            } catch (err: any) {
                console.error(
                    `❌ [ID: ${q.id}] Embedding failed:`,
                    err.message,
                );
                // Continue to next one
            }

            // Sleep 150ms between calls for rate limiting
            await new Promise((resolve) => setTimeout(resolve, 150));
        }

        console.log("🏁 [Batch] Process complete!");
    } catch (e: any) {
        console.error("🔥 [Batch] Critical Error:", e.message);
    }
}

startBatchEmbedding();

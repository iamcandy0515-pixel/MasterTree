import * as dotenv from "dotenv";
dotenv.config();

import { supabase } from "./src/config/supabaseClient";

async function analyzeDiscrepancy() {
    try {
        // 1. Total questions
        const { count: totalCount } = await supabase
            .from("quiz_questions")
            .select("*", { count: "exact", head: true });

        // 2. Questions WITH embedding
        const { count: withEmbedding } = await supabase
            .from("quiz_questions")
            .select("*", { count: "exact", head: true })
            .not("embedding", "is", null);

        // 3. Questions WITHOUT embedding
        const { count: withoutEmbedding } = await supabase
            .from("quiz_questions")
            .select("*", { count: "exact", head: true })
            .is("embedding", null);

        // 4. Questions WITHOUT embedding AND WITHOUT text content
        const { data: noTextQuestions } = await supabase
            .from("quiz_questions")
            .select("id, content_blocks")
            .is("embedding", null);

        let noTextCount = 0;
        if (noTextQuestions) {
            noTextCount = noTextQuestions.filter((q) => {
                const blocks = (q.content_blocks as any[]) || [];
                const text = blocks
                    .filter((b: any) => b.type === "text")
                    .map((b: any) => b.content || "")
                    .join("")
                    .trim();
                return text.length === 0;
            }).length;
        }

        console.log(`\n--- DB Discrepancy Analysis ---`);
        console.log(`Total count in DB: ${totalCount}`);
        console.log(
            `Questions with embedding (Already done): ${withEmbedding}`,
        );
        console.log(
            `Questions without embedding (Pending): ${withoutEmbedding}`,
        );
        console.log(
            `Out of pending, how many have NO text content: ${noTextCount}`,
        );
        console.log(`-------------------------------\n`);
    } catch (e) {
        console.error("Analysis failed:", e);
    }
}

analyzeDiscrepancy();


import { createClient } from "@supabase/supabase-js";
import dotenv from "dotenv";
import path from "path";

// Load .env
dotenv.config({ path: path.join(__dirname, "../.env") });

const url = process.env.SUPABASE_URL!;
const key = process.env.SUPABASE_SERVICE_KEY!;

console.log(`[Diagnostic] Testing DB Permissions for: ${url}`);
console.log(`[Diagnostic] Key Prefix: ${key.substring(0, 15)}...`);

const supabase = createClient(url, key);

async function runDiagnosis() {
    console.log("\n--- Step 1: Connectivity Test ---");
    const { data: health, error: healthError } = await supabase.from("quiz_questions").select("id").limit(1);
    if (healthError) {
        console.error("❌ SELECT failed (even read is blocked?):", healthError.message);
    } else {
        console.log("✅ SELECT successful. (Read access OK)");
    }

    console.log("\n--- Step 2: Write Test (The Real Problem) ---");
    // We try to insert a dummy question. Use high ID or unique combinations.
    const dummyId = 9999999;
    const { data: insertData, error: insertError } = await supabase
        .from("quiz_questions")
        .insert([{
            id: dummyId,
            question_number: 999,
            status: 'draft',
            content_blocks: [{type: 'text', content: 'RLS Diagnostic Test Item'}]
        }])
        .select();

    if (insertError) {
        console.error("❌ INSERT FAILED!");
        console.error("Error Message:", insertError.message);
        console.error("Error Hint:", insertError.hint);
        console.error("Error Details:", insertError.details);
        console.error("Full Error Object:", JSON.stringify(insertError, null, 2));
    } else {
        console.log("✅ INSERT SUCCESSFUL! (Service Role is working perfectly from script)");
        // Cleanup
        await supabase.from("quiz_questions").delete().eq("id", dummyId);
        console.log("✅ Cleanup successful.");
    }
}

runDiagnosis();

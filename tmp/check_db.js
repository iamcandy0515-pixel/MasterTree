const { createClient } = require("@supabase/supabase-js");
require("dotenv").config({ path: "nodejs_admin_api/.env" });

const supabaseUrl = process.env.SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_ANON_KEY;
const supabase = createClient(supabaseUrl, supabaseKey);

async function checkData() {
    console.log("Checking quiz_attempts...");
    const { data: attempts, error: attErr } = await supabase
        .from("quiz_attempts")
        .select("*")
        .limit(5);

    if (attErr) console.error(attErr);
    else console.log("Recent attempts:", JSON.stringify(attempts, null, 2));

    console.log("Checking quiz_questions...");
    const { data: questions, error: qErr } = await supabase
        .from("quiz_questions")
        .select("id, tree_id, exam_id")
        .limit(5);

    if (qErr) console.error(qErr);
    else console.log("Recent questions:", JSON.stringify(questions, null, 2));
}

checkData();

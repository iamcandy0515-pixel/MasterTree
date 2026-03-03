const { createClient } = require("@supabase/supabase-js");
require("dotenv").config({ path: "nodejs_admin_api/.env" });

const supabaseUrl = process.env.SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_ANON_KEY;
const supabase = createClient(supabaseUrl, supabaseKey);

async function checkSchema() {
    console.log("--- Quiz Sessions ---");
    const { data: sessions, error: sErr } = await supabase
        .from("quiz_sessions")
        .select("*")
        .limit(1);
    if (sErr) console.error(sErr);
    else
        console.log(
            "Session columns:",
            Object.keys(sessions[0] || {}),
            sessions[0],
        );

    console.log("--- Quiz Attempts ---");
    const { data: attempts, error: aErr } = await supabase
        .from("quiz_attempts")
        .select("*")
        .limit(1);
    if (aErr) console.error(aErr);
    else
        console.log(
            "Attempt columns:",
            Object.keys(attempts[0] || {}),
            attempts[0],
        );
}

checkSchema();

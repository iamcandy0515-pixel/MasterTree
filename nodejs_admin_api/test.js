require("dotenv").config();
const { createClient } = require("@supabase/supabase-js");

const supabaseUrl = process.env.SUPABASE_URL || "";
const supabaseKey = process.env.SUPABASE_SERVICE_ROLE_KEY || "";

const supabase = createClient(supabaseUrl, supabaseKey);

async function run() {
    const { data: qData, error: qError } = await supabase
        .from("quiz_questions")
        .select("*, quiz_categories!inner(name), quiz_exams!inner(year,round)")
        .like("quiz_categories.name", "%산림필답%")
        .eq("quiz_exams.year", 2013)
        .eq("quiz_exams.round", 1);

    console.log("Filtered questions (int): ", qData ? qData.length : qError);

    const { data: qData2, error: qError2 } = await supabase
        .from("quiz_questions")
        .select("*, quiz_categories!inner(name), quiz_exams!inner(year,round)")
        .like("quiz_categories.name", "%산림필답%")
        .eq("quiz_exams.year", "2013")
        .eq("quiz_exams.round", "1");

    console.log("Filtered questions (str): ", qData2 ? qData2.length : qError2);

    const { data: exams, error: eError } = await supabase
        .from("quiz_exams")
        .select("*");
    if (exams) console.log("Exams schema:", exams[0]);
}
run();

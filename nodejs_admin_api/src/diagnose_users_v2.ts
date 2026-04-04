import dotenv from "dotenv";
dotenv.config();
import { supabase } from "./config/supabaseClient";
import * as fs from 'fs';

async function diagnoseUsers() {
    let output = "";
    output += "--- diagnosing users Table ---\n";
    
    // 1. Get sample
    const { data: cols, error: cErr } = await supabase
        .from('users')
        .select('*')
        .limit(20);

    if (cErr) {
        output += `Error: ${JSON.stringify(cErr)}\n`;
    } else {
        output += `Columns: ${Object.keys(cols[0] || {}).join(', ')}\n`;
        output += `Total items in query: ${cols.length}\n`;
        cols.forEach(u => {
            output += `ID: ${u.id}, Name: ${u.name}, Status: ${u.status}, Email: ${u.email}\n`;
        });
    }

    // 2. Count status frequencies (Raw)
    const { data: allStatuses, error: sErr } = await supabase
        .from('users')
        .select('status');
    
    if (!sErr && allStatuses) {
        const counts: Record<string, number> = {};
        allStatuses.forEach(u => {
            const s = (u.status || 'NULL') as string;
            counts[s] = (counts[s] || 0) + 1;
        });
        output += `\nFrequencies: ${JSON.stringify(counts)}\n`;
    }

    fs.writeFileSync('users_diagnosis.txt', output);
}

diagnoseUsers().catch(err => {
    fs.writeFileSync('users_diagnosis.txt', `Fatal Error: ${err.message}`);
});

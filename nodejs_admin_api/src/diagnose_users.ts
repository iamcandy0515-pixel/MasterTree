import dotenv from "dotenv";
dotenv.config();

import { supabase } from "./config/supabaseClient";

async function diagnoseUsers() {
    console.log("--- 🕵️ diagnosing users Table ---");
    
    // 1. Get column names
    const { data: cols, error: cErr } = await supabase
        .from('users')
        .select('*')
        .limit(1);

    if (cErr) {
        console.error("❌ Error fetching users table:", cErr);
    } else {
        console.log("✅ Columns found:", Object.keys(cols[0] || {}));
        console.log("Sample Data:", cols[0]);
    }

    // 2. Count status frequencies
    console.log("\n--- Status Frequencies ---");
    const { data: statusCounts, error: scErr } = await supabase
        .from('users')
        .select('status');

    if (scErr) {
        console.error("❌ Error counting statuses:", scErr);
    } else {
        const counts: Record<string, number> = {};
        statusCounts.forEach(u => {
            const s = u.status || 'NULL/EMPTY';
            counts[s] = (counts[s] || 0) + 1;
        });
        console.log("Frequencies:", counts);
    }

    // 3. Specifically check for 'pending' users
    console.log("\n--- Pending Users Check ---");
    const { data: pendingUsers, error: pErr } = await supabase
        .from('users')
        .select('*')
        .eq('status', 'pending');

    if (pErr) {
        console.error("❌ Error checking pending users:", pErr);
    } else {
        console.log(`✅ Found ${pendingUsers.length} 'pending' users.`);
        if (pendingUsers.length > 0) {
            console.log("Top 3 pending users:", pendingUsers.slice(0, 3).map(u => ({ id: u.id, name: u.name, status: u.status })));
        }
    }
}

diagnoseUsers();

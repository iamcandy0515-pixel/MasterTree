import { createClient } from "@supabase/supabase-js";
import * as dotenv from "dotenv";
import path from "path";

// Load environment variables
const envPath = path.resolve(__dirname, "../.env");
dotenv.config({ path: envPath });

const supabaseUrl = process.env.SUPABASE_URL;
const supabaseServiceKey = process.env.SUPABASE_SERVICE_KEY;

if (!supabaseUrl || !supabaseServiceKey) {
    console.error("❌ Missing SUPABASE_URL or SUPABASE_SERVICE_KEY in .env");
    process.exit(1);
}

// Initialize Supabase client with Service Role Key (Admin)
const supabase = createClient(supabaseUrl, supabaseServiceKey, {
    auth: {
        autoRefreshToken: false,
        persistSession: false,
    },
});

async function forceResetAdmin() {
    const email = "admin@mastertree.com";
    const password = "admin1234";

    console.log(`🔨 Force resetting admin user: ${email}...`);

    // 1. List users to find ID
    const { data: listData, error: listError } =
        await supabase.auth.admin.listUsers();

    if (listError) {
        console.error("❌ Error listing users:", listError);
        return;
    }

    const user = listData.users.find((u) => u.email === email);

    if (user) {
        console.log(`✅ User found (ID: ${user.id}). Updating password...`);

        const { data: updateData, error: updateError } =
            await supabase.auth.admin.updateUserById(user.id, {
                password: password,
                email_confirm: true,
                user_metadata: { role: "admin" }, // Just in case metadata is used anywhere
            });

        if (updateError) {
            console.error("❌ Error updating user:", updateError);
        } else {
            console.log("✅ Admin password reset to 'admin1234'");
            console.log("✅ Email confirmed.");
        }
    } else {
        console.log("⚠️ User not found. Creating new admin user...");
        const { data: createData, error: createError } =
            await supabase.auth.admin.createUser({
                email: email,
                password: password,
                email_confirm: true,
                user_metadata: { role: "admin" },
            });

        if (createError) {
            console.error("❌ Error creating user:", createError);
        } else {
            console.log("✅ Admin user created with password 'admin1234'");
        }
    }
}

forceResetAdmin();

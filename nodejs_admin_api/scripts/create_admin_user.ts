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

async function createAdminUser() {
    const email = "admin@mastertree.com";
    const password = "admin1234";

    console.log(`🔨 Creating admin user: ${email}...`);

    // 1. Try to create user
    const { data, error } = await supabase.auth.admin.createUser({
        email: email,
        password: password,
        email_confirm: true, // Auto confirm email
    });

    if (error) {
        if (error.message.includes("already registered")) {
            console.log("⚠️ User already exists. Updating password...");

            // 2. If exists, list users to find ID (admin.updateUser requires ID, not email)
            // Note: updateUserById is the method name in some versions, or updateUser with id.
            // Let's rely on listUsers to get ID first.
            const { data: users, error: listError } =
                await supabase.auth.admin.listUsers();

            if (listError) {
                console.error("❌ Error listing users:", listError);
                return;
            }

            const user = users.users.find((u) => u.email === email);
            if (!user) {
                console.error(
                    "❌ Could not find user even though it was reported existing.",
                );
                return;
            }

            const { data: updateData, error: updateError } =
                await supabase.auth.admin.updateUserById(user.id, {
                    password: password,
                });

            if (updateError) {
                console.error("❌ Error updating password:", updateError);
            } else {
                console.log("✅ Password updated successfully!");
                console.log(`📧 Email: ${email}`);
                console.log(`🔑 Password: ${password}`);
            }
        } else {
            console.error("❌ Error creating user:", error);
        }
    } else {
        console.log("✅ User created successfully!");
        console.log(`📧 Email: ${email}`);
        console.log(`🔑 Password: ${password}`);
        console.log(`🆔 ID: ${data.user.id}`);
    }
}

createAdminUser();

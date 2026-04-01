import { createClient } from "@supabase/supabase-js";
import { Database } from "../types/database.types";

console.log(`[Supabase] Initializing with ${process.env.SUPABASE_URL}`);
if (!process.env.SUPABASE_SERVICE_KEY || process.env.SUPABASE_SERVICE_KEY.length < 20) {
    console.error("❌ SUPABASE_SERVICE_KEY is missing or too short! Current length:", process.env.SUPABASE_SERVICE_KEY?.length);
} else {
    console.log(`✅ SUPABASE_SERVICE_KEY loaded (Prefix: ${process.env.SUPABASE_SERVICE_KEY.substring(0, 10)}...)`);
}

export const supabase = createClient<Database>(
    process.env.SUPABASE_URL!,
    process.env.SUPABASE_SERVICE_KEY!,
    {
        auth: {
            persistSession: false,
            autoRefreshToken: false,
            detectSessionInUrl: false,
        }
    }
);


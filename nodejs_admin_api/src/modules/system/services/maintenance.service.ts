import { supabase } from "../../../config/supabaseClient";

export class MaintenanceService {
    /**
     * Executes the DB maintenance purge function to keep the quiz_attempts table within limits.
     * Target: 100 days / 200MB (approximately 400,000 rows x 512 bytes)
     */
    async executeStatsPurge() {
        try {
            console.log("🧹 [Maintenance] Starting quiz_attempts purge...");
            const { data, error } = await supabase.rpc("purge_old_attempts");
            
            if (error) {
                console.error("❌ [Maintenance] Purge failed:", error.message);
                return { success: false, error: error.message };
            }
            
            console.log("✅ [Maintenance] Purge completed:", data);
            return { success: true, result: data };
        } catch (err: any) {
            console.error("❌ [Maintenance] Unexpected error during purge:", err.message);
            return { success: false, error: err.message };
        }
    }
}

export const maintenanceService = new MaintenanceService();

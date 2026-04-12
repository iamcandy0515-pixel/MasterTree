import { supabase } from "../../config/supabaseClient";
import { logger } from "../../utils/logger";

export class SettingsRepository {
    async getValue(key: string): Promise<string | null> {
        const { data, error } = await supabase
            .from("app_settings")
            .select("value")
            .eq("key", key)
            .single();

        if (error) {
            if (error.code === "PGRST116") return null;
            throw error;
        }
        return data.value;
    }

    async upsertValue(key: string, value: string, description: string): Promise<string> {
        const { data, error } = await supabase
            .from("app_settings")
            .upsert(
                {
                    key,
                    value,
                    description,
                    updated_at: new Date().toISOString(),
                },
                { onConflict: "key" },
            )
            .select()
            .single();

        if (error) {
            logger.error(`Failed to update setting: ${key}`, error);
            throw error;
        }
        return data.value;
    }

    async getMultipleValues(keys: string[]): Promise<string | null> {
        const { data, error } = await supabase
            .from("app_settings")
            .select("value")
            .in("key", keys)
            .order('updated_at', { ascending: false })
            .limit(1);

        if (error || !data || data.length === 0) return null;
        return data[0].value;
    }

    async updateAllUsersEntryCode(newCode: string): Promise<number> {
        const { count, error } = await supabase
            .from("users")
            .update({ entry_code: newCode })
            .neq("entry_code", newCode); // Only update those that are different

        if (error) {
            logger.error("Failed to reset all user entry codes", error);
            throw error;
        }
        return count || 0;
    }
}

export const settingsRepository = new SettingsRepository();

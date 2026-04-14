import { supabase } from "../../config/supabaseClient";
import { LoginDto, UserResponseDto, PaginatedUserResponse } from "./users.dto";
import { logger } from "../../utils/logger";
import { TablesUpdate } from "../../types/database.types";

export class UsersService {
    /**
     * Admin Login
     * @param loginDto login credentials and device info
     * @returns session data including access_token
     */
    async login(loginDto: LoginDto) {
        const { email, password, deviceId, deviceModel, osVersion, forceLogout } = loginDto;

        if (!email || !password) {
            throw new Error("Email and password are required");
        }

        // 1. Authenticate with Supabase
        const { data, error } = await supabase.auth.signInWithPassword({
            email,
            password,
        });

        if (error) {
            logger.error("Login failed", error);
            throw new Error(error.message);
        }

        const user = data.user;
        const session = data.session;

        // 2. Check for active session conflict (Single Session Logic)
        if (user && deviceId) {
            const { data: dbUser } = await supabase
                .from('users')
                .select('last_session_id, last_device_id, last_device_model')
                .eq('auth_id', user.id)
                .maybeSingle();

            if (dbUser && dbUser.last_session_id && dbUser.last_device_id !== deviceId && !forceLogout) {
                // Return a specific error with current device info
                const conflictError: any = new Error("이미 다른 기기에서 로그인이 되어있습니다.");
                conflictError.code = "SESSION_ALREADY_EXISTS";
                conflictError.deviceModel = dbUser.last_device_model || "다른 기기";
                throw conflictError;
            }

            // 3. Update/Overwrite session info in DB
            try {
                await supabase
                    .from('users')
                    .update({
                        last_session_id: session?.access_token.substring(0, 50), // Store partial for ID
                        last_device_id: deviceId,
                        last_device_model: deviceModel || "Unknown",
                        last_os_version: osVersion || "Unknown",
                        last_login: new Date().toISOString()
                    })
                    .eq('auth_id', user.id);
            } catch (updateErr: any) {
                logger.warn(`Failed to update session info for ${user.id} (ignore if columns missing): ${updateErr.message}`);
            }
        }

        return {
            user: data.user,
            session: data.session,
        };
    }

    /**
     * Get User Profile
     * @param userId
     */
    async getProfile(userId: string) {
        // In a real scenario, you might fetch additional profile data from a 'profiles' table
        const {
            data: { user },
            error,
        } = await supabase.auth.getUser(userId); // This usually verifies token, here we might just retrieve info if needed, or query public.users table if it exists.

        // As per current requirement, we just return basic auth info or check admin role if implemented in metadata
        if (error) throw error;
        return user;
    }

    /**
     * List Users (Admin)
     * Fetches from 'public.users' table for accurate server-side filtering and persistence.
     */
    async listUsers(page: number = 1, limit: number = 50, status?: string, minimal = false): Promise<PaginatedUserResponse> {
        const offset = (page - 1) * limit;

        // 1. Fetch from 'public.users' table
        let query = supabase
            .from('users')
            .select('*', { count: 'exact' })
            .order('created_at', { ascending: false });

        if (status) {
            query = query.eq('status', status);
        }

        const { data: dbUsers, error, count } = await query.range(offset, offset + limit - 1);

        if (error) {
            logger.error("Failed to fetch users from DB", error);
            throw error;
        }

        // 2. Check for duplicates across the entire table
        const emails = dbUsers.map(u => u.email).filter(Boolean);
        const phones = dbUsers.map(u => u.phone).filter(Boolean);

        let duplicateMap: Record<string, { email?: boolean, phone?: boolean }> = {};

        if (emails.length > 0 || phones.length > 0) {
            const { data: allMatches } = await supabase
                .from('users')
                .select('id, email, phone')
                .or(`email.in.(${emails.map(e => `"${e}"`).join(',')}),phone.in.(${phones.map(p => `"${p}"`).join(',')})`);

            if (allMatches) {
                dbUsers.forEach(u => {
                    const otherEmailMatch = allMatches.some(m => m.id !== u.id && m.email === u.email && u.email);
                    const otherPhoneMatch = allMatches.some(m => m.id !== u.id && m.phone === u.phone && u.phone);
                    if (otherEmailMatch || otherPhoneMatch) {
                        duplicateMap[u.id] = { email: otherEmailMatch, phone: otherPhoneMatch };
                    }
                });
            }
        }

        // 3. Map DB users to standardized format
        const users = dbUsers.map((u) => {
            const isDuplicate = !!duplicateMap[u.id];
            const baseInfo = {
                id: u.auth_id || u.id,
                dbId: u.id,
                email: u.email,
                phone: u.phone,
                name: u.name || "사용자",
                status: u.status || "pending",
                lastLogin: u.last_login,
                createdAt: u.created_at,
                isDuplicate,
                duplicateDetails: duplicateMap[u.id] || null,
            };

            if (minimal) return baseInfo;

            return {
                ...baseInfo,
                role: u.role || (u.email?.includes("admin") ? "Master" : "User"),
                entryCode: u.entry_code,
                expiredAt: u.expired_at,
                expired_at: u.expired_at, // Provide both for frontend safety
            };
        });

        const totalCount = count || 0;

        return {
            data: users,
            meta: {
                total: totalCount,
                page,
                limit,
                totalPages: Math.ceil(totalCount / limit),
            },
        };
    }

    /**
     * Update User Status (Admin)
     * Syncs status to both 'public.users' table and 'auth' metadata.
     */
    async updateUserStatus(userId: string, status: string) {
        // 1. Update public.users table (Primary source of truth for app)
        const { error: dbError } = await supabase
            .from('users')
            .update({ status })
            .or(`auth_id.eq.${userId},id.eq.${userId}`);

        if (dbError) {
            logger.error(`Failed to update DB status for ${userId}`, dbError);
            throw new Error(`Database update failed: ${dbError.message}`);
        }

        // 2. Update Auth Metadata (For redundancy and auth-level checks)
        const { data, error: authError } = await supabase.auth.admin.updateUserById(
            userId,
            {
                user_metadata: { status },
            },
        );

        if (authError) {
            logger.warn(`Auth metadata update failed for ${userId} (non-critical): ${authError.message}`);
            // We don't throw here if DB update succeeded, as public.users is the main source.
        }

        return data?.user || { id: userId, status };
    }

    /**
     * Update User (Admin - Generic)
     */
     async updateUser(userId: string, updateData: TablesUpdate<'users'>) {
        const { data, error } = await supabase
            .from('users')
            .update(updateData)
            .or(`auth_id.eq.${userId},id.eq.${userId}`)
            .select()
            .maybeSingle();

        if (error) {
            logger.error(`Failed to update user ${userId}`, error);
            throw new Error(`Update failed: ${error.message}`);
        }

        if (!data) {
            throw new Error(`사용자를 찾을 수 없거나 업데이트된 행이 없습니다. (ID: ${userId})`);
        }

        return {
            id: data.auth_id || data.id,
            dbId: data.id,
            ...data,
            expiredAt: data.expired_at,
            expired_at: data.expired_at
        };
    }

    /**
     * Delete User (Admin)
     */
    async deleteUser(userId: string) {
        logger.info(`🚨 [Resilient Delete] Initiated for: ${userId}`);

        // 1. Attempt Auth Deletion (Silence errors)
        try {
            const { error: authError } = await supabase.auth.admin.deleteUser(userId);
            if (authError) {
                logger.warn(`[Resilient Delete] Auth skip/fail for ${userId}: ${authError.message}`);
            } else {
                logger.info(`[Resilient Delete] Auth success for ${userId}`);
            }
        } catch (err: any) {
            logger.warn(`[Resilient Delete] Auth catch: ${err.message}`);
        }

        // 2. Attempt DB Deletion (Silently proceed unless critical)
        try {
            const { error: publicError } = await supabase
                .from('users')
                .delete()
                .or(`id.eq.${userId},auth_id.eq.${userId}`);

            if (publicError) {
                logger.error(`[Resilient Delete] DB fail for ${userId}`, publicError);
                // Even if DB fails (e.g. constraints), we might want to return 200 to UI if it's already "ghostly"
                // But for now, we let people know if DB is blocked.
                throw new Error(`Database block: ${publicError.message}`);
            }
        } catch (dbErr: any) {
            logger.error(`[Resilient Delete] DB Exception: ${dbErr.message}`);
            // If it's a foreign key error, we MUST tell the user
            if (dbErr.message.includes('foreign key')) throw dbErr;
        }

        logger.info(`✅ [Resilient Delete] Finished for: ${userId}`);
        return { success: true };
    }
}

export const usersService = new UsersService();

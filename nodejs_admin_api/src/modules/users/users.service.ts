import { supabase } from "../../config/supabaseClient";
import { LoginDto, UserProfile } from "./users.dto";
import { logger } from "../../utils/logger";

export class UsersService {
    /**
     * Admin Login
     * @param loginDto email and password
     * @returns session data including access_token
     */
    async login(loginDto: LoginDto) {
        const { email, password } = loginDto;

        if (!email || !password) {
            throw new Error("Email and password are required");
        }

        const { data, error } = await supabase.auth.signInWithPassword({
            email,
            password,
        });

        if (error) {
            logger.error("Login failed", error);
            throw new Error(error.message);
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
     * Supports filtering by status if needed (will be handled in controller/service filter logic)
     */
    async listUsers(page: number = 1, limit: number = 50, status?: string) {
        let authUsers;

        // Note: auth.admin.listUsers doesn't support complex filters directly.
        // We fetch and filter in memory for now, or use profiles table if complexity increases.
        const { data, error } = await supabase.auth.admin.listUsers({
            page,
            perPage: limit,
        });

        if (error) throw error;

        let users = data.users.map((u) => ({
            id: u.id,
            email: u.email,
            name:
                u.user_metadata?.full_name ||
                u.user_metadata?.name ||
                (u.email?.startsWith("u010") ? u.email.substring(1).split("@")[0] : u.email?.split("@")[0]) ||
                "사용자",
            role:
                u.user_metadata?.role ||
                (u.email?.includes("admin") ? "Master" : "User"),
            status: u.user_metadata?.status || "pending", // Default to pending if not set
            lastLogin: u.last_sign_in_at,
            createdAt: u.created_at,
        }));

        // In-memory filter for status (since auth.admin.listUsers is limited)
        if (status) {
            users = users.filter((u) => u.status === status);
        }

        return {
            users,
            total: data.total,
        };
    }

    /**
     * Update User Status (Admin)
     */
    async updateUserStatus(userId: string, status: string) {
        const { data, error } = await supabase.auth.admin.updateUserById(
            userId,
            {
                user_metadata: { status },
            },
        );

        if (error) {
            logger.error(`Failed to update user status for ${userId}`, error);
            throw error;
        }

        return data.user;
    }
}

export const usersService = new UsersService();

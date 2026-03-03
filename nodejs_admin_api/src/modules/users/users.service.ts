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
     */
    async listUsers(page: number = 1, limit: number = 50) {
        const { data, error } = await supabase.auth.admin.listUsers({
            page,
            perPage: limit,
        });

        if (error) throw error;

        return {
            users: data.users.map((u) => ({
                id: u.id,
                email: u.email,
                name:
                    u.user_metadata?.full_name ||
                    u.user_metadata?.name ||
                    u.email?.split("@")[0] ||
                    "사용자",
                role:
                    u.user_metadata?.role ||
                    (u.email?.includes("admin") ? "Master" : "User"),
                lastLogin: u.last_sign_in_at,
                createdAt: u.created_at,
            })),
            total: data.total,
        };
    }
}

export const usersService = new UsersService();

// DTO for user login
export interface LoginDto {
    email: string;
    password?: string;
}

// User model interface (based on Supabase auth schema)
export interface UserProfile {
    id: string;
    email?: string;
    role?: string;
    created_at: string;
}

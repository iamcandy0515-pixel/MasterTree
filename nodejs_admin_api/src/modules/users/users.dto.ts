// DTO for user login
export interface LoginDto {
    email: string;
    password?: string;
    deviceId?: string;
    deviceModel?: string;
    osVersion?: string;
    forceLogout?: boolean;
}

// User model interface (based on Supabase auth schema)
export interface UserProfile {
    id: string;
    email?: string;
    role?: string;
    created_at: string;
}

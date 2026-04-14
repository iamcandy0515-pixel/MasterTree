// DTO for user login
export interface LoginDto {
    email: string;
    password?: string;
    deviceId?: string;
    deviceModel?: string;
    osVersion?: string;
    forceLogout?: boolean;
}

// User model interface (standardized for API responses)
export interface UserResponseDto {
    id: string;
    dbId: string;
    email: string | null;
    phone: string;
    name: string;
    status: string;
    lastLogin: string | null;
    createdAt: string;
    isDuplicate: boolean;
    duplicateDetails: { email?: boolean, phone?: boolean } | null;
    role?: string;
    entryCode?: string;
    expiredAt?: string | null;
}

// Paginated Response Interface
export interface PaginatedUserResponse {
    data: UserResponseDto[];
    meta: {
        total: number;
        page: number;
        limit: number;
        totalPages: number;
    };
}

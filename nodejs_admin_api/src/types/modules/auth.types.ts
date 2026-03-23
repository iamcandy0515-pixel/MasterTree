import { Json } from "../common.db";

/**
 * Authentication & User Module Types
 * Strategy G: Module Mapping
 */
export interface AuthTables {
  admins: {
    Row: {
      role_level: number | null
      user_id: string
    }
    Insert: {
      role_level?: number | null
      user_id: string
    }
    Update: {
      role_level?: number | null
      user_id?: string
    }
    Relationships: []
  }
  profiles: {
    Row: {
      created_at: string
      id: string
      nickname: string | null
    }
    Insert: {
      created_at?: string
      id: string
      nickname?: string | null
    }
    Update: {
      created_at?: string
      id?: string
      nickname?: string | null
    }
    Relationships: []
  }
  users: {
    Row: {
      created_at: string
      email: string | null
      entry_code: string
      id: string
      name: string
      phone: string
      status: string | null
    }
    Insert: {
      created_at?: string
      email?: string | null
      entry_code: string
      id?: string
      name: string
      phone: string
      status?: string | null
    }
    Update: {
      created_at?: string
      email?: string | null
      entry_code?: string
      id?: string
      name?: string
      phone?: string
      status?: string | null
    }
    Relationships: []
  }
}

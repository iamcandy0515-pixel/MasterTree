/**
 * Shared Database Utility Types
 * Optimized for Rule 1-1 (200-line limit) and Strategy H.
 */

export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export interface CommonEnums {
  [_ in never]: never
}

export interface CommonCompositeTypes {
  [_ in never]: never
}

// Helpers for Supabase generated types
export type Tables<
  T extends { Row: any }
> = T["Row"]

export type TablesInsert<
  T extends { Insert: any }
> = T["Insert"]

export type TablesUpdate<
  T extends { Update: any }
> = T["Update"]

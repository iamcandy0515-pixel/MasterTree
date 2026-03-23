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

export type CommonEnums = {
  [_ in never]: never
}

export type CommonCompositeTypes = {
  [_ in never]: never
}



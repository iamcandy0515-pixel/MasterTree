import { Json } from "../common.db";

/**
 * App Settings Module Types
 * Strategy G: Module Mapping
 */
export interface SettingTables {
  app_settings: {
    Row: {
      description: string | null
      key: string
      updated_at: string | null
      value: string
    }
    Insert: {
      description?: string | null
      key: string
      updated_at?: string | null
      value: string
    }
    Update: {
      description?: string | null
      key?: string
      updated_at?: string | null
      value?: string
    }
    Relationships: []
  }
}

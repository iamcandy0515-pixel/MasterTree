import { Json } from "../common.db";

/**
 * Tree & AI Detection Module Types
 * Strategy G: Module Mapping
 */
export type TreeTables = {
  trees: {
    Row: {
      category: string | null
      created_at: string
      created_by: string | null
      description: string | null
      difficulty: number | null
      id: number
      is_auto_quiz_enabled: boolean | null
      name_en: string | null
      name_kr: string
      quiz_distractors: string[] | null
      scientific_name: string | null
      shape: string | null
      family_name: string | null
    }
    Insert: {
      category?: string | null
      created_at?: string
      created_by?: string | null
      description?: string | null
      difficulty?: number | null
      id?: never
      is_auto_quiz_enabled?: boolean | null
      name_en?: string | null
      name_kr: string
      quiz_distractors?: string[] | null
      scientific_name?: string | null
      shape?: string | null
      family_name?: string | null
    }
    Update: {
      category?: string | null
      created_at?: string
      created_by?: string | null
      description?: string | null
      difficulty?: number | null
      id?: never
      is_auto_quiz_enabled?: boolean | null
      name_en?: string | null
      name_kr?: string
      quiz_distractors?: string[] | null
      scientific_name?: string | null
      shape?: string | null
      family_name?: string | null
    }
    Relationships: []
  }
  tree_images: {
    Row: {
      created_at: string
      hint: string | null
      id: number
      image_type: string | null
      image_url: string | null
      quizz_source_image_url: string | null
      thumbnail_url: string | null
      is_quiz_enabled: boolean
      tree_id: number
      uploaded_by: string | null
    }
    Insert: {
      created_at?: string
      hint?: string | null
      id?: never
      image_type?: string | null
      image_url?: string | null
      quizz_source_image_url?: string | null
      thumbnail_url?: string | null
      is_quiz_enabled?: boolean
      tree_id: number
      uploaded_by?: string | null
    }
    Update: {
      created_at?: string
      hint?: string | null
      id?: never
      image_type?: string | null
      image_url?: string | null
      quizz_source_image_url?: string | null
      thumbnail_url?: string | null
      is_quiz_enabled?: boolean
      tree_id?: number
      uploaded_by?: string | null
    }
    Relationships: [
      {
        foreignKeyName: "tree_images_tree_id_fkey"
        columns: ["tree_id"]
        isOneToOne: false
        referencedRelation: "trees"
        referencedColumns: ["id"]
      },
    ]
  }
  tree_groups: {
    Row: {
      created_at: string
      description: string | null
      group_name: string
      id: number
      image_url: string | null
    }
    Insert: {
      created_at?: string
      description?: string | null
      group_name: string
      id?: number
      image_url?: string | null
    }
    Update: {
      created_at?: string
      description?: string | null
      group_name?: string
      id?: number
      image_url?: string | null
    }
    Relationships: []
  }
  tree_group_members: {
    Row: {
      created_at: string
      group_id: number
      id: number
      key_characteristics: Json | null
      sort_order: number | null
      tree_id: number
    }
    Insert: {
      created_at?: string
      group_id: number
      id?: number
      key_characteristics?: Json | null
      sort_order?: number | null
      tree_id: number
    }
    Update: {
      created_at?: string
      group_id?: number
      id?: number
      key_characteristics?: Json | null
      sort_order?: number | null
      tree_id?: number
    }
    Relationships: [
      {
        foreignKeyName: "tree_group_members_group_id_fkey"
        columns: ["group_id"]
        isOneToOne: false
        referencedRelation: "tree_groups"
        referencedColumns: ["id"]
      },
      {
        foreignKeyName: "tree_group_members_tree_id_fkey"
        columns: ["tree_id"]
        isOneToOne: false
        referencedRelation: "trees"
        referencedColumns: ["id"]
      },
    ]
  }
  ai_detections: {
    Row: {
      confidence: number | null
      created_at: string
      id: number
      predicted_tree_id: number | null
      uploaded_image_url: string
      user_id: string | null
    }
    Insert: {
      confidence?: number | null
      created_at?: string
      id?: never
      predicted_tree_id?: number | null
      uploaded_image_url: string
      user_id?: string | null
    }
    Update: {
      confidence?: number | null
      created_at?: string
      id?: never
      predicted_tree_id?: number | null
      uploaded_image_url?: string
      user_id?: string | null
    }
    Relationships: [
      {
        foreignKeyName: "ai_detections_predicted_tree_id_fkey"
        columns: ["predicted_tree_id"]
        isOneToOne: false
        referencedRelation: "trees"
        referencedColumns: ["id"]
      },
    ]
  }
}

import { Json } from "../common.db";

/**
 * Quiz Master Data Types (Categories, Exams, Questions)
 * Strategy G: Domain Locality
 */
export interface QuizCoreTables {
  quiz_categories: {
    Row: {
      created_at: string
      description: string | null
      id: number
      name: string
    }
    Insert: {
      created_at?: string
      description?: string | null
      id?: never
      name: string
    }
    Update: {
      created_at?: string
      description?: string | null
      id?: never
      name?: string
    }
    Relationships: []
  }
  quiz_exams: {
    Row: {
      created_at: string
      id: number
      is_published: boolean
      round: number
      title: string
      year: number
    }
    Insert: {
      created_at?: string
      id?: never
      is_published?: boolean
      round: number
      title: string
      year: number
    }
    Update: {
      created_at?: string
      id?: never
      is_published?: boolean
      round?: number
      title?: string
      year?: number
    }
    Relationships: []
  }
  quiz_questions: {
    Row: {
      category_id: number | null
      content_blocks: Json
      correct_option_index: number | null
      created_at: string
      difficulty: number | null
      embedding: string | null
      exam_id: number | null
      explanation_blocks: Json
      hint_blocks: Json
      id: number
      options: Json
      question_number: number | null
      raw_source_image_url: string | null
      raw_source_text: string | null
      related_quiz_ids: number[] | null
      name_kr: string | null
      tree_id: number | null
      status: string | null
    }
    Insert: {
      category_id?: number | null
      content_blocks?: Json
      correct_option_index?: number | null
      created_at?: string
      difficulty?: number | null
      embedding?: string | null
      exam_id?: number | null
      explanation_blocks?: Json
      hint_blocks?: Json
      id?: never
      options?: Json
      question_number?: number | null
      raw_source_image_url?: string | null
      raw_source_text?: string | null
      related_quiz_ids?: number[] | null
      status?: string | null
    }
    Update: {
      category_id?: number | null
      content_blocks?: Json
      correct_option_index?: number | null
      created_at?: string
      difficulty?: number | null
      embedding?: string | null
      exam_id?: number | null
      explanation_blocks?: Json
      hint_blocks?: Json
      id?: never
      options?: Json
      question_number?: number | null
      raw_source_image_url?: string | null
      raw_source_text?: string | null
      related_quiz_ids?: number[] | null
      status?: string | null
    }
    Relationships: [
      {
        foreignKeyName: "quiz_questions_category_id_fkey"
        columns: ["category_id"]
        isOneToOne: false
        referencedRelation: "quiz_categories"
        referencedColumns: ["id"]
      },
      {
        foreignKeyName: "quiz_questions_exam_id_fkey"
        columns: ["exam_id"]
        isOneToOne: false
        referencedRelation: "quiz_exams"
        referencedColumns: ["id"]
      },
    ]
  }
}

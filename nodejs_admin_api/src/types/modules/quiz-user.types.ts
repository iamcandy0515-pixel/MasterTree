/**
 * Quiz User Log & Session Types
 * Strategy G: Domain Locality
 */
export interface QuizUserTables {
  quiz_sessions: {
    Row: {
      correct_count: number | null
      finished_at: string | null
      id: number
      mode: string | null
      started_at: string
      total_questions: number | null
      user_id: string | null
    }
    Insert: {
      correct_count?: number | null
      finished_at?: string | null
      id?: never
      mode?: string | null
      started_at?: string
      total_questions?: number | null
      user_id?: string | null
    }
    Update: {
      correct_count?: number | null
      finished_at?: string | null
      id?: never
      mode?: string | null
      started_at?: string
      total_questions?: number | null
      user_id?: string | null
    }
    Relationships: []
  }
  quiz_attempts: {
    Row: {
      category_id: number | null
      created_at: string
      id: number
      is_correct: boolean
      question_id: number
      session_id: number
      time_taken_ms: number | null
      user_answer: string | null
      tree_id: number | null
      user_id: string
    }
    Insert: {
      category_id?: number | null
      created_at?: string
      id?: never
      is_correct: boolean
      question_id?: number | null
      session_id: number
      time_taken_ms?: number | null
      user_answer?: string | null
      tree_id?: number | null
      user_id: string
    }
    Update: {
      category_id?: number | null
      created_at?: string
      id?: never
      is_correct?: boolean
      question_id?: number
      session_id?: number
      time_taken_ms?: number | null
      user_answer?: string | null
      tree_id?: number | null
      user_id?: string
    }
    Relationships: [
      {
        foreignKeyName: "quiz_attempts_category_id_fkey"
        columns: ["category_id"]
        isOneToOne: false
        referencedRelation: "quiz_categories"
        referencedColumns: ["id"]
      },
      {
        foreignKeyName: "quiz_attempts_question_id_fkey"
        columns: ["question_id"]
        isOneToOne: false
        referencedRelation: "quiz_questions"
        referencedColumns: ["id"]
      },
      {
        foreignKeyName: "quiz_attempts_session_id_fkey"
        columns: ["session_id"]
        isOneToOne: false
        referencedRelation: "quiz_sessions"
        referencedColumns: ["id"]
      },
    ]
  }
  quiz_answers: {
    Row: {
      answered_at: string
      id: number
      is_correct: boolean
      session_id: number
      tree_id: number | null
      user_answer: string | null
    }
    Insert: {
      answered_at?: string
      id?: never
      is_correct: boolean
      session_id: number
      tree_id?: number | null
      user_answer?: string | null
    }
    Update: {
      answered_at?: string
      id?: never
      is_correct?: boolean
      session_id?: number
      tree_id?: number | null
      user_answer?: string | null
    }
    Relationships: [
      {
        foreignKeyName: "quiz_answers_session_id_fkey"
        columns: ["session_id"]
        isOneToOne: false
        referencedRelation: "quiz_sessions"
        referencedColumns: ["id"]
      },
      {
        foreignKeyName: "quiz_answers_tree_id_fkey"
        columns: ["tree_id"]
        isOneToOne: false
        referencedRelation: "trees"
        referencedColumns: ["id"]
      },
    ]
  }
  user_quiz_summary: {
    Row: {
      user_id: string
      question_id: number | null
      tree_id: number | null
      is_last_correct: boolean
      updated_at: string
    }
    Insert: {
      user_id: string
      question_id?: number | null
      tree_id?: number | null
      is_last_correct: boolean
      updated_at?: string
    }
    Update: {
      user_id?: string
      question_id?: number | null
      tree_id?: number | null
      is_last_correct?: boolean
      updated_at?: string
    }
    Relationships: []
  }
  user_tree_category_stats: {
    Row: {
      user_id: string
      category_name: string
      total_count: number
      mastered_count: number
      in_progress_count: number
      accuracy_rate: number
      updated_at: string
    }
    Insert: {
      user_id: string
      category_name: string
      total_count: number
      mastered_count: number
      in_progress_count: number
      accuracy_rate: number
      updated_at?: string
    }
    Update: {
      user_id?: string
      category_name?: string
      total_count?: number
      mastered_count?: number
      in_progress_count?: number
      accuracy_rate?: number
      updated_at?: string
    }
    Relationships: []
  }
  user_exam_session_stats: {
    Row: {
      user_id: string
      exam_id: number
      subject_name: string
      total_count: number
      mastered_count: number
      in_progress_count: number
      accuracy_rate: number
      updated_at: string
    }
    Insert: {
      user_id: string
      exam_id: number
      subject_name: string
      total_count: number
      mastered_count: number
      in_progress_count: number
      accuracy_rate: number
      updated_at?: string
    }
    Update: {
      user_id?: string
      exam_id?: number
      subject_name?: string
      total_count?: number
      mastered_count?: number
      in_progress_count?: number
      accuracy_rate?: number
      updated_at?: string
    }
    Relationships: []
  }
}

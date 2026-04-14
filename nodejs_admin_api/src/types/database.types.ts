import { Json } from "./common.db";
import { AuthTables } from "./modules/auth.types";
import { TreeTables } from "./modules/trees.types";
import { QuizCoreTables } from "./modules/quiz-core.types";
import { QuizUserTables } from "./modules/quiz-user.types";
import { SettingTables } from "./modules/settings.types";

/**
 * Database Aggregator (Strategy I)
 * Reassembles split module types into the main Database interface.
 * Adheres to Rule 1-1 (200-line limit).
 */
export type Database = {
  __InternalSupabase: {
    PostgrestVersion: "14.1"
  }
  public: {
    Tables: {
      admins: AuthTables["admins"]
      profiles: AuthTables["profiles"]
      users: AuthTables["users"]
      trees: TreeTables["trees"]
      tree_images: TreeTables["tree_images"]
      tree_groups: TreeTables["tree_groups"]
      tree_group_members: TreeTables["tree_group_members"]
      ai_detections: TreeTables["ai_detections"]
      quiz_categories: QuizCoreTables["quiz_categories"]
      quiz_exams: QuizCoreTables["quiz_exams"]
      quiz_questions: QuizCoreTables["quiz_questions"]
      quiz_sessions: QuizUserTables["quiz_sessions"]
      quiz_attempts: QuizUserTables["quiz_attempts"]
      quiz_answers: QuizUserTables["quiz_answers"]
      user_quiz_summary: QuizUserTables["user_quiz_summary"]
      user_tree_category_stats: QuizUserTables["user_tree_category_stats"]
      user_exam_session_stats: QuizUserTables["user_exam_session_stats"]
      app_settings: SettingTables["app_settings"]
    }
    Views: {
      [_ in never]: never
    }




    Functions: {
      match_quiz_questions: {
        Args: {
          match_count: number
          match_threshold: number
          query_embedding: any
        }
        Returns: {
          content_blocks: Json
          id: number
          quiz_exams: Json
          similarity: number
        }[]
      }
      get_user_tree_category_stats: {
        Args: {
          p_user_id: string
        }
        Returns: any[]
      }
      get_user_exam_session_stats: {
        Args: {
          p_user_id: string
        }
        Returns: any[]
      }
      purge_old_attempts: {
        Args: Record<string, never>
        Returns: any
      }
    }
    Enums: {
      [_ in never]: never
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
}

export type Tables<
  T extends keyof Database["public"]["Tables"]
> = Database["public"]["Tables"][T] extends { Row: infer R } ? R : never

export type TablesInsert<
  T extends keyof Database["public"]["Tables"]
> = Database["public"]["Tables"][T] extends { Insert: infer I } ? I : never

export type TablesUpdate<
  T extends keyof Database["public"]["Tables"]
> = Database["public"]["Tables"][T] extends { Update: infer U } ? U : never

export type Enums<T extends keyof Database["public"]["Enums"]> = Database["public"]["Enums"][T]


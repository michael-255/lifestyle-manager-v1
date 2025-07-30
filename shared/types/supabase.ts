export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export type Database = {
  // Allows to automatically instanciate createClient with right options
  // instead of createClient<Database, { PostgrestVersion: 'XX' }>(URL, KEY)
  __InternalSupabase: {
    PostgrestVersion: "12.2.12 (cd3cf9e)"
  }
  public: {
    Tables: {
      exercise_results: {
        Row: {
          created_at: string
          data: Json | null
          exercise_id: string
          id: string
          is_locked: boolean | null
          note: string | null
          user_id: string
        }
        Insert: {
          created_at?: string
          data?: Json | null
          exercise_id: string
          id?: string
          is_locked?: boolean | null
          note?: string | null
          user_id?: string
        }
        Update: {
          created_at?: string
          data?: Json | null
          exercise_id?: string
          id?: string
          is_locked?: boolean | null
          note?: string | null
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "exercise_results_exercise_id_fkey"
            columns: ["exercise_id"]
            isOneToOne: false
            referencedRelation: "exercises"
            referencedColumns: ["id"]
          },
        ]
      }
      exercises: {
        Row: {
          created_at: string
          default_sets: number | null
          description: string | null
          id: string
          is_locked: boolean | null
          name: string
          rest_timer: number | null
          type: Database["public"]["Enums"]["exercise_type"]
          user_id: string
        }
        Insert: {
          created_at?: string
          default_sets?: number | null
          description?: string | null
          id?: string
          is_locked?: boolean | null
          name: string
          rest_timer?: number | null
          type: Database["public"]["Enums"]["exercise_type"]
          user_id?: string
        }
        Update: {
          created_at?: string
          default_sets?: number | null
          description?: string | null
          id?: string
          is_locked?: boolean | null
          name?: string
          rest_timer?: number | null
          type?: Database["public"]["Enums"]["exercise_type"]
          user_id?: string
        }
        Relationships: []
      }
      workout_exercises: {
        Row: {
          exercise_id: string
          position: number
          workout_id: string
        }
        Insert: {
          exercise_id: string
          position: number
          workout_id: string
        }
        Update: {
          exercise_id?: string
          position?: number
          workout_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "workout_exercises_exercise_id_fkey"
            columns: ["exercise_id"]
            isOneToOne: false
            referencedRelation: "exercises"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "workout_exercises_workout_id_fkey"
            columns: ["workout_id"]
            isOneToOne: false
            referencedRelation: "todays_workouts"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "workout_exercises_workout_id_fkey"
            columns: ["workout_id"]
            isOneToOne: false
            referencedRelation: "workouts"
            referencedColumns: ["id"]
          },
        ]
      }
      workout_result_exercise_results: {
        Row: {
          exercise_result_id: string
          position: number
          workout_result_id: string
        }
        Insert: {
          exercise_result_id: string
          position: number
          workout_result_id: string
        }
        Update: {
          exercise_result_id?: string
          position?: number
          workout_result_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "workout_result_exercise_results_exercise_result_id_fkey"
            columns: ["exercise_result_id"]
            isOneToOne: false
            referencedRelation: "exercise_results"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "workout_result_exercise_results_workout_result_id_fkey"
            columns: ["workout_result_id"]
            isOneToOne: false
            referencedRelation: "todays_workouts"
            referencedColumns: ["last_id"]
          },
          {
            foreignKeyName: "workout_result_exercise_results_workout_result_id_fkey"
            columns: ["workout_result_id"]
            isOneToOne: false
            referencedRelation: "workout_results"
            referencedColumns: ["id"]
          },
        ]
      }
      workout_results: {
        Row: {
          created_at: string
          finished_at: string | null
          id: string
          is_locked: boolean | null
          note: string | null
          user_id: string
          workout_id: string
        }
        Insert: {
          created_at?: string
          finished_at?: string | null
          id?: string
          is_locked?: boolean | null
          note?: string | null
          user_id?: string
          workout_id: string
        }
        Update: {
          created_at?: string
          finished_at?: string | null
          id?: string
          is_locked?: boolean | null
          note?: string | null
          user_id?: string
          workout_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "workout_results_workout_id_fkey"
            columns: ["workout_id"]
            isOneToOne: false
            referencedRelation: "todays_workouts"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "workout_results_workout_id_fkey"
            columns: ["workout_id"]
            isOneToOne: false
            referencedRelation: "workouts"
            referencedColumns: ["id"]
          },
        ]
      }
      workouts: {
        Row: {
          created_at: string
          description: string | null
          id: string
          is_locked: boolean | null
          name: string
          schedule:
            | Database["public"]["Enums"]["workout_schedule_type"][]
            | null
          user_id: string
        }
        Insert: {
          created_at?: string
          description?: string | null
          id?: string
          is_locked?: boolean | null
          name: string
          schedule?:
            | Database["public"]["Enums"]["workout_schedule_type"][]
            | null
          user_id?: string
        }
        Update: {
          created_at?: string
          description?: string | null
          id?: string
          is_locked?: boolean | null
          name?: string
          schedule?:
            | Database["public"]["Enums"]["workout_schedule_type"][]
            | null
          user_id?: string
        }
        Relationships: []
      }
    }
    Views: {
      todays_workouts: {
        Row: {
          description: string | null
          id: string | null
          is_locked: boolean | null
          last_created_at: string | null
          last_id: string | null
          last_note: string | null
          name: string | null
          schedule:
            | Database["public"]["Enums"]["workout_schedule_type"][]
            | null
        }
        Relationships: []
      }
    }
    Functions: {
      [_ in never]: never
    }
    Enums: {
      exercise_type:
        | "Checklist"
        | "Cardio"
        | "Weightlifting"
        | "Sided Weightlifting"
        | "Climbing"
      workout_schedule_type:
        | "Daily"
        | "Weekly"
        | "Sunday"
        | "Monday"
        | "Tuesday"
        | "Wednesday"
        | "Thursday"
        | "Friday"
        | "Saturday"
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
}

type DatabaseWithoutInternals = Omit<Database, "__InternalSupabase">

type DefaultSchema = DatabaseWithoutInternals[Extract<keyof Database, "public">]

export type Tables<
  DefaultSchemaTableNameOrOptions extends
    | keyof (DefaultSchema["Tables"] & DefaultSchema["Views"])
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
        DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
      DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])[TableName] extends {
      Row: infer R
    }
    ? R
    : never
  : DefaultSchemaTableNameOrOptions extends keyof (DefaultSchema["Tables"] &
        DefaultSchema["Views"])
    ? (DefaultSchema["Tables"] &
        DefaultSchema["Views"])[DefaultSchemaTableNameOrOptions] extends {
        Row: infer R
      }
      ? R
      : never
    : never

export type TablesInsert<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Insert: infer I
    }
    ? I
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Insert: infer I
      }
      ? I
      : never
    : never

export type TablesUpdate<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Update: infer U
    }
    ? U
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Update: infer U
      }
      ? U
      : never
    : never

export type Enums<
  DefaultSchemaEnumNameOrOptions extends
    | keyof DefaultSchema["Enums"]
    | { schema: keyof DatabaseWithoutInternals },
  EnumName extends DefaultSchemaEnumNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"]
    : never = never,
> = DefaultSchemaEnumNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"][EnumName]
  : DefaultSchemaEnumNameOrOptions extends keyof DefaultSchema["Enums"]
    ? DefaultSchema["Enums"][DefaultSchemaEnumNameOrOptions]
    : never

export type CompositeTypes<
  PublicCompositeTypeNameOrOptions extends
    | keyof DefaultSchema["CompositeTypes"]
    | { schema: keyof DatabaseWithoutInternals },
  CompositeTypeName extends PublicCompositeTypeNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"]
    : never = never,
> = PublicCompositeTypeNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"][CompositeTypeName]
  : PublicCompositeTypeNameOrOptions extends keyof DefaultSchema["CompositeTypes"]
    ? DefaultSchema["CompositeTypes"][PublicCompositeTypeNameOrOptions]
    : never

export const Constants = {
  public: {
    Enums: {
      exercise_type: [
        "Checklist",
        "Cardio",
        "Weightlifting",
        "Sided Weightlifting",
        "Climbing",
      ],
      workout_schedule_type: [
        "Daily",
        "Weekly",
        "Sunday",
        "Monday",
        "Tuesday",
        "Wednesday",
        "Thursday",
        "Friday",
        "Saturday",
      ],
    },
  },
} as const

export type TaskStatus = 'Pending' | 'In Progress' | 'Completed';

export type EisenhowerQuadrant = 
  | 'urgent_important'      // عاجل وهام (Do First)
  | 'not_urgent_important'  // غير عاجل وهام (Schedule)
  | 'urgent_not_important'  // عاجل وغير هام (Delegate)
  | 'not_urgent_not_important'; // غير عاجل وغير هام (Eliminate)

export interface Project {
  id: string;
  title: string;
  description: string;
  created_at: string;
}

export interface Task {
  id: string;
  project_id: string;
  task_name: string;
  status: TaskStatus;
  quadrant?: EisenhowerQuadrant;
  category?: 'مشروع التخرج' | 'جامعة وحاسبات' | 'شغل وبرمجة' | 'استثمار Thndr' | 'خدمة وكنيسة' | 'أخرى';
  estimatedMinutes?: number;
  actualMinutes?: number;
  startTime?: string;
  endTime?: string;
  created_at?: string;
}

export interface BlockLog {
  id: string;
  target: string;
  layer: string; // e.g. "Layer 1 - SafeSearch", "Layer 4 - Accessibility Deep Scan"
  reason: string;
  timestamp: string;
  actionTaken: string;
}

export interface PersonalizedNotification {
  id: string;
  title: string;
  body: string;
  type: 'graduation' | 'church_service' | 'thndr' | 'deep_focus' | 'break';
  scheduledTime?: string;
  isSent?: boolean;
}

export interface RouterSettings {
  model: string;
  ip: string;
  primaryDns: string;
  secondaryDns: string;
  encryptedPasswordHash?: string;
  isVaultLocked: boolean;
}

export interface Skill {
  id: string;
  project_id: string;
  skill_name: string;
  training_notes: string;
  created_at?: string;
}

export interface BlockerRule {
  id: string;
  blocked_urls: string[];
  active_hours: {
    start: string;
    end: string;
    days: string[];
  };
  fallback_url: string;
  is_active: boolean;
  dns_filtering_enabled?: boolean;
  safe_search_enforced?: boolean;
  app_lock_enabled?: boolean;
  kill_switch_enabled?: boolean;
  updated_at?: string;
}

export interface AIPromptRequest {
  projectIdea: string;
  apiKey?: string;
}

export interface AIPromptResponse {
  tasks: string[];
  skills: Array<{
    name: string;
    notes?: string;
  } | string>;
}


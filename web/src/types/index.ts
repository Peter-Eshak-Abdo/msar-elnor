export type TaskStatus = 'Pending' | 'In Progress' | 'Completed';

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
  created_at?: string;
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

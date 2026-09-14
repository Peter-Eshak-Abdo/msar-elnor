import { db, isFirebaseConfigured } from './firebase';
import { supabase, isSupabaseConfigured } from './supabase';
import {
  collection,
  doc,
  getDocs,
  setDoc,
  deleteDoc,
  updateDoc,
} from 'firebase/firestore';
import { Project, Task, Skill, BlockerRule } from '@/types';

// Default initial data
const INITIAL_PROJECTS: Project[] = [
  {
    id: '11111111-1111-1111-1111-111111111111',
    title: 'مشروع أبونا فلتاؤس',
    description: 'منظومة إدارة المبيعات والمهام التقنية لخدمة وتطوير الأعمال وفق مسار النور',
    created_at: new Date().toISOString(),
  },
];

const INITIAL_TASKS: Task[] = [
  {
    id: 't-1',
    project_id: '11111111-1111-1111-1111-111111111111',
    task_name: 'إعداد البنية التحتية والمصادقة الآمنة',
    status: 'Completed',
    created_at: new Date().toISOString(),
  },
  {
    id: 't-2',
    project_id: '11111111-1111-1111-1111-111111111111',
    task_name: 'بناء واجهة لوحة التحكم ERP بـ Next.js و Tailwind',
    status: 'In Progress',
    created_at: new Date().toISOString(),
  },
  {
    id: 't-3',
    project_id: '11111111-1111-1111-1111-111111111111',
    task_name: 'دمج مسار الذكاء الاصطناعي لتوليد خطط المشاريع والمهام',
    status: 'Pending',
    created_at: new Date().toISOString(),
  },
  {
    id: 't-4',
    project_id: '11111111-1111-1111-1111-111111111111',
    task_name: 'تجهيز خدمة الـ Accessibility في تطبيق Flutter للحظر الصارم',
    status: 'Pending',
    created_at: new Date().toISOString(),
  },
];

const INITIAL_SKILLS: Skill[] = [
  {
    id: 's-1',
    project_id: '11111111-1111-1111-1111-111111111111',
    skill_name: 'مهارات البيع والتفاوض الإقناعي',
    training_notes: 'التدريب على مهارات الاستماع الفعال وتحديد احتياجات العميل بدقة قبل طرح الحلول التسويقية والتقنية',
    created_at: new Date().toISOString(),
  },
  {
    id: 's-2',
    project_id: '11111111-1111-1111-1111-111111111111',
    skill_name: 'إدارة الوقت والتركيز والانضباط الرقمي',
    training_notes: 'الالتزام بأوقات العمل والابتعاد التام عن المشتتات وشبكات التواصل أثناء ساعات الحظر النشطة',
    created_at: new Date().toISOString(),
  },
];

const INITIAL_BLOCKER_RULES: BlockerRule = {
  id: '22222222-2222-2222-2222-222222222222',
  blocked_urls: [
    'facebook.com',
    'tiktok.com',
    'instagram.com',
    'x.com',
    'twitter.com',
    'youtube.com/shorts',
    'reddit.com',
  ],
  active_hours: {
    start: '23:00',
    end: '07:00',
    days: ['Everyday'],
  },
  fallback_url: 'https://www.youtube.com/watch?v=aripsalin-tasbeha',
  is_active: true,
};

function getLocal<T>(key: string, fallback: T): T {
  if (typeof window === 'undefined') return fallback;
  try {
    const item = localStorage.getItem(`msar_elnor_${key}`);
    return item ? JSON.parse(item) : fallback;
  } catch {
    return fallback;
  }
}

function setLocal<T>(key: string, val: T): void {
  if (typeof window === 'undefined') return;
  try {
    localStorage.setItem(`msar_elnor_${key}`, JSON.stringify(val));
  } catch (e) {
    console.error('Failed to write to localStorage', e);
  }
}

export const DataService = {
  // Projects
  async getProjects(): Promise<Project[]> {
    if (isFirebaseConfigured && db) {
      try {
        const snap = await getDocs(collection(db, 'projects'));
        if (!snap.empty) {
          return snap.docs.map((d) => d.data() as Project);
        }
      } catch (err) {
        console.warn('Firebase read error:', err);
      }
    }

    if (isSupabaseConfigured && supabase) {
      try {
        const { data, error } = await supabase.from('projects').select('*').order('created_at', { ascending: false });
        if (!error && data && data.length > 0) return data as Project[];
      } catch {}
    }

    return getLocal<Project[]>('projects', INITIAL_PROJECTS);
  },

  async createProject(title: string, description: string): Promise<Project> {
    const newProj: Project = {
      id: typeof crypto !== 'undefined' && crypto.randomUUID ? crypto.randomUUID() : `proj-${Date.now()}`,
      title,
      description,
      created_at: new Date().toISOString(),
    };

    if (isFirebaseConfigured && db) {
      try {
        await setDoc(doc(db, 'projects', newProj.id), newProj);
      } catch (err) {
        console.warn('Firebase write error:', err);
      }
    }

    if (isSupabaseConfigured && supabase) {
      try {
        await supabase.from('projects').insert([newProj]);
      } catch {}
    }

    const projects = getLocal<Project[]>('projects', INITIAL_PROJECTS);
    const updated = [newProj, ...projects];
    setLocal('projects', updated);
    return newProj;
  },

  async deleteProject(id: string): Promise<void> {
    if (isFirebaseConfigured && db) {
      try {
        await deleteDoc(doc(db, 'projects', id));
      } catch {}
    }

    if (isSupabaseConfigured && supabase) {
      try {
        await supabase.from('projects').delete().eq('id', id);
      } catch {}
    }

    const projects = getLocal<Project[]>('projects', INITIAL_PROJECTS).filter((p) => p.id !== id);
    setLocal('projects', projects);
  },

  // Tasks
  async getTasks(projectId?: string): Promise<Task[]> {
    if (isFirebaseConfigured && db) {
      try {
        const snap = await getDocs(collection(db, 'tasks'));
        if (!snap.empty) {
          const allTasks = snap.docs.map((d) => d.data() as Task);
          return projectId ? allTasks.filter((t) => t.project_id === projectId) : allTasks;
        }
      } catch {}
    }

    if (isSupabaseConfigured && supabase) {
      try {
        let query = supabase.from('tasks').select('*').order('created_at', { ascending: true });
        if (projectId) query = query.eq('project_id', projectId);
        const { data, error } = await query;
        if (!error && data && data.length > 0) return data as Task[];
      } catch {}
    }

    const tasks = getLocal<Task[]>('tasks', INITIAL_TASKS);
    return projectId ? tasks.filter((t) => t.project_id === projectId) : tasks;
  },

  async addTask(projectId: string, taskName: string, status: Task['status'] = 'Pending'): Promise<Task> {
    const newTask: Task = {
      id: typeof crypto !== 'undefined' && crypto.randomUUID ? crypto.randomUUID() : `task-${Date.now()}`,
      project_id: projectId,
      task_name: taskName,
      status,
      created_at: new Date().toISOString(),
    };

    if (isFirebaseConfigured && db) {
      try {
        await setDoc(doc(db, 'tasks', newTask.id), newTask);
      } catch {}
    }

    if (isSupabaseConfigured && supabase) {
      try {
        await supabase.from('tasks').insert([newTask]);
      } catch {}
    }

    const tasks = getLocal<Task[]>('tasks', INITIAL_TASKS);
    const updated = [...tasks, newTask];
    setLocal('tasks', updated);
    return newTask;
  },

  async updateTaskStatus(taskId: string, status: Task['status']): Promise<void> {
    if (isFirebaseConfigured && db) {
      try {
        await updateDoc(doc(db, 'tasks', taskId), { status });
      } catch {}
    }

    if (isSupabaseConfigured && supabase) {
      try {
        await supabase.from('tasks').update({ status }).eq('id', taskId);
      } catch {}
    }

    const tasks = getLocal<Task[]>('tasks', INITIAL_TASKS).map((t) =>
      t.id === taskId ? { ...t, status } : t
    );
    setLocal('tasks', tasks);
  },

  async deleteTask(taskId: string): Promise<void> {
    if (isFirebaseConfigured && db) {
      try {
        await deleteDoc(doc(db, 'tasks', taskId));
      } catch {}
    }

    if (isSupabaseConfigured && supabase) {
      try {
        await supabase.from('tasks').delete().eq('id', taskId);
      } catch {}
    }

    const tasks = getLocal<Task[]>('tasks', INITIAL_TASKS).filter((t) => t.id !== taskId);
    setLocal('tasks', tasks);
  },

  // Skills
  async getSkills(projectId?: string): Promise<Skill[]> {
    if (isFirebaseConfigured && db) {
      try {
        const snap = await getDocs(collection(db, 'skills'));
        if (!snap.empty) {
          const allSkills = snap.docs.map((d) => d.data() as Skill);
          return projectId ? allSkills.filter((s) => s.project_id === projectId) : allSkills;
        }
      } catch {}
    }

    if (isSupabaseConfigured && supabase) {
      try {
        let query = supabase.from('skills').select('*').order('created_at', { ascending: true });
        if (projectId) query = query.eq('project_id', projectId);
        const { data, error } = await query;
        if (!error && data && data.length > 0) return data as Skill[];
      } catch {}
    }

    const skills = getLocal<Skill[]>('skills', INITIAL_SKILLS);
    return projectId ? skills.filter((s) => s.project_id === projectId) : skills;
  },

  async addSkill(projectId: string, skillName: string, notes: string): Promise<Skill> {
    const newSkill: Skill = {
      id: typeof crypto !== 'undefined' && crypto.randomUUID ? crypto.randomUUID() : `skill-${Date.now()}`,
      project_id: projectId,
      skill_name: skillName,
      training_notes: notes,
      created_at: new Date().toISOString(),
    };

    if (isFirebaseConfigured && db) {
      try {
        await setDoc(doc(db, 'skills', newSkill.id), newSkill);
      } catch {}
    }

    if (isSupabaseConfigured && supabase) {
      try {
        await supabase.from('skills').insert([newSkill]);
      } catch {}
    }

    const skills = getLocal<Skill[]>('skills', INITIAL_SKILLS);
    const updated = [...skills, newSkill];
    setLocal('skills', updated);
    return newSkill;
  },

  async deleteSkill(skillId: string): Promise<void> {
    if (isFirebaseConfigured && db) {
      try {
        await deleteDoc(doc(db, 'skills', skillId));
      } catch {}
    }

    if (isSupabaseConfigured && supabase) {
      try {
        await supabase.from('skills').delete().eq('id', skillId);
      } catch {}
    }

    const skills = getLocal<Skill[]>('skills', INITIAL_SKILLS).filter((s) => s.id !== skillId);
    setLocal('skills', skills);
  },

  // Blocker Rules
  async getBlockerRules(): Promise<BlockerRule> {
    if (isFirebaseConfigured && db) {
      try {
        const snap = await getDocs(collection(db, 'blocker_rules'));
        if (!snap.empty) {
          return snap.docs[0].data() as BlockerRule;
        }
      } catch {}
    }

    if (isSupabaseConfigured && supabase) {
      try {
        const { data, error } = await supabase.from('blocker_rules').select('*').limit(1).single();
        if (!error && data) return data as BlockerRule;
      } catch {}
    }

    return getLocal<BlockerRule>('blocker_rules', INITIAL_BLOCKER_RULES);
  },

  async updateBlockerRules(rules: BlockerRule): Promise<BlockerRule> {
    const updated = { ...rules, updated_at: new Date().toISOString() };

    if (isFirebaseConfigured && db) {
      try {
        await setDoc(doc(db, 'blocker_rules', 'current'), updated);
      } catch {}
    }

    if (isSupabaseConfigured && supabase) {
      try {
        await supabase.from('blocker_rules').upsert([updated]);
      } catch {}
    }

    setLocal('blocker_rules', updated);
    return updated;
  },

  // Backup & Restore
  exportAllData(): string {
    const data = {
      projects: getLocal<Project[]>('projects', INITIAL_PROJECTS),
      tasks: getLocal<Task[]>('tasks', INITIAL_TASKS),
      skills: getLocal<Skill[]>('skills', INITIAL_SKILLS),
      blocker_rules: getLocal<BlockerRule>('blocker_rules', INITIAL_BLOCKER_RULES),
      exported_at: new Date().toISOString(),
    };
    return JSON.stringify(data, null, 2);
  },

  importData(jsonString: string): boolean {
    try {
      const parsed = JSON.parse(jsonString);
      if (parsed.projects) setLocal('projects', parsed.projects);
      if (parsed.tasks) setLocal('tasks', parsed.tasks);
      if (parsed.skills) setLocal('skills', parsed.skills);
      if (parsed.blocker_rules) setLocal('blocker_rules', parsed.blocker_rules);
      return true;
    } catch {
      return false;
    }
  },
};

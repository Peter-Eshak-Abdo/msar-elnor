-- ==============================================================================
-- مشروع مسار النور (Msar Elnor) - Supabase Database Schema
-- ==============================================================================

-- تفعيل امتداد توليد المعرفات الفريدة UUID
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. جدول المشاريع (Projects)
CREATE TABLE IF NOT EXISTS public.projects (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title VARCHAR(255) NOT NULL,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 2. جدول المهام (Tasks)
CREATE TABLE IF NOT EXISTS public.tasks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_id UUID NOT NULL REFERENCES public.projects(id) ON DELETE CASCADE,
    task_name VARCHAR(255) NOT NULL,
    status VARCHAR(50) DEFAULT 'Pending' CHECK (status IN ('Pending', 'In Progress', 'Completed')) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 3. جدول المهارات (Skills)
CREATE TABLE IF NOT EXISTS public.skills (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_id UUID NOT NULL REFERENCES public.projects(id) ON DELETE CASCADE,
    skill_name VARCHAR(255) NOT NULL,
    training_notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 4. جدول قواعد الحظر الصارم (Blocker Rules)
CREATE TABLE IF NOT EXISTS public.blocker_rules (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    blocked_urls TEXT[] NOT NULL DEFAULT '{}',
    active_hours JSONB NOT NULL DEFAULT '{"start": "23:00", "end": "07:00", "days": ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]}'::jsonb,
    fallback_url TEXT NOT NULL DEFAULT 'https://www.youtube.com/watch?v=sample-tasbeha',
    is_active BOOLEAN NOT NULL DEFAULT true,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- فهارس تحسين الأداء (Indexes)
CREATE INDEX IF NOT EXISTS idx_tasks_project_id ON public.tasks(project_id);
CREATE INDEX IF NOT EXISTS idx_skills_project_id ON public.skills(project_id);

-- سياسات الأمان على مستوى الصفوف (Row Level Security - RLS)
ALTER TABLE public.projects ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.skills ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.blocker_rules ENABLE ROW LEVEL SECURITY;

-- السماح بالوصول الكامل للمستخدمين المعتمدين والمجهولين في طور التطوير (يمكن تقييدها لاحقاً بالمصادقة)
CREATE POLICY "Allow public read-write for projects" ON public.projects FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow public read-write for tasks" ON public.tasks FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow public read-write for skills" ON public.skills FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow public read-write for blocker_rules" ON public.blocker_rules FOR ALL USING (true) WITH CHECK (true);

-- بيانات أولية تجريبية (Seed Data)
INSERT INTO public.projects (id, title, description)
VALUES 
    ('11111111-1111-1111-1111-111111111111', 'مشروع أبونا فلتاؤس', 'منظومة إدارة المبيعات والمهام التقنية لخدمة وتطوير الأعمال وفق مسار النور')
ON CONFLICT (id) DO NOTHING;

INSERT INTO public.tasks (project_id, task_name, status)
VALUES 
    ('11111111-1111-1111-1111-111111111111', 'إعداد البنية التحتية والمصادقة في Supabase', 'Completed'),
    ('11111111-1111-1111-1111-111111111111', 'بناء واجهة لوحة التحكم ERP بـ Next.js', 'In Progress'),
    ('11111111-1111-1111-1111-111111111111', 'دمج مسار الذكاء الاصطناعي لتوليد خطط المشاريع', 'Pending'),
    ('11111111-1111-1111-1111-111111111111', 'تجهيز خدمة الـ Accessibility في تطبيق Flutter للحظر الصارم', 'Pending')
ON CONFLICT DO NOTHING;

INSERT INTO public.skills (project_id, skill_name, training_notes)
VALUES 
    ('11111111-1111-1111-1111-111111111111', 'مهارات البيع والتفاوض', 'التدريب على مهارات الاستماع الفعال وتحديد احتياجات العميل بدقة قبل طرح الحلول'),
    ('11111111-1111-1111-1111-111111111111', 'إدارة الوقت والتركيز الروحي', 'الالتزام بأوقات العمل والابتعاد التام عن المشتتات أثناء فترات الحظر الرقمي')
ON CONFLICT DO NOTHING;

INSERT INTO public.blocker_rules (id, blocked_urls, active_hours, fallback_url, is_active)
VALUES 
    ('22222222-2222-2222-2222-222222222222', 
     ARRAY['facebook.com', 'tiktok.com', 'instagram.com', 'x.com', 'youtube.com/shorts'], 
     '{"start": "23:00", "end": "07:00", "days": ["Everyday"]}'::jsonb, 
     'https://www.youtube.com/watch?v=aripsalin-tasbeha',
     true)
ON CONFLICT (id) DO NOTHING;

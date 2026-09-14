# خطة بناء تطبيق "مسار النور" - الخطة الشاملة لـ Antigravity

هذا الملف مصمم ليتم إدراجه مباشرة في Antigravity IDE. يحتوي على التقسيم المعماري والبرمجي الكامل للمشروع.

## 1. بنية النظام التقنية (Tech Stack)
- **واجهة الويب (لوحة التحكم):** Next.js, Tailwind CSS, Shadcn UI.
- **قاعدة البيانات والمصادقة:** Supabase.
- **تطبيق الموبايل (أداة الحظر الصارم):** Flutter مع Provider و Hive، واستخدام Native Channels للتحكم بصلاحيات النظام.
- **الذكاء الاصطناعي:** استخدام `@google/genai` عبر Next.js API Routes.

---

## 2. هيكل قواعد البيانات (Supabase Schema)
يجب إنشاء الجداول التالية في Supabase:

1. **`projects`**:
   - `id` (UUID, Primary Key)
   - `title` (String) - مثال: مشروع أبونا فلتاؤس
   - `description` (Text)
   - `created_at` (Timestamp)

2. **`tasks`**:
   - `id` (UUID, Primary Key)
   - `project_id` (UUID, Foreign Key)
   - `task_name` (String)
   - `status` (String) - Pending, In Progress, Completed

3. **`skills`**:
   - `id` (UUID, Primary Key)
   - `project_id` (UUID, Foreign Key)
   - `skill_name` (String) - مثال: مهارات البيع، التسويق
   - `training_notes` (Text)

4. **`blocker_rules`**:
   - `id` (UUID)
   - `blocked_urls` (Array of Strings) - المواقع المحظورة
   - `active_hours` (JSON) - أوقات الحظر (مثال: من 11 مساءً إلى 7 صباحاً)
   - `fallback_url` (String) - رابط ألحان أريبصالين أو التسبحة

---

## 3. حل مشكلة غياب Google AI Studio MCP
بما أن الـ MCP غير متوفر، سنقوم بدمج الذكاء الاصطناعي برمجياً داخل التطبيق مباشرة دون الاعتماد على إضافات المحرر.

**المطلوب في Next.js:**
1. تثبيت مكتبة جوجل: `npm install @google/genai`
2. إنشاء ملف API Route في المسار: `app/api/generate-plan/route.ts`
3. **الكود الأساسي للـ API:**

```typescript
import { GoogleGenAI } from '@google/genai';
import { NextResponse } from 'next/server';

const ai = new GoogleGenAI({ apiKey: process.env.GEMINI_API_KEY });

export async function POST(request: Request) {
  const { projectIdea } = await request.json();

  const systemPrompt = `
    أنت مدير مشاريع تقنية ومدرب مبيعات.
    المستخدم سيطرح فكرة مشروع. قم بتحليلها واستخراج:
    1. مهام برمجية دقيقة (Technical Tasks).
    2. مهارات مطلوبة لتنفيذ وبيع المشروع (Required Skills) مثل مهارات العرض أو التفاوض.
    أرجع النتيجة بصيغة JSON فقط بهذا الهيكل:
    { "tasks": [], "skills": [] }
  `;

  try {
    const response = await ai.models.generateContent({
      model: 'gemini-2.5-pro',
      contents: projectIdea,
      config: { systemInstruction: systemPrompt, responseMimeType: "application/json" }
    });
    return NextResponse.json(JSON.parse(response.text));
  } catch (error) {
    return NextResponse.json({ error: 'Failed to generate plan' }, { status: 500 });
  }
}
```

---

## 4. تطبيق الحظر الصارم (Flutter)
التطبيق لن يكون مجرد تطبيق عادي، بل سيستخدم صلاحيات متقدمة.

**المهام المطلوبة من Antigravity في Flutter:**
1. إعداد **Method Channels** للاتصال بـ Kotlin (Android).
2. طلب صلاحية **Accessibility Service** لمراقبة الشاشة وإغلاق التطبيقات المحظورة فوراً (Force Close).
3. عند رصد فتح موقع/تطبيق محظور:
   - يتم إطلاق حدث (Event) للتطبيق.
   - تظهر شاشة (Overlay) تغطي الشاشة بالكامل تعرض فيديو/صوتيات (تسبحة نصف الليل أو الألحان).
4. استخدام **Hive** لحفظ إعدادات الحظر محلياً لضمان عملها حتى بدون إنترنت.

---

## 5. خطوات التنفيذ لـ Antigravity (Implementation Phases)
قم بتنفيذ هذه الخطوات بالترتيب:
1. **Phase 1**: Initializing Next.js project with Tailwind CSS & Shadcn UI.
2. **Phase 2**: Setting up Supabase client and linking the database schema.
3. **Phase 3**: Creating the Dashboard layout (ERP style) for projects, tasks, and skills.
4. **Phase 4**: Implementing the Gemini API route for generating tasks.
5. **Phase 5**: Generating the Flutter project and implementing the Accessibility Service for the blocker.

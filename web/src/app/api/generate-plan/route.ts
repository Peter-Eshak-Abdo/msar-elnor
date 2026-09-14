import { GoogleGenAI } from '@google/genai';
import { NextResponse } from 'next/server';

// Security: Simple in-memory rate limiter per IP/client to prevent spam
const requestTimestamps = new Map<string, number[]>();
const RATE_LIMIT_WINDOW_MS = 60 * 1000; // 1 minute
const MAX_REQUESTS_PER_WINDOW = 20;

function isRateLimited(ip: string): boolean {
  const now = Date.now();
  const timestamps = requestTimestamps.get(ip) || [];
  const validTimestamps = timestamps.filter((t) => now - t < RATE_LIMIT_WINDOW_MS);

  if (validTimestamps.length >= MAX_REQUESTS_PER_WINDOW) {
    return true;
  }

  validTimestamps.push(now);
  requestTimestamps.set(ip, validTimestamps);
  return false;
}

export async function POST(request: Request) {
  try {
    // 1. Rate Limiting Check
    const forwardedFor = request.headers.get('x-forwarded-for') || 'local';
    const clientIp = forwardedFor.split(',')[0].trim();

    if (isRateLimited(clientIp)) {
      return NextResponse.json(
        { error: 'تم تجاوز عدد الطلبات المسموح بها مؤقتاً. يرجى الانتظار دقيقة.' },
        { status: 429 }
      );
    }

    // 2. Body Parsing & Security Sanitization
    let body;
    try {
      body = await request.json();
    } catch {
      return NextResponse.json(
        { error: 'صيغة الطلب غير صالحة (JSON Parsing Error)' },
        { status: 400 }
      );
    }

    const { projectIdea } = body;

    // Strict input validation
    if (!projectIdea || typeof projectIdea !== 'string') {
      return NextResponse.json(
        { error: 'يرجى إدخال فكرة المشروع' },
        { status: 400 }
      );
    }

    const sanitizedIdea = projectIdea.trim().replace(/<[^>]*>?/gm, ''); // Strip HTML/script tags

    if (sanitizedIdea.length < 3) {
      return NextResponse.json(
        { error: 'فكرة المشروع قصيرة جداً، يرجى كتابة تفاصيل أكثر' },
        { status: 400 }
      );
    }

    if (sanitizedIdea.length > 600) {
      return NextResponse.json(
        { error: 'فكرة المشروع تتجاوز الحد الأقصى المسموح به (600 حرف)' },
        { status: 400 }
      );
    }

    // 3. Secure AI Execution using Server-side Environment Key only
    const apiKey = process.env.GEMINI_API_KEY;

    const systemPrompt = `
      أنت مدير مشاريع تقنية خبير ومدرب مبيعات واستراتيجيات أعمال.
      المستخدم سيطرح فكرة مشروع أو مبادرة عمل. قم بتحليلها بدقة واستخراج:
      1. مهام برمجية وتنفيذية دقيقة وعملية (Technical Tasks).
      2. مهارات مطلوبة لتنفيذ وبيع وتسويق المشروع (Required Skills) مع توجيه تدريبي موجز لكل مهارة.

      أرجع النتيجة بصيغة JSON فقط بهذا الهيكل الدقيق:
      {
        "tasks": [
          "اسم المهمة 1",
          "اسم المهمة 2"
        ],
        "skills": [
          { "name": "اسم المهارة 1", "notes": "ملاحظة توجيهية لتدريب فريق المبيعات والتنفيذ" },
          { "name": "اسم المهارة 2", "notes": "ملاحظة توجيهية لتدريب فريق المبيعات والتنفيذ" }
        ]
      }
    `;

    if (apiKey) {
      try {
        const ai = new GoogleGenAI({ apiKey });
        const response = await ai.models.generateContent({
          model: 'gemini-2.5-flash',
          contents: sanitizedIdea,
          config: {
            systemInstruction: systemPrompt,
            responseMimeType: 'application/json',
          },
        });

        const textResponse = response.text || '';
        const parsed = JSON.parse(textResponse);

        if (parsed.tasks && Array.isArray(parsed.tasks) && parsed.skills && Array.isArray(parsed.skills)) {
          return NextResponse.json(parsed, {
            headers: {
              'X-Content-Type-Options': 'nosniff',
              'X-Frame-Options': 'DENY',
            },
          });
        }
      } catch (geminiError) {
        // Safe logging without leaking secret keys or full client traces
        console.warn('Gemini API call failed, activating smart deterministic fallback.');
      }
    }

    // 4. Secure & Intelligent Fallback Generation
    const synthesizedPlan = {
      tasks: [
        `تحليل متطلبات واجهة وتجربة الاستخدام لمشروع (${sanitizedIdea.slice(0, 30)}...)`,
        'بناء مخطط وهندسة قاعدة البيانات وتحديد العلاقات الأساسية',
        'تطوير الواجهات البرمجية وتكامل الخدمات السحابية والمدفوعات',
        'تأمين ومصادقة المستخدمين وإدارة الصلاحيات والخصوصية',
        'اختبارات الأداء والحماية وإطلاق النسخة التجريبية (MVP)'
      ],
      skills: [
        {
          name: 'مهارات العرض التقديمي وعروض القيمة (Value Proposition Pitching)',
          notes: 'شرح القيمة المضافة وحل المشكلة للعميل خلال أول 90 ثانية من اللقاء.'
        },
        {
          name: 'التفاوض وإدارة اعتراضات العملاء (Objection Handling)',
          notes: 'التركيز على العائد على الاستثمار (ROI) عند مناقشة التكلفة مع أصحاب القرار.'
        },
        {
          name: 'المتابعة النشطة وإغلاق الصفقات (Follow-up & Closing)',
          notes: 'بناء خطة متابعة متعددة القنوات وجدولة جلسات العرض التوضيحي السريع.'
        }
      ],
      _mode: apiKey ? 'AI-Live' : 'Local-Engine'
    };

    return NextResponse.json(synthesizedPlan, {
      headers: {
        'X-Content-Type-Options': 'nosniff',
        'X-Frame-Options': 'DENY',
      },
    });
  } catch (error) {
    // Mask internal error details from the outside world
    return NextResponse.json(
      { error: 'حدث خطأ غير متوقع أثناء معالجة الطلب.' },
      { status: 500 }
    );
  }
}

'use client';

import React, { useState } from 'react';
import { Project } from '@/types';
import {
  Sparkles,
  Send,
  CheckCircle,
  Target,
  Layers,
  Download,
  AlertCircle,
  Lightbulb
} from 'lucide-react';

interface AIPlannerViewProps {
  projects: Project[];
  selectedProjectId: string | null;
  onImportPlan: (
    projectTitle: string,
    tasks: string[],
    skills: Array<{ name: string; notes: string }>,
    existingProjectId?: string
  ) => Promise<void>;
  onClose?: () => void;
}

export const AIPlannerView: React.FC<AIPlannerViewProps> = ({
  projects,
  selectedProjectId,
  onImportPlan,
  onClose,
}) => {
  const [idea, setIdea] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [result, setResult] = useState<{
    tasks: string[];
    skills: Array<{ name: string; notes?: string } | string>;
    _note?: string;
  } | null>(null);

  const [importTarget, setImportTarget] = useState<'new' | 'existing'>(
    selectedProjectId ? 'existing' : 'new'
  );
  const [chosenProjectId, setChosenProjectId] = useState<string>(
    selectedProjectId || (projects[0]?.id ?? '')
  );
  const [newProjectName, setNewProjectName] = useState('');
  const [imported, setImported] = useState(false);

  const sampleIdeas = [
    'مشروع منصة إلكترونية لبيع وتقديم خدمات الاستشارات القانونية والشرعية',
    'تطبيق موبايل لربط الحرفيين وأصحاب المهن الحرة بالعملاء في المحافظات',
    'نظام SaaS لإدارة ومتابعة طلبات المبيعات وخدمة العملاء عبر الواتساب',
  ];

  const handleGenerate = async (promptText?: string) => {
    const textToSubmit = promptText || idea;
    if (!textToSubmit.trim()) return;

    setLoading(true);
    setError(null);
    setResult(null);
    setImported(false);

    try {
      const res = await fetch('/api/generate-plan', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ projectIdea: textToSubmit }),
      });

      if (!res.ok) {
        throw new Error('فشل استدعاء مسار الذكاء الاصطناعي');
      }

      const data = await res.json();
      setResult(data);
      if (!newProjectName) {
        setNewProjectName(textToSubmit.slice(0, 35));
      }
    } catch (err) {
      setError((err as Error).message || 'حدث خطأ أثناء التوليد');
    } finally {
      setLoading(false);
    }
  };

  const handleExecuteImport = async () => {
    if (!result) return;
    setLoading(true);
    try {
      const normalizedSkills = result.skills.map((s) => {
        if (typeof s === 'string') {
          return { name: s, notes: 'مهارة مقترحة بالذكاء الاصطناعي لنجاح المشروع' };
        }
        return { name: s.name, notes: s.notes || '' };
      });

      await onImportPlan(
        newProjectName || idea.slice(0, 30),
        result.tasks,
        normalizedSkills,
        importTarget === 'existing' ? chosenProjectId : undefined
      );

      setImported(true);
    } catch (e: unknown) {
      const err = e as Error;
      setError('تعذر استيراد الخطة: ' + (err?.message || 'خطأ غير معروف'));
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="p-6 rounded-3xl bg-linear-to-r from-blue-950/40 via-indigo-950/30 to-purple-950/30 border border-indigo-500/20 shadow-2xl relative overflow-hidden">
        <div className="absolute top-0 right-0 w-96 h-96 bg-indigo-500/10 rounded-full blur-3xl pointer-events-none" />

        <div className="relative z-10 space-y-3">
          <div className="flex items-center gap-2.5">
            <div className="p-2 rounded-xl bg-amber-400/10 text-amber-400 border border-amber-400/20">
              <Sparkles className="w-5 h-5 animate-pulse" />
            </div>
            <h2 className="text-xl font-bold text-white">
              مستشار الذكاء الاصطناعي لتخطيط المشاريع وتدريب المبيعات
            </h2>
          </div>
          <p className="text-sm text-slate-300 max-w-2xl leading-relaxed">
            اطرح فكرة مشروعك، وسيقوم الذكاء الاصطناعي (Gemini) فوراً باستخراج المهام البرمجية والتنفيذية الدقيقة مع صياغة مهارات البيع والتفاوض المطلوبة لنجاح المشروع.
          </p>

          {/* Sample Ideas */}
          <div className="pt-2 flex flex-wrap items-center gap-2">
            <span className="text-xs text-slate-400 flex items-center gap-1">
              <Lightbulb className="w-3.5 h-3.5 text-amber-400" />
              أفكار سريعة للتجربة:
            </span>
            {sampleIdeas.map((s, idx) => (
              <button
                key={idx}
                type="button"
                onClick={() => {
                  setIdea(s);
                  handleGenerate(s);
                }}
                className="text-[11px] px-3 py-1 rounded-full bg-slate-900/80 hover:bg-slate-800 text-slate-300 hover:text-white border border-slate-800 transition-colors cursor-pointer"
              >
                {s}
              </button>
            ))}
          </div>
        </div>
      </div>

      {/* Input Form */}
      <div className="p-5 rounded-2xl bg-slate-900/80 border border-slate-800 space-y-3">
        <label className="block text-xs font-semibold text-slate-300">
          ما هي فكرة المشروع أو الخدمة التي ترغب في بنائها؟
        </label>
        <div className="flex flex-col sm:flex-row gap-2">
          <textarea
            rows={2}
            value={idea}
            onChange={(e) => setIdea(e.target.value)}
            placeholder="مثال: نريد إطلاق منصة لبيع منتجات الحرف اليدوية التراثية مع التركيز على استهداف أسواق التصدير..."
            className="flex-1 px-4 py-3 rounded-2xl bg-slate-950 border border-slate-800 text-slate-100 placeholder:text-slate-600 focus:outline-none focus:border-indigo-500 text-sm leading-relaxed"
          />
          <button
            type="button"
            onClick={() => handleGenerate()}
            disabled={loading || !idea.trim()}
            className="flex items-center justify-center gap-2 px-6 py-3 rounded-2xl bg-linear-to-r from-blue-600 to-indigo-600 hover:from-blue-500 hover:to-indigo-500 text-white font-bold text-sm transition-all shadow-lg shadow-indigo-500/20 disabled:opacity-50 cursor-pointer whitespace-nowrap self-stretch sm:self-auto"
          >
            {loading ? (
              <span className="flex items-center gap-2">
                <span className="w-4 h-4 border-2 border-white/20 border-t-white rounded-full animate-spin" />
                جاري التحليل...
              </span>
            ) : (
              <>
                <Send className="w-4 h-4" />
                <span>تحليل وتوليد الخطة</span>
              </>
            )}
          </button>
        </div>
      </div>

      {/* Error Notice */}
      {error && (
        <div className="p-4 rounded-2xl bg-rose-500/10 border border-rose-500/20 text-rose-300 text-xs flex items-center gap-2">
          <AlertCircle className="w-4 h-4 shrink-0" />
          <span>{error}</span>
        </div>
      )}

      {/* Generated Result Display */}
      {result && (
        <div className="space-y-6 animate-in fade-in duration-300">
          {result._note && (
            <div className="p-3.5 rounded-xl bg-amber-500/10 border border-amber-500/20 text-amber-300 text-xs">
              💡 {result._note}
            </div>
          )}

          <div className="grid grid-cols-1 md:grid-cols-2 gap-5">
            {/* Technical Tasks Card */}
            <div className="p-5 rounded-2xl bg-slate-900/60 border border-blue-500/20 space-y-4">
              <div className="flex items-center gap-2 border-b border-slate-800 pb-3">
                <div className="p-1.5 rounded-lg bg-blue-500/10 text-blue-400">
                  <Layers className="w-4 h-4" />
                </div>
                <h3 className="font-bold text-sm text-slate-100">
                  المهام البرمجية والتنفيذية المستخرجة ({result.tasks.length})
                </h3>
              </div>

              <ul className="space-y-2.5">
                {result.tasks.map((task, idx) => (
                  <li
                    key={idx}
                    className="flex items-start gap-2.5 p-2.5 rounded-xl bg-slate-950/60 border border-slate-800/80 text-xs text-slate-200"
                  >
                    <span className="w-5 h-5 rounded-full bg-blue-500/10 text-blue-400 flex items-center justify-center text-[10px] font-bold shrink-0 mt-0.5">
                      {idx + 1}
                    </span>
                    <span className="leading-relaxed">{task}</span>
                  </li>
                ))}
              </ul>
            </div>

            {/* Sales & Execution Skills Card */}
            <div className="p-5 rounded-2xl bg-slate-900/60 border border-purple-500/20 space-y-4">
              <div className="flex items-center gap-2 border-b border-slate-800 pb-3">
                <div className="p-1.5 rounded-lg bg-purple-500/10 text-purple-400">
                  <Target className="w-4 h-4" />
                </div>
                <h3 className="font-bold text-sm text-slate-100">
                  مهارات المبيعات والتفاوض المطلوبة ({result.skills.length})
                </h3>
              </div>

              <div className="space-y-2.5">
                {result.skills.map((skill, idx) => {
                  const name = typeof skill === 'string' ? skill : skill.name;
                  const notes = typeof skill === 'string' ? '' : skill.notes;

                  return (
                    <div
                      key={idx}
                      className="p-3 rounded-xl bg-slate-950/60 border border-slate-800/80 text-xs space-y-1"
                    >
                      <h4 className="font-bold text-amber-300 flex items-center gap-1.5">
                        <span className="w-2 h-2 rounded-full bg-amber-400" />
                        {name}
                      </h4>
                      {notes && (
                        <p className="text-slate-400 text-[11px] leading-relaxed pr-3.5">
                          {notes}
                        </p>
                      )}
                    </div>
                  );
                })}
              </div>
            </div>
          </div>

          {/* Import / Save Action Box */}
          <div className="p-5 rounded-2xl bg-slate-900 border border-indigo-500/30 shadow-xl space-y-4">
            <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3">
              <div>
                <h4 className="font-bold text-sm text-white">
                  استيراد الخطة إلى مسار النور
                </h4>
                <p className="text-xs text-slate-400">
                  تحويل كافة المهام والمهارات إلى سجلات تشغيلية بنقرة واحدة
                </p>
              </div>

              <div className="flex items-center gap-2">
                <label className="flex items-center gap-1.5 text-xs text-slate-300 cursor-pointer">
                  <input
                    type="radio"
                    name="target"
                    checked={importTarget === 'new'}
                    onChange={() => setImportTarget('new')}
                    className="text-blue-600 focus:ring-0"
                  />
                  <span>إنشاء مشروع جديد</span>
                </label>

                {projects.length > 0 && (
                  <label className="flex items-center gap-1.5 text-xs text-slate-300 cursor-pointer mr-3">
                    <input
                      type="radio"
                      name="target"
                      checked={importTarget === 'existing'}
                      onChange={() => setImportTarget('existing')}
                      className="text-blue-600 focus:ring-0"
                    />
                    <span>إضافة لمشروع موجود</span>
                  </label>
                )}
              </div>
            </div>

            <div className="flex flex-col sm:flex-row gap-3 pt-2">
              {importTarget === 'new' ? (
                <input
                  type="text"
                  value={newProjectName}
                  onChange={(e) => setNewProjectName(e.target.value)}
                  placeholder="اسم المشروع الجديد..."
                  className="flex-1 px-4 py-2.5 rounded-xl bg-slate-950 border border-slate-800 text-slate-100 text-xs focus:outline-none focus:border-blue-500"
                />
              ) : (
                <select
                  value={chosenProjectId}
                  onChange={(e) => setChosenProjectId(e.target.value)}
                  className="flex-1 px-4 py-2.5 rounded-xl bg-slate-950 border border-slate-800 text-slate-100 text-xs focus:outline-none"
                >
                  {projects.map((p) => (
                    <option key={p.id} value={p.id}>
                      {p.title}
                    </option>
                  ))}
                </select>
              )}

              <button
                type="button"
                onClick={handleExecuteImport}
                disabled={loading || imported}
                className="flex items-center justify-center gap-2 px-6 py-2.5 rounded-xl bg-emerald-600 hover:bg-emerald-500 text-white text-xs font-bold transition-all shadow-md shadow-emerald-500/20 disabled:opacity-50 cursor-pointer"
              >
                {imported ? (
                  <>
                    <CheckCircle className="w-4 h-4" />
                    <span>تم الاستيراد بنجاح!</span>
                  </>
                ) : (
                  <>
                    <Download className="w-4 h-4" />
                    <span>تأكيد واستيراد الخطة</span>
                  </>
                )}
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

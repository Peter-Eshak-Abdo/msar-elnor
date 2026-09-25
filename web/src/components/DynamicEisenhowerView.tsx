'use client';

import React, { useState } from 'react';
import { Task, EisenhowerQuadrant } from '@/types';
import {
  Clock,
  CheckCircle2,
  Plus,
  Trash2,
  Sparkles,
  HeartHandshake,
  CheckSquare2,
} from 'lucide-react';

interface DynamicEisenhowerViewProps {
  tasks: Task[];
  onAddTask: (
    taskName: string,
    quadrant: EisenhowerQuadrant,
    category: Task['category'],
    estimatedMinutes: number
  ) => Promise<void>;
  onCompleteTaskEarly: (taskId: string, actualMinutes: number) => Promise<{ savedMinutes: number }>;
  onDeleteTask: (taskId: string) => Promise<void>;
}

export const DynamicEisenhowerView: React.FC<DynamicEisenhowerViewProps> = ({
  tasks,
  onAddTask,
  onCompleteTaskEarly,
  onDeleteTask,
}) => {
  const [selectedQuadrantFilter, setSelectedQuadrantFilter] = useState<'All' | EisenhowerQuadrant>('All');
  const [newTaskTitle, setNewTaskTitle] = useState('');
  const [newTaskCategory, setNewTaskCategory] = useState<Task['category']>('مشروع التخرج');
  const [newTaskQuadrant, setNewTaskQuadrant] = useState<EisenhowerQuadrant>('urgent_important');
  const [newTaskDuration, setNewTaskDuration] = useState<number>(45);
  const [isSubmitting, setIsSubmitting] = useState(false);

  // Dynamic Saved Time & Agpeya Break Banner state
  const [totalSavedMinutes, setTotalSavedMinutes] = useState<number>(20);
  const [breakBannerMessage, setBreakBannerMessage] = useState<string | null>(null);

  const categories = ['مشروع التخرج', 'جامعة وحاسبات', 'شغل وبرمجة', 'استثمار Thndr', 'خدمة وكنيسة'] as const;

  const handleAddTask = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!newTaskTitle.trim()) return;
    setIsSubmitting(true);
    try {
      await onAddTask(newTaskTitle.trim(), newTaskQuadrant, newTaskCategory, newTaskDuration);
      setNewTaskTitle('');
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleFinishEarly = async (task: Task) => {
    const est = task.estimatedMinutes || 45;
    const actual = Math.max(10, Math.floor(est * 0.6));
    const res = await onCompleteTaskEarly(task.id, actual);

    if (res.savedMinutes > 0) {
      setTotalSavedMinutes((prev) => prev + res.savedMinutes);
      if (res.savedMinutes >= 15) {
        setBreakBannerMessage(
          `🌟 عاش يا بطل! وفّرت ${res.savedMinutes} دقيقة! تم تقديم باقي جدولك تلقائياً.. وقت ممتاز لصلاة الأجبية (الساعة الثالثة/السادسة) وشرب كوب ماء لصفاء ذهنك.`
        );
      } else {
        setBreakBannerMessage(
          `🌟 وفّرت ${res.savedMinutes} دقيقة! تم تعديل مواعيد باقي المهام وإتاحة استراحة 5 دقائق لتمديد العضلات وإراحة عينيك.`
        );
      }
    }
  };

  const getQuadrantDetails = (q: EisenhowerQuadrant) => {
    switch (q) {
      case 'urgent_important':
        return {
          title: 'عاجل وهام (Do First)',
          desc: 'أولويات قاطعة مثل تسليمات مشروع التخرج وحل مشاكل العمل العاجلة',
          color: 'text-rose-400',
          bg: 'bg-rose-500/10',
          border: 'border-rose-500/25',
          badge: 'bg-rose-500/20 text-rose-300',
        };
      case 'not_urgent_important':
        return {
          title: 'غير عاجل وهام (Schedule)',
          desc: 'الاستثمار في الذات، صلاة الأجبية، ومتابعة أسهم Thndr وبناء المهارات',
          color: 'text-blue-400',
          bg: 'bg-blue-500/10',
          border: 'border-blue-500/25',
          badge: 'bg-blue-500/20 text-blue-300',
        };
      case 'urgent_not_important':
        return {
          title: 'عاجل وغير هام (Delegate)',
          desc: 'مقاطعات ورسائل يمكن تفويضها أو تقليص وقتها قدر الإمكان',
          color: 'text-amber-400',
          bg: 'bg-amber-500/10',
          border: 'border-amber-500/25',
          badge: 'bg-amber-500/20 text-amber-300',
        };
      case 'not_urgent_not_important':
        return {
          title: 'غير عاجل وغير هام (Eliminate)',
          desc: 'مشتتات وسائل التواصل والمواقع غير المنتجة المطلوب حظرها',
          color: 'text-emerald-400',
          bg: 'bg-emerald-500/10',
          border: 'border-emerald-500/25',
          badge: 'bg-emerald-500/20 text-emerald-300',
        };
    }
  };

  const filteredTasks = tasks.filter((t) => {
    if (selectedQuadrantFilter === 'All') return true;
    return (t.quadrant || 'urgent_important') === selectedQuadrantFilter;
  });

  const quadrants: EisenhowerQuadrant[] = [
    'urgent_important',
    'not_urgent_important',
    'urgent_not_important',
    'not_urgent_not_important',
  ];

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h2 className="text-xl font-bold text-white flex items-center gap-2">
            <CheckSquare2 className="w-5 h-5 text-indigo-400" />
            <span>مدير المهام الديناميكي (Dynamic Eisenhower Matrix)</span>
          </h2>
          <p className="text-sm text-slate-400">
            مصفوفة أيزنهاور الرباعية الذكية مع ميزة إعادة الجدولة الحية واقتراح فترات الراحة وصلاة الأجبية
          </p>
        </div>

        {/* Saved Time Badge */}
        <div className="flex items-center gap-2 px-4 py-2 rounded-xl bg-linear-to-r from-blue-600/20 to-indigo-600/20 border border-blue-500/30">
          <Sparkles className="w-4 h-4 text-blue-400" />
          <span className="text-xs text-slate-300">الوقت الموفَّر اليوم:</span>
          <span className="text-sm font-bold text-blue-400">{totalSavedMinutes} دقيقة</span>
        </div>
      </div>

      {/* Real-time Rescheduling / Break Alert Banner */}
      {breakBannerMessage && (
        <div className="p-4 rounded-2xl bg-linear-to-r from-emerald-950/40 via-slate-900 to-slate-900 border border-emerald-500/40 flex items-start justify-between gap-3 shadow-lg">
          <div className="flex items-start gap-3">
            <div className="p-2 rounded-xl bg-emerald-500/10 text-emerald-400">
              <HeartHandshake className="w-5 h-5" />
            </div>
            <div>
              <h4 className="text-sm font-bold text-emerald-300">إعادة جدولة ذكية وفترة راحة مستحقة!</h4>
              <p className="text-xs text-slate-300 mt-1 leading-relaxed">{breakBannerMessage}</p>
            </div>
          </div>
          <button
            onClick={() => setBreakBannerMessage(null)}
            className="text-slate-400 hover:text-white text-xs cursor-pointer p-1"
          >
            ✕
          </button>
        </div>
      )}

      {/* Mini 4-Quadrant Visual Dashboard */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-3">
        {quadrants.map((q) => {
          const info = getQuadrantDetails(q);
          const count = tasks.filter((t) => (t.quadrant || 'urgent_important') === q).length;
          const isSelected = selectedQuadrantFilter === q;

          return (
            <div
              key={q}
              onClick={() => setSelectedQuadrantFilter(isSelected ? 'All' : q)}
              className={`p-4 rounded-2xl cursor-pointer transition-all duration-200 border ${
                isSelected ? `${info.border} ring-2 ring-blue-500/50 bg-slate-900` : 'border-slate-800 bg-slate-900/60 hover:bg-slate-900'
              }`}
            >
              <div className="flex items-center justify-between">
                <span className={`text-xs font-bold px-2 py-0.5 rounded-md ${info.badge}`}>
                  {info.title.split('(')[0]}
                </span>
                <span className="text-sm font-bold text-white">{count}</span>
              </div>
              <p className="text-[11px] text-slate-400 mt-2 line-clamp-2">{info.desc}</p>
            </div>
          );
        })}
      </div>

      {/* Add Task Form */}
      <form
        onSubmit={handleAddTask}
        className="p-4 rounded-2xl bg-slate-900 border border-slate-800 space-y-3"
      >
        <div className="flex flex-col md:flex-row gap-3">
          <input
            type="text"
            value={newTaskTitle}
            onChange={(e) => setNewTaskTitle(e.target.value)}
            placeholder="أدخل عنوان المهمة (مثال: كتابة استعلام Firestore لمشروع التخرج)..."
            className="flex-1 px-4 py-2 rounded-xl bg-slate-950 border border-slate-800 text-sm text-white focus:outline-none focus:border-blue-500"
          />

          <select
            value={newTaskCategory}
            onChange={(e) => setNewTaskCategory(e.target.value as any)}
            className="px-3 py-2 rounded-xl bg-slate-950 border border-slate-800 text-xs text-slate-200 focus:outline-none cursor-pointer"
          >
            {categories.map((c) => (
              <option key={c} value={c}>
                {c}
              </option>
            ))}
          </select>

          <select
            value={newTaskQuadrant}
            onChange={(e) => setNewTaskQuadrant(e.target.value as any)}
            className="px-3 py-2 rounded-xl bg-slate-950 border border-slate-800 text-xs text-amber-300 focus:outline-none cursor-pointer"
          >
            <option value="urgent_important">🟥 عاجل وهام (Do First)</option>
            <option value="not_urgent_important">🟦 غير عاجل وهام (Schedule)</option>
            <option value="urgent_not_important">🟨 عاجل وغير هام (Delegate)</option>
            <option value="not_urgent_not_important">🟩 غير عاجل وغير هام (Eliminate)</option>
          </select>

          <div className="flex items-center gap-2 px-3 py-1.5 rounded-xl bg-slate-950 border border-slate-800 text-xs text-slate-300">
            <span>{newTaskDuration} د</span>
            <input
              type="range"
              min={10}
              max={120}
              step={5}
              value={newTaskDuration}
              onChange={(e) => setNewTaskDuration(Number(e.target.value))}
              className="w-20 cursor-pointer accent-blue-500"
            />
          </div>

          <button
            type="submit"
            disabled={isSubmitting || !newTaskTitle.trim()}
            className="flex items-center justify-center gap-1.5 px-5 py-2 rounded-xl bg-blue-600 hover:bg-blue-500 disabled:opacity-50 text-white text-xs font-semibold shadow-md shadow-blue-500/20 cursor-pointer transition-all"
          >
            <Plus className="w-4 h-4" />
            <span>إضافة</span>
          </button>
        </div>
      </form>

      {/* Filter Chips */}
      <div className="flex items-center gap-2 overflow-x-auto pb-1 text-xs">
        <button
          onClick={() => setSelectedQuadrantFilter('All')}
          className={`px-3 py-1.5 rounded-xl cursor-pointer transition-all ${
            selectedQuadrantFilter === 'All' ? 'bg-blue-600 text-white font-bold' : 'bg-slate-900 text-slate-400 hover:text-white'
          }`}
        >
          كل الأرباع ({tasks.length})
        </button>
        {quadrants.map((q) => {
          const count = tasks.filter((t) => (t.quadrant || 'urgent_important') === q).length;
          const info = getQuadrantDetails(q);
          const isSelected = selectedQuadrantFilter === q;
          return (
            <button
              key={q}
              onClick={() => setSelectedQuadrantFilter(q)}
              className={`px-3 py-1.5 rounded-xl cursor-pointer transition-all flex items-center gap-1.5 ${
                isSelected ? 'bg-slate-800 text-white font-bold border border-slate-700' : 'bg-slate-900 text-slate-400 hover:text-white'
              }`}
            >
              <span>{info.title.split('(')[0]}</span>
              <span className={`text-[10px] px-1.5 py-0.2 rounded-full ${info.badge}`}>{count}</span>
            </button>
          );
        })}
      </div>

      {/* Tasks Grid List */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
        {filteredTasks.map((task) => {
          const info = getQuadrantDetails(task.quadrant || 'urgent_important');
          const isDone = task.status === 'Completed';

          return (
            <div
              key={task.id}
              className={`p-4 rounded-2xl border transition-all duration-200 flex flex-col justify-between gap-3 ${
                isDone
                  ? 'bg-slate-950/40 border-slate-800/50 opacity-60'
                  : 'bg-slate-900/90 border-slate-800 hover:border-slate-700'
              }`}
            >
              <div>
                <div className="flex items-center justify-between gap-2 mb-2">
                  <span className={`text-[11px] font-bold px-2 py-0.5 rounded-md ${info.badge}`}>
                    {info.title.split('(')[0]}
                  </span>
                  <span className="text-[11px] text-slate-400 bg-slate-800/80 px-2 py-0.5 rounded-md">
                    {task.category || 'عام'}
                  </span>
                </div>

                <h3
                  className={`text-sm font-semibold text-white ${
                    isDone ? 'line-through text-slate-400' : ''
                  }`}
                >
                  {task.task_name}
                </h3>
              </div>

              <div className="flex items-center justify-between pt-2 border-t border-slate-800/60 text-xs text-slate-400">
                <div className="flex items-center gap-1.5">
                  <Clock className="w-3.5 h-3.5 text-slate-500" />
                  <span>{task.estimatedMinutes || 30} دقيقة مقدرة</span>
                  {task.actualMinutes && (
                    <span className="text-emerald-400 text-[11px]">
                      (أُنجزت في {task.actualMinutes} د)
                    </span>
                  )}
                </div>

                <div className="flex items-center gap-1.5">
                  {!isDone && (
                    <button
                      onClick={() => handleFinishEarly(task)}
                      className="px-2.5 py-1 rounded-lg bg-emerald-500/10 hover:bg-emerald-500/20 border border-emerald-500/30 text-emerald-400 text-[11px] font-bold cursor-pointer transition-colors"
                      title="إنهاء مبكر وإعادة الجدولة الحية لباقي المهام"
                    >
                      أنهيت بدري ⚡
                    </button>
                  )}
                  {isDone && (
                    <span className="flex items-center gap-1 text-emerald-400 text-[11px] font-bold">
                      <CheckCircle2 className="w-3.5 h-3.5" />
                      <span>مكتملة</span>
                    </span>
                  )}
                  <button
                    onClick={() => onDeleteTask(task.id)}
                    className="p-1 rounded-lg text-slate-500 hover:text-rose-400 hover:bg-slate-800 transition-colors cursor-pointer"
                  >
                    <Trash2 className="w-3.5 h-3.5" />
                  </button>
                </div>
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
};

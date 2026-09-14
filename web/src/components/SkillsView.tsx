'use client';

import React, { useState } from 'react';
import { Skill, Project } from '@/types';
import { 
  GraduationCap, 
  Plus, 
  Trash2, 
  BookOpen, 
  FolderKanban,
  Target,
  Sparkles
} from 'lucide-react';

interface SkillsViewProps {
  skills: Skill[];
  projects: Project[];
  selectedProjectId: string | null;
  onSelectProject: (id: string | null) => void;
  onAddSkill: (projectId: string, skillName: string, notes: string) => Promise<void>;
  onDeleteSkill: (skillId: string) => Promise<void>;
  onOpenAIModal: () => void;
}

export const SkillsView: React.FC<SkillsViewProps> = ({
  skills,
  projects,
  selectedProjectId,
  onSelectProject,
  onAddSkill,
  onDeleteSkill,
  onOpenAIModal,
}) => {
  const [isAdding, setIsAdding] = useState(false);
  const [skillName, setSkillName] = useState('');
  const [trainingNotes, setTrainingNotes] = useState('');
  const [targetProjectId, setTargetProjectId] = useState<string>(
    selectedProjectId || (projects[0]?.id ?? '')
  );
  const [loading, setLoading] = useState(false);

  const filteredSkills = skills.filter((s) => {
    return selectedProjectId ? s.project_id === selectedProjectId : true;
  });

  const handleAdd = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!skillName.trim() || !targetProjectId) return;
    setLoading(true);
    try {
      await onAddSkill(targetProjectId, skillName, trainingNotes);
      setSkillName('');
      setTrainingNotes('');
      setIsAdding(false);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="space-y-6">
      {/* Header & Actions */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h2 className="text-xl font-bold text-white flex items-center gap-2">
            <GraduationCap className="w-5 h-5 text-amber-400" />
            <span>بنك مهارات المبيعات والتنفيذ وتوجيهات التدريب</span>
          </h2>
          <p className="text-sm text-slate-400">
            المهارات المطلوبة لبيع وتنفيذ المشاريع مع الإرشادات التكتيكية للنجاح
          </p>
        </div>

        <div className="flex items-center gap-2">
          <button
            onClick={onOpenAIModal}
            className="flex items-center gap-1.5 px-3.5 py-2 rounded-xl bg-indigo-600/20 hover:bg-indigo-600/30 text-indigo-300 text-xs font-semibold border border-indigo-500/30 transition-colors cursor-pointer"
          >
            <Sparkles className="w-3.5 h-3.5 text-amber-300" />
            <span>اقتراح مهارات بالذكاء الاصطناعي</span>
          </button>

          <button
            onClick={() => setIsAdding(!isAdding)}
            className="flex items-center gap-1.5 px-4 py-2 rounded-xl bg-blue-600 hover:bg-blue-500 text-white text-xs font-bold transition-colors cursor-pointer shadow-md shadow-blue-500/20"
          >
            <Plus className="w-4 h-4" />
            <span>{isAdding ? 'إلغاء' : 'مهارة جديدة'}</span>
          </button>
        </div>
      </div>

      {/* Project Selector Filter */}
      {projects.length > 1 && (
        <div className="flex items-center gap-2">
          <span className="text-xs text-slate-400">عرض مهارات:</span>
          <div className="flex items-center gap-2 px-3 py-1.5 rounded-xl bg-slate-900 border border-slate-800 text-xs">
            <FolderKanban className="w-3.5 h-3.5 text-slate-400" />
            <select
              value={selectedProjectId || ''}
              onChange={(e) => onSelectProject(e.target.value || null)}
              className="bg-transparent text-slate-200 focus:outline-none cursor-pointer"
            >
              <option value="" className="bg-slate-900">كافة المشاريع</option>
              {projects.map((p) => (
                <option key={p.id} value={p.id} className="bg-slate-900">
                  {p.title}
                </option>
              ))}
            </select>
          </div>
        </div>
      )}

      {/* Add Skill Form */}
      {isAdding && (
        <form
          onSubmit={handleAdd}
          className="p-5 rounded-2xl bg-slate-900/90 border border-slate-700/60 shadow-xl space-y-4 animate-in fade-in slide-in-from-top-4 duration-300"
        >
          <h3 className="text-base font-semibold text-slate-200">إضافة مهارة وتوجيه تدريبي</h3>
          
          <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
            <div>
              <label className="block text-xs font-medium text-slate-400 mb-1">
                اسم المهارة *
              </label>
              <input
                type="text"
                required
                value={skillName}
                onChange={(e) => setSkillName(e.target.value)}
                placeholder="مثال: مهارات إغلاق الصفقات، إدارة اعتراضات العملاء..."
                className="w-full px-4 py-2.5 rounded-xl bg-slate-950 border border-slate-800 text-slate-100 placeholder:text-slate-600 focus:outline-none focus:border-blue-500 text-sm"
              />
            </div>

            <div>
              <label className="block text-xs font-medium text-slate-400 mb-1">
                المشروع المرتبط
              </label>
              <select
                value={targetProjectId}
                onChange={(e) => setTargetProjectId(e.target.value)}
                className="w-full px-4 py-2.5 rounded-xl bg-slate-950 border border-slate-800 text-slate-200 text-sm focus:outline-none"
              >
                {projects.map((p) => (
                  <option key={p.id} value={p.id}>
                    {p.title}
                  </option>
                ))}
              </select>
            </div>
          </div>

          <div>
            <label className="block text-xs font-medium text-slate-400 mb-1">
              ملاحظات وتوجيهات التدريب (Training Notes)
            </label>
            <textarea
              rows={3}
              value={trainingNotes}
              onChange={(e) => setTrainingNotes(e.target.value)}
              placeholder="نصائح عملية للتدريب، سيناريوهات محاكاة المبيعات، ونقاط التركيز..."
              className="w-full px-4 py-2.5 rounded-xl bg-slate-950 border border-slate-800 text-slate-100 placeholder:text-slate-600 focus:outline-none focus:border-blue-500 text-sm"
            />
          </div>

          <div className="flex justify-end gap-2 pt-2">
            <button
              type="button"
              onClick={() => setIsAdding(false)}
              className="px-4 py-2 rounded-xl text-xs font-medium text-slate-400 hover:text-white hover:bg-slate-800 transition-colors"
            >
              إلغاء
            </button>
            <button
              type="submit"
              disabled={loading}
              className="px-5 py-2 rounded-xl bg-blue-600 hover:bg-blue-500 text-white text-xs font-bold transition-all disabled:opacity-50 cursor-pointer"
            >
              {loading ? 'جاري الحفظ...' : 'حفظ المهارة'}
            </button>
          </div>
        </form>
      )}

      {/* Skills Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        {filteredSkills.map((skill) => {
          const project = projects.find((p) => p.id === skill.project_id);

          return (
            <div
              key={skill.id}
              className="p-5 rounded-2xl bg-slate-900/60 border border-slate-800/80 hover:border-amber-500/30 transition-all space-y-3 relative group"
            >
              <div className="flex items-start justify-between gap-3">
                <div className="flex items-center gap-2.5">
                  <div className="p-2 rounded-xl bg-amber-500/10 text-amber-400 border border-amber-500/20">
                    <Target className="w-4 h-4" />
                  </div>
                  <div>
                    <h3 className="font-bold text-slate-100 text-sm">
                      {skill.skill_name}
                    </h3>
                    {project && (
                      <span className="text-[11px] text-slate-500">
                        مشروع: {project.title}
                      </span>
                    )}
                  </div>
                </div>

                <button
                  onClick={() => onDeleteSkill(skill.id)}
                  className="p-1.5 rounded-lg text-slate-500 hover:text-rose-400 hover:bg-rose-500/10 transition-colors cursor-pointer"
                  title="حذف المهارة"
                >
                  <Trash2 className="w-4 h-4" />
                </button>
              </div>

              {/* Training Notes Body */}
              <div className="p-3 rounded-xl bg-slate-950/70 border border-slate-800/60 text-xs text-slate-300 leading-relaxed">
                <div className="flex items-center gap-1.5 text-amber-400 font-semibold mb-1 text-[11px]">
                  <BookOpen className="w-3.5 h-3.5" />
                  <span>توجيه تدريبي للمبيعات والتنفيذ:</span>
                </div>
                <p className="whitespace-pre-wrap">{skill.training_notes || 'لا توجد ملاحظات تدريبية مضافة.'}</p>
              </div>
            </div>
          );
        })}

        {filteredSkills.length === 0 && (
          <div className="col-span-full py-12 text-center rounded-3xl border border-dashed border-slate-800 text-slate-500 text-sm">
            لا توجد مهارات مسجلة بعد. استخدم مستشار الذكاء الاصطناعي لاقتراح مهارات متخصصة لمشروعك.
          </div>
        )}
      </div>
    </div>
  );
};

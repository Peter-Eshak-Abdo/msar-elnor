'use client';

import React, { useState } from 'react';
import { Project } from '@/types';
import {
  FolderPlus,
  Trash2,
  Calendar,
  ArrowLeft,
  Briefcase
} from 'lucide-react';

interface ProjectsViewProps {
  projects: Project[];
  selectedProjectId: string | null;
  onSelectProject: (id: string | null) => void;
  onCreateProject: (title: string, description: string) => Promise<void>;
  onDeleteProject: (id: string) => Promise<void>;
  onNavigateToTasks: () => void;
}

export const ProjectsView: React.FC<ProjectsViewProps> = ({
  projects,
  selectedProjectId,
  onSelectProject,
  onCreateProject,
  onDeleteProject,
  onNavigateToTasks,
}) => {
  const [isCreating, setIsCreating] = useState(false);
  const [title, setTitle] = useState('');
  const [description, setDescription] = useState('');
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!title.trim()) return;
    setLoading(true);
    try {
      await onCreateProject(title, description);
      setTitle('');
      setDescription('');
      setIsCreating(false);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="space-y-6">
      {/* Header & Add Button */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h2 className="text-xl font-bold text-white flex items-center gap-2">
            <Briefcase className="w-5 h-5 text-blue-400" />
            <span>سجل المشاريع ومسارات الأعمال</span>
          </h2>
          <p className="text-sm text-slate-400">
            إدارة كافة المشاريع وتنسيق المهام وتدريب المبيعات لكل مشروع بشكل مستقل
          </p>
        </div>

        <button
          onClick={() => setIsCreating(!isCreating)}
          className="flex items-center gap-2 px-4 py-2.5 rounded-xl bg-blue-600 hover:bg-blue-500 text-white text-sm font-semibold transition-colors cursor-pointer shadow-lg shadow-blue-500/20"
        >
          <FolderPlus className="w-4 h-4" />
          <span>{isCreating ? 'إلغاء' : 'مشروع جديد'}</span>
        </button>
      </div>

      {/* Create Project Form */}
      {isCreating && (
        <form
          onSubmit={handleSubmit}
          className="p-5 rounded-2xl bg-slate-900/80 border border-slate-700/60 shadow-xl space-y-4 animate-in fade-in slide-in-from-top-4 duration-300"
        >
          <h3 className="text-base font-semibold text-slate-200">إضافة مشروع جديد</h3>
          <div className="space-y-3">
            <div>
              <label className="block text-xs font-medium text-slate-400 mb-1">
                اسم المشروع *
              </label>
              <input
                type="text"
                required
                value={title}
                onChange={(e) => setTitle(e.target.value)}
                placeholder="مثال: مشروع أبونا فلتاؤس، منصة التجارة الرقمية..."
                className="w-full px-4 py-2.5 rounded-xl bg-slate-950 border border-slate-800 text-slate-100 placeholder:text-slate-600 focus:outline-none focus:border-blue-500 text-sm"
              />
            </div>
            <div>
              <label className="block text-xs font-medium text-slate-400 mb-1">
                وصف المشروع وأهدافه
              </label>
              <textarea
                rows={3}
                value={description}
                onChange={(e) => setDescription(e.target.value)}
                placeholder="اكتب نبذة عن المشروع، القيمة المقدمة، والشرائح المستهدفة..."
                className="w-full px-4 py-2.5 rounded-xl bg-slate-950 border border-slate-800 text-slate-100 placeholder:text-slate-600 focus:outline-none focus:border-blue-500 text-sm"
              />
            </div>
          </div>
          <div className="flex justify-end gap-2 pt-2">
            <button
              type="button"
              onClick={() => setIsCreating(false)}
              className="px-4 py-2 rounded-xl text-xs font-medium text-slate-400 hover:text-white hover:bg-slate-800 transition-colors"
            >
              إلغاء
            </button>
            <button
              type="submit"
              disabled={loading}
              className="px-5 py-2 rounded-xl bg-blue-600 hover:bg-blue-500 text-white text-xs font-bold transition-all disabled:opacity-50 cursor-pointer"
            >
              {loading ? 'جاري الحفظ...' : 'حفظ المشروع'}
            </button>
          </div>
        </form>
      )}

      {/* Projects Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-5">
        {projects.map((project) => {
          const isSelected = selectedProjectId === project.id;

          return (
            <div
              key={project.id}
              onClick={() => onSelectProject(isSelected ? null : project.id)}
              className={`p-5 rounded-2xl cursor-pointer transition-all duration-200 border ${
                isSelected
                ? 'bg-linear-to-b from-blue-950/40 to-slate-900 border-blue-500/80 shadow-lg shadow-blue-500/10 ring-1 ring-blue-500'
                  : 'bg-slate-900/60 hover:bg-slate-900 border-slate-800/80 hover:border-slate-700'
              }`}
            >
              <div className="flex items-start justify-between gap-2 mb-3">
                <div className="flex items-center gap-2">
                  <div className={`w-3 h-3 rounded-full ${isSelected ? 'bg-blue-500 animate-pulse' : 'bg-slate-700'}`} />
                  <h3 className="font-bold text-base text-white line-clamp-1">
                    {project.title}
                  </h3>
                </div>
                <button
                  onClick={(e) => {
                    e.stopPropagation();
                    if (confirm(`هل أنت متأكد من حذف "${project.title}"؟`)) {
                      onDeleteProject(project.id);
                    }
                  }}
                  className="text-slate-500 hover:text-rose-400 p-1 rounded-lg hover:bg-rose-500/10 transition-colors"
                  title="حذف المشروع"
                >
                  <Trash2 className="w-4 h-4" />
                </button>
              </div>

              <p className="text-xs text-slate-400 line-clamp-3 mb-4 leading-relaxed">
                {project.description || 'لا يوجد وصف محدد لهذا المشروع.'}
              </p>

              <div className="pt-3 border-t border-slate-800/80 flex items-center justify-between text-xs text-slate-500">
                <span className="flex items-center gap-1.5">
                  <Calendar className="w-3.5 h-3.5" />
                  {new Date(project.created_at).toLocaleDateString('ar-EG', {
                    day: 'numeric',
                    month: 'short',
                    year: 'numeric',
                  })}
                </span>

                <button
                  onClick={(e) => {
                    e.stopPropagation();
                    onSelectProject(project.id);
                    onNavigateToTasks();
                  }}
                  className="flex items-center gap-1 text-blue-400 hover:text-blue-300 font-medium transition-colors"
                >
                  <span>عرض المهام</span>
                  <ArrowLeft className="w-3.5 h-3.5" />
                </button>
              </div>
            </div>
          );
        })}

        {projects.length === 0 && (
          <div className="col-span-full py-12 text-center border-2 border-dashed border-slate-800 rounded-3xl bg-slate-900/30">
            <p className="text-slate-400 text-sm mb-3">لا توجد مشاريع مضافة حالياً.</p>
            <button
              onClick={() => setIsCreating(true)}
              className="px-4 py-2 rounded-xl bg-blue-600/80 hover:bg-blue-600 text-white text-xs font-semibold"
            >
              أضف أول مشروع
            </button>
          </div>
        )}
      </div>
    </div>
  );
};

'use client';

import React from 'react';
import {
  FolderKanban,
  CheckCircle2,
  GraduationCap,
  ShieldAlert
} from 'lucide-react';
import { Project, Task, Skill, BlockerRule } from '@/types';

interface StatsCardsProps {
  projects: Project[];
  tasks: Task[];
  skills: Skill[];
  blockerRules: BlockerRule;
}

export const StatsCards: React.FC<StatsCardsProps> = ({
  projects,
  tasks,
  skills,
  blockerRules,
}) => {
  const completedTasks = tasks.filter((t) => t.status === 'Completed').length;
  const inProgressTasks = tasks.filter((t) => t.status === 'In Progress').length;

  const stats = [
    {
      title: 'المشاريع المسجلة',
      value: projects.length,
      subtitle: `${projects[0]?.title ? `الرئيسي: ${projects[0].title}` : 'لا توجد مشاريع'}`,
      icon: FolderKanban,
      color: 'from-blue-500/20 to-blue-600/10 text-blue-400 border-blue-500/20',
    },
    {
      title: 'المهام التنفيذية',
      value: `${completedTasks} / ${tasks.length}`,
      subtitle: `${inProgressTasks} مهام قيد التنفيذ الآن`,
      icon: CheckCircle2,
      color: 'from-emerald-500/20 to-emerald-600/10 text-emerald-400 border-emerald-500/20',
    },
    {
      title: 'بنك مهارات المبيعات',
      value: skills.length,
      subtitle: 'مهارات وإرشادات تدريبية موثقة',
      icon: GraduationCap,
      color: 'from-amber-500/20 to-amber-600/10 text-amber-400 border-amber-500/20',
    },
    {
      title: 'الحظر الصارم والتسابيح',
      value: blockerRules.is_active ? 'مُفعّل' : 'مُعطل',
      subtitle: `فترة الحظر: ${blockerRules.active_hours.start} إلى ${blockerRules.active_hours.end}`,
      icon: ShieldAlert,
      color: 'from-rose-500/20 to-rose-600/10 text-rose-400 border-rose-500/20',
    },
  ];

  return (
    <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
      {stats.map((stat, idx) => {
        const Icon = stat.icon;
        return (
          <div
            key={idx}
            className="p-5 rounded-2xl bg-slate-900/60 border border-slate-800/80 hover:border-slate-700 transition-all flex flex-col justify-between"
          >
            <div className="flex items-center justify-between mb-3">
              <span className="text-xs font-semibold text-slate-400">
                {stat.title}
              </span>
              <div className={`p-2 rounded-xl border bg-linear-to-br ${stat.color}`}>
                <Icon className="w-4 h-4" />
              </div>
            </div>

            <div>
              <div className="text-2xl font-black text-white tracking-tight mb-1">
                {stat.value}
              </div>
              <p className="text-[11px] text-slate-400 line-clamp-1">
                {stat.subtitle}
              </p>
            </div>
          </div>
        );
      })}
    </div>
  );
};

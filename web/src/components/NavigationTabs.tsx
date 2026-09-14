'use client';

import React from 'react';
import { 
  FolderKanban, 
  CheckSquare, 
  GraduationCap, 
  ShieldAlert, 
  Sparkles,
  Settings
} from 'lucide-react';

interface NavigationTabsProps {
  activeTab: string;
  setActiveTab: (tab: string) => void;
  counts: {
    projects: number;
    tasks: number;
    skills: number;
  };
}

export const NavigationTabs: React.FC<NavigationTabsProps> = ({
  activeTab,
  setActiveTab,
  counts,
}) => {
  const tabs = [
    {
      id: 'projects',
      label: 'المشاريع',
      icon: FolderKanban,
      badge: counts.projects,
    },
    {
      id: 'tasks',
      label: 'المهام التقنية',
      icon: CheckSquare,
      badge: counts.tasks,
    },
    {
      id: 'skills',
      label: 'مهارات المبيعات والتدريب',
      icon: GraduationCap,
      badge: counts.skills,
    },
    {
      id: 'ai-planner',
      label: 'مستشار الذكاء الاصطناعي',
      icon: Sparkles,
      highlight: true,
    },
    {
      id: 'blocker',
      label: 'نظام الحظر الصارم',
      icon: ShieldAlert,
    },
    {
      id: 'settings',
      label: 'الإعدادات والربط',
      icon: Settings,
    },
  ];

  return (
    <nav className="flex items-center gap-2 p-1.5 bg-slate-900/60 rounded-2xl border border-slate-800/80 overflow-x-auto">
      {tabs.map((tab) => {
        const Icon = tab.icon;
        const isActive = activeTab === tab.id;

        return (
          <button
            key={tab.id}
            onClick={() => setActiveTab(tab.id)}
            className={`flex items-center gap-2.5 px-4 py-2.5 rounded-xl text-sm font-medium transition-all duration-200 whitespace-nowrap cursor-pointer ${
              isActive
                ? 'bg-blue-600 text-white shadow-md shadow-blue-500/25'
                : 'text-slate-400 hover:text-slate-200 hover:bg-slate-800/50'
            }`}
          >
            <Icon className={`w-4 h-4 ${isActive ? 'text-white' : tab.highlight ? 'text-amber-400' : 'text-slate-400'}`} />
            <span>{tab.label}</span>
            {typeof tab.badge === 'number' && (
              <span
                className={`text-[11px] px-1.5 py-0.2 rounded-full font-bold ${
                  isActive
                    ? 'bg-white/20 text-white'
                    : 'bg-slate-800 text-slate-400'
                }`}
              >
                {tab.badge}
              </span>
            )}
          </button>
        );
      })}
    </nav>
  );
};

'use client';

import React, { useState, useEffect } from 'react';
import { Project, Task, Skill, BlockerRule, TaskStatus, EisenhowerQuadrant, PersonalizedNotification, RouterSettings } from '@/types';
import { DataService } from '@/lib/dataService';
import { Navbar } from '@/components/Navbar';
import { NavigationTabs } from '@/components/NavigationTabs';
import { StatsCards } from '@/components/StatsCards';
import { ProjectsView } from '@/components/ProjectsView';
import { TasksView } from '@/components/TasksView';
import { DynamicEisenhowerView } from '@/components/DynamicEisenhowerView';
import { SkillsView } from '@/components/SkillsView';
import { BlockerSettingsView } from '@/components/BlockerSettingsView';
import { RouterGuideView } from '@/components/RouterGuideView';
import { PersonalizedNotificationsView } from '@/components/PersonalizedNotificationsView';
import { AIPlannerView } from '@/components/AIPlannerView';
import { SettingsView } from '@/components/SettingsView';
import { AIModal } from '@/components/AIModal';

export default function DashboardPage() {
  const [projects, setProjects] = useState<Project[]>([]);
  const [tasks, setTasks] = useState<Task[]>([]);
  const [skills, setSkills] = useState<Skill[]>([]);
  const [blockerRules, setBlockerRules] = useState<BlockerRule>({
    id: 'default',
    blocked_urls: ['facebook.com', 'tiktok.com', 'instagram.com', 'x.com'],
    active_hours: { start: '23:00', end: '07:00', days: ['Everyday'] },
    fallback_url: 'https://www.youtube.com/watch?v=aripsalin-tasbeha',
    is_active: true,
  });

  const [notifications, setNotifications] = useState<PersonalizedNotification[]>([]);
  const [routerSettings, setRouterSettings] = useState<RouterSettings | undefined>(undefined);
  const [selectedProjectId, setSelectedProjectId] = useState<string | null>(null);
  const [activeTab, setActiveTab] = useState<string>('eisenhower');
  const [isAIModalOpen, setIsAIModalOpen] = useState(false);
  const [loading, setLoading] = useState(true);

  // Initial Data Fetch
  useEffect(() => {
    async function loadData() {
      try {
        const [loadedProjects, loadedTasks, loadedSkills, loadedBlocker, loadedNotifs, loadedRouter] = await Promise.all([
          DataService.getProjects(),
          DataService.getTasks(),
          DataService.getSkills(),
          DataService.getBlockerRules(),
          DataService.getNotifications(),
          DataService.getRouterSettings(),
        ]);

        setProjects(loadedProjects);
        setTasks(loadedTasks);
        setSkills(loadedSkills);
        setBlockerRules(loadedBlocker);
        setNotifications(loadedNotifs);
        setRouterSettings(loadedRouter);

        if (loadedProjects.length > 0) {
          setSelectedProjectId(loadedProjects[0].id);
        }
      } catch (err) {
        console.error('Failed to load initial data:', err);
      } finally {
        setLoading(false);
      }
    }

    loadData();
  }, []);

  // Handlers for Projects
  const handleCreateProject = async (title: string, description: string) => {
    const created = await DataService.createProject(title, description);
    setProjects((prev) => [created, ...prev]);
    setSelectedProjectId(created.id);
  };

  const handleDeleteProject = async (id: string) => {
    await DataService.deleteProject(id);
    setProjects((prev) => prev.filter((p) => p.id !== id));
    setTasks((prev) => prev.filter((t) => t.project_id !== id));
    setSkills((prev) => prev.filter((s) => s.project_id !== id));
    if (selectedProjectId === id) {
      setSelectedProjectId(null);
    }
  };

  // Handlers for Tasks & Eisenhower Matrix
  const handleAddTask = async (projectId: string, taskName: string, status?: TaskStatus) => {
    const created = await DataService.addTask(projectId, taskName, status);
    setTasks((prev) => [...prev, created]);
  };

  const handleAddEisenhowerTask = async (
    taskName: string,
    quadrant: EisenhowerQuadrant,
    category: Task['category'],
    estimatedMinutes: number
  ) => {
    const projId = selectedProjectId || (projects[0]?.id ?? 'default-proj');
    const created = await DataService.addTask(projId, taskName, 'Pending', quadrant, category, estimatedMinutes);
    setTasks((prev) => [...prev, created]);
  };

  const handleCompleteTaskEarly = async (taskId: string, actualMinutes: number) => {
    const res = await DataService.completeTaskEarly(taskId, actualMinutes);
    setTasks([...res.updatedTasks]);
    return { savedMinutes: res.savedMinutes };
  };

  const handleAddNotification = async (notif: Omit<PersonalizedNotification, 'id'>) => {
    const created = await DataService.addNotification(notif);
    setNotifications((prev) => [created, ...prev]);
  };

  const handleSaveRouterSettings = async (settings: RouterSettings) => {
    const saved = await DataService.updateRouterSettings(settings);
    setRouterSettings(saved);
  };

  const handleUpdateTaskStatus = async (taskId: string, status: TaskStatus) => {
    await DataService.updateTaskStatus(taskId, status);
    setTasks((prev) =>
      prev.map((t) => (t.id === taskId ? { ...t, status } : t))
    );
  };

  const handleDeleteTask = async (taskId: string) => {
    await DataService.deleteTask(taskId);
    setTasks((prev) => prev.filter((t) => t.id !== taskId));
  };

  // Handlers for Skills
  const handleAddSkill = async (projectId: string, skillName: string, notes: string) => {
    const created = await DataService.addSkill(projectId, skillName, notes);
    setSkills((prev) => [...prev, created]);
  };

  const handleDeleteSkill = async (skillId: string) => {
    await DataService.deleteSkill(skillId);
    setSkills((prev) => prev.filter((s) => s.id !== skillId));
  };

  // Handler for Blocker Rules
  const handleUpdateBlockerRules = async (updated: BlockerRule) => {
    const saved = await DataService.updateBlockerRules(updated);
    setBlockerRules(saved);
  };

  // 1-Click Import Plan from AI
  const handleImportPlan = async (
    projectTitle: string,
    importedTasks: string[],
    importedSkills: Array<{ name: string; notes: string }>,
    existingProjectId?: string
  ) => {
    let targetId = existingProjectId;

    if (!targetId) {
      const newProj = await DataService.createProject(
        projectTitle,
        `مشروع ومسار عمل تم إنشاؤه عبر مستشار الذكاء الاصطناعي بتاريخ ${new Date().toLocaleDateString('ar-EG')}`
      );
      setProjects((prev) => [newProj, ...prev]);
      targetId = newProj.id;
      setSelectedProjectId(targetId);
    }

    // Add tasks
    for (const t of importedTasks) {
      await handleAddTask(targetId, t, 'Pending');
    }

    // Add skills
    for (const s of importedSkills) {
      await handleAddSkill(targetId, s.name, s.notes);
    }

    setActiveTab('tasks');
  };

  return (
    <div className="min-h-screen flex flex-col bg-[#090d16] text-slate-100">
      {/* Top Navbar */}
      <Navbar
        activeTab={activeTab}
        setActiveTab={setActiveTab}
        onOpenAIModal={() => setIsAIModalOpen(true)}
      />

      {/* Main Container */}
      <main className="flex-1 max-w-7xl w-full mx-auto px-4 sm:px-6 lg:px-8 py-6 space-y-6">
        {/* Executive Stats Bar */}
        <StatsCards
          projects={projects}
          tasks={tasks}
          skills={skills}
          blockerRules={blockerRules}
        />

        {/* Navigation Tabs Bar */}
        <NavigationTabs
          activeTab={activeTab}
          setActiveTab={setActiveTab}
          counts={{
            projects: projects.length,
            tasks: tasks.length,
            skills: skills.length,
          }}
        />

        {/* Tab Views */}
        <div className="min-h-[500px]">
          {loading ? (
            <div className="flex flex-col items-center justify-center py-24 space-y-4">
              <div className="w-10 h-10 border-4 border-blue-500/20 border-t-blue-500 rounded-full animate-spin" />
              <p className="text-sm text-slate-400">جاري تحميل بيانات مسار النور...</p>
            </div>
          ) : (
            <>
              {activeTab === 'projects' && (
                <ProjectsView
                  projects={projects}
                  selectedProjectId={selectedProjectId}
                  onSelectProject={setSelectedProjectId}
                  onCreateProject={handleCreateProject}
                  onDeleteProject={handleDeleteProject}
                  onNavigateToTasks={() => setActiveTab('tasks')}
                />
              )}

              {activeTab === 'tasks' && (
                <TasksView
                  tasks={tasks}
                  projects={projects}
                  selectedProjectId={selectedProjectId}
                  onSelectProject={setSelectedProjectId}
                  onAddTask={handleAddTask}
                  onUpdateTaskStatus={handleUpdateTaskStatus}
                  onDeleteTask={handleDeleteTask}
                />
              )}

              {activeTab === 'eisenhower' && (
                <DynamicEisenhowerView
                  tasks={tasks}
                  onAddTask={handleAddEisenhowerTask}
                  onCompleteTaskEarly={handleCompleteTaskEarly}
                  onDeleteTask={handleDeleteTask}
                />
              )}

              {activeTab === 'skills' && (
                <SkillsView
                  skills={skills}
                  projects={projects}
                  selectedProjectId={selectedProjectId}
                  onSelectProject={setSelectedProjectId}
                  onAddSkill={handleAddSkill}
                  onDeleteSkill={handleDeleteSkill}
                  onOpenAIModal={() => setIsAIModalOpen(true)}
                />
              )}

              {activeTab === 'ai-planner' && (
                <AIPlannerView
                  projects={projects}
                  selectedProjectId={selectedProjectId}
                  onImportPlan={handleImportPlan}
                />
              )}

              {activeTab === 'blocker' && (
                <BlockerSettingsView
                  blockerRules={blockerRules}
                  onUpdateRules={handleUpdateBlockerRules}
                />
              )}

              {activeTab === 'router-guide' && (
                <RouterGuideView
                  initialSettings={routerSettings}
                  onSaveSettings={handleSaveRouterSettings}
                />
              )}

              {activeTab === 'notifications' && (
                <PersonalizedNotificationsView
                  notifications={notifications}
                  onAddNotification={handleAddNotification}
                />
              )}

              {activeTab === 'settings' && <SettingsView />}
            </>
          )}
        </div>
      </main>

      {/* Global AI Modal */}
      <AIModal
        isOpen={isAIModalOpen}
        onClose={() => setIsAIModalOpen(false)}
        projects={projects}
        selectedProjectId={selectedProjectId}
        onImportPlan={handleImportPlan}
      />

      {/* Footer */}
      <footer className="border-t border-slate-800/80 bg-slate-950/60 py-6 text-center text-xs text-slate-500">
        <div className="max-w-7xl mx-auto px-4 flex flex-col sm:flex-row items-center justify-between gap-2">
          <p>© 2026 مسار النور (Msar Elnor) - منظومة إدارة الأعمال وتطوير المهارات والحظر الصارم</p>
          <p className="text-slate-600">بناء متكامل وفق المخطط الشامل لـ Antigravity</p>
        </div>
      </footer>
    </div>
  );
}

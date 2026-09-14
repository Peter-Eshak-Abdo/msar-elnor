'use client';

import React, { useState } from 'react';
import { Task, Project, TaskStatus } from '@/types';
import {
  CheckCircle2,
  Clock,
  Circle,
  Plus,
  Trash2,
  CheckSquare2,
  FolderKanban
} from 'lucide-react';

interface TasksViewProps {
  tasks: Task[];
  projects: Project[];
  selectedProjectId: string | null;
  onSelectProject: (id: string | null) => void;
  onAddTask: (projectId: string, taskName: string, status?: TaskStatus) => Promise<void>;
  onUpdateTaskStatus: (taskId: string, status: TaskStatus) => Promise<void>;
  onDeleteTask: (taskId: string) => Promise<void>;
}

export const TasksView: React.FC<TasksViewProps> = ({
  tasks,
  projects,
  selectedProjectId,
  onSelectProject,
  onAddTask,
  onUpdateTaskStatus,
  onDeleteTask,
}) => {
  const [newTaskName, setNewTaskName] = useState('');
  const [targetProjectId, setTargetProjectId] = useState<string>(
    selectedProjectId || (projects[0]?.id ?? '')
  );
  const [statusFilter, setStatusFilter] = useState<'All' | TaskStatus>('All');
  const [isSubmitting, setIsSubmitting] = useState(false);

  const filteredTasks = tasks.filter((t) => {
    const matchProject = selectedProjectId ? t.project_id === selectedProjectId : true;
    const matchStatus = statusFilter === 'All' ? true : t.status === statusFilter;
    return matchProject && matchStatus;
  });

  const completedCount = filteredTasks.filter((t) => t.status === 'Completed').length;
  const progressPercent = filteredTasks.length > 0 ? Math.round((completedCount / filteredTasks.length) * 100) : 0;

  const handleAddTask = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!newTaskName.trim() || !targetProjectId) return;
    setIsSubmitting(true);
    try {
      await onAddTask(targetProjectId, newTaskName, 'Pending');
      setNewTaskName('');
    } finally {
      setIsSubmitting(false);
    }
  };

  const getStatusBadge = (status: TaskStatus) => {
    switch (status) {
      case 'Completed':
        return (
          <span className="flex items-center gap-1 text-[11px] px-2.5 py-1 rounded-full font-semibold bg-emerald-500/10 text-emerald-400 border border-emerald-500/20">
            <CheckCircle2 className="w-3 h-3" />
            <span>مكتملة</span>
          </span>
        );
      case 'In Progress':
        return (
          <span className="flex items-center gap-1 text-[11px] px-2.5 py-1 rounded-full font-semibold bg-amber-500/10 text-amber-400 border border-amber-500/20">
            <Clock className="w-3 h-3" />
            <span>جاري التنفيذ</span>
          </span>
        );
      default:
        return (
          <span className="flex items-center gap-1 text-[11px] px-2.5 py-1 rounded-full font-semibold bg-slate-500/10 text-slate-400 border border-slate-500/20">
            <Circle className="w-3 h-3" />
            <span>قيد الانتظار</span>
          </span>
        );
    }
  };

  return (
    <div className="space-y-6">
      {/* Header & Filter Controls */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <h2 className="text-xl font-bold text-white flex items-center gap-2">
            <CheckSquare2 className="w-5 h-5 text-indigo-400" />
            <span>لوحة المهام التقنية والتنفيذية</span>
          </h2>
          <p className="text-sm text-slate-400">
            متابعة حالة الإنجاز، وإدارة مراحل التطوير البرمجي والتنفيذ
          </p>
        </div>

        {/* Project Selector Filter */}
        <div className="flex flex-wrap items-center gap-2">
          <div className="flex items-center gap-2 px-3 py-1.5 rounded-xl bg-slate-900 border border-slate-800 text-xs">
            <FolderKanban className="w-3.5 h-3.5 text-slate-400" />
            <select
              value={selectedProjectId || ''}
              onChange={(e) => onSelectProject(e.target.value || null)}
              className="bg-transparent text-slate-200 focus:outline-none cursor-pointer"
            >
              <option value="" className="bg-slate-900">كل المشاريع</option>
              {projects.map((p) => (
                <option key={p.id} value={p.id} className="bg-slate-900">
                  {p.title}
                </option>
              ))}
            </select>
          </div>

          {/* Status Filter */}
          <div className="flex items-center gap-1 p-1 bg-slate-900 rounded-xl border border-slate-800 text-xs">
            {(['All', 'Pending', 'In Progress', 'Completed'] as const).map((st) => (
              <button
                key={st}
                onClick={() => setStatusFilter(st)}
                className={`px-2.5 py-1 rounded-lg transition-colors cursor-pointer ${
                  statusFilter === st
                    ? 'bg-blue-600 text-white font-semibold'
                    : 'text-slate-400 hover:text-slate-200'
                }`}
              >
                {st === 'All' ? 'الكل' : st === 'Pending' ? 'الانتظار' : st === 'In Progress' ? 'جاري' : 'مكتمل'}
              </button>
            ))}
          </div>
        </div>
      </div>

      {/* Progress Bar */}
      <div className="p-4 rounded-2xl bg-slate-900/60 border border-slate-800/80 space-y-2">
        <div className="flex items-center justify-between text-xs text-slate-300">
          <span>نسبة الإنجاز ({completedCount} من {filteredTasks.length} مهام)</span>
          <span className="font-bold text-blue-400">{progressPercent}%</span>
        </div>
        <div className="w-full h-2 bg-slate-800 rounded-full overflow-hidden">
          <div
            className="h-full bg-linear-to-r from-blue-500 to-emerald-400 transition-all duration-500 rounded-full"
            style={{ width: `${progressPercent}%` }}
          />
        </div>
      </div>

      {/* Quick Add Task */}
      <form
        onSubmit={handleAddTask}
        className="flex flex-col sm:flex-row gap-2 p-2 rounded-2xl bg-slate-900/80 border border-slate-800"
      >
        <input
          type="text"
          value={newTaskName}
          onChange={(e) => setNewTaskName(e.target.value)}
          placeholder="أضف مهمة برمجية أو إجرائية جديدة..."
          className="flex-1 px-4 py-2.5 rounded-xl bg-slate-950 border border-slate-800 text-slate-100 placeholder:text-slate-600 focus:outline-none focus:border-blue-500 text-sm"
        />

        {projects.length > 1 && !selectedProjectId && (
          <select
            value={targetProjectId}
            onChange={(e) => setTargetProjectId(e.target.value)}
            className="px-3 py-2.5 rounded-xl bg-slate-950 border border-slate-800 text-slate-300 text-xs focus:outline-none"
          >
            {projects.map((p) => (
              <option key={p.id} value={p.id}>
                {p.title}
              </option>
            ))}
          </select>
        )}

        <button
          type="submit"
          disabled={isSubmitting || !newTaskName.trim()}
          className="flex items-center justify-center gap-1.5 px-5 py-2.5 rounded-xl bg-blue-600 hover:bg-blue-500 text-white text-xs font-bold transition-all disabled:opacity-50 cursor-pointer shadow-md shadow-blue-500/20"
        >
          <Plus className="w-4 h-4" />
          <span>إضافة مهمة</span>
        </button>
      </form>

      {/* Tasks List */}
      <div className="space-y-3">
        {filteredTasks.map((task) => {
          const project = projects.find((p) => p.id === task.project_id);

          return (
            <div
              key={task.id}
              className="p-4 rounded-2xl bg-slate-900/50 border border-slate-800/80 hover:border-slate-700 transition-all flex flex-col sm:flex-row sm:items-center justify-between gap-3 group"
            >
              <div className="flex items-start sm:items-center gap-3">
                <button
                  onClick={() => {
                    const nextStatus: TaskStatus =
                      task.status === 'Pending' ? 'In Progress' :
                      task.status === 'In Progress' ? 'Completed' : 'Pending';
                    onUpdateTaskStatus(task.id, nextStatus);
                  }}
                  title="انقر لتغيير الحالة"
                  className="mt-0.5 sm:mt-0 p-1 rounded-lg hover:bg-slate-800 transition-colors cursor-pointer"
                >
                  {task.status === 'Completed' ? (
                    <CheckCircle2 className="w-5 h-5 text-emerald-400" />
                  ) : task.status === 'In Progress' ? (
                    <Clock className="w-5 h-5 text-amber-400" />
                  ) : (
                    <Circle className="w-5 h-5 text-slate-500 group-hover:text-slate-400" />
                  )}
                </button>

                <div>
                  <h4 className={`text-sm font-semibold text-slate-100 ${task.status === 'Completed' ? 'line-through text-slate-400' : ''}`}>
                    {task.task_name}
                  </h4>
                  {project && (
                    <span className="text-[11px] text-slate-500">
                      مشروع: {project.title}
                    </span>
                  )}
                </div>
              </div>

              {/* Status and Actions */}
              <div className="flex items-center gap-2 self-end sm:self-center">
                <select
                  value={task.status}
                  onChange={(e) => onUpdateTaskStatus(task.id, e.target.value as TaskStatus)}
                  className="text-xs bg-slate-950 border border-slate-800 text-slate-300 px-2.5 py-1.5 rounded-lg focus:outline-none cursor-pointer"
                >
                  <option value="Pending">قيد الانتظار</option>
                  <option value="In Progress">جاري التنفيذ</option>
                  <option value="Completed">مكتملة</option>
                </select>

                <button
                  onClick={() => onDeleteTask(task.id)}
                  className="p-1.5 rounded-lg text-slate-500 hover:text-rose-400 hover:bg-rose-500/10 transition-colors cursor-pointer"
                  title="حذف المهمة"
                >
                  <Trash2 className="w-4 h-4" />
                </button>
              </div>
            </div>
          );
        })}

        {filteredTasks.length === 0 && (
          <div className="py-12 text-center rounded-3xl border border-dashed border-slate-800 text-slate-500 text-sm">
            لا توجد مهام تطابق الفلتر المحدد. استخدم مولد الذكاء الاصطناعي أو نموذج الإضافة أعلاه.
          </div>
        )}
      </div>
    </div>
  );
};

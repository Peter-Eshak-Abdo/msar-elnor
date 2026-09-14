'use client';

import React from 'react';
import { X } from 'lucide-react';
import { AIPlannerView } from './AIPlannerView';
import { Project } from '@/types';

interface AIModalProps {
  isOpen: boolean;
  onClose: () => void;
  projects: Project[];
  selectedProjectId: string | null;
  onImportPlan: (
    projectTitle: string,
    tasks: string[],
    skills: Array<{ name: string; notes: string }>,
    existingProjectId?: string
  ) => Promise<void>;
}

export const AIModal: React.FC<AIModalProps> = ({
  isOpen,
  onClose,
  projects,
  selectedProjectId,
  onImportPlan,
}) => {
  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 sm:p-6 bg-black/80 backdrop-blur-sm animate-in fade-in duration-200">
      <div className="relative w-full max-w-4xl max-h-[90vh] overflow-y-auto bg-slate-950 border border-slate-800 rounded-3xl p-6 shadow-2xl space-y-4">
        <button
          onClick={onClose}
          className="absolute top-5 left-5 p-2 rounded-xl text-slate-400 hover:text-white hover:bg-slate-800 transition-colors cursor-pointer"
        >
          <X className="w-5 h-5" />
        </button>

        <AIPlannerView
          projects={projects}
          selectedProjectId={selectedProjectId}
          onImportPlan={async (title, tasks, skills, existingId) => {
            await onImportPlan(title, tasks, skills, existingId);
            setTimeout(() => onClose(), 1200);
          }}
          onClose={onClose}
        />
      </div>
    </div>
  );
};

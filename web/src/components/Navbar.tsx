'use client';

import React from 'react';
import {
  Sparkles,
} from 'lucide-react';
import { isSupabaseConfigured } from '@/lib/supabase';

interface NavbarProps {
  activeTab: string;
  setActiveTab: (tab: string) => void;
  onOpenAIModal: () => void;
}

export const Navbar: React.FC<NavbarProps> = ({
  onOpenAIModal,
}) => {
  return (
    <header className="sticky top-0 z-40 border-b border-slate-800 bg-[#090d16]/80 backdrop-blur-md">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex items-center justify-between h-16">
          {/* Logo & Brand */}
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 rounded-xl bg-linear-to-tr from-blue-600 via-indigo-500 to-amber-400 p-0.5 shadow-lg shadow-indigo-500/20">
              <div className="w-full h-full bg-slate-950 rounded-[10px] flex items-center justify-center">
                <span className="text-xl font-black bg-linear-to-r from-amber-300 via-yellow-400 to-amber-200 bg-clip-text text-transparent">
                  ن
                </span>
              </div>
            </div>
            <div>
              <div className="flex items-center gap-2">
                <h1 className="text-lg font-bold tracking-tight text-white">مسار النور</h1>
                <span className="text-[10px] font-semibold uppercase tracking-wider px-2 py-0.5 rounded-full bg-blue-500/10 text-blue-400 border border-blue-500/20">
                  ERP v1.0
                </span>
              </div>
              <p className="text-xs text-slate-400 hidden sm:block">
                منظومة إدارة المشاريع والمهام والحظر الصارم
              </p>
            </div>
          </div>

          {/* Quick Action Button */}
          <div className="flex items-center gap-3">
            <button
              onClick={onOpenAIModal}
              className="relative group flex items-center gap-2 px-4 py-2 rounded-xl bg-linear-to-r from-blue-600 to-indigo-600 hover:from-blue-500 hover:to-indigo-500 text-white text-sm font-semibold shadow-lg shadow-indigo-500/25 transition-all duration-200 cursor-pointer active:scale-95"
            >
              <Sparkles className="w-4 h-4 text-amber-300 animate-pulse" />
              <span>توليد خطة بالذكاء الاصطناعي</span>
            </button>

            {/* Supabase Status Indicator */}
            <div className="hidden md:flex items-center gap-2 px-3 py-1.5 rounded-lg bg-slate-900 border border-slate-800 text-xs">
              <span className={`w-2 h-2 rounded-full ${isSupabaseConfigured ? 'bg-emerald-400 animate-ping' : 'bg-amber-400'}`} />
              <span className="text-slate-300">
                {isSupabaseConfigured ? 'Supabase متصل' : 'تخزين محلي مؤمن'}
              </span>
            </div>
          </div>
        </div>
      </div>
    </header>
  );
};

'use client';

import React, { useState } from 'react';
import { 
  Settings, 
  Database, 
  Flame, 
  Download, 
  Upload, 
  CheckCircle, 
  Copy, 
  Sparkles,
  ShieldCheck,
  AlertTriangle
} from 'lucide-react';
import { isFirebaseConfigured } from '@/lib/firebase';
import { isSupabaseConfigured } from '@/lib/supabase';
import { DataService } from '@/lib/dataService';

export const SettingsView: React.FC = () => {
  const [copied, setCopied] = useState(false);
  const [backupStatus, setBackupStatus] = useState<string | null>(null);

  const copyFirebaseSnippet = () => {
    const snippet = `NEXT_PUBLIC_FIREBASE_API_KEY=AIzaSy...
NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN=your-app.firebaseapp.com
NEXT_PUBLIC_FIREBASE_PROJECT_ID=your-app
NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET=your-app.appspot.com
NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID=123456789
NEXT_PUBLIC_FIREBASE_APP_ID=1:123456789:web:abcdef`;
    navigator.clipboard.writeText(snippet);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  const handleExportData = () => {
    const dataStr = DataService.exportAllData();
    const blob = new Blob([dataStr], { type: 'application/json' });
    const url = URL.createObjectURL(blob);
    const link = document.createElement('a');
    link.href = url;
    link.download = `msar-elnor-backup-${new Date().toISOString().slice(0, 10)}.json`;
    link.click();
    URL.revokeObjectURL(url);
    setBackupStatus('تم تصدير النسخة الاحتياطية بنجاح!');
    setTimeout(() => setBackupStatus(null), 3000);
  };

  const handleImportData = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;

    const reader = new FileReader();
    reader.onload = (event) => {
      const content = event.target?.result as string;
      if (content) {
        const success = DataService.importData(content);
        if (success) {
          setBackupStatus('تم استيراد البيانات بنجاح! يرجى تحديث الصفحة لرؤية البيانات المستوردة.');
        } else {
          setBackupStatus('فشل استيراد الملف: يرجى التأكد من أنه ملف JSON صحيح.');
        }
      }
    };
    reader.readAsText(file);
  };

  return (
    <div className="space-y-6 max-w-4xl">
      <div>
        <h2 className="text-xl font-bold text-white flex items-center gap-2">
          <Settings className="w-5 h-5 text-slate-400" />
          <span>إعدادات النظام، قواعد البيانات، والنسخ الاحتياطي</span>
        </h2>
        <p className="text-sm text-slate-400">
          تكوين التزامن السحابي (Firebase / Supabase)، وأدوات حفظ واستيراد البيانات، وجاهزية النشر على Vercel
        </p>
      </div>

      {backupStatus && (
        <div className="p-4 rounded-2xl bg-blue-500/10 border border-blue-500/20 text-blue-300 text-xs flex items-center gap-2">
          <CheckCircle className="w-4 h-4 text-blue-400 shrink-0" />
          <span>{backupStatus}</span>
        </div>
      )}

      {/* Vercel Ready Banner */}
      <div className="p-5 rounded-2xl bg-gradient-to-r from-emerald-950/40 via-slate-900 to-slate-900 border border-emerald-500/30 space-y-2">
        <div className="flex items-center gap-2 text-emerald-400 font-bold text-sm">
          <ShieldCheck className="w-5 h-5" />
          <span>جاهز 100% للنشر الفوري على Vercel</span>
        </div>
        <p className="text-xs text-slate-300 leading-relaxed">
          تم تزويد المنظومة بمحرك هجين مستقل (Zero-Config Hybrid Storage). يمكنك رفع هذا المستودع على Vercel الآن وسيعمل مباشرة وبكامل وظائفه حتى دون الحاجة لضبط أي متغيرات بيئية سحابية.
        </p>
      </div>

      {/* Cloud Database (Firebase Firestore) Card */}
      <div className="p-5 rounded-2xl bg-slate-900/70 border border-slate-800 space-y-4">
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-2.5">
            <div className={`p-2 rounded-xl ${isFirebaseConfigured ? 'bg-amber-500/10 text-amber-400' : 'bg-slate-800 text-slate-400'}`}>
              <Flame className="w-5 h-5" />
            </div>
            <div>
              <h3 className="font-bold text-sm text-white">ربط Firebase Firestore (باقة مجانية مدى الحياة)</h3>
              <p className="text-xs text-slate-400">
                {isFirebaseConfigured
                  ? 'قاعدة بيانات Firestore السحابية متصلة وتعمل بالتزامن المباشر.'
                  : 'غير مفعل حالياً. النظام يعمل بمحرك التخزين المحلي الهجين فائق السرعة والأمان.'}
              </p>
            </div>
          </div>

          <span
            className={`text-xs px-3 py-1 rounded-full font-semibold border ${
              isFirebaseConfigured
                ? 'bg-amber-500/10 text-amber-400 border-amber-500/20'
                : 'bg-slate-800 text-slate-400 border-slate-700'
            }`}
          >
            {isFirebaseConfigured ? 'Firestore متصل' : 'تخزين محلي مؤمن'}
          </span>
        </div>

        {/* Firebase setup guide */}
        <div className="p-4 rounded-xl bg-slate-950/80 border border-slate-800/80 text-xs space-y-2 text-slate-300">
          <div className="flex items-center justify-between">
            <span className="font-bold text-slate-200">لتفعيل Firebase في أي وقت:</span>
            <button
              onClick={copyFirebaseSnippet}
              className="inline-flex items-center gap-1 text-amber-400 hover:text-amber-300 text-[11px] cursor-pointer"
            >
              <Copy className="w-3 h-3" />
              <span>{copied ? 'تم النسخ!' : 'نسخ المتغيرات المطلوبة'}</span>
            </button>
          </div>
          <p className="text-slate-400 leading-relaxed">
            أنشئ مشروعاً مجانياً على <a href="https://console.firebase.google.com" target="_blank" rel="noreferrer" className="text-amber-400 underline">Firebase Console</a>، وفعّل Cloud Firestore، ثم أضف المتغيرات في إعدادات Vercel أو في ملف <code className="text-amber-400 font-mono">web/.env.local</code>.
          </p>
        </div>
      </div>

      {/* Data Backup & Export/Import Tool */}
      <div className="p-5 rounded-2xl bg-slate-900/70 border border-slate-800 space-y-4">
        <div className="flex items-center gap-2.5">
          <div className="p-2 rounded-xl bg-blue-500/10 text-blue-400">
            <Database className="w-5 h-5" />
          </div>
          <div>
            <h3 className="font-bold text-sm text-white">النسخ الاحتياطي واستيراد البيانات (Data Portability)</h3>
            <p className="text-xs text-slate-400">
              تصدير كافة المشاريع والمهام والمهارات وقواعد الحظر في ملف JSON مستقل، أو استرجاعها في أي جهاز
            </p>
          </div>
        </div>

        <div className="flex flex-wrap gap-3 pt-1">
          <button
            onClick={handleExportData}
            className="flex items-center gap-2 px-4 py-2.5 rounded-xl bg-blue-600 hover:bg-blue-500 text-white text-xs font-bold transition-all shadow-md shadow-blue-500/20 cursor-pointer"
          >
            <Download className="w-4 h-4" />
            <span>تصدير نسخة احتياطية كاملة (JSON)</span>
          </button>

          <label className="flex items-center gap-2 px-4 py-2.5 rounded-xl bg-slate-800 hover:bg-slate-700 text-slate-200 text-xs font-bold transition-all border border-slate-700 cursor-pointer">
            <Upload className="w-4 h-4 text-amber-400" />
            <span>استيراد نسخة بيانات</span>
            <input
              type="file"
              accept=".json"
              onChange={handleImportData}
              className="hidden"
            />
          </label>
        </div>
      </div>
    </div>
  );
};

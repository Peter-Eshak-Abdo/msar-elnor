'use client';

import React, { useState } from 'react';
import { BlockerRule } from '@/types';
import {
  ShieldAlert,
  Clock,
  Globe,
  Music,
  Plus,
  X,
  Save,
  Play,
  Radio,
  Smartphone,
  ExternalLink,
  CheckCircle
} from 'lucide-react';

interface BlockerSettingsViewProps {
  blockerRules: BlockerRule;
  onUpdateRules: (updated: BlockerRule) => Promise<void>;
}

export const BlockerSettingsView: React.FC<BlockerSettingsViewProps> = ({
  blockerRules,
  onUpdateRules,
}) => {
  const [rules, setRules] = useState<BlockerRule>(blockerRules);
  const [newUrl, setNewUrl] = useState('');
  const [saving, setSaving] = useState(false);
  const [savedSuccess, setSavedSuccess] = useState(false);
  const [showPlayerPreview, setShowPlayerPreview] = useState(false);

  const handleAddUrl = (e: React.FormEvent) => {
    e.preventDefault();
    const cleanUrl = newUrl.trim().toLowerCase().replace(/^https?:\/\//, '').replace(/\/$/, '');
    if (!cleanUrl || rules.blocked_urls.includes(cleanUrl)) return;

    setRules({
      ...rules,
      blocked_urls: [...rules.blocked_urls, cleanUrl],
    });
    setNewUrl('');
  };

  const handleRemoveUrl = (target: string) => {
    setRules({
      ...rules,
      blocked_urls: rules.blocked_urls.filter((u) => u !== target),
    });
  };

  const handleSave = async () => {
    setSaving(true);
    setSavedSuccess(false);
    try {
      await onUpdateRules(rules);
      setSavedSuccess(true);
      setTimeout(() => setSavedSuccess(false), 3000);
    } finally {
      setSaving(false);
    }
  };

  // Convert YouTube link to embed link if possible
  const getEmbedUrl = (url: string) => {
    try {
      if (url.includes('youtube.com') || url.includes('youtu.be')) {
        let videoId = '';
        if (url.includes('v=')) {
          videoId = url.split('v=')[1]?.split('&')[0] || '';
        } else if (url.includes('youtu.be/')) {
          videoId = url.split('youtu.be/')[1]?.split('?')[0] || '';
        }
        if (videoId && videoId !== 'sample-tasbeha' && videoId !== 'aripsalin-tasbeha') {
          return `https://www.youtube.com/embed/${videoId}?autoplay=1`;
        }
      }
      return null;
    } catch {
      return null;
    }
  };

  const embedUrl = getEmbedUrl(rules.fallback_url);

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h2 className="text-xl font-bold text-white flex items-center gap-2">
            <ShieldAlert className="w-5 h-5 text-rose-400" />
            <span>إعدادات نظام الحظر الصارم (Strict Blocker)</span>
          </h2>
          <p className="text-sm text-slate-400">
            تخصيص قواعد الحظر ومواقيت التركيز ورابط التوجيه الروحي (الألحان والتسابيح) المتزامن مع تطبيق الموبايل
          </p>
        </div>

        <button
          onClick={handleSave}
          disabled={saving}
          className="flex items-center gap-2 px-5 py-2.5 rounded-xl bg-blue-600 hover:bg-blue-500 text-white text-xs font-bold transition-all shadow-lg shadow-blue-500/20 disabled:opacity-50 cursor-pointer"
        >
          {savedSuccess ? (
            <>
              <CheckCircle className="w-4 h-4 text-emerald-300" />
              <span>تم الحفظ والمزامنة!</span>
            </>
          ) : (
            <>
              <Save className="w-4 h-4" />
              <span>{saving ? 'جاري المزامنة...' : 'حفظ الإعدادات'}</span>
            </>
          )}
        </button>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Left 2 Cols: URL list & Active hours */}
        <div className="lg:col-span-2 space-y-5">
          {/* Active Hours Box */}
          <div className="p-5 rounded-2xl bg-slate-900/70 border border-slate-800 space-y-4">
            <div className="flex items-center gap-2 text-slate-200 font-bold text-sm">
              <Clock className="w-4 h-4 text-blue-400" />
              <span>ساعات الحظر الصارم (Active Hours)</span>
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <div>
                <label className="block text-xs text-slate-400 mb-1">
                  بداية الحظر (مساءً)
                </label>
                <input
                  type="time"
                  value={rules.active_hours.start}
                  onChange={(e) =>
                    setRules({
                      ...rules,
                      active_hours: { ...rules.active_hours, start: e.target.value },
                    })
                  }
                  className="w-full px-4 py-2.5 rounded-xl bg-slate-950 border border-slate-800 text-slate-100 text-sm focus:outline-none focus:border-blue-500"
                />
              </div>

              <div>
                <label className="block text-xs text-slate-400 mb-1">
                  نهاية الحظر (صباحاً)
                </label>
                <input
                  type="time"
                  value={rules.active_hours.end}
                  onChange={(e) =>
                    setRules({
                      ...rules,
                      active_hours: { ...rules.active_hours, end: e.target.value },
                    })
                  }
                  className="w-full px-4 py-2.5 rounded-xl bg-slate-950 border border-slate-800 text-slate-100 text-sm focus:outline-none focus:border-blue-500"
                />
              </div>
            </div>

            <div className="flex items-center gap-2 pt-1 text-xs text-slate-400">
              <span className="w-2 h-2 rounded-full bg-emerald-400 animate-pulse" />
              <span>الحظر مفعل طوال أيام الأسبوع في هذه الفترة الزمنية.</span>
            </div>
          </div>

          {/* Blocked URLs List */}
          <div className="p-5 rounded-2xl bg-slate-900/70 border border-slate-800 space-y-4">
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-2 text-slate-200 font-bold text-sm">
                <Globe className="w-4 h-4 text-rose-400" />
                <span>قائمة المواقع والتطبيقات المحظورة ({rules.blocked_urls.length})</span>
              </div>
            </div>

            {/* Add URL Form */}
            <form onSubmit={handleAddUrl} className="flex gap-2">
              <input
                type="text"
                value={newUrl}
                onChange={(e) => setNewUrl(e.target.value)}
                placeholder="أضف نطاق أو رابط (مثال: tiktok.com, x.com)..."
                className="flex-1 px-4 py-2.5 rounded-xl bg-slate-950 border border-slate-800 text-slate-100 text-sm placeholder:text-slate-600 focus:outline-none focus:border-rose-500"
              />
              <button
                type="submit"
                disabled={!newUrl.trim()}
                className="flex items-center gap-1.5 px-4 py-2.5 rounded-xl bg-rose-600/80 hover:bg-rose-600 text-white text-xs font-bold transition-colors disabled:opacity-40 cursor-pointer"
              >
                <Plus className="w-4 h-4" />
                <span>إضافة</span>
              </button>
            </form>

            {/* Chips */}
            <div className="flex flex-wrap gap-2 pt-2">
              {rules.blocked_urls.map((url) => (
                <span
                  key={url}
                  className="flex items-center gap-1.5 px-3 py-1.5 rounded-xl bg-rose-950/40 border border-rose-800/50 text-rose-200 text-xs font-mono group"
                >
                  <span>{url}</span>
                  <button
                    type="button"
                    onClick={() => handleRemoveUrl(url)}
                    className="text-rose-400 hover:text-white transition-colors cursor-pointer"
                  >
                    <X className="w-3.5 h-3.5" />
                  </button>
                </span>
              ))}
            </div>
          </div>
        </div>

        {/* Right Col: Fallback Spiritual Media (Tasbeha / Hymns) */}
        <div className="p-5 rounded-2xl bg-linear-to-b from-indigo-950/30 to-slate-900 border border-indigo-500/20 space-y-4">
          <div className="flex items-center gap-2 text-slate-100 font-bold text-sm">
            <Music className="w-4 h-4 text-amber-400" />
            <span>رابط التوجيه الروحي البديل (Fallback URL)</span>
          </div>

          <p className="text-xs text-slate-400 leading-relaxed">
            الرابط الذي يتم تشغيله فوراً على كامل الشاشة عند محاولة فتح موقع محظور (مثل ألحان أريبصالين أو تسبحة نصف الليل).
          </p>

          <div>
            <label className="block text-xs font-medium text-slate-400 mb-1">
              رابط البث أو الفيديو (يوتيوب أو ملف صوتي)
            </label>
            <input
              type="url"
              value={rules.fallback_url}
              onChange={(e) => setRules({ ...rules, fallback_url: e.target.value })}
              className="w-full px-3.5 py-2.5 rounded-xl bg-slate-950 border border-slate-800 text-slate-200 text-xs font-mono focus:outline-none focus:border-indigo-500"
            />
          </div>

          {/* Quick preset selector */}
          <div className="space-y-1.5 pt-1">
            <span className="text-[11px] text-slate-500">روابط مقترحة سريعة:</span>
            <div className="flex flex-col gap-1.5 text-xs">
              <button
                type="button"
                onClick={() =>
                  setRules({
                    ...rules,
                    fallback_url: 'https://www.youtube.com/watch?v=kYv9G_P4a4I',
                  })
                }
                className="text-right p-2 rounded-lg bg-slate-950/60 hover:bg-slate-800 text-slate-300 text-[11px] transition-colors cursor-pointer"
              >
                🎵 لحن أريبصالين بالطقس السنوي المفرح
              </button>
              <button
                type="button"
                onClick={() =>
                  setRules({
                    ...rules,
                    fallback_url: 'https://www.youtube.com/watch?v=0k0kU_Tasbeha',
                  })
                }
                className="text-right p-2 rounded-lg bg-slate-950/60 hover:bg-slate-800 text-slate-300 text-[11px] transition-colors cursor-pointer"
              >
                🕯️ تسبحة نصف الليل المباركة (كاملة)
              </button>
            </div>
          </div>

          {/* Preview Button */}
          <button
            type="button"
            onClick={() => setShowPlayerPreview(!showPlayerPreview)}
            className="w-full flex items-center justify-center gap-2 py-2.5 rounded-xl bg-indigo-600/20 hover:bg-indigo-600/30 border border-indigo-500/30 text-indigo-300 text-xs font-semibold transition-colors cursor-pointer"
          >
            <Play className="w-3.5 h-3.5 text-amber-300" />
            <span>{showPlayerPreview ? 'إخفاء المعاينة' : 'معاينة شاشة الطوارئ الروحية'}</span>
          </button>

          {/* Embedded Player Preview */}
          {showPlayerPreview && (
            <div className="p-3 rounded-xl bg-slate-950 border border-indigo-500/30 space-y-2">
              <span className="text-[11px] font-bold text-amber-300 flex items-center gap-1.5">
                <Radio className="w-3.5 h-3.5 animate-pulse" />
                شاشة الطوارئ والإنقاذ الروحي:
              </span>
              {embedUrl ? (
                <iframe
                  src={embedUrl}
                  title="Tasbeha Fallback Preview"
                  className="w-full h-44 rounded-lg border border-slate-800"
                  allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
                  allowFullScreen
                />
              ) : (
                <div className="p-4 text-center text-xs text-slate-400 bg-slate-900 rounded-lg space-y-2">
                  <p>رابط المشغل الروحي النشط:</p>
                  <a
                    href={rules.fallback_url}
                    target="_blank"
                    rel="noreferrer"
                    className="inline-flex items-center gap-1 text-blue-400 underline text-[11px]"
                  >
                    <span>فتح الرابط في علامة تبويب جديدة</span>
                    <ExternalLink className="w-3 h-3" />
                  </a>
                </div>
              )}
            </div>
          )}

          {/* Mobile App Sync Note */}
          <div className="p-3 rounded-xl bg-slate-950/80 border border-slate-800 text-[11px] text-slate-400 flex items-start gap-2">
            <Smartphone className="w-4 h-4 text-blue-400 shrink-0 mt-0.5" />
            <span>
              يتم سحب هذه القواعد وتخزينها في قاعدة بيانات Hive المحلية بتطبيق الموبايل لتعمل خدمة الحظر حتى في حال انقطاع الإنترنت.
            </span>
          </div>
        </div>
      </div>
    </div>
  );
};

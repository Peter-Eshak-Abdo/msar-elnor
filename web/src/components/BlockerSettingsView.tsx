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
  CheckCircle,
  KeyRound,
  Copy,
  RefreshCw,
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

  // Remote Unlock Authority states
  const [unlockToken, setUnlockToken] = useState<string | null>(null);
  const [isGeneratingToken, setIsGeneratingToken] = useState(false);
  const [tokenCopied, setTokenCopied] = useState(false);

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

  const generateRemoteUnlockToken = async () => {
    setIsGeneratingToken(true);
    try {
      const res = await fetch('/api/device/unlock');
      const data = await res.json();
      if (data.success && data.token) {
        setUnlockToken(data.token);
      }
    } catch (err) {
      console.error('Failed to generate unlock token:', err);
    } finally {
      setIsGeneratingToken(false);
    }
  };

  const copyTokenToClipboard = () => {
    if (!unlockToken) return;
    navigator.clipboard.writeText(unlockToken);
    setTokenCopied(true);
    setTimeout(() => setTokenCopied(false), 2000);
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
            <span>إعدادات نظام الحظر الصارم (3-Tier Strict Blocker)</span>
          </h2>
          <p className="text-sm text-slate-400">
            تخصيص قواعد الحظر ومواقيت التركيز ورابط التوجيه الروحي وكود الفك المشروط عن بعد المتصل بـ MongoDB
          </p>
        </div>

        <button
          type="button"
          onClick={handleSave}
          disabled={saving}
          className="flex items-center gap-2 px-5 py-2.5 rounded-xl bg-gradient-to-r from-blue-600 to-indigo-600 hover:from-blue-500 hover:to-indigo-500 text-white text-sm font-semibold shadow-lg shadow-blue-500/20 disabled:opacity-50 transition-all cursor-pointer"
        >
          {saving ? (
            <span>جارِ الحفظ...</span>
          ) : savedSuccess ? (
            <>
              <CheckCircle className="w-4 h-4 text-green-300" />
              <span>تم الحفظ والمزامنة!</span>
            </>
          ) : (
            <>
              <Save className="w-4 h-4" />
              <span>حفظ وتحديث القواعد</span>
            </>
          )}
        </button>
      </div>

      {/* Remote Unlock Authority Card (MongoDB Controlled) */}
      <div className="p-5 rounded-2xl bg-gradient-to-br from-slate-900 via-amber-950/20 to-slate-900 border border-amber-500/30 shadow-xl space-y-4">
        <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3">
          <div className="flex items-center gap-3">
            <div className="p-2.5 rounded-xl bg-amber-500/10 border border-amber-500/20 text-amber-400">
              <KeyRound className="w-5 h-5" />
            </div>
            <div>
              <h3 className="text-sm font-bold text-white">
                سلطة فك الحظر والتحكم عن بعد (Remote Unlock Authority)
              </h3>
              <p className="text-xs text-slate-400">
                لا يمكن للمستخدم مسح التطبيق أو إلغاء حماية مسؤول الجهاز إلا عبر كود أمان مؤقت يُطلب من لوحة التحكم هذه حصراً.
              </p>
            </div>
          </div>

          <button
            type="button"
            onClick={generateRemoteUnlockToken}
            disabled={isGeneratingToken}
            className="inline-flex items-center gap-2 px-4 py-2 rounded-xl bg-amber-500 hover:bg-amber-400 text-slate-950 font-bold text-xs shadow-lg shadow-amber-500/20 transition-all cursor-pointer disabled:opacity-50"
          >
            <RefreshCw className={`w-3.5 h-3.5 ${isGeneratingToken ? 'animate-spin' : ''}`} />
            <span>{isGeneratingToken ? 'جارِ التوليد...' : 'توليد رمز فك حظر سري (OTP)'}</span>
          </button>
        </div>

        {unlockToken && (
          <div className="p-4 rounded-xl bg-slate-950/90 border border-amber-500/40 flex flex-col sm:flex-row items-center justify-between gap-4 animate-in fade-in">
            <div className="text-center sm:text-right">
              <span className="text-[11px] text-amber-400/90 font-medium">
                كود فك الحظر النشط (صالح لمدة 15 دقيقة):
              </span>
              <div className="text-2xl font-mono font-bold tracking-[0.3em] text-white mt-0.5">
                {unlockToken}
              </div>
            </div>

            <div className="flex items-center gap-2">
              <button
                type="button"
                onClick={copyTokenToClipboard}
                className="flex items-center gap-1.5 px-3 py-1.5 rounded-lg bg-slate-800 hover:bg-slate-700 text-slate-200 text-xs font-semibold transition-colors cursor-pointer"
              >
                <Copy className="w-3.5 h-3.5 text-amber-400" />
                <span>{tokenCopied ? 'تم النسخ!' : 'نسخ الكود'}</span>
              </button>
            </div>
          </div>
        )}
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Left 2 Cols: Blocked URLs and Times */}
        <div className="lg:col-span-2 space-y-6">
          {/* Active Hours */}
          <div className="p-5 rounded-2xl bg-slate-900/60 border border-slate-800 shadow-xl space-y-4">
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-2 text-white font-bold text-sm">
                <Clock className="w-4 h-4 text-blue-400" />
                <span>أوقات تفعيل الحظر الصارم (Curfew Hours)</span>
              </div>
              <label className="relative inline-flex items-center cursor-pointer">
                <input
                  type="checkbox"
                  checked={rules.is_active}
                  onChange={(e) => setRules({ ...rules, is_active: e.target.checked })}
                  className="sr-only peer"
                />
                <div className="w-11 h-6 bg-slate-800 peer-focus:outline-none rounded-full peer peer-checked:after:translate-x-full rtl:peer-checked:after:-translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:start-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-blue-600"></div>
                <span className="ms-3 text-xs font-medium text-slate-300">
                  {rules.is_active ? 'نشط' : 'معطل'}
                </span>
              </label>
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4 pt-2">
              <div className="space-y-1.5">
                <label className="text-xs text-slate-400">ساعة البدء (مساءً)</label>
                <input
                  type="time"
                  value={rules.active_hours?.start || '23:00'}
                  onChange={(e) =>
                    setRules({
                      ...rules,
                      active_hours: {
                        start: e.target.value,
                        end: rules.active_hours?.end || '07:00',
                        days: rules.active_hours?.days || [],
                      },
                    })
                  }
                  className="w-full px-3.5 py-2.5 rounded-xl bg-slate-950 border border-slate-800 text-white text-sm focus:outline-none focus:border-blue-500 transition-colors"
                />
              </div>

              <div className="space-y-1.5">
                <label className="text-xs text-slate-400">ساعة الانتهاء (صباحاً)</label>
                <input
                  type="time"
                  value={rules.active_hours?.end || '07:00'}
                  onChange={(e) =>
                    setRules({
                      ...rules,
                      active_hours: {
                        start: rules.active_hours?.start || '23:00',
                        end: e.target.value,
                        days: rules.active_hours?.days || [],
                      },
                    })
                  }
                  className="w-full px-3.5 py-2.5 rounded-xl bg-slate-950 border border-slate-800 text-white text-sm focus:outline-none focus:border-blue-500 transition-colors"
                />
              </div>
            </div>
            <p className="text-[11px] text-slate-500">
              * ينصح بضبط الساعات من 11:00 مساءً حتى 7:00 صباحاً لتأمين أوقات النوم واليقظة الذهنية.
            </p>
          </div>

          {/* Blocked URLs List */}
          <div className="p-5 rounded-2xl bg-slate-900/60 border border-slate-800 shadow-xl space-y-4">
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-2 text-white font-bold text-sm">
                <Globe className="w-4 h-4 text-rose-400" />
                <span>قائمة المواقع والتطبيقات المحظورة ({rules.blocked_urls.length})</span>
              </div>
            </div>

            {/* Add New URL Form */}
            <form onSubmit={handleAddUrl} className="flex gap-2">
              <input
                type="text"
                placeholder="أضف نطاقاً جديداً (مثال: tiktok.com أو reddit.com)"
                value={newUrl}
                onChange={(e) => setNewUrl(e.target.value)}
                className="flex-1 px-3.5 py-2.5 rounded-xl bg-slate-950 border border-slate-800 text-white text-sm placeholder:text-slate-600 focus:outline-none focus:border-rose-500 transition-colors"
              />
              <button
                type="submit"
                className="flex items-center gap-1.5 px-4 py-2.5 rounded-xl bg-rose-600/20 hover:bg-rose-600/30 text-rose-300 border border-rose-500/30 text-xs font-semibold transition-colors cursor-pointer"
              >
                <Plus className="w-4 h-4" />
                <span>إضافة</span>
              </button>
            </form>

            {/* URL Chips */}
            <div className="flex flex-wrap gap-2 pt-2">
              {rules.blocked_urls.map((url) => (
                <div
                  key={url}
                  className="group flex items-center gap-1.5 px-3 py-1.5 rounded-lg bg-slate-950 border border-slate-800 hover:border-rose-500/40 text-xs text-slate-300 transition-colors"
                >
                  <span className="font-mono">{url}</span>
                  <button
                    type="button"
                    onClick={() => handleRemoveUrl(url)}
                    className="text-slate-500 hover:text-rose-400 transition-colors cursor-pointer"
                  >
                    <X className="w-3.5 h-3.5" />
                  </button>
                </div>
              ))}
            </div>
          </div>
        </div>

        {/* Right Col: Fallback Spiritual Redirection URL */}
        <div className="p-5 rounded-2xl bg-slate-900/60 border border-slate-800 shadow-xl space-y-4 flex flex-col justify-between">
          <div className="space-y-4">
            <div className="flex items-center gap-2 text-white font-bold text-sm">
              <Music className="w-4 h-4 text-amber-400" />
              <span>رابط التوجيه الروحي الإلزامي (Fallback Hymn)</span>
            </div>

            <p className="text-xs text-slate-400">
              عند رصد أي محاولة للدخول لموقع محظور، يتم إغلاقه فوراً وإطلاق شاشة الدوبامين الإيجابية وتشغيل الترنيمة بصوت أبونا موسى رشدي.
            </p>

            <div className="space-y-1.5">
              <label className="text-xs text-slate-400">رابط الفيديو أو التسبحة البديلة</label>
              <input
                type="url"
                value={rules.fallback_url}
                onChange={(e) => setRules({ ...rules, fallback_url: e.target.value })}
                className="w-full px-3.5 py-2.5 rounded-xl bg-slate-950 border border-slate-800 text-amber-300 text-xs font-mono focus:outline-none focus:border-amber-500 transition-colors"
              />
            </div>

            {/* Quick Presets */}
            <div className="space-y-1.5 pt-1">
              <span className="text-[11px] text-slate-500">نماذج روحية جاهزة للاختيار:</span>
              <div className="grid grid-cols-1 gap-1.5">
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
                  🎵 ترنيمة ذنوبي حمول بجرجرها - أبونا موسى رشدي
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
          </div>

          {/* Mobile App Sync Note */}
          <div className="p-3 rounded-xl bg-slate-950/80 border border-slate-800 text-[11px] text-slate-400 flex items-start gap-2 mt-4">
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

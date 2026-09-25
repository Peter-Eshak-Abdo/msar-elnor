'use client';

import React, { useState } from 'react';
import { PersonalizedNotification } from '@/types';
import {
  Bell,
  Send,
  Sparkles,
  GraduationCap,
  Church,
  TrendingUp,
  Brain,
  CheckCircle2,
  Clock,
  Plus,
} from 'lucide-react';

interface PersonalizedNotificationsViewProps {
  notifications: PersonalizedNotification[];
  onAddNotification: (notif: Omit<PersonalizedNotification, 'id'>) => Promise<void>;
}

export const PersonalizedNotificationsView: React.FC<PersonalizedNotificationsViewProps> = ({
  notifications,
  onAddNotification,
}) => {
  const [sendingId, setSendingId] = useState<string | null>(null);
  const [sendSuccessId, setSendSuccessId] = useState<string | null>(null);
  const [customTitle, setCustomTitle] = useState('');
  const [customBody, setCustomBody] = useState('');
  const [customType, setCustomType] = useState<PersonalizedNotification['type']>('graduation');

  // Persona Presets as required in msar-elnor-edits2.md
  const presetTemplates = [
    {
      title: 'عاش يا باشمهندس! إنجاز مبكر 🚀',
      body: 'خلصت تاسك الشغل بدري! وقت استثمارك الذهني في كود مشروع التخرج لحاسبات ومعلومات دلوقتي.',
      type: 'graduation' as const,
      icon: GraduationCap,
      color: 'text-blue-400 bg-blue-500/10 border-blue-500/30',
    },
    {
      title: 'بركة الخدمة وصلاة سريعة ⛪',
      body: 'صلاة سريعة بالأجبية قبل التاسك الجاي ببركة خدمتك كأغنسطس.. ربنا يبارك خدمتك ونقاء فكرك.',
      type: 'church_service' as const,
      icon: Church,
      color: 'text-amber-400 bg-amber-500/10 border-amber-500/30',
    },
    {
      title: 'متابعة استثمارك في Thndr 📈',
      body: 'سهمك في Thndr ومحفظتك (10 آلاف جنيه) محتاجة متابعة، بس خلص مذاكرتك الأول يا بطل!',
      type: 'thndr' as const,
      icon: TrendingUp,
      color: 'text-emerald-400 bg-emerald-500/10 border-emerald-500/30',
    },
    {
      title: 'قمة التركيز العصبي (Peak Prefrontal State) 🧠',
      body: 'الفص الجبهي عندك الآن في أعلى درجات اليقظة والانتباه.. استغل الساعة دي في برمجة الـ Core Feature لمشروع التخرج.',
      type: 'deep_focus' as const,
      icon: Brain,
      color: 'text-purple-400 bg-purple-500/10 border-purple-500/30',
    },
    {
      title: '«كُلُّ الأَشْيَاءِ تَحِلُّ لِي، لكِنْ لَيْسَ كُلُّ الأَشْيَاءِ تَبْنِي» ✝️',
      body: 'تذكر هدفك ومسارك النقي دائماً.. أنت خادم وابن للملك، وكل دقيقة تركيز هي استثمار في أبديتك ومستقبلك.',
      type: 'church_service' as const,
      icon: Church,
      color: 'text-cyan-400 bg-cyan-500/10 border-cyan-500/30',
    },
  ];

  const handleSendNotification = async (item: { title: string; body: string; type: string; id?: string }) => {
    const key = item.id || item.title;
    setSendingId(key);
    try {
      const res = await fetch('/api/notifications/send', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          title: item.title,
          message: item.body,
          type: item.type,
        }),
      });
      const data = await res.json();
      if (data.success) {
        setSendSuccessId(key);
        setTimeout(() => setSendSuccessId(null), 3000);
      }
    } catch (e) {
      console.error('Failed to trigger FCM push notification', e);
    } finally {
      setSendingId(null);
    }
  };

  const handleCreateCustom = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!customTitle.trim() || !customBody.trim()) return;
    await onAddNotification({
      title: customTitle.trim(),
      body: customBody.trim(),
      type: customType,
    });
    setCustomTitle('');
    setCustomBody('');
  };

  return (
    <div className="space-y-6">
      {/* Header */}
      <div>
        <h2 className="text-xl font-bold text-white flex items-center gap-2">
          <Bell className="w-5 h-5 text-amber-400" />
          <span>نظام الإشعارات التحفيزية المخصصة (FCM Notifications)</span>
        </h2>
        <p className="text-sm text-slate-400">
          إشعارات ذكية مبرمجة ومصممة خصيصاً لشخصيتك (طالب حاسبات ومعلومات • شماس أغنسطس • مستثمر في Thndr)
        </p>
      </div>

      {/* Persona Profile Card */}
      <div className="p-4 rounded-2xl bg-linear-to-r from-slate-900 via-indigo-950/30 to-slate-900 border border-indigo-500/30 flex flex-wrap items-center justify-between gap-4">
        <div className="flex items-center gap-3">
          <div className="w-12 h-12 rounded-2xl bg-indigo-600/20 border border-indigo-500/30 flex items-center justify-center text-indigo-400 font-bold text-lg">
            21
          </div>
          <div>
            <h3 className="text-sm font-bold text-white">البروفايل المستهدف للإشعارات</h3>
            <p className="text-xs text-slate-300 mt-0.5">
              شاب ٢١ سنة • حاسبات ومعلومات (مشروع تخرج) • شماس أغنسطس وخادم • مستثمر Thndr (10,000 ج.م)
            </p>
          </div>
        </div>

        <div className="flex items-center gap-2">
          <span className="text-[11px] px-2.5 py-1 rounded-full bg-blue-500/10 text-blue-400 border border-blue-500/20 font-semibold">
            🎓 مشروع التخرج
          </span>
          <span className="text-[11px] px-2.5 py-1 rounded-full bg-amber-500/10 text-amber-400 border border-amber-500/20 font-semibold">
            ⛪ شماس أغنسطس
          </span>
          <span className="text-[11px] px-2.5 py-1 rounded-full bg-emerald-500/10 text-emerald-400 border border-emerald-500/20 font-semibold">
            📈 Thndr Portfolio
          </span>
        </div>
      </div>

      {/* Preset Custom Notification Templates */}
      <div className="space-y-3">
        <h3 className="text-sm font-bold text-white flex items-center gap-2">
          <Sparkles className="w-4 h-4 text-amber-400" />
          <span>القوالب التحفيزية المجهزة (انقر للإرسال الفوري عبر FCM):</span>
        </h3>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
          {presetTemplates.map((template, idx) => {
            const Icon = template.icon;
            const isSending = sendingId === template.title;
            const isSuccess = sendSuccessId === template.title;

            return (
              <div
                key={idx}
                className="p-4 rounded-2xl bg-slate-900 border border-slate-800 flex flex-col justify-between gap-3 hover:border-slate-700 transition-all"
              >
                <div>
                  <div className="flex items-center justify-between gap-2 mb-2">
                    <span className={`text-[11px] font-bold px-2 py-0.5 rounded-md flex items-center gap-1 border ${template.color}`}>
                      <Icon className="w-3 h-3" />
                      <span>{template.title.split(' ')[0]}</span>
                    </span>
                    <button
                      onClick={() => handleSendNotification(template)}
                      disabled={isSending}
                      className="flex items-center gap-1 px-3 py-1 rounded-lg bg-blue-600 hover:bg-blue-500 text-white text-xs font-semibold cursor-pointer shadow-md shadow-blue-600/20 disabled:opacity-50 transition-all"
                    >
                      {isSending ? (
                        <span>جارِ الإرسال...</span>
                      ) : isSuccess ? (
                        <>
                          <CheckCircle2 className="w-3.5 h-3.5 text-emerald-300" />
                          <span>تم الإرسال!</span>
                        </>
                      ) : (
                        <>
                          <Send className="w-3.5 h-3.5" />
                          <span>إرسال للجهاز</span>
                        </>
                      )}
                    </button>
                  </div>

                  <h4 className="text-xs font-bold text-white mb-1">{template.title}</h4>
                  <p className="text-xs text-slate-300 leading-relaxed">{template.body}</p>
                </div>
              </div>
            );
          })}
        </div>
      </div>

      {/* Custom Notification Form */}
      <form
        onSubmit={handleCreateCustom}
        className="p-4 rounded-2xl bg-slate-900 border border-slate-800 space-y-3"
      >
        <h4 className="text-xs font-bold text-white flex items-center gap-2">
          <Plus className="w-4 h-4 text-blue-400" />
          <span>إضافة وتخصيص إشعار دفع جديد (Custom Notification):</span>
        </h4>

        <div className="grid grid-cols-1 sm:grid-cols-3 gap-3">
          <input
            type="text"
            value={customTitle}
            onChange={(e) => setCustomTitle(e.target.value)}
            placeholder="عنوان الإشعار..."
            className="px-3 py-2 rounded-xl bg-slate-950 border border-slate-800 text-xs text-white focus:outline-none focus:border-blue-500"
          />

          <input
            type="text"
            value={customBody}
            onChange={(e) => setCustomBody(e.target.value)}
            placeholder="نص الإشعار التحفيزي..."
            className="px-3 py-2 rounded-xl bg-slate-950 border border-slate-800 text-xs text-white focus:outline-none focus:border-blue-500 sm:col-span-1"
          />

          <div className="flex gap-2">
            <select
              value={customType}
              onChange={(e) => setCustomType(e.target.value as any)}
              className="flex-1 px-3 py-2 rounded-xl bg-slate-950 border border-slate-800 text-xs text-slate-200 focus:outline-none cursor-pointer"
            >
              <option value="graduation">مشروع التخرج</option>
              <option value="church_service">خدمة وصلاة أجبية</option>
              <option value="thndr">استثمار Thndr</option>
              <option value="deep_focus">تركيز عميق</option>
            </select>

            <button
              type="submit"
              disabled={!customTitle.trim() || !customBody.trim()}
              className="px-4 py-2 rounded-xl bg-blue-600 hover:bg-blue-500 disabled:opacity-50 text-white text-xs font-semibold cursor-pointer shadow-md shadow-blue-600/20"
            >
              حفظ
            </button>
          </div>
        </div>
      </form>
    </div>
  );
};

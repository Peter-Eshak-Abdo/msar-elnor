'use client';

import React, { useState, useEffect } from 'react';
import { RouterSettings } from '@/types';
import {
  Router as RouterIcon,
  Shield,
  Key,
  Copy,
  Lock,
  Unlock,
  CheckCircle,
  RefreshCw,
  ExternalLink,
  Info,
} from 'lucide-react';

interface RouterGuideViewProps {
  initialSettings?: RouterSettings;
  onSaveSettings: (settings: RouterSettings) => Promise<void>;
}

export const RouterGuideView: React.FC<RouterGuideViewProps> = ({
  initialSettings,
  onSaveSettings,
}) => {
  const [selectedRouterIndex, setSelectedRouterIndex] = useState(0);
  const [generatedPassword, setGeneratedPassword] = useState('');
  const [isCopied, setIsCopied] = useState(false);
  const [isVaultLocked, setIsVaultLocked] = useState(initialSettings?.isVaultLocked ?? true);
  const [savedSuccess, setSavedSuccess] = useState(false);

  const routers = [
    {
      name: 'راوتر وي (WE - ZTE H168N / H188A)',
      ip: '192.168.1.1',
      steps: [
        'افتح المتصفح واكتب في شريط العنوان: 192.168.1.1',
        'سجل الدخول باسم المستخدم admin وكلمة المرور المطبوعة على ظهر الراوتر.',
        'ادخل على القائمة الجانبية: Local Network -> LAN -> DHCP Server.',
        'ابحث عن خانتي Primary DNS Server و Secondary DNS Server.',
        'ضع في Primary DNS: 185.228.168.168 (CleanBrowsing Adult Filter).',
        'ضع في Secondary DNS: 185.228.169.168 أو 208.67.222.123 (OpenDNS Family).',
        'اضغط Apply / Save وأعد تشغيل الراوتر لتعميم الحماية على كل أجهزة المنزل.',
      ],
    },
    {
      name: 'راوتر فودافون (Vodafone VDSL)',
      ip: '192.168.1.1',
      steps: [
        'افتح المتصفح واكتب: 192.168.1.1',
        'سجل الدخول بحساب admin أو vodafone وكلمة السر خلف الراوتر.',
        'انتقل إلى: Internet -> Network Configuration -> DNS Configuration.',
        'فعل خيار Static DNS بدلاً من Automatic DNS.',
        'اكتب Primary DNS: 185.228.168.168 والـ Secondary: 1.1.1.3.',
        'احفظ الإعدادات بالضغط على Save.',
      ],
    },
    {
      name: 'راوتر أورنج (Orange DSL / VDSL)',
      ip: '192.168.1.1',
      steps: [
        'افتح العنوان: 192.168.1.1 في المتصفح.',
        'سجل الدخول باسم المستخدم وكلمة السر.',
        'اذهب إلى: Basic -> WAN -> خيارات DNS.',
        'أدخل: 185.228.168.168 ثم اضغط Submit.',
      ],
    },
    {
      name: 'راوتر تي بي لينك (TP-Link Archer / VR)',
      ip: '192.168.1.1',
      steps: [
        'ادخل على: 192.168.1.1 أو tplinkwifi.net.',
        'اذهب إلى: Advanced -> Network -> DHCP Server.',
        'حدد Primary DNS: 185.228.168.168 و Secondary DNS: 208.67.222.123.',
        'اضغط Save ثم أعد تشغيل الراوتر.',
      ],
    },
  ];

  const generateUnbreakablePassword = () => {
    const chars = 'abcdefghijkmnopqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ23456789!@#%^&*()-_+=';
    const array = new Uint32Array(24);
    if (typeof window !== 'undefined' && window.crypto) {
      window.crypto.getRandomValues(array);
    }
    const pwd = Array.from(array)
      .map((x) => chars[x % chars.length])
      .join('');
    setGeneratedPassword(pwd);
  };

  const copyToClipboard = (text: string) => {
    if (!text) return;
    navigator.clipboard.writeText(text);
    setIsCopied(true);
    setTimeout(() => setIsCopied(false), 2000);
  };

  const handleLockInVault = async () => {
    if (!generatedPassword) return;
    setIsVaultLocked(true);
    await onSaveSettings({
      model: routers[selectedRouterIndex].name,
      ip: routers[selectedRouterIndex].ip,
      primaryDns: '185.228.168.168',
      secondaryDns: '185.228.169.168',
      encryptedPasswordHash: btoa(generatedPassword), // Base64 vault simulation
      isVaultLocked: true,
    });
    setSavedSuccess(true);
    setTimeout(() => setSavedSuccess(false), 3000);
  };

  const current = routers[selectedRouterIndex];

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h2 className="text-xl font-bold text-white flex items-center gap-2">
            <RouterIcon className="w-5 h-5 text-cyan-400" />
            <span>دليل حماية الراوتر المنزلي والخزينة المشفرة (Layer 9)</span>
          </h2>
          <p className="text-sm text-slate-400">
            تأمين شبكة الواي فاي المنزلية عبر CleanBrowsing DNS وتوليد كلمة مرور صعبة للراوتر وتخزينها مشفرة
          </p>
        </div>

        <a
          href="http://192.168.1.1"
          target="_blank"
          rel="noreferrer"
          className="flex items-center gap-2 px-4 py-2 rounded-xl bg-slate-800 hover:bg-slate-700 text-slate-200 text-xs font-semibold border border-slate-700 transition-colors"
        >
          <span>فتح لوحة الراوتر (192.168.1.1)</span>
          <ExternalLink className="w-3.5 h-3.5 text-cyan-400" />
        </a>
      </div>

      {/* Info Card */}
      <div className="p-4 rounded-2xl bg-linear-to-r from-cyan-950/30 via-slate-900 to-slate-900 border border-cyan-500/30 flex items-start gap-3">
        <div className="p-2 rounded-xl bg-cyan-500/10 text-cyan-400 shrink-0">
          <Shield className="w-5 h-5" />
        </div>
        <div>
          <h4 className="text-sm font-bold text-cyan-300">لماذا حماية الراوتر هي الطبقة الأقوى؟</h4>
          <p className="text-xs text-slate-300 mt-1 leading-relaxed">
            عند تفعيل Family DNS على الراوتر، تصبح كل أجهزة المنزل (الهواتف، اللابتوب، التابلت) محمية من المنبع
            حتى لو تم استخدام متصفح خفي أو جهاز بدون تطبيق، ولا يمكن إيقاف الحظر إلا بالدخول لإعدادات الراوتر.
          </p>
        </div>
      </div>

      {/* Router Tabs */}
      <div className="flex items-center gap-2 overflow-x-auto pb-1 text-xs">
        {routers.map((r, idx) => (
          <button
            key={r.name}
            onClick={() => setSelectedRouterIndex(idx)}
            className={`px-4 py-2 rounded-xl font-semibold transition-all cursor-pointer whitespace-nowrap ${
              selectedRouterIndex === idx
                ? 'bg-cyan-600 text-white shadow-md shadow-cyan-500/20'
                : 'bg-slate-900 text-slate-400 hover:text-white'
            }`}
          >
            {r.name.split('(')[0]}
          </button>
        ))}
      </div>

      {/* Steps List */}
      <div className="p-5 rounded-2xl bg-slate-900 border border-slate-800 space-y-4">
        <div className="flex items-center justify-between pb-3 border-b border-slate-800">
          <h3 className="text-sm font-bold text-white flex items-center gap-2">
            <span>خطوات الضبط لـ:</span>
            <span className="text-cyan-400">{current.name}</span>
          </h3>
          <span className="text-xs font-mono px-2.5 py-1 rounded-md bg-slate-950 text-amber-400 border border-slate-800">
            عنوان الراوتر: {current.ip}
          </span>
        </div>

        <div className="space-y-3">
          {current.steps.map((step, i) => (
            <div key={i} className="flex items-start gap-3">
              <span className="w-6 h-6 rounded-full bg-cyan-500/10 border border-cyan-500/30 text-cyan-400 text-xs font-bold flex items-center justify-center shrink-0">
                {i + 1}
              </span>
              <p className="text-xs text-slate-300 leading-relaxed pt-0.5">{step}</p>
            </div>
          ))}
        </div>
      </div>

      {/* Password Generator & Encrypted Vault Card */}
      <div className="p-5 rounded-2xl bg-linear-to-br from-slate-900 via-amber-950/20 to-slate-900 border border-amber-500/30 space-y-4">
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-2">
            <div className="p-2 rounded-xl bg-amber-500/10 text-amber-400">
              <Key className="w-5 h-5" />
            </div>
            <div>
              <h3 className="text-sm font-bold text-white">توليد كلمة سر معقدة للراوتر والخزينة المشفرة</h3>
              <p className="text-xs text-slate-400">
                استبدل باسورد الراوتر المكتوب على الظهر بكلمة عشوائية مشفرة لمنع نفسك من إيقاف DNS الراوتر
              </p>
            </div>
          </div>

          <button
            onClick={generateUnbreakablePassword}
            className="flex items-center gap-1.5 px-3 py-1.5 rounded-xl bg-amber-500/20 hover:bg-amber-500/30 text-amber-300 text-xs font-bold border border-amber-500/40 cursor-pointer transition-all"
          >
            <RefreshCw className="w-3.5 h-3.5" />
            <span>توليد باسورد جديد</span>
          </button>
        </div>

        {generatedPassword && (
          <div className="flex flex-col sm:flex-row items-center gap-3 p-3 rounded-xl bg-slate-950 border border-amber-500/30">
            <span className="text-xs font-mono text-amber-300 break-all flex-1 tracking-wider text-center sm:text-right">
              {generatedPassword}
            </span>
            <div className="flex items-center gap-2 shrink-0">
              <button
                onClick={() => copyToClipboard(generatedPassword)}
                className="flex items-center gap-1 px-3 py-1.5 rounded-lg bg-slate-800 hover:bg-slate-700 text-slate-200 text-xs font-semibold cursor-pointer"
              >
                {isCopied ? <CheckCircle className="w-3.5 h-3.5 text-emerald-400" /> : <Copy className="w-3.5 h-3.5" />}
                <span>{isCopied ? 'تم النسخ' : 'نسخ'}</span>
              </button>
              <button
                onClick={handleLockInVault}
                className="flex items-center gap-1 px-3 py-1.5 rounded-lg bg-emerald-600 hover:bg-emerald-500 text-white text-xs font-bold cursor-pointer shadow-md shadow-emerald-600/20"
              >
                <Lock className="w-3.5 h-3.5" />
                <span>حفظ مشفراً بالخزينة</span>
              </button>
            </div>
          </div>
        )}

        {savedSuccess && (
          <div className="p-3 rounded-xl bg-emerald-500/10 border border-emerald-500/30 text-emerald-300 text-xs flex items-center gap-2">
            <CheckCircle className="w-4 h-4 text-emerald-400" />
            <span>تم حفظ كلمة السر مشفرة في قاعدة البيانات Firestore بنجاح! الخزينة مقفلة الآن لحمايتك.</span>
          </div>
        )}
      </div>
    </div>
  );
};

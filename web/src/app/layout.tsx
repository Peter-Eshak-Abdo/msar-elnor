import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "مسار النور | Msar Elnor - نظام إدارة المشاريع والمهام والحظر الصارم",
  description: "لوحة تحكم ذكية متكاملة لإدارة المشاريع، مهارات المبيعات، وتوليد الخطط بالذكاء الاصطناعي مع نظام حظر صارم للمشتتات",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="ar" dir="rtl" className="dark">
      <head>
        <link rel="preconnect" href="https://fonts.googleapis.com" />
        <link rel="preconnect" href="https://fonts.gstatic.com" crossOrigin="anonymous" />
        <link
          href="https://fonts.googleapis.com/css2?family=Cairo:wght@300;400;500;600;700;800&display=swap"
          rel="stylesheet"
        />
      </head>
      <body className="min-h-screen bg-[#090d16] text-slate-100 font-['Cairo',sans-serif] selection:bg-blue-600 selection:text-white">
        {children}
      </body>
    </html>
  );
}

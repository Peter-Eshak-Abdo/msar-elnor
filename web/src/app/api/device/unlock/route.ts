import { NextResponse } from 'next/server';
import { getDatabase } from '@/lib/mongodb';

// In-memory fallback if MongoDB connection string is not set
const localTokens: { token: string; createdAt: number; expiresAt: number; used: boolean }[] = [];

export async function GET() {
  try {
    // Generate a secure 6-digit random unlock token valid for 15 minutes
    const token = Math.floor(100000 + Math.random() * 900000).toString();
    const now = Date.now();
    const expiresAt = now + 15 * 60 * 1000; // 15 minutes

    const db = await getDatabase();
    if (db) {
      await db.collection('unlock_tokens').insertOne({
        token,
        createdAt: new Date(now),
        expiresAt: new Date(expiresAt),
        used: false,
      });
    } else {
      localTokens.push({ token, createdAt: now, expiresAt, used: false });
    }

    return NextResponse.json({
      success: true,
      token,
      expiresInMinutes: 15,
      message: 'تم توليد كود فك الحظر المؤقت بنجاح من خادم مسار النور.',
    });
  } catch (error: any) {
    return NextResponse.json(
      { success: false, error: error?.message || 'Failed to generate unlock token' },
      { status: 500 }
    );
  }
}

export async function POST(request: Request) {
  try {
    const { token } = await request.json();

    if (!token) {
      return NextResponse.json(
        { success: false, error: 'Token is required' },
        { status: 400 }
      );
    }

    const now = new Date();
    const db = await getDatabase();

    if (db) {
      const record = await db.collection('unlock_tokens').findOne({
        token,
        used: false,
        expiresAt: { $gt: now },
      });

      if (!record) {
        return NextResponse.json(
          { success: false, error: 'رمز فك الحظر غير صحيح أو منتهي الصلاحية.' },
          { status: 403 }
        );
      }

      await db.collection('unlock_tokens').updateOne(
        { _id: record._id },
        { $set: { used: true, usedAt: now } }
      );

      return NextResponse.json({
        success: true,
        message: 'تم التحقق من كود فك الحظر بنجاح، مصرح للهاتف بإلغاء التقييد مؤقتاً.',
      });
    } else {
      // Check memory store
      const matchIndex = localTokens.findIndex(
        (t) => t.token === token && !t.used && t.expiresAt > Date.now()
      );

      if (matchIndex === -1) {
        return NextResponse.json(
          { success: false, error: 'رمز فك الحظر غير صحيح أو منتهي الصلاحية.' },
          { status: 403 }
        );
      }

      localTokens[matchIndex].used = true;
      return NextResponse.json({
        success: true,
        message: 'تم التحقق من كود فك الحظر بنجاح.',
      });
    }
  } catch (error: any) {
    return NextResponse.json(
      { success: false, error: error?.message || 'Verification error' },
      { status: 500 }
    );
  }
}

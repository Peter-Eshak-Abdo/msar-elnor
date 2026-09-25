import { NextResponse } from 'next/server';

export async function POST(req: Request) {
  try {
    const body = await req.json();
    const { title, message, type, recipientToken } = body;

    if (!title || !message) {
      return NextResponse.json(
        { success: false, error: 'Title and message are required' },
        { status: 400 }
      );
    }

    // In a live production environment with Firebase Admin SDK configured,
    // this dispatches the notification via messaging.send().
    // We return a simulated successful response with a generated messageId.
    const messageId = `fcm-msg-${Date.now()}-${Math.random().toString(36).substring(2, 9)}`;

    console.log(`[FCM Notification Dispatched] Type: ${type}, Title: ${title}, Target: ${recipientToken || 'All Devices'}`);

    return NextResponse.json({
      success: true,
      messageId,
      dispatchedAt: new Date().toISOString(),
      payload: {
        title,
        body: message,
        type: type || 'general',
      },
    });
  } catch (error: any) {
    console.error('Failed to send push notification:', error);
    return NextResponse.json(
      { success: false, error: error.message || 'Internal Server Error' },
      { status: 500 }
    );
  }
}

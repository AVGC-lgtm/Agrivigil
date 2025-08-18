import { NextRequest, NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';
import bcrypt from 'bcryptjs';
import { signJwtToken } from '@/lib/auth';
import { handleCors } from '@/lib/cors';

export async function POST(req: NextRequest) {
  const corsResponse = handleCors(req);
  if (corsResponse) return corsResponse;

  try {
    const { email, password } = await req.json();

    const user = await prisma.user.findUnique({
      where: { email },
      include: {
        role: {
          select: {
            id: true,
            name: true,
            description: true
          }
        }
      }
    });

    if (!user || !user.password || !bcrypt.compareSync(password, user.password)) {
      return NextResponse.json({ error: 'Invalid credentials' }, { status: 401 });
    }

    const sessionToken = signJwtToken({ userId: user.id });
    const expires = new Date(Date.now() + 60 * 60 * 1000); // 1 hour

    await prisma.session.create({
      data: {
        sessionToken,
        userId: user.id,
        expires,
      },
    });

    const response = NextResponse.json(
      {
        user: { 
          id: user.id, 
          email: user.email, 
          name: user.name,
          officerCode: user.officerCode,
          roleId: user.roleId,
          role: user.role
        },
        token: sessionToken,
        expires: expires.toISOString()
      },
      { status: 200 }
    );

    response.headers.set('Access-Control-Allow-Origin', '*');
    return response;

  } catch (error) {
    console.error('Login Error:', error);
    return NextResponse.json({ error: 'Internal Server Error' }, { status: 500 });
  }
}

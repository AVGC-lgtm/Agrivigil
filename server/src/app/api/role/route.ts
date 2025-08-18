import { NextRequest, NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';

export async function GET() {
  try {
    const role = await prisma.role.findMany({
      select: {
        id: true,
        name: true,
        description: true,
        createdAt: true,
        updatedAt: true
      }
    })
    return NextResponse.json(role)
  } catch (error) {
    console.error('Error fetching role:', error)
    return NextResponse.json({ error: 'Internal server error' }, { status: 500 })
  }
}

export async function POST(request: NextRequest) {
  try {
    const body = await request.json();
    const { id, name, description } = body;

    if (!name) {
      return NextResponse.json(
        { error: "Missing required field: name" },
        { status: 400 }
      );
    }

    let role;

    if (id) {
      // 🔎 Ensure role exists
      const existing = await prisma.role.findUnique({ where: { id } });
      if (!existing) {
        return NextResponse.json({ error: "Role not found" }, { status: 404 });
      }

      // 🔎 Prevent updating to a duplicate name
      const duplicate = await prisma.role.findUnique({ where: { name } });
      if (duplicate && duplicate.id !== id) {
        return NextResponse.json(
          { error: "Role with this name already exists" },
          { status: 409 }
        );
      }

      role = await prisma.role.update({
        where: { id },
        data: { name, description },
        select: {
          id: true,
          name: true,
          description: true,
          createdAt: true,
          updatedAt: true,
        },
      });
    } else {
      // 🔎 Prevent duplicate create
      const existing = await prisma.role.findUnique({ where: { name } });
      if (existing) {
        return NextResponse.json(
          { error: "Role with this name already exists" },
          { status: 409 }
        );
      }

      role = await prisma.role.create({
        data: { name, description },
        select: {
          id: true,
          name: true,
          description: true,
          createdAt: true,
          updatedAt: true,
        },
      });
    }

    return NextResponse.json(role, { status: id ? 200 : 201 });
  } catch (error: any) {
    console.error("Error creating/updating role:", error.message, error);
    return NextResponse.json(
      { error: error.message || "Internal server error" },
      { status: 500 }
    );
  }
}

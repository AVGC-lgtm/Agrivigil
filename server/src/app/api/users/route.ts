import { NextRequest, NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';
import bcrypt from 'bcrypt';

export async function GET(request: NextRequest) {
  try {
    const users = await prisma.user.findMany({
      select: {
        id: true,
        email: true,
        name: true,
        officerCode: true,
        roleId: true,
        role: {
          select: {
            id: true,
            name: true,
            description: true
          }
        },
        createdAt: true,
        updatedAt: true
      }
    })

    return NextResponse.json(users)
  } catch (error) {
    console.error('Error fetching users:', error)
    return NextResponse.json({ error: 'Internal server error' }, { status: 500 })
  }
}

export async function POST(request: NextRequest) {
  try {
    const body = await request.json()
    const { id, email, name, password, roleId, officerCode } = body

    if (!email || !password || !roleId || !officerCode) {
      return NextResponse.json(
        { error: 'Missing required fields' },
        { status: 400 }
      )
    }

    let user

    if (id) {
      // Update existing user
      const updateData: any = { email, name, roleId, officerCode }

      if (password) {
        updateData.password = await bcrypt.hash(password, 12)
      }

      user = await prisma.user.update({
        where: { id },
        data: updateData,
        select: {
          id: true,
          email: true,
          name: true,
          officerCode: true,
          roleId: true,
          role: {
            select: {
              id: true,
              name: true,
              description: true
            }
          },
          createdAt: true,
          updatedAt: true
        }
      })
    } else {
      // Insert new user
      const existingUser = await prisma.user.findUnique({ where: { email } })
      if (existingUser) {
        return NextResponse.json({ error: 'User already exists' }, { status: 409 })
      }

      const hashedPassword = await bcrypt.hash(password, 12)

      user = await prisma.user.create({
        data: { email, name, password: hashedPassword, roleId, officerCode },
        select: {
          id: true,
          email: true,
          name: true,
          roleId: true,
          officerCode: true,
          role: {
            select: {
              id: true,
              name: true,
              description: true
            }
          },
          createdAt: true,
          updatedAt: true
        }
      })
    }

    return NextResponse.json(user, { status: id ? 200 : 201 })
  } catch (error) {
    console.error('Error creating/updating user:', error)
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    )
  }
}

export async function PUT(request: NextRequest) {
  try {
    const body = await request.json()
    const { id, email, name, password, roleId, officerCode } = body

    if (!id || !email || !roleId || !officerCode) {
      return NextResponse.json(
        { error: 'Missing required fields' },
        { status: 400 }
      )
    }

    // Check if user exists
    const existingUser = await prisma.user.findUnique({
      where: { id }
    });

    if (!existingUser) {
      return NextResponse.json(
        { error: 'User not found' },
        { status: 404 }
      )
    }

    // Check if email is already taken by another user
    const emailConflict = await prisma.user.findFirst({
      where: {
        email,
        id: { not: id }
      }
    });

    if (emailConflict) {
      return NextResponse.json(
        { error: 'User with this email already exists' },
        { status: 409 }
      )
    }

    // Update user
    const updateData: any = { email, name, roleId, officerCode }

    if (password) {
      updateData.password = await bcrypt.hash(password, 12)
    }

    const user = await prisma.user.update({
      where: { id },
      data: updateData,
      select: {
        id: true,
        email: true,
        name: true,
        officerCode: true,
        roleId: true,
        role: {
          select: {
            id: true,
            name: true,
            description: true
          }
        },
        createdAt: true,
        updatedAt: true
      }
    });

    return NextResponse.json(user, { status: 200 })
  } catch (error) {
    console.error('Error updating user:', error)
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    )
  }
}

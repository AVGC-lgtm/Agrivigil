import { NextRequest, NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';

export async function GET(request: NextRequest) {
  try {
    // For testing purposes, we'll return a default user and permissions
    // In production, this should be protected and return actual user data
    
    // Get the first available user for testing
    const user = await prisma.user.findFirst({
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
        }
      }
    });

    if (!user) {
      return NextResponse.json({ error: 'No users found in system' }, { status: 404 })
    }

    // Get role permissions for this user's role
    const rolePermissions = await prisma.rolePermission.findMany({
      where: { roleId: user.roleId },
      select: {
        id: true,
        roleId: true,
        menuId: true,
        authType: true
      }
    });

    // Check if permissions exist for this role
    if (!rolePermissions || rolePermissions.length === 0) {
      return NextResponse.json({
        user,
        permissions: {},
        error: `Role permissions not set for role: ${user.role.name}`
      }, { status: 404 });
    }

    // Format permissions for easier consumption
    const formattedPermissions = rolePermissions.reduce((acc, permission) => {
      permission.menuId.forEach((menuId, index) => {
        const authType = permission.authType[index] || 'N';
        acc[menuId] = authType;
      });
      return acc;
    }, {} as Record<string, string>);

    return NextResponse.json({
      user,
      permissions: formattedPermissions
    });
  } catch (error) {
    console.error('Error fetching user permissions:', error)
    return NextResponse.json({ error: 'Internal server error' }, { status: 500 })
  }
}

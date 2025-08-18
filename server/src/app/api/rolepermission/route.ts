import { NextRequest, NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';
import { MENU_DEFINITIONS, AUTH_TYPES } from '@/lib/constants';

export async function GET(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url);
    const roleId = searchParams.get('roleId');

    let rolePermission;
    
    if (roleId) {
      // Get permissions for specific role
      rolePermission = await prisma.rolePermission.findMany({
        where: { roleId },
        select: {
          id: true,
          roleId: true,
          menuId: true,
          authType: true,
          createdAt: true,
          updatedAt: true
        }
      });
    } else {
      // Get all role permissions
      rolePermission = await prisma.rolePermission.findMany({
        select: {
          id: true,
          roleId: true,
          menuId: true,
          authType: true,
          createdAt: true,
          updatedAt: true
        }
      });
    }

    return NextResponse.json(rolePermission)
  } catch (error) {
    console.error('Error fetching rolePermission:', error)
    return NextResponse.json({ error: 'Internal server error' }, { status: 500 })
  }
}

export async function POST(request: NextRequest) {
  try {
    const body = await request.json()
    const { roleId, permissions } = body

    // Validate required fields
    if (!roleId || !permissions) {
      return NextResponse.json(
        { error: 'Missing required fields: roleId or permissions' },
        { status: 400 }
      )
    }

    // Validate permissions structure
    if (typeof permissions !== 'object') {
      return NextResponse.json(
        { error: 'Permissions must be an object with menuId as key and authType as value' },
        { status: 400 }
      )
    }

    // Validate each permission
    const validMenuIds = MENU_DEFINITIONS.map(menu => menu.id);
    const validAuthTypes = Object.values(AUTH_TYPES);

    for (const [menuId, authType] of Object.entries(permissions)) {
      if (!validMenuIds.includes(menuId)) {
        return NextResponse.json(
          { error: `Invalid menuId: ${menuId}` },
          { status: 400 }
        )
      }

      if (!validAuthTypes.includes(authType as string)) {
        return NextResponse.json(
          { error: `Invalid authType for ${menuId}: ${authType}. Must be F (Full), R (Read), or N (None)` },
          { status: 400 }
        )
      }
    }

    // Delete existing permissions for this role
    await prisma.rolePermission.deleteMany({
      where: { roleId }
    });

    // Create new permissions for this role
    const menuIds: string[] = [];
    const authTypes: string[] = [];

    // Add all permissions (including N for None)
    for (const [menuId, authType] of Object.entries(permissions)) {
      menuIds.push(menuId);
      authTypes.push(authType as string);
    }

    // Only create permission record if there are permissions to save
    if (menuIds.length > 0) {
      const rolePermission = await prisma.rolePermission.create({
        data: { 
          roleId, 
          menuId: menuIds, 
          authType: authTypes 
        },
        select: {
          id: true,
          roleId: true,
          menuId: true,
          authType: true,
          createdAt: true,
          updatedAt: true
        }
      });

      return NextResponse.json(rolePermission, { status: 201 })
    } else {
      return NextResponse.json({ message: 'No permissions to save' }, { status: 200 })
    }
  } catch (error) {
    console.error('Error creating/updating rolePermission:', error)
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    )
  }
}

export async function PUT(request: NextRequest) {
  try {
    const body = await request.json()
    const { roleId, permissions } = body

    // Validate required fields
    if (!roleId || !permissions) {
      return NextResponse.json(
        { error: 'Missing required fields: roleId or permissions' },
        { status: 400 }
      )
    }

    // Validate permissions structure
    if (typeof permissions !== 'object') {
      return NextResponse.json(
        { error: 'Permissions must be an object with menuId as key and authType as value' },
        { status: 400 }
      )
    }

    // Validate each permission
    const validMenuIds = MENU_DEFINITIONS.map(menu => menu.id);
    const validAuthTypes = Object.values(AUTH_TYPES);

    for (const [menuId, authType] of Object.entries(permissions)) {
      if (!validMenuIds.includes(menuId)) {
        return NextResponse.json(
          { error: `Invalid menuId: ${menuId}` },
          { status: 400 }
        )
      }

      if (!validAuthTypes.includes(authType as string)) {
        return NextResponse.json(
          { error: `Invalid authType for ${menuId}: ${authType}. Must be F (Full), R (Read), or N (None)` },
          { status: 400 }
        )
      }
    }

    // Delete existing permissions for this role
    await prisma.rolePermission.deleteMany({
      where: { roleId }
    });

    // Create new permissions for this role
    const menuIds: string[] = [];
    const authTypes: string[] = [];

    // Add all permissions (including N for None)
    for (const [menuId, authType] of Object.entries(permissions)) {
      menuIds.push(menuId);
      authTypes.push(authType as string);
    }

    // Only create permission record if there are permissions to save
    if (menuIds.length > 0) {
      const rolePermission = await prisma.rolePermission.create({
        data: { 
          roleId, 
          menuId: menuIds, 
          authType: authTypes 
        },
        select: {
          id: true,
          roleId: true,
          menuId: true,
          authType: true,
          createdAt: true,
          updatedAt: true
        }
      });

      return NextResponse.json(rolePermission, { status: 200 })
    } else {
      return NextResponse.json({ message: 'No permissions to save' }, { status: 200 })
    }
  } catch (error) {
    console.error('Error updating rolePermission:', error)
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    )
  }
}

export async function DELETE(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url);
    const id = searchParams.get('id');
    const roleId = searchParams.get('roleId');

    if (!id && !roleId) {
      return NextResponse.json(
        { error: 'Missing required parameter: id or roleId' },
        { status: 400 }
      )
    }

    if (id) {
      // Delete specific permission by ID
      await prisma.rolePermission.delete({
        where: { id }
      });
    } else if (roleId) {
      // Delete all permissions for a specific role
      await prisma.rolePermission.deleteMany({
        where: { roleId }
      });
    }

    return NextResponse.json({ message: 'Permission deleted successfully' }, { status: 200 })
  } catch (error) {
    console.error('Error deleting rolePermission:', error)
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    )
  }
}

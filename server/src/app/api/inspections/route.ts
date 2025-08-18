
import { NextRequest, NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';
import { requireAuth } from '@/lib/middleware';

export async function GET(request: NextRequest) {
  try {
    const session = await requireAuth(request);
    
    if (!session) {
      return NextResponse.json({ error: 'Unauthorized - Please provide valid authentication token' }, { status: 401 })
    }

    const { searchParams } = new URL(request.url)
    const status = searchParams.get('status')
    const userId = searchParams.get('userId')
    const district = searchParams.get('district')
    const taluka = searchParams.get('taluka')
    const targetType = searchParams.get('targetType')
    const dateFrom = searchParams.get('dateFrom')
    const dateTo = searchParams.get('dateTo')

    const where: any = {}
    
    if (status) {
      where.status = status
    }
    
    if (userId) {
      where.userId = userId
    }

    if (district) {
      where.district = district
    }

    if (taluka) {
      where.taluka = taluka
    }

    if (targetType) {
      where.targetType = targetType
    }

    if (dateFrom || dateTo) {
      where.datetime = {}
      if (dateFrom) {
        where.datetime.gte = dateFrom
      }
      if (dateTo) {
        where.datetime.lte = dateTo
      }
    }

    const inspectionTasks = await prisma.inspectionTask.findMany({
      where,
      include: {
        user: {
          select: {
            id: true,
            name: true,
            email: true,
            role: true
          }
        }
      },
      orderBy: {
        createdAt: 'desc'
      }
    })

    return NextResponse.json(inspectionTasks)
  } catch (error) {
    console.error('Error fetching inspection tasks:', error)
    return NextResponse.json({ error: 'Internal server error' }, { status: 500 })
  }
}

export async function POST(request: NextRequest) {
  try {
    const session = await requireAuth(request);
    
    if (!session) {
      return NextResponse.json({ error: 'Unauthorized - Please provide valid authentication token' }, { status: 401 })
    }

    const body = await request.json()
    const { 
      inspectioncode,
      datetime,
      state,
      district,
      taluka,
      location,
      addressland,
      targetType,
      typeofpremises,
      visitpurpose,
      equipment,
      totaltarget
    } = body

    // Validate required fields
    if (!datetime || !district || !taluka || !location || !targetType) {
      return NextResponse.json({ 
        error: 'Missing required fields: datetime, district, taluka, location, targetType are required' 
      }, { status: 400 })
    }

    // Validate datetime format
    const dateValidation = new Date(datetime)
    if (isNaN(dateValidation.getTime())) {
      return NextResponse.json({ 
        error: 'Invalid datetime format. Please provide a valid date and time.' 
      }, { status: 400 })
    }

    // Generate inspection code if not provided
    const finalInspectionCode = inspectioncode || `INS-${Date.now()}-${Math.random().toString(36).substr(2, 5).toUpperCase()}`

    const inspectionTask = await prisma.inspectionTask.create({
      data: {
        inspectioncode: finalInspectionCode,
        userId: session.userId,
        datetime,
        state: state || 'Maharashtra',
        district,
        taluka,
        location,
        addressland: addressland || '',
        targetType,
        typeofpremises: typeofpremises || [],
        visitpurpose: visitpurpose || [],
        equipment: equipment || [],
        totaltarget: totaltarget || '10',
        achievedtarget: '0',
        status: 'scheduled'
      },
      include: {
        user: {
          select: {
            id: true,
            name: true,
            email: true,
            role: true
          }
        }
      }
    })

    return NextResponse.json(inspectionTask, { status: 201 })
  } catch (error) {
    console.error('Error creating inspection task:', error)
    if (error instanceof Error && error.message.includes('Unique constraint')) {
      return NextResponse.json({ error: 'Inspection code already exists' }, { status: 400 })
    }
    return NextResponse.json({ error: 'Internal server error' }, { status: 500 })
  }
}

export async function PUT(request: NextRequest) {
  try {
    const session = await requireAuth(request);
    
    if (!session) {
      return NextResponse.json({ error: 'Unauthorized - Please provide valid authentication token' }, { status: 401 })
    }

    const body = await request.json()
    const { 
      id,
      datetime,
      state,
      district,
      taluka,
      location,
      addressland,
      targetType,
      typeofpremises,
      visitpurpose,
      equipment,
      totaltarget,
      achievedtarget,
      status
    } = body

    if (!id) {
      return NextResponse.json({ error: 'Inspection ID is required' }, { status: 400 })
    }

    // Check if inspection exists and user has permission
    const existingInspection = await prisma.inspectionTask.findUnique({
      where: { id },
      include: { user: true }
    })

    if (!existingInspection) {
      return NextResponse.json({ error: 'Inspection not found' }, { status: 404 })
    }

    // Only allow updates if user is the owner or has admin role
    if (existingInspection.userId !== session.userId && session.role !== 'ADMIN') {
      return NextResponse.json({ error: 'Unauthorized to update this inspection' }, { status: 403 })
    }

    const updatedInspection = await prisma.inspectionTask.update({
      where: { id },
      data: {
        ...(datetime && { datetime }),
        ...(state && { state }),
        ...(district && { district }),
        ...(taluka && { taluka }),
        ...(location && { location }),
        ...(addressland !== undefined && { addressland }),
        ...(targetType && { targetType }),
        ...(typeofpremises && { typeofpremises }),
        ...(visitpurpose && { visitpurpose }),
        ...(equipment && { equipment }),
        ...(totaltarget && { totaltarget }),
        ...(achievedtarget !== undefined && { achievedtarget }),
        ...(status && { status })
      },
      include: {
        user: {
          select: {
            id: true,
            name: true,
            email: true,
            role: true
          }
        }
      }
    })

    return NextResponse.json(updatedInspection)
  } catch (error) {
    console.error('Error updating inspection task:', error)
    return NextResponse.json({ error: 'Internal server error' }, { status: 500 })
  }
}

export async function DELETE(request: NextRequest) {
  try {
    const session = await requireAuth(request);
    
    if (!session) {
      return NextResponse.json({ error: 'Unauthorized - Please provide valid authentication token' }, { status: 401 })
    }

    const { searchParams } = new URL(request.url)
    const id = searchParams.get('id')

    if (!id) {
      return NextResponse.json({ error: 'Inspection ID is required' }, { status: 400 })
    }

    // Check if inspection exists and user has permission
    const existingInspection = await prisma.inspectionTask.findUnique({
      where: { id },
      include: { user: true }
    })

    if (!existingInspection) {
      return NextResponse.json({ error: 'Inspection not found' }, { status: 404 })
    }

    // Only allow deletion if user is the owner or has admin role
    if (existingInspection.userId !== session.userId && session.role !== 'ADMIN') {
      return NextResponse.json({ error: 'Unauthorized to delete this inspection' }, { status: 403 })
    }

    await prisma.inspectionTask.delete({
      where: { id }
    })

    return NextResponse.json({ message: 'Inspection deleted successfully' })
  } catch (error) {
    console.error('Error deleting inspection task:', error)
    return NextResponse.json({ error: 'Internal server error' }, { status: 500 })
  }
}

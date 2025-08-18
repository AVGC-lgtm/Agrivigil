import { NextRequest, NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';
import { requireAuth } from '@/lib/middleware';
import { Prisma } from '@prisma/client'; 

export async function GET(request: NextRequest) {
  try {
    const session = await requireAuth(request);
    if (!session || !session.userId) {
      return NextResponse.json({ error: 'Unauthorized - Please provide valid authentication token' }, { status: 401 });
    }

    const { searchParams } = new URL(request.url);
    const status = searchParams.get('status');
    const userId = searchParams.get('userId');
    const location = searchParams.get('location');
    const district = searchParams.get('district');
    const taluka = searchParams.get('taluka');
    const fertilizer_type = searchParams.get('fertilizer_type');
    const batch_no = searchParams.get('batch_no');

    const where: Prisma.SeizureWhereInput = {}; 
    if (status) where.status = status;
    if (userId) where.userId = userId;
    if (location) where.location = { contains: location, mode: 'insensitive' };
    if (district) where.district = district;
    if (taluka) where.taluka = taluka;
    if (fertilizer_type) where.fertilizer_type = fertilizer_type;
    if (batch_no) where.batch_no = batch_no;

    const seizures = await prisma.seizure.findMany({
      where,
      include: {
        user: {
          select: { id: true, name: true, email: true, role: true }
        },
        scanResult: true,
        fieldExecution: {
          select: {
            id: true,
            fieldcode: true,
            companyname: true,
            productname: true,
            dealer_name: true,
            fertilizer_type: true,
            batch_no: true
          }
        },
        labSamples: {
          include: {
            user: { select: { id: true, name: true, email: true, role: true } }
          }
        },
        firCases: {
          include: {
            user: { select: { id: true, name: true, email: true, role: true } }
          }
        }
      },
      orderBy: { createdAt: 'desc' }
    });

    return NextResponse.json(seizures);
  } catch (error) {
    console.error('Error fetching seizures:', error);
    return NextResponse.json({ error: 'Internal server error' }, { status: 500 });
  }
}

export async function POST(request: NextRequest) {
  try {
    const session = await requireAuth(request);
    if (!session || !session.userId) {
      return NextResponse.json({ error: 'Unauthorized - Please provide valid authentication token' }, { status: 401 });
    }

    const body = await request.json();
    const {
      seizurecode,
      fieldExecutionId,
      location,
      district,
      taluka,
      premises_type,
      fertilizer_type,
      batch_no,
      quantity,
      estimatedValue,
      witnessName,
      evidencePhotos,
      videoEvidence,
      remarks,
      seizure_date,
      memo_no,
      officer_name,
      scanResultId
    } = body;

    // Validate required fields
    if (!fieldExecutionId || !location || !district || !quantity || !estimatedValue) {
      return NextResponse.json({ 
        error: 'Missing required fields: fieldExecutionId, location, district, quantity, estimatedValue are required' 
      }, { status: 400 });
    }

    // Check if field execution exists
    const fieldExecution = await prisma.fieldExecution.findUnique({
      where: { id: parseInt(fieldExecutionId) }
    });

    if (!fieldExecution) {
      return NextResponse.json({ error: 'Field execution not found' }, { status: 404 });
    }

    // Generate seizure code if not provided
    const finalSeizureCode = seizurecode || `SEZ-${Date.now()}-${Math.random().toString(36).substr(2, 5).toUpperCase()}`;

    const seizure = await prisma.seizure.create({
      data: {
        seizurecode: finalSeizureCode,
        fieldExecutionId: parseInt(fieldExecutionId),
        location,
        district,
        taluka: taluka || null,
        premises_type: premises_type || [],
        fertilizer_type: fertilizer_type || null,
        batch_no: batch_no || null,
        quantity: parseFloat(quantity),
        estimatedValue,
        witnessName: witnessName || null,
        evidencePhotos: evidencePhotos || [],
        videoEvidence: videoEvidence || null,
        status: 'pending',
        remarks: remarks || null,
        seizure_date: seizure_date ? new Date(seizure_date) : null,
        memo_no: memo_no || null,
        officer_name: officer_name || null,
        userId: session.userId,
        scanResultId: scanResultId || null
      },
      include: {
        user: {
          select: { id: true, name: true, email: true, role: true }
        },
        scanResult: true,
        fieldExecution: {
          select: {
            id: true,
            fieldcode: true,
            companyname: true,
            productname: true,
            dealer_name: true,
            fertilizer_type: true,
            batch_no: true
          }
        }
      }
    });

    return NextResponse.json(seizure, { status: 201 });
  } catch (error) {
    console.error('Error creating seizure:', error);
    if (error instanceof Error && error.message.includes('Unique constraint')) {
      return NextResponse.json({ error: 'Seizure code already exists' }, { status: 400 });
    }
    return NextResponse.json({ error: 'Internal server error' }, { status: 500 });
  }
}

export async function PUT(request: NextRequest) {
  try {
    const session = await requireAuth(request);
    if (!session || !session.userId) {
      return NextResponse.json({ error: 'Unauthorized - Please provide valid authentication token' }, { status: 401 });
    }

    const body = await request.json();
    const {
      id,
      location,
      district,
      taluka,
      premises_type,
      fertilizer_type,
      batch_no,
      quantity,
      estimatedValue,
      witnessName,
      evidencePhotos,
      videoEvidence,
      status,
      remarks,
      seizure_date,
      memo_no,
      officer_name
    } = body;

    if (!id) {
      return NextResponse.json({ error: 'Seizure ID is required' }, { status: 400 });
    }

    // Check if seizure exists and user has permission
    const existingSeizure = await prisma.seizure.findUnique({
      where: { id },
      include: { user: true }
    });

    if (!existingSeizure) {
      return NextResponse.json({ error: 'Seizure not found' }, { status: 404 });
    }

    // Only allow updates if user is the owner or has admin role
    if (existingSeizure.userId !== session.userId && session.role !== 'ADMIN') {
      return NextResponse.json({ error: 'Unauthorized to update this seizure' }, { status: 403 });
    }

    const updatedSeizure = await prisma.seizure.update({
      where: { id },
      data: {
        ...(location && { location }),
        ...(district && { district }),
        ...(taluka !== undefined && { taluka }),
        ...(premises_type && { premises_type }),
        ...(fertilizer_type !== undefined && { fertilizer_type }),
        ...(batch_no !== undefined && { batch_no }),
        ...(quantity && { quantity: parseFloat(quantity) }),
        ...(estimatedValue && { estimatedValue }),
        ...(witnessName !== undefined && { witnessName }),
        ...(evidencePhotos && { evidencePhotos }),
        ...(videoEvidence !== undefined && { videoEvidence }),
        ...(status && { status }),
        ...(remarks !== undefined && { remarks }),
        ...(seizure_date && { seizure_date: new Date(seizure_date) }),
        ...(memo_no !== undefined && { memo_no }),
        ...(officer_name !== undefined && { officer_name })
      },
      include: {
        user: {
          select: { id: true, name: true, email: true, role: true }
        },
        scanResult: true,
        fieldExecution: {
          select: {
            id: true,
            fieldcode: true,
            companyname: true,
            productname: true,
            dealer_name: true,
            fertilizer_type: true,
            batch_no: true
          }
        }
      }
    });

    return NextResponse.json(updatedSeizure);
  } catch (error) {
    console.error('Error updating seizure:', error);
    return NextResponse.json({ error: 'Internal server error' }, { status: 500 });
  }
}

export async function DELETE(request: NextRequest) {
  try {
    const session = await requireAuth(request);
    if (!session || !session.userId) {
      return NextResponse.json({ error: 'Unauthorized - Please provide valid authentication token' }, { status: 401 });
    }

    const { searchParams } = new URL(request.url);
    const id = searchParams.get('id');

    if (!id) {
      return NextResponse.json({ error: 'Seizure ID is required' }, { status: 400 });
    }

    // Check if seizure exists and user has permission
    const existingSeizure = await prisma.seizure.findUnique({
      where: { id },
      include: { user: true }
    });

    if (!existingSeizure) {
      return NextResponse.json({ error: 'Seizure not found' }, { status: 404 });
    }

    // Only allow deletion if user is the owner or has admin role
    if (existingSeizure.userId !== session.userId && session.role !== 'ADMIN') {
      return NextResponse.json({ error: 'Unauthorized to delete this seizure' }, { status: 403 });
    }

    await prisma.seizure.delete({
      where: { id }
    });

    return NextResponse.json({ message: 'Seizure deleted successfully' });
  } catch (error) {
    console.error('Error deleting seizure:', error);
    return NextResponse.json({ error: 'Internal server error' }, { status: 500 });
  }
}

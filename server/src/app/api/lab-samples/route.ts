
import { NextRequest, NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';
import { requireAuth } from '@/lib/middleware';
import { Prisma } from '@prisma/client'; 

export async function GET(request: NextRequest) {
  try {
    // 🔐 Authentication
    const session = await requireAuth(request);
    if (!session) {
      return NextResponse.json(
        { error: "Unauthorized - Please provide valid authentication token" },
        { status: 401 }
      );
    }

    // 🔍 Query Params
    const { searchParams } = new URL(request.url);
    const status = searchParams.get("status");
    const userId = searchParams.get("userId");
    const sampleType = searchParams.get("sampleType");
    const labDestination = searchParams.get("labDestination");
    const seizureId = searchParams.get("seizureId");
    const testType = searchParams.get("testType");

    // 📌 Filters
    const where: Prisma.LabSampleWhereInput = {};
    if (status) where.status = status;
    if (userId) where.userId = userId;
    if (sampleType) where.sampleType = sampleType;
    if (labDestination) where.labDestination = labDestination;
    if (seizureId) where.seizureId = seizureId;
    if (testType) where.testType = testType;

    // 📦 Fetch Lab Samples
    const labSamples = await prisma.labSample.findMany({
      where,
      include: {
        user: {
          select: {
            id: true,
            name: true,
            email: true,
            role: {
              select: {
                id: true,
                name: true,
              },
            },
          },
        },
        seizure: {
          include: {
            scanResult: true,
            fieldExecution: {
              select: {
                id: true,
                fieldcode: true,
                companyname: true,
                productname: true,
                dealer_name: true,
                fertilizer_type: true,
                batch_no: true,
              },
            },
            user: {
              select: {
                id: true,
                name: true,
                email: true,
                role: {
                  select: {
                    id: true,
                    name: true,
                  },
                },
              },
            },
          },
        },
        firCases: {
          include: {
            user: {
              select: {
                id: true,
                name: true,
                email: true,
                role: {
                  select: {
                    id: true,
                    name: true,
                  },
                },
              },
            },
          },
        },
      },
      orderBy: {
        collected_at: "desc", // ✅ FIX: createdAt ऐवजी योग्य field वापरलं
      },
    });

    // ✅ Response
    return NextResponse.json(labSamples);
  } catch (error) {
    console.error("Error fetching lab samples:", error);
    return NextResponse.json(
      { error: "Internal server error", details: String(error) },
      { status: 500 }
    );
  }
}

export async function POST(request: NextRequest) {
  try {
    const session = await requireAuth(request);
    
    if (!session) {
      return NextResponse.json({ error: 'Unauthorized - Please provide valid authentication token' }, { status: 401 });
    }

    const body = await request.json();
    const { 
      sampleType,
      labDestination,
      seizureId,
      testType,
      sampleCode,
      sampleWeight,
      sampleDescription,
      specialInstructions,
      expectedResults,
      priority
    } = body;

    // Validate required fields
    if (!sampleType || !labDestination || !seizureId) {
      return NextResponse.json({ 
        error: 'Missing required fields: sampleType, labDestination, seizureId are required' 
      }, { status: 400 });
    }

    // Verify seizure exists
    const seizure = await prisma.seizure.findUnique({
      where: { id: seizureId }
    });

    if (!seizure) {
      return NextResponse.json({ error: 'Seizure not found' }, { status: 404 });
    }

    // Generate sample code if not provided
    const finalSampleCode = sampleCode || `LS-${Date.now()}-${Math.random().toString(36).substr(2, 5).toUpperCase()}`;

    const labSample = await prisma.labSample.create({
      data: {
        samplecode: finalSampleCode,
        department: labDestination || 'General Lab',
        sample_desc: sampleDescription || 'Lab sample for testing',
        district: 'Maharashtra', // Default value, can be made dynamic
        status: 'pending',
        userId: session.userId,
        seizureId: seizureId || null
      },
      include: {
        user: {
          select: {
            id: true,
            name: true,
            email: true,
            role: true
          }
        },
        seizure: {
          select: {
            id: true,
            seizurecode: true,
            location: true,
            quantity: true,
            status: true
          }
        }
      }
    });

    return NextResponse.json(labSample, { status: 201 });
  } catch (error) {
    console.error('Error creating lab sample:', error);
    if (error instanceof Error && error.message.includes('Unique constraint')) {
      return NextResponse.json({ error: 'Sample code already exists' }, { status: 400 });
    }
    return NextResponse.json({ error: 'Internal server error' }, { status: 500 });
  }
}

export async function PUT(request: NextRequest) {
  try {
    const session = await requireAuth(request);
    
    if (!session) {
      return NextResponse.json({ error: 'Unauthorized - Please provide valid authentication token' }, { status: 401 });
    }

    const body = await request.json();
    const {
      id,
      sampleType,
      labDestination,
      testType,
      sampleCode,
      sampleWeight,
      sampleDescription,
      specialInstructions,
      expectedResults,
      priority,
      status,
      testResults,
      testDate,
      analystName,
      remarks
    } = body;

    if (!id) {
      return NextResponse.json({ error: 'Lab sample ID is required' }, { status: 400 });
    }

    // Check if lab sample exists and user has permission
    const existingLabSample = await prisma.labSample.findUnique({
      where: { id },
      include: { user: true }
    });

    if (!existingLabSample) {
      return NextResponse.json({ error: 'Lab sample not found' }, { status: 404 });
    }

    // Only allow updates if user is the owner or has admin role
    if (existingLabSample.userId !== session.userId && session.role !== 'ADMIN') {
      return NextResponse.json({ error: 'Unauthorized to update this lab sample' }, { status: 403 });
    }

    const updatedLabSample = await prisma.labSample.update({
      where: { id },
      data: {
        ...(sampleType && { sampleType }),
        ...(labDestination && { labDestination }),
        ...(testType !== undefined && { testType }),
        ...(sampleCode && { sampleCode }),
        ...(sampleWeight !== undefined && { sampleWeight: parseFloat(sampleWeight) }),
        ...(sampleDescription !== undefined && { sampleDescription }),
        ...(specialInstructions !== undefined && { specialInstructions }),
        ...(expectedResults !== undefined && { expectedResults }),
        ...(priority && { priority }),
        ...(status && { status }),
        ...(testResults !== undefined && { testResults }),
        ...(testDate && { testDate: new Date(testDate) }),
        ...(analystName !== undefined && { analystName }),
        ...(remarks !== undefined && { remarks })
      },
      include: {
        user: {
          select: {
            id: true,
            name: true,
            email: true,
            role: true
          }
        },
        seizure: {
          include: {
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
        }
      }
    });

    return NextResponse.json(updatedLabSample);
  } catch (error) {
    console.error('Error updating lab sample:', error);
    return NextResponse.json({ error: 'Internal server error' }, { status: 500 });
  }
}

export async function DELETE(request: NextRequest) {
  try {
    const session = await requireAuth(request);
    
    if (!session) {
      return NextResponse.json({ error: 'Unauthorized - Please provide valid authentication token' }, { status: 401 });
    }

    const { searchParams } = new URL(request.url);
    const id = searchParams.get('id');

    if (!id) {
      return NextResponse.json({ error: 'Lab sample ID is required' }, { status: 400 });
    }

    // Check if lab sample exists and user has permission
    const existingLabSample = await prisma.labSample.findUnique({
      where: { id },
      include: { user: true }
    });

    if (!existingLabSample) {
      return NextResponse.json({ error: 'Lab sample not found' }, { status: 404 });
    }

    // Only allow deletion if user is the owner or has admin role
    if (existingLabSample.userId !== session.userId && session.role !== 'ADMIN') {
      return NextResponse.json({ error: 'Unauthorized to delete this lab sample' }, { status: 403 });
    }

    await prisma.labSample.delete({
      where: { id }
    });

    return NextResponse.json({ message: 'Lab sample deleted successfully' });
  } catch (error) {
    console.error('Error deleting lab sample:', error);
    return NextResponse.json({ error: 'Internal server error' }, { status: 500 });
  }
}

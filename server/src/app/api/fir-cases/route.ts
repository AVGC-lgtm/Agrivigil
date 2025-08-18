import { NextRequest, NextResponse } from 'next/server';
import { prisma } from '@/lib/prisma';
import { requireAuth } from '@/lib/middleware';
import { Prisma } from '@prisma/client'; 

export async function GET() {
  try {
    const firCases = await prisma.fIRCase.findMany({
      include: {
        user: {
          select: {
            id: true,
            name: true,
            email: true,
            role: {
              select: { id: true, name: true },
            },
          },
        },
        // ✅ FIRCase -> Seizure[] (Capital S required)
        Seizure: {
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
                  select: { id: true, name: true },
                },
              },
            },
          },
        },
        labSample: {
          include: {
            user: {
              select: {
                id: true,
                name: true,
                email: true,
                role: {
                  select: { id: true, name: true },
                },
              },
            },
            // ✅ LabSample -> seizure relation (check small `seizure`)
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
              },
            },
          },
        },
      },
    });

    return NextResponse.json(firCases, { status: 200 });
  } catch (error: any) {
    console.error("❌ Error fetching FIR Cases:", error);
    return NextResponse.json(
      {
        error: "Internal server error",
        details: error.message,
      },
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
      labReportId, 
      violationType, 
      accused, 
      location, 
      caseNotes, 
      courtDate, 
      seizureId, 
      labSampleId,
      caseNumber,
      policeStation,
      investigatingOfficer,
      evidenceDetails,
      witnessStatements,
      legalRepresentation,
      priority
    } = body;

    // Validate required fields
    if (!violationType || !accused || !location) {
      return NextResponse.json({ 
        error: 'Missing required fields: violationType, accused, location are required' 
      }, { status: 400 });
    }

    // Verify seizure exists if provided
    if (seizureId) {
      const seizure = await prisma.seizure.findUnique({
        where: { id: seizureId }
      });
      if (!seizure) {
        return NextResponse.json({ error: 'Seizure not found' }, { status: 404 });
      }
    }

    // Verify lab sample exists if provided
    if (labSampleId) {
      const labSample = await prisma.labSample.findUnique({
        where: { id: labSampleId }
      });
      if (!labSample) {
        return NextResponse.json({ error: 'Lab sample not found' }, { status: 404 });
      }
    }

    // Generate case number if not provided
    const finalCaseNumber = caseNumber || `FIR-${Date.now()}-${Math.random().toString(36).substr(2, 5).toUpperCase()}`;
    
    // Generate fircode - similar format to caseNumber but with FIR prefix
    const firCode = `FIR-${Date.now()}-${Math.random().toString(36).substr(2, 5).toUpperCase()}`;

    const firCase = await prisma.fIRCase.create({
      data: {
        fircode: firCode,
        police_station: policeStation || 'Unknown Police Station',
        accused_party: accused,
        suspect_name: accused, // Using accused as suspect_name
        entity_type: 'Individual', // Default value
        district: 'Maharashtra', // Default value, can be made dynamic
        state: 'Maharashtra', // Default value
        violation_type: violationType ? [violationType] : [], // Convert to array
        evidence: evidenceDetails || null,
        remarks: caseNotes || null,
        userId: session.userId,
        labSampleId: labSampleId || null
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
        labSample: {
          select: {
            id: true,
            samplecode: true,
            department: true,
            sample_desc: true,
            district: true,
            status: true
          }
        }
      }
    });

    return NextResponse.json(firCase, { status: 201 });
  } catch (error) {
    console.error('Error creating FIR case:', error);
    if (error instanceof Error && error.message.includes('Unique constraint')) {
      return NextResponse.json({ error: 'Case number already exists' }, { status: 400 });
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
      labReportId,
      violationType,
      accused,
      location,
      caseNumber,
      policeStation,
      investigatingOfficer,
      evidenceDetails,
      witnessStatements,
      legalRepresentation,
      priority,
      status,
      caseNotes,
      courtDate
    } = body;

    if (!id) {
      return NextResponse.json({ error: 'FIR case ID is required' }, { status: 400 });
    }

    // Check if FIR case exists and user has permission
    const existingFIRCase = await prisma.fIRCase.findUnique({
      where: { id },
      include: { user: true }
    });

    if (!existingFIRCase) {
      return NextResponse.json({ error: 'FIR case not found' }, { status: 404 });
    }

    // Only allow updates if user is the owner or has admin role
    if (existingFIRCase.userId !== session.userId && session.role !== 'ADMIN') {
      return NextResponse.json({ error: 'Unauthorized to update this FIR case' }, { status: 403 });
    }

    const updatedFIRCase = await prisma.fIRCase.update({
      where: { id },
      data: {
        ...(labReportId !== undefined && { labReportId }),
        ...(violationType && { violationType }),
        ...(accused && { accused }),
        ...(location && { location }),
        ...(caseNumber && { caseNumber }),
        ...(policeStation !== undefined && { policeStation }),
        ...(investigatingOfficer !== undefined && { investigatingOfficer }),
        ...(evidenceDetails !== undefined && { evidenceDetails }),
        ...(witnessStatements !== undefined && { witnessStatements }),
        ...(legalRepresentation !== undefined && { legalRepresentation }),
        ...(priority && { priority }),
        ...(status && { status }),
        ...(caseNotes !== undefined && { caseNotes }),
        ...(courtDate && { courtDate: new Date(courtDate) })
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
        },
        labSample: {
          include: {
            seizure: {
              include: {
                scanResult: true,
                fieldExecution: {
                  select: {
                    id: true,
                    fieldcode: true,
                    companyname: true,
                    productname: true,
                    fertilizer_type: true,
                    batch_no: true
                  }
                }
              }
            }
          }
        }
      }
    });

    return NextResponse.json(updatedFIRCase);
  } catch (error) {
    console.error('Error updating FIR case:', error);
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
      return NextResponse.json({ error: 'FIR case ID is required' }, { status: 400 });
    }

    // Check if FIR case exists and user has permission
    const existingFIRCase = await prisma.fIRCase.findUnique({
      where: { id },
      include: { user: true }
    });

    if (!existingFIRCase) {
      return NextResponse.json({ error: 'FIR case not found' }, { status: 404 });
    }

    // Only allow deletion if user is the owner or has admin role
    if (existingFIRCase.userId !== session.userId && session.role !== 'ADMIN') {
      return NextResponse.json({ error: 'Unauthorized to delete this FIR case' }, { status: 403 });
    }

    await prisma.fIRCase.delete({
      where: { id }
    });

    return NextResponse.json({ message: 'FIR case deleted successfully' });
  } catch (error) {
    console.error('Error deleting FIR case:', error);
    return NextResponse.json({ error: 'Internal server error' }, { status: 500 });
  }
}

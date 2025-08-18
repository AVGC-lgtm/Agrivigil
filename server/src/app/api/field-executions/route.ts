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
    const inspectionid = searchParams.get('inspectionid')
    const userid = searchParams.get('userid')
    const companyname = searchParams.get('companyname')
    const productname = searchParams.get('productname')
    const dealer_name = searchParams.get('dealer_name')
    const fertilizer_type = searchParams.get('fertilizer_type')
    const status = searchParams.get('status')

    const where: any = {}
    
    if (inspectionid) {
      where.inspectionid = inspectionid
    }
    
    if (userid) {
      where.userid = userid
    }

    if (companyname) {
      where.companyname = { contains: companyname, mode: 'insensitive' }
    }

    if (productname) {
      where.productname = { contains: productname, mode: 'insensitive' }
    }

    if (dealer_name) {
      where.dealer_name = { contains: dealer_name, mode: 'insensitive' }
    }

    if (fertilizer_type) {
      where.fertilizer_type = fertilizer_type
    }

    if (status) {
      where.status = status
    }

    const fieldExecutions = await prisma.fieldExecution.findMany({
      where,
      include: {
        inspectiontask: {
          select: {
            id: true,
            inspectioncode: true,
            location: true,
            district: true,
            taluka: true,
            targetType: true,
            status: true
          }
        },
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
        id: 'desc'
      }
    })

    return NextResponse.json(fieldExecutions)
  } catch (error) {
    console.error('Error fetching field executions:', error)
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
      inspectionid,
      companyname,
      productname,
      dealer_name,
      registration_no,
      sampling_date,
      fertilizer_type,
      batch_no,
      manufacture_import_date,
      stock_receipt_date,
      sample_code,
      stock_position,
      physical_condition,
      specification_fco,
      composition_analysis,
      variation,
      moisture,
      total_n,
      nh4n,
      nh4no3n,
      urea_n,
      total_p2o5,
      nac_soluble_p2o5,
      citric_soluble_p2o5,
      water_soluble_p2o5,
      water_soluble_k2o,
      particle_size,
      document,
      productphoto
    } = body

    // Validate required fields
    if (!inspectionid || !companyname || !productname || !dealer_name || !fertilizer_type) {
      return NextResponse.json({ 
        error: 'Missing required fields: inspectionid, companyname, productname, dealer_name, fertilizer_type are required' 
      }, { status: 400 })
    }

    // Check if inspection exists
    const inspection = await prisma.inspectionTask.findUnique({
      where: { id: inspectionid }
    })

    if (!inspection) {
      return NextResponse.json({ error: 'Inspection not found' }, { status: 404 })
    }

    // Generate field code
    const fieldcode = `FE-${Date.now()}-${Math.random().toString(36).substr(2, 5).toUpperCase()}`

    const fieldExecution = await prisma.fieldExecution.create({
      data: {
        inspectionid,
        fieldcode,
        companyname,
        productname,
        dealer_name,
        registration_no: registration_no || null,
        sampling_date: sampling_date ? new Date(sampling_date) : null,
        fertilizer_type,
        batch_no: batch_no || null,
        manufacture_import_date: manufacture_import_date ? new Date(manufacture_import_date) : null,
        stock_receipt_date: stock_receipt_date ? new Date(stock_receipt_date) : null,
        sample_code: sample_code || null,
        stock_position: stock_position || null,
        physical_condition: physical_condition || null,
        specification_fco: specification_fco || null,
        composition_analysis: composition_analysis || null,
        variation: variation || null,
        moisture: moisture ? parseFloat(moisture) : null,
        total_n: total_n ? parseFloat(total_n) : null,
        nh4n: nh4n ? parseFloat(nh4n) : null,
        nh4no3n: nh4no3n ? parseFloat(nh4no3n) : null,
        urea_n: urea_n ? parseFloat(urea_n) : null,
        total_p2o5: total_p2o5 ? parseFloat(total_p2o5) : null,
        nac_soluble_p2o5: nac_soluble_p2o5 ? parseFloat(nac_soluble_p2o5) : null,
        citric_soluble_p2o5: citric_soluble_p2o5 ? parseFloat(citric_soluble_p2o5) : null,
        water_soluble_p2o5: water_soluble_p2o5 ? parseFloat(water_soluble_p2o5) : null,
        water_soluble_k2o: water_soluble_k2o ? parseFloat(water_soluble_k2o) : null,
        particle_size: particle_size || null,
        document: document || '',
        productphoto: productphoto || '',
        userid: session.userId
      },
      include: {
        inspectiontask: {
          select: {
            id: true,
            inspectioncode: true,
            location: true,
            district: true,
            taluka: true,
            targetType: true,
            status: true
          }
        },
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

    return NextResponse.json(fieldExecution, { status: 201 })
  } catch (error) {
    console.error('Error creating field execution:', error)
    if (error instanceof Error && error.message.includes('Unique constraint')) {
      return NextResponse.json({ error: 'Field code already exists' }, { status: 400 })
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
      companyname,
      productname,
      dealer_name,
      registration_no,
      sampling_date,
      fertilizer_type,
      batch_no,
      manufacture_import_date,
      stock_receipt_date,
      sample_code,
      stock_position,
      physical_condition,
      specification_fco,
      composition_analysis,
      variation,
      moisture,
      total_n,
      nh4n,
      nh4no3n,
      urea_n,
      total_p2o5,
      nac_soluble_p2o5,
      citric_soluble_p2o5,
      water_soluble_p2o5,
      water_soluble_k2o,
      particle_size,
      document,
      productphoto
    } = body

    if (!id) {
      return NextResponse.json({ error: 'Field execution ID is required' }, { status: 400 })
    }

    // Check if field execution exists and user has permission
    const existingFieldExecution = await prisma.fieldExecution.findUnique({
      where: { id: parseInt(id) },
      include: { user: true }
    })

    if (!existingFieldExecution) {
      return NextResponse.json({ error: 'Field execution not found' }, { status: 404 })
    }

    // Only allow updates if user is the owner or has admin role
    if (existingFieldExecution.userid !== session.userId && session.role !== 'ADMIN') {
      return NextResponse.json({ error: 'Unauthorized to update this field execution' }, { status: 403 })
    }

    const updatedFieldExecution = await prisma.fieldExecution.update({
      where: { id: parseInt(id) },
      data: {
        ...(companyname && { companyname }),
        ...(productname && { productname }),
        ...(dealer_name && { dealer_name }),
        ...(registration_no !== undefined && { registration_no }),
        ...(sampling_date && { sampling_date: new Date(sampling_date) }),
        ...(fertilizer_type && { fertilizer_type }),
        ...(batch_no !== undefined && { batch_no }),
        ...(manufacture_import_date && { manufacture_import_date: new Date(manufacture_import_date) }),
        ...(stock_receipt_date && { stock_receipt_date: new Date(stock_receipt_date) }),
        ...(sample_code !== undefined && { sample_code }),
        ...(stock_position !== undefined && { stock_position }),
        ...(physical_condition !== undefined && { physical_condition }),
        ...(specification_fco !== undefined && { specification_fco }),
        ...(composition_analysis !== undefined && { composition_analysis }),
        ...(variation !== undefined && { variation }),
        ...(moisture !== undefined && { moisture: parseFloat(moisture) }),
        ...(total_n !== undefined && { total_n: parseFloat(total_n) }),
        ...(nh4n !== undefined && { nh4n: parseFloat(nh4n) }),
        ...(nh4no3n !== undefined && { nh4no3n: parseFloat(nh4no3n) }),
        ...(urea_n !== undefined && { urea_n: parseFloat(urea_n) }),
        ...(total_p2o5 !== undefined && { total_p2o5: parseFloat(total_p2o5) }),
        ...(nac_soluble_p2o5 !== undefined && { nac_soluble_p2o5: parseFloat(nac_soluble_p2o5) }),
        ...(citric_soluble_p2o5 !== undefined && { citric_soluble_p2o5: parseFloat(citric_soluble_p2o5) }),
        ...(water_soluble_p2o5 !== undefined && { water_soluble_p2o5: parseFloat(water_soluble_p2o5) }),
        ...(water_soluble_k2o !== undefined && { water_soluble_k2o: parseFloat(water_soluble_k2o) }),
        ...(particle_size !== undefined && { particle_size }),
        ...(document !== undefined && { document }),
        ...(productphoto !== undefined && { productphoto })
      },
      include: {
        inspectiontask: {
          select: {
            id: true,
            inspectioncode: true,
            location: true,
            district: true,
            taluka: true,
            targetType: true,
            status: true
          }
        },
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

    return NextResponse.json(updatedFieldExecution)
  } catch (error) {
    console.error('Error updating field execution:', error)
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
      return NextResponse.json({ error: 'Field execution ID is required' }, { status: 400 })
    }

    // Check if field execution exists and user has permission
    const existingFieldExecution = await prisma.fieldExecution.findUnique({
      where: { id: parseInt(id) },
      include: { user: true }
    })

    if (!existingFieldExecution) {
      return NextResponse.json({ error: 'Field execution not found' }, { status: 404 })
    }

    // Only allow deletion if user is the owner or has admin role
    if (existingFieldExecution.userid !== session.userId && session.role !== 'ADMIN') {
      return NextResponse.json({ error: 'Unauthorized to delete this field execution' }, { status: 403 })
    }

    await prisma.fieldExecution.delete({
      where: { id: parseInt(id) }
    })

    return NextResponse.json({ message: 'Field execution deleted successfully' })
  } catch (error) {
    console.error('Error deleting field execution:', error)
    return NextResponse.json({ error: 'Internal server error' }, { status: 500 })
  }
}

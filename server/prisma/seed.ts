import { PrismaClient } from '@prisma/client'
import bcrypt from 'bcryptjs'
import { USER_ROLES } from '../src/lib/constants'

const prisma = new PrismaClient()

async function main() {
  console.log('🌱 Starting database seeding...')

  // Hash default password
  const hashedPassword = await bcrypt.hash('password123', 12)

  // Create default users
  const users = [
    { email: 'dao@agrishield.com', name: 'District Agricultural Officer', password: hashedPassword, role: USER_ROLES.DAO },
    { email: 'field@agrishield.com', name: 'Field Officer', password: hashedPassword, role: USER_ROLES.FIELD_OFFICER },
    { email: 'legal@agrishield.com', name: 'Legal Officer', password: hashedPassword, role: USER_ROLES.LEGAL_OFFICER },
    { email: 'lab@agrishield.com', name: 'Lab Coordinator', password: hashedPassword, role: USER_ROLES.LAB_COORDINATOR },
    { email: 'hq@agrishield.com', name: 'HQ Monitoring', password: hashedPassword, role: USER_ROLES.HQ_MONITORING },
    { email: 'admin@agrishield.com', name: 'District Admin', password: hashedPassword, role: USER_ROLES.DISTRICT_ADMIN },
  ]

  console.log('👥 Creating users...')
  for (const userData of users) {
    const user = await prisma.user.upsert({
      where: { email: userData.email },
      update: {},
      create: userData,
    })
    console.log(`✅ Created user: ${user.email}`)
  }

  // Sample inspection tasks
  console.log('📋 Creating sample inspection tasks...')
  const daoUser = await prisma.user.findUnique({ where: { email: 'dao@agrishield.com' } })
  const fieldUser = await prisma.user.findUnique({ where: { email: 'field@agrishield.com' } })

  if (daoUser && fieldUser) {
    const inspections = [
      {
        inspectioncode: 'INS-20240115-001',
        userId: daoUser.id,
        datetime: '2024-01-15T10:00:00Z',
        state: 'Maharashtra',
        district: 'Pune',
        taluka: 'Pune City',
        location: 'Market Area, District Center',
        addressland: 'Near Central Market, Main Street',
        targetType: 'retailer',
        typeofpremises: ['Retail Fertilizer Shop'],
        visitpurpose: ['Routine'],
        equipment: ['TruScan Device', 'Gemini Analyzer', 'Axon Body Cam'],
        totaltarget: '10',
        achievedtarget: '0',
        status: 'scheduled'
      },
      {
        inspectioncode: 'INS-20240116-001',
        userId: fieldUser.id,
        datetime: '2024-01-16T14:00:00Z',
        state: 'Maharashtra',
        district: 'Pune',
        taluka: 'Hinjewadi',
        location: 'Agricultural Warehouse, Sector 5',
        addressland: 'Industrial Area, Plot No. 45',
        targetType: 'warehouse',
        typeofpremises: ['Warehouse (Private / Govt/CWC/Co-op)'],
        visitpurpose: ['Routine', 'Sample Collection'],
        equipment: ['TruScan Device', 'Sample Collection Kit', 'GPS Tracker'],
        totaltarget: '15',
        achievedtarget: '8',
        status: 'in-progress'
      },
      {
        inspectioncode: 'INS-20240114-001',
        userId: fieldUser.id,
        datetime: '2024-01-14T09:00:00Z',
        state: 'Maharashtra',
        district: 'Pune',
        taluka: 'Shivaji Nagar',
        location: 'Farmer Cooperative, Village A',
        addressland: 'Village Center, Near Temple',
        targetType: 'distributor',
        typeofpremises: ['Distributor\'s Office / Depot'],
        visitpurpose: ['Follow-up'],
        equipment: ['TruScan Device', 'Axon Body Cam'],
        totaltarget: '8',
        achievedtarget: '8',
        status: 'completed'
      },
    ]

    for (const task of inspections) {
      await prisma.inspectionTask.create({ data: task })
      console.log(`✅ Created inspection task: ${task.inspectioncode}`)
    }
  }

  // Sample scan results and seizures
  console.log('🔍 Creating sample scan results and seizures...')
  const uplSaafProduct = await prisma.product.findFirst({ where: { company: 'UPL', name: 'Saaf' } })
  if (uplSaafProduct && fieldUser) {
    const scanResult = await prisma.scanResult.create({
      data: {
        company: 'UPL',
        product: 'Saaf',
        batchNumber: 'UPL-SAAF-202401-12345',
        authenticityScore: 25.5,
        issues: ['Poor print quality', 'Missing hologram', 'Incorrect packaging'],
        recommendation: 'Suspected Counterfeit',
        geoLocation: '28.6139, 77.2090',
        timestamp: new Date().toISOString(),
        productId: uplSaafProduct.id,
      },
    })

    const seizure = await prisma.seizure.create({
      data: {
        quantity: '50 packets (100g each)',
        estimatedValue: '6000',
        witnessName: 'Ram Kumar (Shop Owner)',
        evidencePhotos: ['/uploads/evidence1.jpg', '/uploads/evidence2.jpg'],
        videoEvidence: '/uploads/seizure_video.mp4',
        status: 'pending',
        userId: fieldUser.id,
        scanResultId: scanResult.id,
      },
    })

    // Lab sample
    const labUser = await prisma.user.findUnique({ where: { email: 'lab@agrishield.com' } })
    if (labUser) {
      const labSample = await prisma.labSample.create({
        data: {
          sampleType: 'Pesticide Sample',
          labDestination: 'Central Agricultural Lab',
          status: 'testing',
          userId: labUser.id,
          seizureId: seizure.id,
        },
      })

      // FIR case
      const legalUser = await prisma.user.findUnique({ where: { email: 'legal@agrishield.com' } })
      if (legalUser) {
        await prisma.fIRCase.create({
          data: {
            labReportId: 'LAB-RPT-2024-001',
            violationType: 'Sale of Counterfeit Pesticides',
            accused: 'Shop Owner - Ram Kumar',
            location: 'Market Area, District Center',
            status: 'draft',
            caseNotes: 'Counterfeit UPL Saaf pesticide found during routine inspection',
            userId: legalUser.id,
            seizureId: seizure.id,
            labSampleId: labSample.id,
          },
        })
        console.log(`✅ Created FIR case`)
      }
    }

    console.log(`✅ Created seizure: ${seizure.id}`)
  }

  // Create sample field executions
  const inspectionTask1 = await prisma.inspectionTask.findFirst({ where: { inspectioncode: 'INS-20240115-001' } });
  const inspectionTask2 = await prisma.inspectionTask.findFirst({ where: { inspectioncode: 'INS-20240116-001' } });
  const inspectionTask3 = await prisma.inspectionTask.findFirst({ where: { inspectioncode: 'INS-20240114-001' } });

  if (inspectionTask1 && inspectionTask2 && inspectionTask3) {
    const fieldOfficer = await prisma.user.findUnique({ where: { email: 'field@agrishield.com' } });
    if (fieldOfficer) {
      const fieldExecution1 = await prisma.fieldExecution.create({
        data: {
          inspectionid: inspectionTask1.id,
          fieldcode: "FE-20250115-001",
          companyname: "UPL Limited",
          productname: "UPL Fertilizer NPK 20:20:20",
          dealer_name: "ABC Agro Center",
          registration_no: "REG123456",
          sampling_date: new Date("2025-01-15"),
          fertilizer_type: "NPK",
          batch_no: "BATCH2025001",
          manufacture_import_date: new Date("2025-01-01"),
          stock_receipt_date: new Date("2025-01-10"),
          sample_code: "SAMP001",
          stock_position: "Good",
          physical_condition: "Excellent",
          specification_fco: "FCO-1985",
          composition_analysis: "N: 20%, P: 20%, K: 20%",
          variation: "Within limits",
          moisture: 2.5,
          total_n: 20.0,
          nh4n: 15.0,
          nh4no3n: 5.0,
          urea_n: 0.0,
          total_p2o5: 20.0,
          nac_soluble_p2o5: 18.0,
          citric_soluble_p2o5: 2.0,
          water_soluble_p2o5: 20.0,
          water_soluble_k2o: 20.0,
          particle_size: "Standard",
          document: "uploaded",
          productphoto: "uploaded",
          userid: fieldOfficer.id,
        },
      });

      const fieldExecution2 = await prisma.fieldExecution.create({
        data: {
          inspectionid: inspectionTask2.id,
          fieldcode: "FE-20250116-001",
          companyname: "IFFCO",
          productname: "IFFCO Urea 46-0-0",
          dealer_name: "XYZ Fertilizer Store",
          registration_no: "REG789012",
          sampling_date: new Date("2025-01-16"),
          fertilizer_type: "Urea",
          batch_no: "BATCH2025002",
          manufacture_import_date: new Date("2025-01-05"),
          stock_receipt_date: new Date("2025-01-12"),
          sample_code: "SAMP002",
          stock_position: "Fair",
          physical_condition: "Good",
          specification_fco: "FCO-1985",
          composition_analysis: "N: 46%",
          variation: "Within limits",
          moisture: 1.8,
          total_n: 46.0,
          nh4n: 0.0,
          nh4no3n: 0.0,
          urea_n: 46.0,
          total_p2o5: 0.0,
          nac_soluble_p2o5: 0.0,
          citric_soluble_p2o5: 0.0,
          water_soluble_p2o5: 0.0,
          water_soluble_k2o: 0.0,
          particle_size: "Standard",
          document: "uploaded",
          productphoto: "uploaded",
          userid: fieldOfficer.id,
        },
      });

      const fieldExecution3 = await prisma.fieldExecution.create({
        data: {
          inspectionid: inspectionTask3.id,
          fieldcode: "FE-20250117-001",
          companyname: "Coromandel International",
          productname: "Coromandel DAP 18:46:0",
          dealer_name: "PQR Agro Solutions",
          registration_no: "REG345678",
          sampling_date: new Date("2025-01-17"),
          fertilizer_type: "DAP",
          batch_no: "BATCH2025003",
          manufacture_import_date: new Date("2025-01-08"),
          stock_receipt_date: new Date("2025-01-14"),
          sample_code: "SAMP003",
          stock_position: "Excellent",
          physical_condition: "Excellent",
          specification_fco: "FCO-1985",
          composition_analysis: "N: 18%, P: 46%",
          variation: "Within limits",
          moisture: 1.2,
          total_n: 18.0,
          nh4n: 18.0,
          nh4no3n: 0.0,
          urea_n: 0.0,
          total_p2o5: 46.0,
          nac_soluble_p2o5: 44.0,
          citric_soluble_p2o5: 2.0,
          water_soluble_p2o5: 46.0,
          water_soluble_k2o: 0.0,
          particle_size: "Standard",
          document: "uploaded",
          productphoto: "uploaded",
          userid: fieldOfficer.id,
        },
      });

      console.log('✅ Sample field executions created');
    }
  }

  // Create sample seizures
  let seizure1, seizure2, seizure3;
  
  if (fieldExecution1 && fieldExecution2 && fieldExecution3) {
    seizure1 = await prisma.seizure.create({
      data: {
        seizurecode: "SEZ-20250115-001",
        fieldExecutionId: fieldExecution1.id,
        location: "Pune City Market Area",
        district: "Pune",
        taluka: "Pune City",
        premises_type: ["Retail Fertilizer Shop"],
        fertilizer_type: "NPK",
        batch_no: "BATCH2025001",
        quantity: 500.0,
        estimatedValue: "₹25,000",
        witnessName: "Rajesh Kumar",
        evidencePhotos: ["photo1.jpg", "photo2.jpg"],
        videoEvidence: "video1.mp4",
        status: "pending",
        remarks: "Suspicious packaging found",
        seizure_date: new Date("2025-01-15"),
        memo_no: "MEMO001",
        officer_name: "Priya Sharma",
        userId: fieldOfficer.id,
      },
    });

    seizure2 = await prisma.seizure.create({
      data: {
        seizurecode: "SEZ-20250116-001",
        fieldExecutionId: fieldExecution2.id,
        location: "Hinjewadi Industrial Area",
        district: "Pune",
        taluka: "Hinjewadi",
        premises_type: ["Distributor's Office / Depot"],
        fertilizer_type: "Urea",
        batch_no: "BATCH2025002",
        quantity: 1000.0,
        estimatedValue: "₹35,000",
        witnessName: "Suresh Patil",
        evidencePhotos: ["photo3.jpg"],
        videoEvidence: null,
        status: "under-investigation",
        remarks: "Expired product found",
        seizure_date: new Date("2025-01-16"),
        memo_no: "MEMO002",
        officer_name: "Suresh Patil",
        userId: fieldOfficer.id,
      },
    });

    seizure3 = await prisma.seizure.create({
      data: {
        seizurecode: "SEZ-20250117-001",
        fieldExecutionId: fieldExecution3.id,
        location: "Koregaon Park Market",
        district: "Pune",
        taluka: "Koregaon Park",
        premises_type: ["Wholesale Fertilizer Dealer"],
        fertilizer_type: "DAP",
        batch_no: "BATCH2025003",
        quantity: 750.0,
        estimatedValue: "₹45,000",
        witnessName: "Amit Shah",
        evidencePhotos: ["photo4.jpg", "photo5.jpg", "photo6.jpg"],
        videoEvidence: "video2.mp4",
        status: "case-filed",
        remarks: "Counterfeit product suspected",
        seizure_date: new Date("2025-01-17"),
        memo_no: "MEMO003",
        officer_name: "Amit Shah",
        userId: fieldOfficer.id,
      },
    });

    console.log('✅ Sample seizures created');
  }

  // Create sample lab samples
  let labSample1, labSample2, labSample3;
  
  if (seizure1 && seizure2 && seizure3) {
    labSample1 = await prisma.labSample.create({
      data: {
        samplecode: "LS-20250115-001",
        department: "Chemistry Lab",
        sample_desc: "NPK Fertilizer Sample from UPL Limited - Suspicious packaging",
        district: "Pune",
        status: "pending",
        collected_at: new Date("2025-01-15"),
        dispatched_at: new Date("2025-01-16"),
        received_at: new Date("2025-01-17"),
        under_testing: true,
        result_status: "Analysis in Progress",
        report_sent_at: null,
        officer_name: "Dr. Priya Sharma",
        remarks: "Handle with care - potential contamination",
        userId: fieldOfficer.id,
        seizureId: seizure1.id,
      },
    });

    labSample2 = await prisma.labSample.create({
      data: {
        samplecode: "LS-20250116-001",
        department: "Microbiology Lab",
        sample_desc: "Urea Sample from IFFCO - Expired product",
        district: "Pune",
        status: "in-transit",
        collected_at: new Date("2025-01-16"),
        dispatched_at: new Date("2025-01-17"),
        received_at: new Date("2025-01-18"),
        under_testing: false,
        result_status: "Sample Received",
        report_sent_at: null,
        officer_name: "Dr. Suresh Patil",
        remarks: "Check for microbial contamination",
        userId: fieldOfficer.id,
        seizureId: seizure2.id,
      },
    });

    labSample3 = await prisma.labSample.create({
      data: {
        samplecode: "LS-20250117-001",
        department: "Quality Control",
        sample_desc: "DAP Sample from Coromandel International - Counterfeit suspected",
        district: "Pune",
        status: "received",
        collected_at: new Date("2025-01-17"),
        dispatched_at: new Date("2025-01-18"),
        received_at: new Date("2025-01-19"),
        under_testing: true,
        result_status: "Under Analysis",
        report_sent_at: null,
        officer_name: "Dr. Amit Shah",
        remarks: "Verify authenticity and purity",
        userId: fieldOfficer.id,
        seizureId: seizure3.id,
      },
    });

    console.log('✅ Sample lab samples created');
  }

  // Create sample FIR cases
  if (seizure1 && seizure2 && seizure3 && labSample1 && labSample2 && labSample3) {
    const firCase1 = await prisma.fIRCase.create({
      data: {
        fircode: "FIR-20250115-001",
        police_station: "Pune City Police Station",
        accused_party: "UPL Limited",
        suspect_name: "Rajesh Kumar",
        entity_type: "Company",
        street1: "123 Main Street",
        street2: "Industrial Area",
        village: "Pune City",
        district: "Pune",
        state: "Maharashtra",
        license_no: "LIC123456",
        contact_no: "+91-9876543210",
        brand_name: "UPL Fertilizer",
        fertilizer_type: "NPK",
        batch_no: "BATCH2025001",
        manufacture_date: new Date("2025-01-01"),
        expiry_date: new Date("2026-01-01"),
        violation_type: ["Counterfeit", "Quality Standards"],
        evidence: "Lab analysis report confirms counterfeit NPK fertilizer",
        remarks: "Case filed based on lab analysis and witness statements",
        userId: fieldOfficer.id,
        labSampleId: labSample1.id,
      },
    });

    const firCase2 = await prisma.fIRCase.create({
      data: {
        fircode: "FIR-20250116-001",
        police_station: "Hinjewadi Police Station",
        accused_party: "IFFCO",
        suspect_name: "Suresh Patil",
        entity_type: "Distributor",
        street1: "456 Industrial Road",
        street2: "Warehouse Complex",
        village: "Hinjewadi",
        district: "Pune",
        state: "Maharashtra",
        license_no: "LIC789012",
        contact_no: "+91-9876543211",
        brand_name: "IFFCO Urea",
        fertilizer_type: "Urea",
        batch_no: "BATCH2025002",
        manufacture_date: new Date("2024-12-01"),
        expiry_date: new Date("2025-06-01"),
        violation_type: ["Expired Product", "Storage Violation"],
        evidence: "Physical inspection confirms expired urea products",
        remarks: "Expired products found in storage, investigation ongoing",
        userId: fieldOfficer.id,
        labSampleId: labSample2.id,
      },
    });

    const firCase3 = await prisma.fIRCase.create({
      data: {
        fircode: "FIR-20250117-001",
        police_station: "Koregaon Park Police Station",
        accused_party: "Coromandel International",
        suspect_name: "Amit Shah",
        entity_type: "Company",
        street1: "789 Market Street",
        street2: "Commercial Area",
        village: "Koregaon Park",
        district: "Pune",
        state: "Maharashtra",
        license_no: "LIC345678",
        contact_no: "+91-9876543212",
        brand_name: "Coromandel DAP",
        fertilizer_type: "DAP",
        batch_no: "BATCH2025003",
        manufacture_date: new Date("2025-01-08"),
        expiry_date: new Date("2026-01-08"),
        violation_type: ["Quality Standards", "Documentation Fraud"],
        evidence: "Lab analysis shows substandard DAP fertilizer",
        remarks: "Substandard DAP fertilizer suspected, case preparation in progress",
        userId: fieldOfficer.id,
        labSampleId: labSample3.id,
      },
    });

    console.log('✅ Sample FIR cases created');
  }

  console.log('🎉 Database seeding completed successfully!')
}

main()
  .catch((e) => {
    console.error('❌ Error during seeding:', e)
    process.exit(1)
  })
  .finally(async () => {
    await prisma.$disconnect()
  })

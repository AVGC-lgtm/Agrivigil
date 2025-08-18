-- CreateTable
CREATE TABLE "public"."accounts" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "type" TEXT NOT NULL,
    "provider" TEXT NOT NULL,
    "providerAccountId" TEXT NOT NULL,
    "refresh_token" TEXT,
    "access_token" TEXT,
    "expires_at" INTEGER,
    "token_type" TEXT,
    "scope" TEXT,
    "id_token" TEXT,
    "session_state" TEXT,

    CONSTRAINT "accounts_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."sessions" (
    "id" TEXT NOT NULL,
    "sessionToken" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "expires" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "sessions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."verificationtokens" (
    "identifier" TEXT NOT NULL,
    "token" TEXT NOT NULL,
    "expires" TIMESTAMP(3) NOT NULL
);

-- CreateTable
CREATE TABLE "public"."audit_logs" (
    "id" TEXT NOT NULL,
    "action" TEXT NOT NULL,
    "entity" TEXT NOT NULL,
    "entityId" TEXT NOT NULL,
    "oldData" JSONB,
    "newData" JSONB,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "userId" TEXT NOT NULL,

    CONSTRAINT "audit_logs_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."roles" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "description" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "roles_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."role_permissions" (
    "id" TEXT NOT NULL,
    "roleId" TEXT,
    "menuId" TEXT NOT NULL,
    "authType" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "role_permissions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."users" (
    "id" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "name" TEXT,
    "officerCode" TEXT,
    "password" TEXT NOT NULL,
    "roleId" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "users_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."inspection_tasks" (
    "id" TEXT NOT NULL,
    "inspectioncode" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "datetime" TEXT NOT NULL,
    "state" TEXT NOT NULL,
    "district" TEXT NOT NULL,
    "taluka" TEXT NOT NULL,
    "location" TEXT NOT NULL,
    "addressland" TEXT NOT NULL,
    "targetType" TEXT NOT NULL,
    "typeofpremises" TEXT[],
    "visitpurpose" TEXT[],
    "equipment" TEXT[],
    "totaltarget" TEXT NOT NULL,
    "achievedtarget" TEXT NOT NULL,
    "status" TEXT NOT NULL DEFAULT 'scheduled',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "inspection_tasks_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."field_executions" (
    "id" SERIAL NOT NULL,
    "inspectionid" TEXT NOT NULL,
    "fieldcode" TEXT NOT NULL,
    "companyname" TEXT NOT NULL,
    "productname" TEXT NOT NULL,
    "dealer_name" TEXT NOT NULL,
    "registration_no" TEXT,
    "sampling_date" TIMESTAMP(3),
    "fertilizer_type" TEXT NOT NULL,
    "batch_no" TEXT,
    "manufacture_import_date" TIMESTAMP(3),
    "stock_receipt_date" TIMESTAMP(3),
    "sample_code" TEXT,
    "stock_position" TEXT,
    "physical_condition" TEXT,
    "specification_fco" TEXT,
    "composition_analysis" TEXT,
    "variation" TEXT,
    "moisture" DECIMAL(5,2),
    "total_n" DECIMAL(5,2),
    "nh4n" DECIMAL(5,2),
    "nh4no3n" DECIMAL(5,2),
    "urea_n" DECIMAL(5,2),
    "total_p2o5" DECIMAL(5,2),
    "nac_soluble_p2o5" DECIMAL(5,2),
    "citric_soluble_p2o5" DECIMAL(5,2),
    "water_soluble_p2o5" DECIMAL(5,2),
    "water_soluble_k2o" DECIMAL(5,2),
    "particle_size" TEXT,
    "document" TEXT NOT NULL,
    "productphoto" TEXT NOT NULL,
    "userid" TEXT NOT NULL,

    CONSTRAINT "field_executions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."seizures" (
    "id" TEXT NOT NULL,
    "seizurecode" TEXT NOT NULL,
    "fieldExecutionId" INTEGER NOT NULL,
    "location" TEXT NOT NULL,
    "district" TEXT NOT NULL,
    "taluka" TEXT,
    "premises_type" TEXT[],
    "fertilizer_type" TEXT,
    "batch_no" TEXT,
    "quantity" DECIMAL(10,2),
    "estimatedValue" TEXT,
    "witnessName" TEXT,
    "evidencePhotos" TEXT[],
    "videoEvidence" TEXT,
    "status" TEXT NOT NULL DEFAULT 'pending',
    "remarks" TEXT,
    "seizure_date" TIMESTAMP(3),
    "memo_no" TEXT,
    "officer_name" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "userId" TEXT NOT NULL,
    "scanResultId" TEXT,

    CONSTRAINT "seizures_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."lab_samples" (
    "id" SERIAL NOT NULL,
    "samplecode" TEXT NOT NULL,
    "department" TEXT NOT NULL,
    "sample_desc" TEXT NOT NULL,
    "district" TEXT NOT NULL,
    "status" TEXT NOT NULL,
    "collected_at" TIMESTAMP(3),
    "dispatched_at" TIMESTAMP(3),
    "received_at" TIMESTAMP(3),
    "under_testing" BOOLEAN NOT NULL DEFAULT false,
    "result_status" TEXT,
    "report_sent_at" TIMESTAMP(3),
    "officer_name" TEXT,
    "remarks" TEXT,
    "userId" TEXT NOT NULL,
    "seizureId" TEXT,

    CONSTRAINT "lab_samples_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."fir_cases" (
    "id" SERIAL NOT NULL,
    "fircode" TEXT NOT NULL,
    "police_station" TEXT NOT NULL,
    "accused_party" TEXT NOT NULL,
    "suspect_name" TEXT NOT NULL,
    "entity_type" TEXT NOT NULL,
    "street1" TEXT,
    "street2" TEXT,
    "village" TEXT,
    "district" TEXT NOT NULL,
    "state" TEXT NOT NULL,
    "license_no" TEXT,
    "contact_no" TEXT,
    "brand_name" TEXT,
    "fertilizer_type" TEXT,
    "batch_no" TEXT,
    "manufacture_date" TIMESTAMP(3),
    "expiry_date" TIMESTAMP(3),
    "violation_type" TEXT[],
    "evidence" TEXT,
    "remarks" TEXT,
    "userId" TEXT NOT NULL,
    "labSampleId" INTEGER,

    CONSTRAINT "fir_cases_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."files" (
    "id" TEXT NOT NULL,
    "filename" TEXT NOT NULL,
    "originalName" TEXT NOT NULL,
    "mimetype" TEXT NOT NULL,
    "size" INTEGER NOT NULL,
    "path" TEXT NOT NULL,
    "url" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "files_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."products" (
    "id" TEXT NOT NULL,
    "category" TEXT NOT NULL,
    "company" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "activeIngredient" TEXT,
    "composition" TEXT,
    "packaging" TEXT[],
    "batchFormat" TEXT,
    "commonCounterfeitMarkers" TEXT[],
    "mrp" JSONB,
    "hologramFeatures" TEXT[],
    "bagColor" TEXT,
    "subsidizedRate" DOUBLE PRECISION,
    "varieties" TEXT[],
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "products_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."scan_results" (
    "id" TEXT NOT NULL,
    "company" TEXT NOT NULL,
    "product" TEXT NOT NULL,
    "batchNumber" TEXT NOT NULL,
    "authenticityScore" DOUBLE PRECISION NOT NULL,
    "issues" TEXT[],
    "recommendation" TEXT NOT NULL,
    "geoLocation" TEXT NOT NULL,
    "timestamp" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "productId" TEXT,

    CONSTRAINT "scan_results_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "public"."_FIRCaseToSeizure" (
    "A" INTEGER NOT NULL,
    "B" TEXT NOT NULL,

    CONSTRAINT "_FIRCaseToSeizure_AB_pkey" PRIMARY KEY ("A","B")
);

-- CreateIndex
CREATE UNIQUE INDEX "accounts_provider_providerAccountId_key" ON "public"."accounts"("provider", "providerAccountId");

-- CreateIndex
CREATE UNIQUE INDEX "sessions_sessionToken_key" ON "public"."sessions"("sessionToken");

-- CreateIndex
CREATE UNIQUE INDEX "verificationtokens_token_key" ON "public"."verificationtokens"("token");

-- CreateIndex
CREATE UNIQUE INDEX "verificationtokens_identifier_token_key" ON "public"."verificationtokens"("identifier", "token");

-- CreateIndex
CREATE UNIQUE INDEX "roles_name_key" ON "public"."roles"("name");

-- CreateIndex
CREATE UNIQUE INDEX "users_email_key" ON "public"."users"("email");

-- CreateIndex
CREATE UNIQUE INDEX "inspection_tasks_inspectioncode_key" ON "public"."inspection_tasks"("inspectioncode");

-- CreateIndex
CREATE UNIQUE INDEX "field_executions_fieldcode_key" ON "public"."field_executions"("fieldcode");

-- CreateIndex
CREATE UNIQUE INDEX "seizures_seizurecode_key" ON "public"."seizures"("seizurecode");

-- CreateIndex
CREATE UNIQUE INDEX "lab_samples_samplecode_key" ON "public"."lab_samples"("samplecode");

-- CreateIndex
CREATE UNIQUE INDEX "fir_cases_fircode_key" ON "public"."fir_cases"("fircode");

-- CreateIndex
CREATE UNIQUE INDEX "products_category_company_name_key" ON "public"."products"("category", "company", "name");

-- CreateIndex
CREATE INDEX "_FIRCaseToSeizure_B_index" ON "public"."_FIRCaseToSeizure"("B");

-- AddForeignKey
ALTER TABLE "public"."accounts" ADD CONSTRAINT "accounts_userId_fkey" FOREIGN KEY ("userId") REFERENCES "public"."users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."sessions" ADD CONSTRAINT "sessions_userId_fkey" FOREIGN KEY ("userId") REFERENCES "public"."users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."audit_logs" ADD CONSTRAINT "audit_logs_userId_fkey" FOREIGN KEY ("userId") REFERENCES "public"."users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."role_permissions" ADD CONSTRAINT "role_permissions_roleId_fkey" FOREIGN KEY ("roleId") REFERENCES "public"."roles"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."users" ADD CONSTRAINT "users_roleId_fkey" FOREIGN KEY ("roleId") REFERENCES "public"."roles"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."inspection_tasks" ADD CONSTRAINT "inspection_tasks_userId_fkey" FOREIGN KEY ("userId") REFERENCES "public"."users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."field_executions" ADD CONSTRAINT "field_executions_inspectionid_fkey" FOREIGN KEY ("inspectionid") REFERENCES "public"."inspection_tasks"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."field_executions" ADD CONSTRAINT "field_executions_userid_fkey" FOREIGN KEY ("userid") REFERENCES "public"."users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."seizures" ADD CONSTRAINT "seizures_userId_fkey" FOREIGN KEY ("userId") REFERENCES "public"."users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."seizures" ADD CONSTRAINT "seizures_scanResultId_fkey" FOREIGN KEY ("scanResultId") REFERENCES "public"."scan_results"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."seizures" ADD CONSTRAINT "seizures_fieldExecutionId_fkey" FOREIGN KEY ("fieldExecutionId") REFERENCES "public"."field_executions"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."lab_samples" ADD CONSTRAINT "lab_samples_userId_fkey" FOREIGN KEY ("userId") REFERENCES "public"."users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."lab_samples" ADD CONSTRAINT "lab_samples_seizureId_fkey" FOREIGN KEY ("seizureId") REFERENCES "public"."seizures"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."fir_cases" ADD CONSTRAINT "fir_cases_userId_fkey" FOREIGN KEY ("userId") REFERENCES "public"."users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."fir_cases" ADD CONSTRAINT "fir_cases_labSampleId_fkey" FOREIGN KEY ("labSampleId") REFERENCES "public"."lab_samples"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."scan_results" ADD CONSTRAINT "scan_results_productId_fkey" FOREIGN KEY ("productId") REFERENCES "public"."products"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."_FIRCaseToSeizure" ADD CONSTRAINT "_FIRCaseToSeizure_A_fkey" FOREIGN KEY ("A") REFERENCES "public"."fir_cases"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "public"."_FIRCaseToSeizure" ADD CONSTRAINT "_FIRCaseToSeizure_B_fkey" FOREIGN KEY ("B") REFERENCES "public"."seizures"("id") ON DELETE CASCADE ON UPDATE CASCADE;

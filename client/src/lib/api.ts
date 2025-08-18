// lib/api.ts
import axios from 'axios'
const api = axios.create({
  baseURL: process.env.NEXT_PUBLIC_API_URL,
})
// Attach token from localStorage to every request
api.interceptors.request.use(
  (config) => {
    const token = sessionStorage.getItem('token')
    if (token) {
      config.headers.Authorization = `Bearer ${token}`
    }
    return config
  },
  (error) => Promise.reject(error)
)
export default api

// Inspection API functions
export const inspectionAPI = {
  // Get all inspections with optional filters
  getInspections: async (filters?: {
    status?: string;
    userId?: string;
    district?: string;
    taluka?: string;
    targetType?: string;
    dateFrom?: string;
    dateTo?: string;
  }) => {
    const params = new URLSearchParams();
    if (filters) {
      Object.entries(filters).forEach(([key, value]) => {
        if (value) params.append(key, value);
      });
    }

    const response = await api.get(`inspections?${params.toString()}`);
    return response.data;
  },

  // Create new inspection
  createInspection: async (data: {
    inspectioncode?: string;
    datetime: string;
    state?: string;
    district: string;
    taluka: string;
    location: string;
    addressland?: string;
    targetType: string;
    typeofpremises?: string[];
    visitpurpose?: string[];
    equipment?: string[];
    totaltarget?: string;
  }) => {
    const response = await api.post('inspections', data);
    return response.data;
  },

  // Update inspection
  updateInspection: async (id: string, data: {
    datetime?: string;
    state?: string;
    district?: string;
    taluka?: string;
    location?: string;
    addressland?: string;
    targetType?: string;
    typeofpremises?: string[];
    visitpurpose?: string[];
    equipment?: string[];
    totaltarget?: string;
    achievedtarget?: string;
    status?: string;
  }) => {
    const response = await api.put('inspections', { id, ...data });
    return response.data;
  },

  // Delete inspection
  deleteInspection: async (id: string) => {
    const response = await api.delete(`inspections?id=${id}`);
    return response.data;
  },
};

// Field Execution API functions
export const fieldExecutionAPI = {
  // Get all field executions with optional filters
  getFieldExecutions: async (filters?: {
    inspectionid?: string;
    userid?: string;
    companyname?: string;
    productname?: string;
    dealer_name?: string;
    fertilizer_type?: string;
    status?: string;
  }) => {
    const params = new URLSearchParams();
    if (filters) {
      Object.entries(filters).forEach(([key, value]) => {
        if (value) params.append(key, value);
      });
    }

    const response = await api.get(`field-executions?${params.toString()}`);
    return response.data;
  },

  // Create new field execution
  createFieldExecution: async (data: {
    inspectionid: string;
    companyname: string;
    productname: string;
    dealer_name: string;
    registration_no?: string;
    sampling_date?: string;
    fertilizer_type: string;
    batch_no?: string;
    manufacture_import_date?: string;
    stock_receipt_date?: string;
    sample_code?: string;
    stock_position?: string;
    physical_condition?: string;
    specification_fco?: string;
    composition_analysis?: string;
    variation?: string;
    moisture?: string;
    total_n?: string;
    nh4n?: string;
    nh4no3n?: string;
    urea_n?: string;
    total_p2o5?: string;
    nac_soluble_p2o5?: string;
    citric_soluble_p2o5?: string;
    water_soluble_p2o5?: string;
    water_soluble_k2o?: string;
    particle_size?: string;
    document?: string;
    productphoto?: string;
  }) => {
    const response = await api.post('field-executions', data);
    return response.data;
  },

  // Update field execution
  updateFieldExecution: async (id: string, data: {
    companyname?: string;
    productname?: string;
    dealer_name?: string;
    registration_no?: string;
    sampling_date?: string;
    fertilizer_type?: string;
    batch_no?: string;
    manufacture_import_date?: string;
    stock_receipt_date?: string;
    sample_code?: string;
    stock_position?: string;
    physical_condition?: string;
    specification_fco?: string;
    composition_analysis?: string;
    variation?: string;
    moisture?: string;
    total_n?: string;
    nh4n?: string;
    nh4no3n?: string;
    urea_n?: string;
    total_p2o5?: string;
    nac_soluble_p2o5?: string;
    citric_soluble_p2o5?: string;
    water_soluble_p2o5?: string;
    water_soluble_k2o?: string;
    particle_size?: string;
    document?: string;
    productphoto?: string;
  }) => {
    const response = await api.put('field-executions', { id, ...data });
    return response.data;
  },

  // Delete field execution
  deleteFieldExecution: async (id: string) => {
    const response = await api.delete(`field-executions?id=${id}`);
    return response.data;
  },
};

// Seizures API functions
export const seizuresAPI = {
  // Get all seizures with optional filters
  getSeizures: async (filters?: {
    status?: string;
    userId?: string;
    location?: string;
    district?: string;
    taluka?: string;
    fertilizer_type?: string;
    batch_no?: string;
  }) => {
    const params = new URLSearchParams();
    if (filters) {
      Object.entries(filters).forEach(([key, value]) => {
        if (value) params.append(key, value);
      });
    }

    const response = await api.get(`seizures?${params.toString()}`);
    return response.data;
  },

  // Create new seizure
  createSeizure: async (data: {
    seizurecode?: string;
    fieldExecutionId: string;
    location: string;
    district: string;
    taluka?: string;
    premises_type?: string[];
    fertilizer_type?: string;
    batch_no?: string;
    quantity: string;
    estimatedValue: string;
    witnessName?: string;
    evidencePhotos?: string[];
    videoEvidence?: string;
    remarks?: string;
    seizure_date?: string;
    memo_no?: string;
    officer_name?: string;
    scanResultId?: string;
  }) => {
    const response = await api.post('seizures', data);
    return response.data;
  },

  // Update seizure
  updateSeizure: async (id: string, data: {
    location?: string;
    district?: string;
    taluka?: string;
    premises_type?: string[];
    fertilizer_type?: string;
    batch_no?: string;
    quantity?: string;
    estimatedValue?: string;
    witnessName?: string;
    evidencePhotos?: string[];
    videoEvidence?: string;
    status?: string;
    remarks?: string;
    seizure_date?: string;
    memo_no?: string;
    officer_name?: string;
  }) => {
    const response = await api.put('seizures', { id, ...data });
    return response.data;
  },

  // Delete seizure
  deleteSeizure: async (id: string) => {
    const response = await api.delete(`seizures?id=${id}`);
    return response.data;
  },
};

// Lab Samples API functions
export const labSamplesAPI = {
  // Get all lab samples with optional filters
  getLabSamples: async (filters?: {
    status?: string;
    userId?: string;
    sampleType?: string;
    labDestination?: string;
    seizureId?: string;
    testType?: string;
  }) => {
    const params = new URLSearchParams();
    if (filters) {
      Object.entries(filters).forEach(([key, value]) => {
        if (value) params.append(key, value);
      });
    }

    const response = await api.get(`lab-samples?${params.toString()}`);
    return response.data;
  },

  // Create new lab sample
  createLabSample: async (data: {
    sampleType: string;
    labDestination: string;
    seizureId: string;
    testType?: string;
    sampleCode?: string;
    sampleWeight?: string;
    sampleDescription?: string;
    specialInstructions?: string;
    expectedResults?: string;
    priority?: string;
  }) => {
    const response = await api.post('lab-samples', data);
    return response.data;
  },

  // Update lab sample
  updateLabSample: async (id: string, data: {
    sampleType?: string;
    labDestination?: string;
    testType?: string;
    sampleCode?: string;
    sampleWeight?: string;
    sampleDescription?: string;
    specialInstructions?: string;
    expectedResults?: string;
    priority?: string;
    status?: string;
    testResults?: string;
    testDate?: string;
    analystName?: string;
    remarks?: string;
  }) => {
    const response = await api.put('lab-samples', { id, ...data });
    return response.data;
  },

  // Delete lab sample
  deleteLabSample: async (id: string) => {
    const response = await api.delete(`lab-samples?id=${id}`);
    return response.data;
  },
};

// FIR Cases API functions
export const firCasesAPI = {
  // Get all FIR cases with optional filters
  getFIRCases: async (filters?: {
    status?: string;
    userId?: string;
    violationType?: string;
    accused?: string;
    location?: string;
    seizureId?: string;
    labSampleId?: string;
  }) => {
    const params = new URLSearchParams();
    if (filters) {
      Object.entries(filters).forEach(([key, value]) => {
        if (value) params.append(key, value);
      });
    }

    const response = await api.get(`fir-cases?${params.toString()}`);
    return response.data;
  },

  // Create new FIR case
  createFIRCase: async (data: {
    labReportId?: string;
    violationType: string;
    accused: string;
    location: string;
    caseNotes?: string;
    courtDate?: string;
    seizureId?: string;
    labSampleId?: string;
    caseNumber?: string;
    policeStation?: string;
    investigatingOfficer?: string;
    evidenceDetails?: string;
    witnessStatements?: string;
    legalRepresentation?: string;
    priority?: string;
  }) => {
    const response = await api.post('fir-cases', data);
    return response.data;
  },

  // Update FIR case
  updateFIRCase: async (id: string, data: {
    labReportId?: string;
    violationType?: string;
    accused?: string;
    location?: string;
    caseNumber?: string;
    policeStation?: string;
    investigatingOfficer?: string;
    evidenceDetails?: string;
    witnessStatements?: string;
    legalRepresentation?: string;
    priority?: string;
    status?: string;
    caseNotes?: string;
    courtDate?: string;
    seizureId?: string;
    labSampleId?: string;
  }) => {
    const response = await api.put('fir-cases', { id, ...data });
    return response.data;
  },

  // Delete FIR case
  deleteFIRCase: async (id: string) => {
    const response = await api.delete(`fir-cases?id=${id}`);
    return response.data;
  },
};

// Reports API functions
export const reportsAPI = {
  // Get dashboard report
  getDashboardReport: async (filters?: {
    startDate?: string;
    endDate?: string;
    officer?: string;
    district?: string;
    keyword?: string;
  }) => {
    const params = new URLSearchParams();
    params.append('type', 'dashboard');
    if (filters) {
      Object.entries(filters).forEach(([key, value]) => {
        if (value) params.append(key, value);
      });
    }

    const response = await api.get(`reports?${params.toString()}`);
    return response.data;
  },

  // Get inspections report
  getInspectionsReport: async (filters?: {
    startDate?: string;
    endDate?: string;
    officer?: string;
    district?: string;
    keyword?: string;
  }) => {
    const params = new URLSearchParams();
    params.append('type', 'inspections');
    if (filters) {
      Object.entries(filters).forEach(([key, value]) => {
        if (value) params.append(key, value);
      });
    }

    const response = await api.get(`reports?${params.toString()}`);
    return response.data;
  },

  // Get seizures report
  getSeizuresReport: async (filters?: {
    startDate?: string;
    endDate?: string;
    officer?: string;
    district?: string;
    keyword?: string;
  }) => {
    const params = new URLSearchParams();
    params.append('type', 'seizures');
    if (filters) {
      Object.entries(filters).forEach(([key, value]) => {
        if (value) params.append(key, value);
      });
    }

    const response = await api.get(`reports?${params.toString()}`);
    return response.data;
  },

  // Get lab samples report
  getLabSamplesReport: async (filters?: {
    startDate?: string;
    endDate?: string;
    officer?: string;
    district?: string;
    keyword?: string;
  }) => {
    const params = new URLSearchParams();
    params.append('type', 'lab-samples');
    if (filters) {
      Object.entries(filters).forEach(([key, value]) => {
        if (value) params.append(key, value);
      });
    }

    const response = await api.get(`reports?${params.toString()}`);
    return response.data;
  },

  // Get FIR cases report
  getFIRCasesReport: async (filters?: {
    startDate?: string;
    endDate?: string;
    officer?: string;
    district?: string;
    keyword?: string;
  }) => {
    const params = new URLSearchParams();
    params.append('type', 'fir-cases');
    if (filters) {
      Object.entries(filters).forEach(([key, value]) => {
        if (value) params.append(key, value);
      });
    }

    const response = await api.get(`reports?${params.toString()}`);
    return response.data;
  },

  // Get custom report by type
  getCustomReport: async (reportType: string, filters?: {
    startDate?: string;
    endDate?: string;
    officer?: string;
    district?: string;
    keyword?: string;
  }) => {
    const params = new URLSearchParams();
    params.append('type', reportType);
    if (filters) {
      Object.entries(filters).forEach(([key, value]) => {
        if (value) params.append(key, value);
      });
    }

    const response = await api.get(`reports?${params.toString()}`);
    return response.data;
  },
};

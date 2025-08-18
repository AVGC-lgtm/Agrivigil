// === User Roles ===
export const USER_ROLES = {
  DAO: "DAO",
  FIELD_OFFICER: "FIELD_OFFICER",
  LEGAL_OFFICER: "LEGAL_OFFICER",
  LAB_COORDINATOR: "LAB_COORDINATOR",
  HQ_MONITORING: "HQ_MONITORING",
  DISTRICT_ADMIN: "DISTRICT_ADMIN",
} as const

// === Menu Definitions for Role Permissions ===
export const MENU_DEFINITIONS = [
  {
    id: "dashboard",
    name: "Dashboard",
    description: "Main monitoring dashboard"
  },
  {
    id: "administration",
    name: "Administration",
    description: "User and role management"
  },
  {
    id: "inspection-planning",
    name: "Inspection Planning",
    description: "Plan inspection visits"
  },
  {
    id: "field-execution",
    name: "Field Execution",
    description: "Execute field inspections"
  },
  {
    id: "seizure-logging",
    name: "Seizure Logging",
    description: "Log seized items"
  },
  {
    id: "lab-interface",
    name: "Lab Interface",
    description: "Lab sample tracking"
  },
  {
    id: "legal-module",
    name: "Legal Module",
    description: "Legal enforcement"
  },
  {
    id: "report-audit",
    name: "Reports & Audit",
    description: "View reports and audit logs"
  },
  {
    id: "agri-forms-module",
    name: "Agri-Forms Portal",
    description: "Access agricultural forms portal"
  }
] as const;

// === Auth Types for Permissions ===
export const AUTH_TYPES = {
  FULL: "F",    // Full access - Create, Read, Update, Delete
  READ: "R",    // Read only access
  NONE: "N"     // No access
} as const;

// === Product Database (sample data) ===
export const PRODUCT_DATABASE = {
  fertilizers: {
    UPL: {
      Saaf: {
        activeIngredient: "Carbendazim + Mancozeb",
        composition: "12% + 63%",
        packaging: ["100g", "250g", "500g", "1kg"],
        batchFormat: "UPL-SAAF-YYYYMM-#####",
        commonCounterfeitMarkers: ["blurry text", "fake hologram"],
        mrp: 120,
        hologramFeatures: ["UPL logo hologram", "UV print"],
        bagColor: "white",
        subsidizedRate: 90,
        varieties: ["Standard"],
      },
    },
  },
}

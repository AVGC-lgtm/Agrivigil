import type { ProductDatabase, UserRole } from '@/types';
import { BarChart3, Calendar, Camera, Package, Scale, Building, FileSearch, Shield, ClipboardEdit, User } from 'lucide-react';

export const USER_ROLES: UserRole = {
  FIELD_OFFICER: 'Field Officer',
  DAO: 'District Agricultural Officer',
  LEGAL_OFFICER: 'Legal Officer',
  LAB_COORDINATOR: 'Lab Coordinator',
  HQ_MONITORING: 'HQ Monitoring Cell',
  DISTRICT_ADMIN: 'District Admin'
};

// === Super User Configuration ===
export const SUPER_USER = {
  email: 'super@gmail.com',
  password: '123',
  name: 'Super Administrator',
  officerCode: 'SUPER001',
  role: 'Super Admin'
} as const;

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
export const PRODUCT_DATABASE: ProductDatabase = {
  pesticides: {
    'UPL': {
      'Saaf': {
        activeIngredient: 'Carbendazim 12% + Mancozeb 63%',
        packaging: ['100g', '250g', '500g'],
        batchFormat: 'UPL-SAAF-YYYYMM-XXXXX',
        commonCounterfeitMarkers: ['Poor print quality', 'Wrong shade of green', 'Missing hologram'],
        mrp: { '100g': 120, '250g': 280, '500g': 520 }
      },
      'Ulala': {
        activeIngredient: 'Flonicamid 50% WG',
        packaging: ['100g', '500g'],
        batchFormat: 'UPL-ULA-YYYYMM-XXXXX',
        mrp: { '100g': 650, '500g': 3100 }
      },
      'Curacron': {
        activeIngredient: 'Profenofos 50% EC',
        packaging: ['250ml', '500ml', '1L'],
        mrp: { '250ml': 480, '500ml': 940, '1L': 1850 }
      }
    },
    'Bayer': {
      'Confidor': {
        activeIngredient: 'Imidacloprid 17.8% SL',
        packaging: ['50ml', '100ml', '250ml', '500ml'],
        hologramFeatures: ['3D hologram', 'Color-changing ink', 'Microtext'],
        mrp: { '50ml': 165, '100ml': 320, '250ml': 785, '500ml': 1550 }
      },
      'Nativo': {
        activeIngredient: 'Tebuconazole 50% + Trifloxystrobin 25%',
        packaging: ['50g', '100g', '200g'],
        mrp: { '50g': 570, '100g': 1120, '200g': 2200 }
      }
    },
    'Syngenta': {
      'Karate': {
        activeIngredient: 'Lambda Cyhalothrin 5% EC',
        packaging: ['100ml', '250ml', '500ml'],
        mrp: { '100ml': 310, '250ml': 750, '500ml': 1480 }
      },
      'Ridomil Gold': {
        activeIngredient: 'Metalaxyl-M 4% + Mancozeb 64%',
        packaging: ['250g', '500g', '1kg'],
        mrp: { '250g': 590, '500g': 1160, '1kg': 2280 }
      }
    }
  },
  fertilizers: {
    'IFFCO': {
      'DAP': {
        composition: '18-46-0',
        packaging: ['50kg'],
        bagColor: 'Green with IFFCO logo',
        subsidizedRate: 1350,
        mrp: { '50kg': 1350 } // changed to object
      },
      'NPK 10:26:26': {
        composition: '10-26-26',
        packaging: ['50kg'],
        subsidizedRate: 1470,
        mrp: { '50kg': 1470 } // changed to object
      }
    },
    'Coromandel': {
      'Gromor': {
        composition: '14-35-14',
        packaging: ['50kg'],
        bagColor: 'White with green stripes',
        mrp: { '50kg': 1520 } // changed to object
      }
    }
  },
  seeds: {
    'Mahyco': {
      'Bt Cotton': {
        varieties: ['MECH-162', 'MECH-184'],
        packaging: ['450g'],
        mrp: { '450g': 930 }
      }
    },
    'Nuziveedu': {
      'Cotton Hybrid': {
        varieties: ['Bhakti', 'Mallika'],
        packaging: ['475g'],
        mrp: { '475g': 980 }
      }
    }
  }
};

export interface TabDefinition {
  id: string;
  icon: any;
  text: string;
  ariaLabel: string;
}

export const TABS: TabDefinition[] = [
  {
    id: 'dashboard',
    icon: BarChart3,
    text: 'Dashboard',
    ariaLabel: 'View monitoring dashboard',
  },
  {
    id: 'administration',
    icon: User,
    text: 'Administration',
    ariaLabel: 'administration',
  },
  {
    id: 'inspection-planning',
    icon: Calendar,
    text: 'Inspection Planning',
    ariaLabel: 'Plan inspection visits',
  },
  {
    id: 'field-execution',
    icon: Camera,
    text: 'Field Execution',
    ariaLabel: 'Execute field inspections',
  },
  {
    id: 'seizure-logging',
    icon: Package,
    text: 'Seizure Logging',
    ariaLabel: 'Log seized items',
  },
  {
    id: 'lab-interface',
    icon: Building,
    text: 'Lab Interface',
    ariaLabel: 'Lab sample tracking',
  },
  {
    id: 'legal-module',
    icon: Scale,
    text: 'Legal Module',
    ariaLabel: 'Legal enforcement',
  },
  {
    id: 'report-audit',
    icon: FileSearch,
    text: 'Reports & Audit',
    ariaLabel: 'View reports and audit logs',
  },
  {
    id: 'agri-forms-module',
    icon: ClipboardEdit,
    text: 'Agri-Forms Portal',
    ariaLabel: 'Access agricultural forms portal',
  }
];

export const APP_NAME = "Agrivigil";
export const APP_LOGO = Shield;
export const COMPANY_INFO = {
  name: "Dawell Lifescience Private Limited",
  contact: "9850647444",
  copyright: "© 2025 Agrivigil - Developed by Dawell Lifescience Private Limited. All rights reserved."
};

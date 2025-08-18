'use client'

import React, { Suspense } from "react"
import { useRouter, useSearchParams } from "next/navigation"
import { AppHeader } from "@/components/layout/Header"
import { AppSidebar } from "@/components/layout/Sidebar"
import { SidebarProvider, SidebarInset } from "@/components/ui/sidebar"
import DashboardModule from "@/components/modules/DashboardModule";
import AdministrationModule from "@/components/modules/AdministrationModule";
import InspectionPlanningModule from "@/components/modules/InspectionPlanningModule";
import FieldExecutionModule from "@/components/modules/FieldExecutionModule";
import SeizureLoggingModule from "@/components/modules/SeizureLoggingModule";
import LegalModule from "@/components/modules/LegalModule";
import LabInterfaceModule from "@/components/modules/LabInterfaceModule";
import ReportAuditModule from "@/components/modules/ReportsAuditModule";
import AgriFormsModule from "@/components/modules/AgriFormsPortalModule";
import { usePermissions } from "@/hooks/use-permissions";

function DashboardContent() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const { userPermissions, isLoading, error, canAccess, isSuperUser, getMenuPermission } = usePermissions();
  
  // Check authentication - super user or regular user with token
  React.useEffect(() => {
    const isSuperUserFlag = localStorage.getItem('isSuperUser') || sessionStorage.getItem('isSuperUser');
    const token = sessionStorage.getItem('token') || localStorage.getItem('token');
    
    // If neither super user nor regular user with token, redirect to login
    if (!isSuperUserFlag && !token) {
      router.push('/auth/signin');
    }
  }, [router]);

  // get active module from ?tab=...
  const activeModule = searchParams.get("tab") || "dashboard";
  
  const handleModuleChange = (moduleId: string) => {
    // Super user can access everything
    if (isSuperUser) {
      router.push(`?tab=${moduleId}`);
      return;
    }
    
    // Check if user has permission to access this module
    if (canAccess(moduleId)) {
      router.push(`?tab=${moduleId}`);
    } else {
      console.warn(`User has no access to module: ${moduleId}`);
    }
  };

  const renderModule = () => {
    // Super user can access everything
    if (isSuperUser) {
      switch (activeModule) {
        case "dashboard":
          return <DashboardModule />;
        case "administration":
          return <AdministrationModule />;
        case "inspection-planning":
          return <InspectionPlanningModule />;
        case "field-execution":
          return <FieldExecutionModule />;
        case "seizure-logging":
          return <SeizureLoggingModule />;
        case "legal-module":
          return <LegalModule />;
        case "lab-interface":
          return <LabInterfaceModule />;
        case "report-audit":
          return <ReportAuditModule />;
        case "agri-forms-module":
          return <AgriFormsModule />;
        default:
          return <DashboardModule />;
      }
    }

    // Check if user has permission to view the active module
    if (!canAccess(activeModule)) {
      return (
        <div className="flex items-center justify-center h-64">
          <div className="text-center">
            <h2 className="text-2xl font-semibold text-gray-600 mb-2">Access Denied</h2>
            <p className="text-gray-500">You don't have permission to access this module.</p>
            <p className="text-sm text-gray-400 mt-2">
              Required permission: Read (R) or Full (F)<br/>
              Your permission: {getMenuPermission(activeModule)}
            </p>
          </div>
        </div>
      );
    }

    switch (activeModule) {
      case "dashboard":
        return <DashboardModule />;
      case "administration":
        return <AdministrationModule />;
      case "inspection-planning":
        return <InspectionPlanningModule />;
      case "field-execution":
        return <FieldExecutionModule />;
      case "seizure-logging":
        return <SeizureLoggingModule />;
      case "legal-module":
        return <LegalModule />;
      case "lab-interface":
        return <LabInterfaceModule />;
      case "report-audit":
        return <ReportAuditModule />;
      case "agri-forms-module":
        return <AgriFormsModule />;
      default:
        return <DashboardModule />;
    }
  };

  if (isLoading) {
    return (
      <div className="flex items-center justify-center h-screen">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto mb-4"></div>
          <p className="text-gray-600">Loading permissions...</p>
        </div>
      </div>
    );
  }

  if (error || !userPermissions) {
    return (
      <div className="flex items-center justify-center h-screen">
        <div className="text-center">
          <h2 className="text-2xl font-semibold text-gray-600 mb-2">Authentication Error</h2>
          <p className="text-gray-500">{error || 'Unable to load user permissions.'}</p>
          <button 
            onClick={() => router.push('/auth/signin')}
            className="mt-4 px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700"
          >
            Go to Login
          </button>
        </div>
      </div>
    );
  }

  // Create permissions object for sidebar with proper F, R, N values
  const sidebarPermissions: Record<string, string> = {};
  if (userPermissions && userPermissions.permissions) {
    Object.keys(userPermissions.permissions).forEach(menuId => {
      sidebarPermissions[menuId] = userPermissions.permissions[menuId];
    });
  }

  return (
    <SidebarProvider>
      <AppSidebar 
        activeModule={activeModule} 
        onModuleChange={handleModuleChange}
        userPermissions={sidebarPermissions}
        isSuperUser={isSuperUser}
      />
      <SidebarInset>
        <AppHeader user={userPermissions.user} />
        <main className="flex-1 overflow-auto bg-background p-4 sm:p-6 md:p-8">
          <div className="mx-auto w-full max-w-screen-2xl">
            {renderModule()}
          </div>
        </main>
      </SidebarInset>
    </SidebarProvider>
  )
}

export default function DashboardPage() {
  return (
    <Suspense fallback={
      <div className="flex items-center justify-center h-screen">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto mb-4"></div>
          <p className="text-gray-600">Loading dashboard...</p>
        </div>
      </div>
    }>
      <DashboardContent />
    </Suspense>
  );
}

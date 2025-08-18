"use client";
import React from "react";
import AgriSidebar from "@/components/agri-forms/AgriSidebar";
import AgriHeader from "@/components/agri-forms/AgriHeader";
import AgriDashboard from "@/components/agri-forms/AgriDashboard";

export default function AgriFormsModule() {
  return (
    <div className="flex h-full bg-background">
      {/* Sidebar */}
      <AgriSidebar
        activeMenu="dashboard"
        navigateTo={() => {}}
        expandedCategories={{ fertilizer: true, insecticide: false }}
        toggleCategory={() => {}}
        selectedForm={null}
        isMobile={false}
        mobileOpen={false}
        setMobileOpen={() => {}}
      />

      {/* Main content area */}
      <div className="flex-1 flex flex-col overflow-hidden">
        <AgriHeader
          searchQuery=""
          setSearchQuery={() => {}}
          isMobile={false}
          onMobileMenuClick={() => {}}
        />

        <main className="flex-1 overflow-y-auto p-4 sm:p-6 bg-background">
          <AgriDashboard />
        </main>
      </div>
    </div>
  );
}

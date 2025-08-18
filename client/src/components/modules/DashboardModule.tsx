"use client";

import React from 'react';

export default function DashboardModule() {
  return (
    <div className="space-y-6">
      <div className="flex items-center gap-2">
        <h1 className="text-3xl font-bold">Dashboard</h1>
      </div>
      
      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
        <div className="p-6 border rounded-lg">
          <h3 className="text-sm font-medium">Total Inspections</h3>
          <div className="text-2xl font-bold">1,234</div>
          <p className="text-xs text-muted-foreground">+20.1% from last month</p>
        </div>
        
        <div className="p-6 border rounded-lg">
          <h3 className="text-sm font-medium">Active Cases</h3>
          <div className="text-2xl font-bold">89</div>
          <p className="text-xs text-muted-foreground">+5.2% from last month</p>
        </div>
        
        <div className="p-6 border rounded-lg">
          <h3 className="text-sm font-medium">Field Officers</h3>
          <div className="text-2xl font-bold">45</div>
          <p className="text-xs text-muted-foreground">+2 new this month</p>
        </div>
        
        <div className="p-6 border rounded-lg">
          <h3 className="text-sm font-medium">Pending Reports</h3>
          <div className="text-2xl font-bold">23</div>
          <p className="text-xs text-muted-foreground">-12% from last month</p>
        </div>
      </div>
      
      <div className="p-6 border rounded-lg">
        <h3 className="text-lg font-semibold mb-4">Recent Activities</h3>
        <div className="space-y-4">
          <div className="flex items-center gap-4 p-4 border rounded-lg">
            <div className="w-2 h-2 bg-green-500 rounded-full"></div>
            <div className="flex-1">
              <p className="font-medium">Field inspection completed - District A</p>
              <p className="text-sm text-muted-foreground">2 hours ago</p>
            </div>
          </div>
          <div className="flex items-center gap-4 p-4 border rounded-lg">
            <div className="w-2 h-2 bg-blue-500 rounded-full"></div>
            <div className="flex-1">
              <p className="font-medium">New case registered - Seizure #1234</p>
              <p className="text-sm text-muted-foreground">4 hours ago</p>
            </div>
          </div>
          <div className="flex items-center gap-4 p-4 border rounded-lg">
            <div className="w-2 h-2 bg-yellow-500 rounded-full"></div>
            <div className="flex-1">
              <p className="font-medium">Lab sample submitted - Case #5678</p>
              <p className="text-sm text-muted-foreground">6 hours ago</p>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

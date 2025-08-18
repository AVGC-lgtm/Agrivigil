"use client";

import React, { useState } from "react";
import { Card, CardHeader, CardTitle, CardContent } from "@/components/ui/card";
import { Tabs, TabsList, TabsTrigger, TabsContent } from "@/components/ui/tabs";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Button } from "@/components/ui/button";
import { Checkbox } from "@/components/ui/checkbox";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import {
  Select,
  SelectTrigger,
  SelectValue,
  SelectContent,
  SelectItem,
} from "@/components/ui/select";
import { Textarea } from "@/components/ui/textarea";

// Import icons
import { FileText, BarChart3, Calendar, Download, Filter, Search } from "lucide-react";

export default function ReportsAuditModule() {
  const [auditLogs, setAuditLogs] = useState([
    {
      id: "AUD001",
      action: "CREATE",
      entity: "InspectionTask",
      entityId: "450001",
      oldData: null,
      newData: { inspectioncode: "450001", status: "scheduled" },
      createdAt: "2025-01-15 10:30:00",
      userId: "USER001",
      userName: "Priya Sharma",
    },
    {
      id: "AUD002",
      action: "UPDATE",
      entity: "FieldExecution",
      entityId: "FE001",
      oldData: { status: "pending" },
      newData: { status: "completed" },
      createdAt: "2025-01-16 14:20:00",
      userId: "USER002",
      userName: "Suresh Patil",
    },
    {
      id: "AUD003",
      action: "DELETE",
      entity: "Product",
      entityId: "PROD001",
      oldData: { name: "Test Product", category: "Fertilizer" },
      newData: null,
      createdAt: "2025-01-17 09:15:00",
      userId: "USER001",
      userName: "Priya Sharma",
    },
  ]);

  const reportTypes = [
    "Inspection Summary Report",
    "Field Execution Report",
    "Seizure Report",
    "Lab Analysis Report",
    "FIR Cases Report",
    "Audit Trail Report",
    "Compliance Report",
    "Performance Metrics Report",
  ];

  const districts = ["Pune", "Mumbai", "Nagpur", "Aurangabad"];
  const actions = ["CREATE", "UPDATE", "DELETE", "LOGIN", "LOGOUT"];
  const entities = ["InspectionTask", "FieldExecution", "Seizure", "LabSample", "FIRCase", "Product", "User"];

  return (
    <div className="p-4">
      <Tabs defaultValue="reports" className="w-full">
        <TabsList className="grid grid-cols-2 w-full mb-4">
          <TabsTrigger value="reports">Reports Generation</TabsTrigger>
          <TabsTrigger value="audit">Audit Logs</TabsTrigger>
        </TabsList>

        {/* === REPORTS GENERATION TAB === */}
        <TabsContent value="reports">
          <Card>
            <CardHeader>
              <CardTitle>Generate Reports</CardTitle>
            </CardHeader>
            <CardContent>
              <form className="grid gap-4">
                <div>
                  <Label>Report Type</Label>
                  <Select>
                    <SelectTrigger>
                      <SelectValue placeholder="Select Report Type" />
                    </SelectTrigger>
                    <SelectContent>
                      {reportTypes.map((type) => (
                        <SelectItem key={type} value={type}>
                          {type}
                        </SelectItem>
                      ))}
                    </SelectContent>
                  </Select>
                </div>

                <div className="grid grid-cols-3 gap-4">
                  <div>
                    <Label>State</Label>
                    <Select>
                      <SelectTrigger>
                        <SelectValue placeholder="Select State" />
                      </SelectTrigger>
                      <SelectContent>
                        <SelectItem value="Maharashtra">Maharashtra</SelectItem>
                      </SelectContent>
                    </Select>
                  </div>

                  <div>
                    <Label>District</Label>
                    <Select>
                      <SelectTrigger>
                        <SelectValue placeholder="Select District" />
                      </SelectTrigger>
                      <SelectContent>
                        {districts.map((d) => (
                          <SelectItem key={d} value={d}>
                            {d}
                          </SelectItem>
                        ))}
                      </SelectContent>
                    </Select>
                  </div>

                  <div>
                    <Label>Date Range</Label>
                    <Select>
                      <SelectTrigger>
                        <SelectValue placeholder="Select Date Range" />
                      </SelectTrigger>
                      <SelectContent>
                        <SelectItem value="today">Today</SelectItem>
                        <SelectItem value="week">This Week</SelectItem>
                        <SelectItem value="month">This Month</SelectItem>
                        <SelectItem value="quarter">This Quarter</SelectItem>
                        <SelectItem value="year">This Year</SelectItem>
                        <SelectItem value="custom">Custom Range</SelectItem>
                      </SelectContent>
                    </Select>
                  </div>
                </div>

                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <Label>Date From</Label>
                    <Input type="date" />
                  </div>

                  <div>
                    <Label>Date To</Label>
                    <Input type="date" />
                  </div>
                </div>

                <div>
                  <Label>Additional Filters</Label>
                  <div className="grid grid-cols-2 gap-4">
                    <div className="flex items-center gap-2">
                      <Checkbox /> <span>Include Inactive Records</span>
                    </div>
                    <div className="flex items-center gap-2">
                      <Checkbox /> <span>Include Deleted Records</span>
                    </div>
                    <div className="flex items-center gap-2">
                      <Checkbox /> <span>Export to Excel</span>
                    </div>
                    <div className="flex items-center gap-2">
                      <Checkbox /> <span>Include Charts</span>
                    </div>
                  </div>
                </div>

                <div>
                  <Label>Report Description</Label>
                  <Textarea placeholder="Enter report description or notes" />
                </div>

                <div className="flex gap-2">
                  <Button type="submit" className="flex items-center gap-2">
                    <BarChart3 className="w-4 h-4" />
                    Generate Report
                  </Button>
                  <Button variant="outline" className="flex items-center gap-2">
                    <Download className="w-4 h-4" />
                    Download Template
                  </Button>
                </div>
              </form>
            </CardContent>
          </Card>
        </TabsContent>

        {/* === AUDIT LOGS TAB === */}
        <TabsContent value="audit">
          <Card>
            <CardHeader>
              <CardTitle>Audit Logs</CardTitle>
            </CardHeader>
            <CardContent>
              {/* FILTERS */}
              <div className="grid grid-cols-1 md:grid-cols-5 gap-4 mb-4">
                <div>
                  <Label>Action</Label>
                  <Select>
                    <SelectTrigger>
                      <SelectValue placeholder="Select Action" />
                    </SelectTrigger>
                    <SelectContent>
                      {actions.map((action) => (
                        <SelectItem key={action} value={action}>
                          {action}
                        </SelectItem>
                      ))}
                    </SelectContent>
                  </Select>
                </div>

                <div>
                  <Label>Entity</Label>
                  <Select>
                    <SelectTrigger>
                      <SelectValue placeholder="Select Entity" />
                    </SelectTrigger>
                    <SelectContent>
                      {entities.map((entity) => (
                        <SelectItem key={entity} value={entity}>
                          {entity}
                        </SelectItem>
                      ))}
                    </SelectContent>
                  </Select>
                </div>

                <div>
                  <Label>User ID</Label>
                  <Input placeholder="Filter by user ID" />
                </div>

                <div>
                  <Label>Date From</Label>
                  <Input type="date" />
                </div>

                <div>
                  <Label>Date To</Label>
                  <Input type="date" />
                </div>
              </div>

              {/* TABLE */}
              <div className="overflow-x-auto overflow-y-auto max-h-[32rem] border rounded">
                <div className="min-w-[1200px]">
                  <Table className="text-sm w-full">
                    <TableHeader>
                      <TableRow className="text-xs">
                        <TableHead className="whitespace-nowrap">Audit ID</TableHead>
                        <TableHead className="whitespace-nowrap">Action</TableHead>
                        <TableHead className="whitespace-nowrap">Entity</TableHead>
                        <TableHead className="whitespace-nowrap">Entity ID</TableHead>
                        <TableHead className="whitespace-nowrap">Old Data</TableHead>
                        <TableHead className="whitespace-nowrap">New Data</TableHead>
                        <TableHead className="whitespace-nowrap">Created At</TableHead>
                        <TableHead className="whitespace-nowrap">User ID</TableHead>
                        <TableHead className="whitespace-nowrap">User Name</TableHead>
                      </TableRow>
                    </TableHeader>
                    <TableBody>
                      {auditLogs.map((log) => (
                        <TableRow key={log.id} className="text-xs">
                          <TableCell className="whitespace-nowrap">
                            {log.id}
                          </TableCell>
                          <TableCell className="whitespace-nowrap">
                            <span className={`px-2 py-1 rounded-full text-xs ${
                              log.action === 'CREATE' 
                                ? 'bg-green-100 text-green-800' 
                                : log.action === 'UPDATE'
                                ? 'bg-blue-100 text-blue-800'
                                : log.action === 'DELETE'
                                ? 'bg-red-100 text-red-800'
                                : 'bg-gray-100 text-gray-800'
                            }`}>
                              {log.action}
                            </span>
                          </TableCell>
                          <TableCell className="whitespace-nowrap">
                            {log.entity}
                          </TableCell>
                          <TableCell className="whitespace-nowrap">
                            {log.entityId}
                          </TableCell>
                          <TableCell className="whitespace-nowrap">
                            <div className="max-w-[200px] truncate">
                              {log.oldData ? JSON.stringify(log.oldData) : '-'}
                            </div>
                          </TableCell>
                          <TableCell className="whitespace-nowrap">
                            <div className="max-w-[200px] truncate">
                              {log.newData ? JSON.stringify(log.newData) : '-'}
                            </div>
                          </TableCell>
                          <TableCell className="whitespace-nowrap">
                            {log.createdAt}
                          </TableCell>
                          <TableCell className="whitespace-nowrap">
                            {log.userId}
                          </TableCell>
                          <TableCell className="whitespace-nowrap">
                            {log.userName}
                          </TableCell>
                        </TableRow>
                      ))}
                    </TableBody>
                  </Table>
                </div>
              </div>

              {/* EXPORT BUTTONS */}
              <div className="flex gap-2 mt-4">
                <Button variant="outline" className="flex items-center gap-2">
                  <Download className="w-4 h-4" />
                  Export to Excel
                </Button>
                <Button variant="outline" className="flex items-center gap-2">
                  <FileText className="w-4 h-4" />
                  Export to PDF
                </Button>
                <Button variant="outline" className="flex items-center gap-2">
                  <BarChart3 className="w-4 h-4" />
                  Generate Summary
                </Button>
              </div>
            </CardContent>
          </Card>
        </TabsContent>
      </Tabs>
    </div>
  );
}
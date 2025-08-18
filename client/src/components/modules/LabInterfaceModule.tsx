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
import { FlaskConical, Microscope, FileText, Calendar, User, Package } from "lucide-react";

export default function LabInterfaceModule() {
  const [labSamples, setLabSamples] = useState([
    {
      id: 1,
      sampleCode: "LAB001",
      department: "Chemistry Lab",
      sampleDesc: "NPK Fertilizer Sample - UPL Limited",
      district: "Pune",
      status: "Under Testing",
      collectedAt: "2025-01-15",
      dispatchedAt: "2025-01-16",
      receivedAt: "2025-01-17",
      underTesting: true,
      resultStatus: "Analysis in Progress",
      reportSentAt: null,
      officerName: "Dr. Priya Sharma",
      remarks: "Sample received in good condition",
      seizureId: "SEZ001",
    },
    {
      id: 2,
      sampleCode: "LAB002",
      department: "Microbiology Lab",
      sampleDesc: "Urea Sample - IFFCO",
      district: "Pune",
      status: "Completed",
      collectedAt: "2025-01-14",
      dispatchedAt: "2025-01-15",
      receivedAt: "2025-01-16",
      underTesting: false,
      resultStatus: "Analysis Complete",
      reportSentAt: "2025-01-20",
      officerName: "Dr. Suresh Patil",
      remarks: "Sample analysis completed successfully",
      seizureId: "SEZ002",
    },
  ]);

  const departments = ["Chemistry Lab", "Microbiology Lab", "Physical Lab", "Quality Control"];
  const districts = ["Pune", "Mumbai", "Nagpur", "Aurangabad"];
  const statuses = ["Pending", "Under Testing", "Completed", "Dispatched", "Received"];
  const resultStatuses = ["Pending", "Analysis in Progress", "Analysis Complete", "Report Generated", "Report Sent"];

  return (
    <div className="p-4">
      <Tabs defaultValue="sample" className="w-full">
        <TabsList className="grid grid-cols-2 w-full mb-4">
          <TabsTrigger value="sample">Lab Sample Creation</TabsTrigger>
          <TabsTrigger value="samples">Lab Samples List</TabsTrigger>
        </TabsList>

        {/* === LAB SAMPLE CREATION TAB === */}
        <TabsContent value="sample">
          <Card>
            <CardHeader>
              <CardTitle>Create Lab Sample</CardTitle>
            </CardHeader>
            <CardContent>
              <form className="grid gap-4">
                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <Label>Sample Code</Label>
                    <Input placeholder="Auto-generated" readOnly />
                  </div>

                  <div>
                    <Label>Department</Label>
                    <Select>
                      <SelectTrigger>
                        <SelectValue placeholder="Select Department" />
                      </SelectTrigger>
                      <SelectContent>
                        {departments.map((dept) => (
                          <SelectItem key={dept} value={dept}>
                            {dept}
                          </SelectItem>
                        ))}
                      </SelectContent>
                    </Select>
                  </div>
                </div>

                <div>
                  <Label>Sample Description</Label>
                  <Textarea placeholder="Enter detailed sample description" />
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
                    <Label>Status</Label>
                    <Select>
                      <SelectTrigger>
                        <SelectValue placeholder="Select Status" />
                      </SelectTrigger>
                      <SelectContent>
                        {statuses.map((status) => (
                          <SelectItem key={status} value={status}>
                            {status}
                          </SelectItem>
                        ))}
                      </SelectContent>
                    </Select>
                  </div>
                </div>

                <div className="grid grid-cols-3 gap-4">
                  <div>
                    <Label>Collected At</Label>
                    <Input type="datetime-local" />
                  </div>

                  <div>
                    <Label>Dispatched At</Label>
                    <Input type="datetime-local" />
                  </div>

                  <div>
                    <Label>Received At</Label>
                    <Input type="datetime-local" />
                  </div>
                </div>

                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <Label>Under Testing</Label>
                    <div className="flex items-center gap-2">
                      <Checkbox /> <span>Mark as under testing</span>
                    </div>
                  </div>

                  <div>
                    <Label>Result Status</Label>
                    <Select>
                      <SelectTrigger>
                        <SelectValue placeholder="Select Result Status" />
                      </SelectTrigger>
                      <SelectContent>
                        {resultStatuses.map((status) => (
                          <SelectItem key={status} value={status}>
                            {status}
                          </SelectItem>
                        ))}
                      </SelectContent>
                    </Select>
                  </div>
                </div>

                <div>
                  <Label>Report Sent At</Label>
                    <Input type="datetime-local" />
                </div>

                <div>
                  <Label>Officer Name</Label>
                  <Input placeholder="Enter officer name" />
                </div>

                <div>
                  <Label>Seizure ID (Optional)</Label>
                  <Select>
                    <SelectTrigger>
                      <SelectValue placeholder="Select Seizure ID" />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="SEZ001">SEZ001</SelectItem>
                      <SelectItem value="SEZ002">SEZ002</SelectItem>
                    </SelectContent>
                  </Select>
                </div>

                <div>
                  <Label>Remarks</Label>
                  <Textarea placeholder="Enter additional remarks or observations" />
                </div>

                <Button className="w-fit">Save Lab Sample</Button>
              </form>
            </CardContent>
          </Card>
        </TabsContent>

        {/* === LAB SAMPLES LIST TAB === */}
        <TabsContent value="samples">
          <Card>
            <CardHeader>
              <CardTitle>Lab Samples List</CardTitle>
            </CardHeader>
            <CardContent>
              {/* FILTERS */}
              <div className="grid grid-cols-1 md:grid-cols-4 gap-4 mb-4">
                <div>
                  <Label>Sample Code</Label>
                  <Input placeholder="Filter by sample code" />
                </div>

                <div>
                  <Label>Department</Label>
                  <Select>
                    <SelectTrigger>
                      <SelectValue placeholder="Select Department" />
                    </SelectTrigger>
                    <SelectContent>
                      {departments.map((dept) => (
                        <SelectItem key={dept} value={dept}>
                          {dept}
                        </SelectItem>
                      ))}
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
                  <Label>Status</Label>
                  <Select>
                    <SelectTrigger>
                      <SelectValue placeholder="Select Status" />
                    </SelectTrigger>
                    <SelectContent>
                      {statuses.map((status) => (
                        <SelectItem key={status} value={status}>
                          {status}
                        </SelectItem>
                      ))}
                    </SelectContent>
                  </Select>
                </div>
              </div>

              {/* TABLE */}
              <div className="overflow-x-auto overflow-y-auto max-h-[32rem] border rounded">
                <div className="min-w-[1200px]">
                  <Table className="text-sm w-full">
                    <TableHeader>
                      <TableRow className="text-xs">
                        <TableHead className="whitespace-nowrap">Sample Code</TableHead>
                        <TableHead className="whitespace-nowrap">Department</TableHead>
                        <TableHead className="whitespace-nowrap">Sample Description</TableHead>
                        <TableHead className="whitespace-nowrap">District</TableHead>
                        <TableHead className="whitespace-nowrap">Status</TableHead>
                        <TableHead className="whitespace-nowrap">Collected At</TableHead>
                        <TableHead className="whitespace-nowrap">Dispatched At</TableHead>
                        <TableHead className="whitespace-nowrap">Received At</TableHead>
                        <TableHead className="whitespace-nowrap">Under Testing</TableHead>
                        <TableHead className="whitespace-nowrap">Result Status</TableHead>
                        <TableHead className="whitespace-nowrap">Report Sent At</TableHead>
                        <TableHead className="whitespace-nowrap">Officer Name</TableHead>
                        <TableHead className="whitespace-nowrap">Seizure ID</TableHead>
                      </TableRow>
                    </TableHeader>
                    <TableBody>
                      {labSamples.map((sample) => (
                        <TableRow key={sample.id} className="text-xs">
                          <TableCell className="whitespace-nowrap">
                            {sample.sampleCode}
                          </TableCell>
                          <TableCell className="whitespace-nowrap">
                            {sample.department}
                          </TableCell>
                          <TableCell className="whitespace-nowrap">
                            {sample.sampleDesc}
                          </TableCell>
                          <TableCell className="whitespace-nowrap">
                            {sample.district}
                          </TableCell>
                          <TableCell className="whitespace-nowrap">
                            <span className={`px-2 py-1 rounded-full text-xs ${
                              sample.status === 'Completed' 
                                ? 'bg-green-100 text-green-800' 
                                : sample.status === 'Under Testing'
                                ? 'bg-blue-100 text-blue-800'
                                : sample.status === 'Pending'
                                ? 'bg-yellow-100 text-yellow-800'
                                : 'bg-gray-100 text-gray-800'
                            }`}>
                              {sample.status}
                            </span>
                          </TableCell>
                          <TableCell className="whitespace-nowrap">
                            {sample.collectedAt}
                          </TableCell>
                          <TableCell className="whitespace-nowrap">
                            {sample.dispatchedAt}
                          </TableCell>
                          <TableCell className="whitespace-nowrap">
                            {sample.receivedAt}
                          </TableCell>
                          <TableCell className="whitespace-nowrap">
                            <span className={`px-2 py-1 rounded-full text-xs ${
                              sample.underTesting 
                                ? 'bg-blue-100 text-blue-800' 
                                : 'bg-green-100 text-green-800'
                            }`}>
                              {sample.underTesting ? 'Yes' : 'No'}
                            </span>
                          </TableCell>
                          <TableCell className="whitespace-nowrap">
                            {sample.resultStatus}
                          </TableCell>
                          <TableCell className="whitespace-nowrap">
                            {sample.reportSentAt || '-'}
                          </TableCell>
                          <TableCell className="whitespace-nowrap">
                            {sample.officerName}
                          </TableCell>
                          <TableCell className="whitespace-nowrap">
                            {sample.seizureId || '-'}
                          </TableCell>
                        </TableRow>
                      ))}
                    </TableBody>
                  </Table>
                </div>
              </div>
            </CardContent>
          </Card>
        </TabsContent>
      </Tabs>
    </div>
  );
}
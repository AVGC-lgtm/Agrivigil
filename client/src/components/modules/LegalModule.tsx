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
import { Gavel, Building2, User, Calendar, FileText, MapPin } from "lucide-react";

export default function LegalModule() {
  const [firCases, setFirCases] = useState([
    {
      id: 1,
      firCode: "FIR001",
      policeStation: "Pune City Police Station",
      accusedParty: "UPL Limited",
      suspectName: "Rajesh Kumar",
      entityType: "Company",
      street1: "123 Main Street",
      street2: "Industrial Area",
      village: "Pune City",
      district: "Pune",
      state: "Maharashtra",
      licenseNo: "LIC123456",
      contactNo: "+91-9876543210",
      brandName: "UPL Fertilizer",
      fertilizerType: "NPK",
      batchNo: "BATCH2025001",
      manufactureDate: "2025-01-01",
      expiryDate: "2026-01-01",
      violationType: ["Counterfeit", "Quality Standards"],
      evidence: "Lab report attached",
      remarks: "Case filed based on lab analysis",
      status: "Under Investigation",
      labSampleId: 1,
    },
    {
      id: 2,
      firCode: "FIR002",
      policeStation: "Hinjewadi Police Station",
      accusedParty: "IFFCO",
      suspectName: "Suresh Patil",
      entityType: "Distributor",
      street1: "456 Industrial Road",
      street2: "Warehouse Complex",
      village: "Hinjewadi",
      district: "Pune",
      state: "Maharashtra",
      licenseNo: "LIC789012",
      contactNo: "+91-9876543211",
      brandName: "IFFCO Urea",
      fertilizerType: "Urea",
      batchNo: "BATCH2025002",
      manufactureDate: "2024-12-01",
      expiryDate: "2025-06-01",
      violationType: ["Expired Product", "Storage Violation"],
      evidence: "Physical inspection report",
      remarks: "Expired products found in storage",
      status: "Case Filed",
      labSampleId: 2,
    },
  ]);

  const districts = ["Pune", "Mumbai", "Nagpur", "Aurangabad"];
  const states = ["Maharashtra", "Delhi", "Karnataka", "Tamil Nadu"];
  const entityTypes = ["Company", "Distributor", "Retailer", "Individual", "Partnership"];
  const fertilizerTypes = ["NPK", "Urea", "DAP", "SSP", "MOP", "Complex"];
  const violationTypes = [
    "Counterfeit",
    "Quality Standards",
    "Expired Product",
    "Storage Violation",
    "Licensing Violation",
    "Misbranding",
    "Adulteration",
    "Illegal Import",
  ];
  const statuses = ["Pending", "Under Investigation", "Case Filed", "Court Proceedings", "Closed", "Disposed"];

  return (
    <div className="p-4">
      <Tabs defaultValue="fir" className="w-full">
        <TabsList className="grid grid-cols-2 w-full mb-4">
          <TabsTrigger value="fir">FIR Case Creation</TabsTrigger>
          <TabsTrigger value="cases">FIR Cases List</TabsTrigger>
        </TabsList>

        {/* === FIR CASE CREATION TAB === */}
        <TabsContent value="fir">
          <Card>
            <CardHeader>
              <CardTitle>Create FIR Case</CardTitle>
            </CardHeader>
            <CardContent>
              <form className="grid gap-4">
                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <Label>FIR Code</Label>
                    <Input placeholder="Auto-generated" readOnly />
                  </div>

                  <div>
                    <Label>Police Station</Label>
                    <Input placeholder="Enter Police Station Name" />
                  </div>
                </div>

                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <Label>Accused Party</Label>
                    <Input placeholder="Enter Accused Party Name" />
                  </div>

                  <div>
                    <Label>Suspect Name</Label>
                    <Input placeholder="Enter Suspect Name" />
                  </div>
                </div>

                <div>
                  <Label>Entity Type</Label>
                  <Select>
                    <SelectTrigger>
                      <SelectValue placeholder="Select Entity Type" />
                    </SelectTrigger>
                    <SelectContent>
                      {entityTypes.map((type) => (
                        <SelectItem key={type} value={type}>
                          {type}
                        </SelectItem>
                      ))}
                    </SelectContent>
                  </Select>
                </div>

                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <Label>Street 1</Label>
                    <Input placeholder="Enter Street Address 1" />
                  </div>

                  <div>
                    <Label>Street 2</Label>
                    <Input placeholder="Enter Street Address 2" />
                  </div>
                </div>

                <div className="grid grid-cols-3 gap-4">
                  <div>
                    <Label>Village/City</Label>
                    <Input placeholder="Enter Village or City" />
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
                    <Label>State</Label>
                    <Select>
                      <SelectTrigger>
                        <SelectValue placeholder="Select State" />
                      </SelectTrigger>
                      <SelectContent>
                        {states.map((s) => (
                          <SelectItem key={s} value={s}>
                            {s}
                          </SelectItem>
                        ))}
                      </SelectContent>
                    </Select>
                  </div>
                </div>

                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <Label>License No</Label>
                    <Input placeholder="Enter License Number" />
                  </div>

                  <div>
                    <Label>Contact No</Label>
                    <Input placeholder="Enter Contact Number" />
                  </div>
                </div>

                <div className="grid grid-cols-3 gap-4">
                  <div>
                    <Label>Brand Name</Label>
                    <Input placeholder="Enter Brand Name" />
                  </div>

                  <div>
                    <Label>Fertilizer Type</Label>
                    <Select>
                      <SelectTrigger>
                        <SelectValue placeholder="Select Type" />
                      </SelectTrigger>
                      <SelectContent>
                        {fertilizerTypes.map((type) => (
                          <SelectItem key={type} value={type}>
                            {type}
                          </SelectItem>
                        ))}
                      </SelectContent>
                    </Select>
                  </div>

                  <div>
                    <Label>Batch No</Label>
                    <Input placeholder="Enter Batch Number" />
                  </div>
                </div>

                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <Label>Manufacture Date</Label>
                    <Input type="date" />
                  </div>

                  <div>
                    <Label>Expiry Date</Label>
                    <Input type="date" />
                  </div>
                </div>

                <div>
                  <Label>Violation Type (Select all applicable)</Label>
                  <div className="grid grid-cols-2 gap-2">
                    {violationTypes.map((violation, i) => (
                      <div key={i} className="flex items-center gap-2">
                        <Checkbox /> <span>{violation}</span>
                      </div>
                    ))}
                  </div>
                </div>

                <div>
                  <Label>Evidence</Label>
                  <Textarea placeholder="Enter evidence details" />
                </div>

                <div>
                  <Label>Lab Sample ID (Optional)</Label>
                    <Select>
                      <SelectTrigger>
                        <SelectValue placeholder="Select Lab Sample ID" />
                      </SelectTrigger>
                      <SelectContent>
                        <SelectItem value="1">LAB001</SelectItem>
                        <SelectItem value="2">LAB002</SelectItem>
                      </SelectContent>
                    </Select>
                </div>

                <div>
                  <Label>Remarks</Label>
                  <Textarea placeholder="Enter additional remarks or observations" />
                </div>

                <Button className="w-fit">Save FIR Case</Button>
              </form>
            </CardContent>
          </Card>
        </TabsContent>

        {/* === FIR CASES LIST TAB === */}
        <TabsContent value="cases">
          <Card>
            <CardHeader>
              <CardTitle>FIR Cases List</CardTitle>
            </CardHeader>
            <CardContent>
              {/* FILTERS */}
              <div className="grid grid-cols-1 md:grid-cols-4 gap-4 mb-4">
                <div>
                  <Label>FIR Code</Label>
                  <Input placeholder="Filter by FIR code" />
                </div>

                <div>
                  <Label>Police Station</Label>
                  <Input placeholder="Filter by police station" />
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
                <div className="min-w-[1400px]">
                  <Table className="text-sm w-full">
                    <TableHeader>
                      <TableRow className="text-xs">
                        <TableHead className="whitespace-nowrap">FIR Code</TableHead>
                        <TableHead className="whitespace-nowrap">Police Station</TableHead>
                        <TableHead className="whitespace-nowrap">Accused Party</TableHead>
                        <TableHead className="whitespace-nowrap">Suspect Name</TableHead>
                        <TableHead className="whitespace-nowrap">Entity Type</TableHead>
                        <TableHead className="whitespace-nowrap">Address</TableHead>
                        <TableHead className="whitespace-nowrap">District</TableHead>
                        <TableHead className="whitespace-nowrap">License No</TableHead>
                        <TableHead className="whitespace-nowrap">Brand Name</TableHead>
                        <TableHead className="whitespace-nowrap">Fertilizer Type</TableHead>
                        <TableHead className="whitespace-nowrap">Batch No</TableHead>
                        <TableHead className="whitespace-nowrap">Violation Type</TableHead>
                        <TableHead className="whitespace-nowrap">Lab Sample ID</TableHead>
                        <TableHead className="whitespace-nowrap">Status</TableHead>
                      </TableRow>
                    </TableHeader>
                    <TableBody>
                      {firCases.map((fir) => (
                        <TableRow key={fir.id} className="text-xs">
                          <TableCell className="whitespace-nowrap">
                            {fir.firCode}
                          </TableCell>
                          <TableCell className="whitespace-nowrap">
                            {fir.policeStation}
                          </TableCell>
                          <TableCell className="whitespace-nowrap">
                            {fir.accusedParty}
                          </TableCell>
                          <TableCell className="whitespace-nowrap">
                            {fir.suspectName}
                          </TableCell>
                          <TableCell className="whitespace-nowrap">
                            {fir.entityType}
                          </TableCell>
                          <TableCell className="whitespace-nowrap">
                            {`${fir.street1}, ${fir.village}`}
                          </TableCell>
                          <TableCell className="whitespace-nowrap">
                            {fir.district}
                          </TableCell>
                          <TableCell className="whitespace-nowrap">
                            {fir.licenseNo}
                          </TableCell>
                          <TableCell className="whitespace-nowrap">
                            {fir.brandName}
                          </TableCell>
                          <TableCell className="whitespace-nowrap">
                            {fir.fertilizerType}
                          </TableCell>
                          <TableCell className="whitespace-nowrap">
                            {fir.batchNo}
                          </TableCell>
                          <TableCell className="whitespace-nowrap">
                            {fir.violationType.join(", ")}
                          </TableCell>
                          <TableCell className="whitespace-nowrap">
                            {fir.labSampleId || '-'}
                          </TableCell>
                          <TableCell className="whitespace-nowrap">
                            <span className={`px-2 py-1 rounded-full text-xs ${
                              fir.status === 'Under Investigation' 
                                ? 'bg-blue-100 text-blue-800' 
                                : fir.status === 'Case Filed'
                                ? 'bg-purple-100 text-purple-800'
                                : fir.status === 'Court Proceedings'
                                ? 'bg-orange-100 text-orange-800'
                                : fir.status === 'Closed'
                                ? 'bg-green-100 text-green-800'
                                : fir.status === 'Pending'
                                ? 'bg-yellow-100 text-yellow-800'
                                : 'bg-gray-100 text-gray-800'
                            }`}>
                              {fir.status}
                            </span>
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

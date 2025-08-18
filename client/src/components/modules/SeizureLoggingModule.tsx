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
import { Package, MapPin, Camera, Video, FileText, Scale } from "lucide-react";

export default function SeizureLoggingModule() {
  const [seizures, setSeizures] = useState([
    {
      id: "SEZ001",
      seizureCode: "SEZ001",
      fieldExecutionId: "FE001",
      location: "Pune City",
      district: "Pune",
      taluka: "Pune City",
      premisesType: ["Retail Fertilizer Shop"],
      fertilizerType: "NPK",
      batchNo: "BATCH2025001",
      quantity: 500.0,
      estimatedValue: "₹25,000",
      witnessName: "Rajesh Kumar",
      evidencePhotos: ["photo1.jpg", "photo2.jpg"],
      videoEvidence: "video1.mp4",
      status: "Pending",
      remarks: "Suspicious packaging found",
      seizureDate: "2025-01-15",
      memoNo: "MEMO001",
      officerName: "Priya Sharma",
    },
    {
      id: "SEZ002",
      seizureCode: "SEZ002",
      fieldExecutionId: "FE002",
      location: "Hinjewadi",
      district: "Pune",
      taluka: "Hinjewadi",
      premisesType: ["Distributor's Office / Depot"],
      fertilizerType: "Urea",
      batchNo: "BATCH2025002",
      quantity: 1000.0,
      estimatedValue: "₹35,000",
      witnessName: "Suresh Patil",
      evidencePhotos: ["photo3.jpg"],
      videoEvidence: "",
      status: "Under Investigation",
      remarks: "Expired product found",
      seizureDate: "2025-01-16",
      memoNo: "MEMO002",
      officerName: "Suresh Patil",
    },
  ]);

  const districts = ["Pune", "Mumbai", "Nagpur", "Aurangabad"];
  const talukas = ["Pune City", "Hinjewadi", "Shivaji Nagar", "Koregaon Park"];
  const fertilizerTypes = ["NPK", "Urea", "DAP", "SSP", "MOP", "Complex"];
  const premisesTypes = [
    "Manufacturer Unit",
    "Formulation Plant",
    "Blending Plant",
    "Warehouse (Private / Govt/CWC/Co-op)",
    "Retail Fertilizer Shop",
    "Wholesale Fertilizer Dealer",
    "Distributor's Office / Depot",
    "Farmer's Field (For Complaint Verification)",
    "Market Yard / Agro-input Cluster",
  ];
  const statuses = ["Pending", "Under Investigation", "Case Filed", "Closed", "Disposed"];

  return (
    <div className="p-4">
      <Tabs defaultValue="logging" className="w-full">
        <TabsList className="grid grid-cols-2 w-full mb-4">
          <TabsTrigger value="logging">Seizure Logging</TabsTrigger>
          <TabsTrigger value="seizures">Seizures List</TabsTrigger>
        </TabsList>

        {/* === SEIZURE LOGGING TAB === */}
        <TabsContent value="logging">
          <Card>
            <CardHeader>
              <CardTitle>Create Seizure Record</CardTitle>
            </CardHeader>
            <CardContent>
              <form className="grid gap-4">
                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <Label>Field Execution ID</Label>
                    <Select>
                      <SelectTrigger>
                        <SelectValue placeholder="Select Field Execution" />
                      </SelectTrigger>
                      <SelectContent>
                        <SelectItem value="FE001">FE001</SelectItem>
                        <SelectItem value="FE002">FE002</SelectItem>
                      </SelectContent>
                    </Select>
                  </div>

                  <div>
                    <Label>Seizure Code</Label>
                    <Input placeholder="Auto-generated" readOnly />
                  </div>
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
                    <Label>Taluka</Label>
                    <Select>
                      <SelectTrigger>
                        <SelectValue placeholder="Select Taluka" />
                      </SelectTrigger>
                      <SelectContent>
                        {talukas.map((t) => (
                          <SelectItem key={t} value={t}>
                            {t}
                          </SelectItem>
                        ))}
                      </SelectContent>
                    </Select>
                  </div>
                </div>

                <div>
                  <Label>Location / Address</Label>
                  <Input placeholder="Enter detailed location or address" />
                </div>

                <div>
                  <Label>Type of Premises (Select all applicable)</Label>
                  <div className="grid grid-cols-2 gap-2">
                    {premisesTypes.map((prem, i) => (
                      <div key={i} className="flex items-center gap-2">
                        <Checkbox /> <span>{prem}</span>
                      </div>
                    ))}
                  </div>
                </div>

                <div className="grid grid-cols-3 gap-4">
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
                    <Input placeholder="Enter Batch No" />
                  </div>

                  <div>
                    <Label>Quantity (kg)</Label>
                    <Input type="number" step="0.01" placeholder="0.00" />
                  </div>
                </div>

                <div>
                  <Label>Estimated Value</Label>
                  <Input placeholder="Enter estimated value" />
                </div>

                <div>
                  <Label>Witness Name</Label>
                  <Input placeholder="Enter witness name" />
                </div>

                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <Label>Evidence Photos</Label>
                    <div className="border-2 border-dashed border-gray-300 rounded-lg p-4 text-center">
                      <Camera className="mx-auto h-12 w-12 text-gray-400" />
                      <p className="mt-2 text-sm text-gray-600">Click to upload photos</p>
                    </div>
                  </div>

                  <div>
                    <Label>Video Evidence</Label>
                    <div className="border-2 border-dashed border-gray-300 rounded-lg p-4 text-center">
                      <Video className="mx-auto h-12 w-12 text-gray-400" />
                      <p className="mt-2 text-sm text-gray-600">Click to upload video</p>
                    </div>
                  </div>
                </div>

                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <Label>Seizure Date</Label>
                    <Input type="datetime-local" />
                  </div>

                  <div>
                    <Label>Memo No</Label>
                    <Input placeholder="Enter memo number" />
                  </div>
                </div>

                <div>
                  <Label>Officer Name</Label>
                  <Input placeholder="Enter officer name" />
                </div>

                <div>
                  <Label>Remarks</Label>
                  <Textarea placeholder="Enter additional remarks or observations" />
                </div>

                <Button className="w-fit">Save Seizure Record</Button>
              </form>
            </CardContent>
          </Card>
        </TabsContent>

        {/* === SEIZURES LIST TAB === */}
        <TabsContent value="seizures">
          <Card>
            <CardHeader>
              <CardTitle>Seizures List</CardTitle>
            </CardHeader>
            <CardContent>
              {/* FILTERS */}
              <div className="grid grid-cols-1 md:grid-cols-4 gap-4 mb-4">
                <div>
                  <Label>Seizure Code</Label>
                  <Input placeholder="Filter by seizure code" />
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
                        <TableHead className="whitespace-nowrap">Seizure Code</TableHead>
                        <TableHead className="whitespace-nowrap">Field Execution ID</TableHead>
                        <TableHead className="whitespace-nowrap">Location</TableHead>
                        <TableHead className="whitespace-nowrap">District</TableHead>
                        <TableHead className="whitespace-nowrap">Taluka</TableHead>
                        <TableHead className="whitespace-nowrap">Premises Type</TableHead>
                        <TableHead className="whitespace-nowrap">Fertilizer Type</TableHead>
                        <TableHead className="whitespace-nowrap">Batch No</TableHead>
                        <TableHead className="whitespace-nowrap">Quantity (kg)</TableHead>
                        <TableHead className="whitespace-nowrap">Estimated Value</TableHead>
                        <TableHead className="whitespace-nowrap">Witness Name</TableHead>
                        <TableHead className="whitespace-nowrap">Seizure Date</TableHead>
                        <TableHead className="whitespace-nowrap">Memo No</TableHead>
                        <TableHead className="whitespace-nowrap">Officer Name</TableHead>
                        <TableHead className="whitespace-nowrap">Status</TableHead>
                      </TableRow>
                    </TableHeader>
                    <TableBody>
                      {seizures.map((seizure) => (
                        <TableRow key={seizure.id} className="text-xs">
                          <TableCell className="whitespace-nowrap">
                            {seizure.seizureCode}
                          </TableCell>
                          <TableCell className="whitespace-nowrap">
                            {seizure.fieldExecutionId}
                          </TableCell>
                          <TableCell className="whitespace-nowrap">
                            {seizure.location}
                          </TableCell>
                          <TableCell className="whitespace-nowrap">
                            {seizure.district}
                          </TableCell>
                          <TableCell className="whitespace-nowrap">
                            {seizure.taluka}
                          </TableCell>
                          <TableCell className="whitespace-nowrap">
                            {seizure.premisesType.join(", ")}
                          </TableCell>
                          <TableCell className="whitespace-nowrap">
                            {seizure.fertilizerType}
                          </TableCell>
                          <TableCell className="whitespace-nowrap">
                            {seizure.batchNo}
                          </TableCell>
                          <TableCell className="whitespace-nowrap">
                            {seizure.quantity}
                          </TableCell>
                          <TableCell className="whitespace-nowrap">
                            {seizure.estimatedValue}
                          </TableCell>
                          <TableCell className="whitespace-nowrap">
                            {seizure.witnessName}
                          </TableCell>
                          <TableCell className="whitespace-nowrap">
                            {seizure.seizureDate}
                          </TableCell>
                          <TableCell className="whitespace-nowrap">
                            {seizure.memoNo}
                          </TableCell>
                          <TableCell className="whitespace-nowrap">
                            {seizure.officerName}
                          </TableCell>
                          <TableCell className="whitespace-nowrap">
                            <span className={`px-2 py-1 rounded-full text-xs ${
                              seizure.status === 'Pending' 
                                ? 'bg-yellow-100 text-yellow-800' 
                                : seizure.status === 'Under Investigation'
                                ? 'bg-blue-100 text-blue-800'
                                : seizure.status === 'Case Filed'
                                ? 'bg-purple-100 text-purple-800'
                                : seizure.status === 'Closed'
                                ? 'bg-green-100 text-green-800'
                                : 'bg-gray-100 text-gray-800'
                            }`}>
                              {seizure.status}
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



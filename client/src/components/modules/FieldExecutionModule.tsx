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
import { Building2, Package, User, Calendar, FileText, Camera } from "lucide-react";

export default function FieldExecutionModule() {
  const [fieldExecutions, setFieldExecutions] = useState([
    {
      id: "FE001",
      inspectionId: "450001",
      fieldCode: "FE001",
      companyName: "UPL Limited",
      productName: "UPL Fertilizer NPK 20:20:20",
      dealerName: "ABC Agro Center",
      registrationNo: "REG123456",
      samplingDate: "2025-01-15",
      fertilizerType: "NPK",
      batchNo: "BATCH2025001",
      manufactureDate: "2025-01-01",
      stockReceiptDate: "2025-01-10",
      sampleCode: "SAMP001",
      stockPosition: "Good",
      physicalCondition: "Excellent",
      specificationFCO: "FCO-1985",
      compositionAnalysis: "N: 20%, P: 20%, K: 20%",
      variation: "Within limits",
      moisture: 2.5,
      totalN: 20.0,
      nh4n: 15.0,
      nh4no3n: 5.0,
      ureaN: 0.0,
      totalP2o5: 20.0,
      nacSolubleP2o5: 18.0,
      citricSolubleP2o5: 2.0,
      waterSolubleP2o5: 20.0,
      waterSolubleK2o: 20.0,
      particleSize: "Standard",
      document: "uploaded",
      productPhoto: "uploaded",
      status: "Completed",
    },
    {
      id: "FE002",
      inspectionId: "450002",
      fieldCode: "FE002",
      companyName: "IFFCO",
      productName: "IFFCO Urea 46-0-0",
      dealerName: "XYZ Fertilizer Store",
      registrationNo: "REG789012",
      samplingDate: "2025-01-16",
      fertilizerType: "Urea",
      batchNo: "BATCH2025002",
      manufactureDate: "2025-01-05",
      stockReceiptDate: "2025-01-12",
      sampleCode: "SAMP002",
      stockPosition: "Fair",
      physicalCondition: "Good",
      specificationFCO: "FCO-1985",
      compositionAnalysis: "N: 46%",
      variation: "Within limits",
      moisture: 1.8,
      totalN: 46.0,
      nh4n: 0.0,
      nh4no3n: 0.0,
      ureaN: 46.0,
      totalP2o5: 0.0,
      nacSolubleP2o5: 0.0,
      citricSolubleP2o5: 0.0,
      waterSolubleP2o5: 0.0,
      waterSolubleK2o: 0.0,
      particleSize: "Standard",
      document: "uploaded",
      productPhoto: "uploaded",
      status: "In Progress",
    },
  ]);

  const districts = ["Pune", "Mumbai", "Nagpur", "Aurangabad"];
  const talukas = ["Pune City", "Hinjewadi", "Shivaji Nagar", "Koregaon Park"];
  const fertilizerTypes = ["NPK", "Urea", "DAP", "SSP", "MOP", "Complex"];
  const stockPositions = ["Excellent", "Good", "Fair", "Poor"];
  const physicalConditions = ["Excellent", "Good", "Fair", "Poor"];
  const particleSizes = ["Standard", "Fine", "Coarse", "Irregular"];

  return (
    <div className="p-4">
      <Tabs defaultValue="execution" className="w-full">
        <TabsList className="grid grid-cols-2 w-full mb-4">
          <TabsTrigger value="execution">Field Execution</TabsTrigger>
          <TabsTrigger value="executions">Field Executions List</TabsTrigger>
        </TabsList>

        {/* === FIELD EXECUTION TAB === */}
        <TabsContent value="execution">
          <Card>
            <CardHeader>
              <CardTitle>Create Field Execution</CardTitle>
            </CardHeader>
            <CardContent>
              <form className="grid gap-4">
                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <Label>Inspection ID</Label>
                    <Select>
                      <SelectTrigger>
                        <SelectValue placeholder="Select Inspection ID" />
                      </SelectTrigger>
                      <SelectContent>
                        <SelectItem value="450001">450001</SelectItem>
                        <SelectItem value="450002">450002</SelectItem>
                      </SelectContent>
                    </Select>
                  </div>

                  <div>
                    <Label>Field Code</Label>
                    <Input placeholder="Auto-generated" readOnly />
                  </div>
                </div>

                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <Label>Company Name</Label>
                    <Input placeholder="Enter Company Name" />
                  </div>

                  <div>
                    <Label>Product Name</Label>
                    <Input placeholder="Enter Product Name" />
                  </div>
                </div>

                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <Label>Dealer Name</Label>
                    <Input placeholder="Enter Dealer Name" />
                  </div>

                  <div>
                    <Label>Registration No</Label>
                    <Input placeholder="Enter Registration No" />
                  </div>
                </div>

                <div className="grid grid-cols-3 gap-4">
                  <div>
                    <Label>Sampling Date</Label>
                    <Input type="datetime-local" />
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
                    <Input placeholder="Enter Batch No" />
                  </div>
                </div>

                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <Label>Manufacture/Import Date</Label>
                    <Input type="date" />
                  </div>

                  <div>
                    <Label>Stock Receipt Date</Label>
                    <Input type="date" />
                  </div>
                </div>

                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <Label>Sample Code</Label>
                    <Input placeholder="Enter Sample Code" />
                  </div>

                  <div>
                    <Label>Stock Position</Label>
                    <Select>
                      <SelectTrigger>
                        <SelectValue placeholder="Select Position" />
                      </SelectTrigger>
                      <SelectContent>
                        {stockPositions.map((pos) => (
                          <SelectItem key={pos} value={pos}>
                            {pos}
                          </SelectItem>
                        ))}
                      </SelectContent>
                    </Select>
                  </div>
                </div>

                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <Label>Physical Condition</Label>
                    <Select>
                      <SelectTrigger>
                        <SelectValue placeholder="Select Condition" />
                      </SelectTrigger>
                      <SelectContent>
                        {physicalConditions.map((cond) => (
                          <SelectItem key={cond} value={cond}>
                            {cond}
                          </SelectItem>
                        ))}
                      </SelectContent>
                    </Select>
                  </div>

                  <div>
                    <Label>Specification (FCO)</Label>
                    <Input placeholder="Enter FCO Specification" />
                  </div>
                </div>

                <div>
                  <Label>Composition Analysis</Label>
                  <Textarea placeholder="Enter detailed composition analysis" />
                </div>

                <div>
                  <Label>Variation</Label>
                  <Input placeholder="Enter variation details" />
                </div>

                {/* === CHEMICAL ANALYSIS SECTION === */}
                <div className="border rounded-lg p-4">
                  <h3 className="text-lg font-semibold mb-4">Chemical Analysis</h3>
                  <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
                    <div>
                      <Label>Moisture (%)</Label>
                      <Input type="number" step="0.01" placeholder="0.00" />
                    </div>
                    <div>
                      <Label>Total N (%)</Label>
                      <Input type="number" step="0.01" placeholder="0.00" />
                    </div>
                    <div>
                      <Label>NH4-N (%)</Label>
                      <Input type="number" step="0.01" placeholder="0.00" />
                    </div>
                    <div>
                      <Label>NH4NO3-N (%)</Label>
                      <Input type="number" step="0.01" placeholder="0.00" />
                    </div>
                    <div>
                      <Label>Urea-N (%)</Label>
                      <Input type="number" step="0.01" placeholder="0.00" />
                    </div>
                    <div>
                      <Label>Total P2O5 (%)</Label>
                      <Input type="number" step="0.01" placeholder="0.00" />
                    </div>
                    <div>
                      <Label>NAC Soluble P2O5 (%)</Label>
                      <Input type="number" step="0.01" placeholder="0.00" />
                    </div>
                    <div>
                      <Label>Citric Soluble P2O5 (%)</Label>
                      <Input type="number" step="0.01" placeholder="0.00" />
                    </div>
                    <div>
                      <Label>Water Soluble P2O5 (%)</Label>
                      <Input type="number" step="0.01" placeholder="0.00" />
                    </div>
                    <div>
                      <Label>Water Soluble K2O (%)</Label>
                      <Input type="number" step="0.01" placeholder="0.00" />
                    </div>
                  </div>
                </div>

                <div>
                  <Label>Particle Size</Label>
                  <Select>
                    <SelectTrigger>
                      <SelectValue placeholder="Select Particle Size" />
                    </SelectTrigger>
                    <SelectContent>
                      {particleSizes.map((size) => (
                        <SelectItem key={size} value={size}>
                          {size}
                        </SelectItem>
                      ))}
                    </SelectContent>
                  </Select>
                </div>

                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <Label>Document Upload</Label>
                    <div className="border-2 border-dashed border-gray-300 rounded-lg p-4 text-center">
                      <FileText className="mx-auto h-12 w-12 text-gray-400" />
                      <p className="mt-2 text-sm text-gray-600">Click to upload documents</p>
                    </div>
                  </div>

                  <div>
                    <Label>Product Photo</Label>
                    <div className="border-2 border-dashed border-gray-300 rounded-lg p-4 text-center">
                      <Camera className="mx-auto h-12 w-12 text-gray-400" />
                      <p className="mt-2 text-sm text-gray-600">Click to upload photo</p>
                    </div>
                  </div>
                </div>

                <Button className="w-fit">Save Field Execution</Button>
              </form>
            </CardContent>
          </Card>
        </TabsContent>

        {/* === FIELD EXECUTIONS LIST TAB === */}
        <TabsContent value="executions">
          <Card>
            <CardHeader>
              <CardTitle>Field Executions List</CardTitle>
            </CardHeader>
            <CardContent>
              {/* FILTERS */}
              <div className="grid grid-cols-1 md:grid-cols-4 gap-4 mb-4">
                <div>
                  <Label>Company Name</Label>
                  <Input placeholder="Filter by company" />
                </div>

                <div>
                  <Label>Product Name</Label>
                  <Input placeholder="Filter by product" />
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
                      <SelectItem value="Completed">Completed</SelectItem>
                      <SelectItem value="In Progress">In Progress</SelectItem>
                      <SelectItem value="Pending">Pending</SelectItem>
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
                        <TableHead className="whitespace-nowrap">Field Code</TableHead>
                        <TableHead className="whitespace-nowrap">Inspection ID</TableHead>
                        <TableHead className="whitespace-nowrap">Company Name</TableHead>
                        <TableHead className="whitespace-nowrap">Product Name</TableHead>
                        <TableHead className="whitespace-nowrap">Dealer Name</TableHead>
                        <TableHead className="whitespace-nowrap">Fertilizer Type</TableHead>
                        <TableHead className="whitespace-nowrap">Batch No</TableHead>
                        <TableHead className="whitespace-nowrap">Sampling Date</TableHead>
                        <TableHead className="whitespace-nowrap">Stock Position</TableHead>
                        <TableHead className="whitespace-nowrap">Physical Condition</TableHead>
                        <TableHead className="whitespace-nowrap">Total N (%)</TableHead>
                        <TableHead className="whitespace-nowrap">Total P2O5 (%)</TableHead>
                        <TableHead className="whitespace-nowrap">Status</TableHead>
                      </TableRow>
                    </TableHeader>
                    <TableBody>
                      {fieldExecutions.map((execution) => (
                        <TableRow key={execution.id} className="text-xs">
                          <TableCell className="whitespace-nowrap">
                            {execution.fieldCode}
                          </TableCell>
                          <TableCell className="whitespace-nowrap">
                            {execution.inspectionId}
                          </TableCell>
                          <TableCell className="whitespace-nowrap">
                            {execution.companyName}
                          </TableCell>
                          <TableCell className="whitespace-nowrap">
                            {execution.productName}
                          </TableCell>
                          <TableCell className="whitespace-nowrap">
                            {execution.dealerName}
                          </TableCell>
                          <TableCell className="whitespace-nowrap">
                            {execution.fertilizerType}
                          </TableCell>
                          <TableCell className="whitespace-nowrap">
                            {execution.batchNo}
                          </TableCell>
                          <TableCell className="whitespace-nowrap">
                            {execution.samplingDate}
                          </TableCell>
                          <TableCell className="whitespace-nowrap">
                            {execution.stockPosition}
                          </TableCell>
                          <TableCell className="whitespace-nowrap">
                            {execution.physicalCondition}
                          </TableCell>
                          <TableCell className="whitespace-nowrap">
                            {execution.totalN}%
                          </TableCell>
                          <TableCell className="whitespace-nowrap">
                            {execution.totalP2o5}%
                          </TableCell>
                          <TableCell className="whitespace-nowrap">
                            <span className={`px-2 py-1 rounded-full text-xs ${
                              execution.status === 'Completed' 
                                ? 'bg-green-100 text-green-800' 
                                : execution.status === 'In Progress'
                                ? 'bg-yellow-100 text-yellow-800'
                                : 'bg-gray-100 text-gray-800'
                            }`}>
                              {execution.status}
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
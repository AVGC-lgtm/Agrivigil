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
import { useToast } from "@/hooks/use-toast";
import { Camera, MapPin, Cpu, QrCode, RefreshCw } from "lucide-react";

export default function InspectionPlanningModule() {
  const { toast } = useToast();
  const [inspections, setInspections] = useState([
    {
      id: "450001",
      officerCode: "00001",
      officerName: "Priya Sharma",
      visitDateTime: "31-07-2025 1:30 PM",
      district: "Pune",
      taluka: "Pune City",
      area: "Mandai",
      targetType: "Retailer",
      visitPurpose: ["Routine"],
      totalTarget: 10,
      targetAchieved: 10,
      status: "Completed",
      assignedEquipment: ["TruScan Device", "Gemini Analyzer", "Axon Body Cam"],
    },
    {
      id: "450002",
      officerCode: "00002",
      officerName: "Suresh Patil",
      visitDateTime: "31-07-2025 1:30 PM",
      district: "Pune",
      taluka: "Pune City",
      area: "Sadashiv Peth",
      targetType: "Distributor",
      visitPurpose: ["Routine"],
      totalTarget: 10,
      targetAchieved: 9,
      status: "In Progress",
      assignedEquipment: ["TruScan Device", "Gemini Analyzer", "Axon Body Cam"],
    },
  ]);

  const [formData, setFormData] = useState({
    officerCode: "",
    visitDateTime: "",
    district: "",
    taluka: "",
    location: "",
    address: "",
    targetType: "",
    premisesTypes: [] as string[],
    visitPurpose: [] as string[],
    assignedEquipment: [] as string[],
    totalTarget: 10,
  });

  const [loading, setLoading] = useState(false);
  const [refreshLoading, setRefreshLoading] = useState(false);

  const districts = ["Pune", "Mumbai", "Nagpur"];
  const talukas = ["Pune City", "Hinjewadi", "Shivaji Nagar"];
  const officers = [
    { name: "Priya Sharma", code: "00001" },
    { name: "Suresh Patil", code: "00002" },
  ];

  const targetTypes = [
    {
      value: "retailer",
      label: "Retailer",
      description: "Local shop or store inspection",
    },
    {
      value: "distributor",
      label: "Distributor",
      description: "Regional distributor facility",
    },
    {
      value: "warehouse",
      label: "Warehouse",
      description: "Storage facility inspection",
    },
    {
      value: "market-survey",
      label: "Market Survey",
      description: "General market area survey",
    },
  ];

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

  const visitPurposes = [
    "Routine",
    "Complaint",
    "Raid",
    "Follow-up",
    "Sample Collection",
    "Licensing",
  ];

  const equipmentList = [
    { name: "TruScan Device", icon: <QrCode className="w-5 h-5" /> },
    { name: "Gemini Analyzer", icon: <Cpu className="w-5 h-5" /> },
    { name: "Axon Body Cam", icon: <Camera className="w-5 h-5" /> },
    { name: "GPS Tracker", icon: <MapPin className="w-5 h-5" /> },
  ];

  const handleInputChange = (field: string, value: string | string[] | number) => {
    setFormData(prev => ({ ...prev, [field]: value }));
  };

  const handleCheckboxChange = (field: string, value: string, checked: boolean) => {
    setFormData(prev => {
      const currentValues = prev[field as keyof typeof prev] as string[];
      const newValues = checked 
        ? [...currentValues, value] 
        : currentValues.filter(item => item !== value);
      return { ...prev, [field]: newValues };
    });
  };

  const handleRefreshInspections = () => {
    setRefreshLoading(true);
    // Simulate API call
    setTimeout(() => {
      toast({
        title: "Inspections Refreshed",
        description: "Latest inspection data has been loaded.",
      });
      setRefreshLoading(false);
    }, 1000);
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);

    // Validate required fields
    if (
      !formData.officerCode ||
      !formData.visitDateTime ||
      !formData.district ||
      !formData.taluka ||
      !formData.location ||
      !formData.targetType
    ) {
      toast({
        title: "Validation Error",
        description: "Please fill all required fields.",
        variant: "destructive",
      });
      setLoading(false);
      return;
    }

    // Validate visit date is not in the past
    const selectedDate = new Date(formData.visitDateTime);
    const now = new Date();
    if (selectedDate < now) {
      toast({
        title: "Invalid Date",
        description: "Please select a future date and time for the visit.",
        variant: "destructive",
      });
      setLoading(false);
      return;
    }

    // Simulate API call
    setTimeout(() => {
      const newInspection = {
        id: `45000${inspections.length + 1}`,
        officerCode: formData.officerCode,
        officerName: officers.find(o => o.code === formData.officerCode)?.name || "Unknown",
        visitDateTime: new Date(formData.visitDateTime).toLocaleString(),
        district: formData.district,
        taluka: formData.taluka,
        area: formData.location,
        targetType: formData.targetType,
        visitPurpose: formData.visitPurpose,
        totalTarget: formData.totalTarget,
        targetAchieved: 0,
        status: "Scheduled",
        assignedEquipment: formData.assignedEquipment,
      };

      setInspections(prev => [newInspection, ...prev]);
      
      toast({
        title: "Inspection Scheduled",
        description: "New inspection has been successfully created.",
      });

      // Reset form
      setFormData({
        officerCode: "",
        visitDateTime: "",
        district: "",
        taluka: "",
        location: "",
        address: "",
        targetType: "",
        premisesTypes: [],
        visitPurpose: [],
        assignedEquipment: [],
        totalTarget: 10,
      });

      setLoading(false);
    }, 1500);
  };

  return (
    <div className="p-4">
      <Tabs defaultValue="planning" className="w-full">
        <TabsList className="grid grid-cols-2 w-full mb-4">
          <TabsTrigger value="planning">Inspection Planning</TabsTrigger>
          <TabsTrigger value="scheduled">Scheduled Inspections</TabsTrigger>
        </TabsList>

        {/* === INSPECTION PLANNING TAB === */}
        <TabsContent value="planning">
          <Card>
            <CardHeader>
              <CardTitle>Create Inspection</CardTitle>
            </CardHeader>
            <CardContent>
              <form onSubmit={handleSubmit} className="grid gap-4">
                <div>
                  <Label>Inspection Code</Label>
                  <Input placeholder="Auto-generated" readOnly />
                </div>

                <div>
                  <Label>Officer Code *</Label>
                  <Select
                    value={formData.officerCode}
                    onValueChange={(value) => handleInputChange("officerCode", value)}
                  >
                    <SelectTrigger>
                      <SelectValue placeholder="Select Officer Code" />
                    </SelectTrigger>
                    <SelectContent>
                      {officers.map((o) => (
                        <SelectItem key={o.code} value={o.code}>
                          {o.code} - {o.name}
                        </SelectItem>
                      ))}
                    </SelectContent>
                  </Select>
                </div>

                <div>
                  <Label>Visit Date & Time *</Label>
                  <Input
                    type="datetime-local"
                    value={formData.visitDateTime}
                    onChange={(e) =>
                      handleInputChange("visitDateTime", e.target.value)
                    }
                  />
                </div>

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

                <div className="grid grid-cols-3 gap-4">
                  <div>
                    <Label>District *</Label>
                    <Select
                      value={formData.district}
                      onValueChange={(value) =>
                        handleInputChange("district", value)
                      }
                    >
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
                    <Label>Taluka *</Label>
                    <Select
                      value={formData.taluka}
                      onValueChange={(value) =>
                        handleInputChange("taluka", value)
                      }
                    >
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

                  <div>
                    <Label>Location / Village *</Label>
                    <Input
                      placeholder="Enter Location / Village"
                      value={formData.location}
                      onChange={(e) =>
                        handleInputChange("location", e.target.value)
                      }
                    />
                  </div>
                </div>

                <div>
                  <Label>Address / Landmark</Label>
                  <Input
                    placeholder="Enter Address or Landmark"
                    value={formData.address}
                    onChange={(e) =>
                      handleInputChange("address", e.target.value)
                    }
                  />
                </div>

                <div>
                  <Label>Target Type *</Label>
                  <Select
                    value={formData.targetType}
                    onValueChange={(value) =>
                      handleInputChange("targetType", value)
                    }
                  >
                    <SelectTrigger>
                      <SelectValue placeholder="Select Target Type" />
                    </SelectTrigger>
                    <SelectContent>
                      {targetTypes.map((type) => (
                        <SelectItem key={type.value} value={type.value}>
                          {type.label} - {type.description}
                        </SelectItem>
                      ))}
                    </SelectContent>
                  </Select>
                </div>

                <div>
                  <Label>Type of Premises (Select all applicable)</Label>
                  <div className="grid grid-cols-2 gap-2">
                    {premisesTypes.map((prem, i) => (
                      <div key={i} className="flex items-center gap-2">
                        <Checkbox
                          checked={formData.premisesTypes.includes(prem)}
                          onCheckedChange={(checked) =>
                            handleCheckboxChange(
                              "premisesTypes",
                              prem,
                              checked as boolean
                            )
                          }
                        />{" "}
                        <span>{prem}</span>
                      </div>
                    ))}
                  </div>
                </div>

                <div>
                  <Label>Visit Purpose (Select all applicable)</Label>
                  <div className="grid grid-cols-3 gap-2">
                    {visitPurposes.map((purpose) => (
                      <div key={purpose} className="flex items-center gap-2">
                        <Checkbox
                          checked={formData.visitPurpose.includes(purpose)}
                          onCheckedChange={(checked) =>
                            handleCheckboxChange(
                              "visitPurpose",
                              purpose,
                              checked as boolean
                            )
                          }
                        />{" "}
                        <span>{purpose}</span>
                      </div>
                    ))}
                  </div>
                </div>

                {/* === ASSIGNED EQUIPMENT SECTION WITH ICONS === */}
                <div>
                  <Label>Assign Equipment</Label>
                  <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
                    {equipmentList.map((eq) => (
                      <div
                        key={eq.name}
                        className="flex items-center gap-2 border rounded p-2"
                      >
                        <Checkbox
                          checked={formData.assignedEquipment.includes(eq.name)}
                          onCheckedChange={(checked) =>
                            handleCheckboxChange(
                              "assignedEquipment",
                              eq.name,
                              checked as boolean
                            )
                          }
                        />
                        <div className="flex items-center gap-1">
                          {eq.icon} <span>{eq.name}</span>
                        </div>
                      </div>
                    ))}
                  </div>
                </div>

                <div>
                  <Label>Total Target</Label>
                  <Input
                    type="number"
                    value={formData.totalTarget}
                    onChange={(e) =>
                      handleInputChange("totalTarget", parseInt(e.target.value))
                    }
                  />
                </div>

                <Button type="submit" className="w-fit" disabled={loading}>
                  {loading ? (
                    <>
                      <RefreshCw className="mr-2 h-4 w-4 animate-spin" />
                      Saving...
                    </>
                  ) : (
                    "Save Inspection"
                  )}
                </Button>
              </form>
            </CardContent>
          </Card>
        </TabsContent>

        {/* === SCHEDULED INSPECTIONS TAB === */}
        <TabsContent value="scheduled">
          <Card>
            <CardHeader>
              <div className="flex justify-between items-center">
                <CardTitle>Scheduled Inspections</CardTitle>
                <Button
                  variant="outline"
                  size="sm"
                  onClick={handleRefreshInspections}
                  disabled={refreshLoading}
                >
                  <RefreshCw
                    className={`mr-2 h-4 w-4 ${
                      refreshLoading ? "animate-spin" : ""
                    }`}
                  />
                  Refresh
                </Button>
              </div>
            </CardHeader>
            <CardContent>
              {/* FILTERS */}
              <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mb-4">
                {/* Officer Name */}
                <div>
                  <Label>Officer Name</Label>
                  <Select>
                    <SelectTrigger>
                      <SelectValue placeholder="Select Officer" />
                    </SelectTrigger>
                    <SelectContent>
                      {officers.map((o) => (
                        <SelectItem key={o.name} value={o.name}>
                          {o.name}
                        </SelectItem>
                      ))}
                    </SelectContent>
                  </Select>
                </div>

                {/* District */}
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

                {/* Taluka */}
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

                {/* Visit Date From */}
                <div>
                  <Label>Visit Date From</Label>
                  <Input type="date" />
                </div>

                {/* Visit Date To */}
                <div>
                  <Label>Visit Date To</Label>
                  <Input type="date" />
                </div>

                {/* Target Type */}
                <div>
                  <Label>Target Type</Label>
                  <Select>
                    <SelectTrigger>
                      <SelectValue placeholder="Select Target Type" />
                    </SelectTrigger>
                    <SelectContent>
                      {targetTypes.map((type) => (
                        <SelectItem key={type.value} value={type.value}>
                          {type.label}
                        </SelectItem>
                      ))}
                    </SelectContent>
                  </Select>
                </div>

                {/* Visit Status */}
                <div>
                  <Label>Visit Status</Label>
                  <Select>
                    <SelectTrigger>
                      <SelectValue placeholder="Select Status" />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="Completed">Completed</SelectItem>
                      <SelectItem value="In Progress">In Progress</SelectItem>
                      <SelectItem value="Missed">Missed</SelectItem>
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
                        <TableHead className="whitespace-nowrap">
                          Inspection ID
                        </TableHead>
                        <TableHead className="whitespace-nowrap">
                          Officer Code / ID
                        </TableHead>
                        <TableHead className="whitespace-nowrap">
                          Field Officer Name
                        </TableHead>
                        <TableHead className="whitespace-nowrap">
                          Visit Date & Time
                        </TableHead>
                        <TableHead className="whitespace-nowrap">
                          District
                        </TableHead>
                        <TableHead className="whitespace-nowrap">
                          Taluka
                        </TableHead>
                        <TableHead className="whitespace-nowrap">
                          Area / Village
                        </TableHead>
                        <TableHead className="whitespace-nowrap">
                          Target Premises Type
                        </TableHead>
                        <TableHead className="whitespace-nowrap">
                          Visit Purpose
                        </TableHead>
                        <TableHead className="whitespace-nowrap">
                          Assigned Equipment
                        </TableHead>
                        <TableHead className="whitespace-nowrap">
                          Total Target
                        </TableHead>
                        <TableHead className="whitespace-nowrap">
                          Target Achieved
                        </TableHead>
                        <TableHead className="whitespace-nowrap">
                          Status
                        </TableHead>
                      </TableRow>
                    </TableHeader>
                    <TableBody>
                      {inspections.map((i) => (
                        <TableRow key={i.id} className="text-xs">
                          <TableCell className="whitespace-nowrap">
                            {i.id}
                          </TableCell>
                          <TableCell className="whitespace-nowrap">
                            {i.officerCode}
                          </TableCell>
                          <TableCell className="whitespace-nowrap">
                            {i.officerName}
                          </TableCell>
                          <TableCell className="whitespace-nowrap">
                            {i.visitDateTime}
                          </TableCell>
                          <TableCell className="whitespace-nowrap">
                            {i.district}
                          </TableCell>
                          <TableCell className="whitespace-nowrap">
                            {i.taluka}
                          </TableCell>
                          <TableCell className="whitespace-nowrap">
                            {i.area}
                          </TableCell>
                          <TableCell className="whitespace-nowrap">
                            {i.targetType}
                          </TableCell>
                          <TableCell className="whitespace-nowrap">
                            {i.visitPurpose.join(", ")}
                          </TableCell>
                          <TableCell className="whitespace-nowrap">
                            {i.assignedEquipment.join(", ")}
                          </TableCell>
                          <TableCell className="whitespace-nowrap">
                            {i.totalTarget}
                          </TableCell>
                          <TableCell className="whitespace-nowrap">
                            {i.targetAchieved}
                          </TableCell>
                          <TableCell className="whitespace-nowrap">
                            {i.status}
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
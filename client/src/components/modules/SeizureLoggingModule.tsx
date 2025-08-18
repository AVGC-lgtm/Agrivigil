"use client";

import React, { useState, useEffect } from "react";
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
import { useToast } from "@/hooks/use-toast";
import { seizuresAPI, fieldExecutionAPI } from "@/lib/api";

// Import icons
import { Package, MapPin, Camera, Video, FileText, Scale, RefreshCw, Edit, Trash2, Plus } from "lucide-react";

interface Seizure {
  id: string;
  seizurecode: string;
  fieldExecutionId: number;
  location: string;
  district: string;
  taluka?: string;
  premises_type: string[];
  fertilizer_type?: string;
  batch_no?: string;
  quantity: number;
  estimatedValue: string;
  witnessName?: string;
  evidencePhotos: string[];
  videoEvidence?: string;
  status: string;
  remarks?: string;
  seizure_date?: string;
  memo_no?: string;
  officer_name?: string;
  userId: string;
  scanResultId?: string;
  fieldExecution: {
    id: number;
    fieldcode: string;
    companyname: string;
    productname: string;
    dealer_name: string;
    fertilizer_type: string;
    batch_no?: string;
  };
  user: {
    id: string;
    name: string;
    email: string;
    role: string;
  };
}

interface FieldExecution {
  id: number;
  fieldcode: string;
  companyname: string;
  productname: string;
  dealer_name: string;
  fertilizer_type: string;
  batch_no?: string;
}

export default function SeizureLoggingModule() {
  const { toast } = useToast();
  const [seizures, setSeizures] = useState<Seizure[]>([]);
  const [fieldExecutions, setFieldExecutions] = useState<FieldExecution[]>([]);
  const [loading, setLoading] = useState(false);
  const [refreshLoading, setRefreshLoading] = useState(false);
  const [isEditing, setIsEditing] = useState(false);
  const [editingId, setEditingId] = useState<string | null>(null);

  const [formData, setFormData] = useState({
    fieldExecutionId: "",
    location: "",
    district: "",
    taluka: "",
    premises_type: [] as string[],
    fertilizer_type: "",
    batch_no: "",
    quantity: "",
    estimatedValue: "",
    witnessName: "",
    evidencePhotos: [] as string[],
    videoEvidence: "",
    remarks: "",
    seizure_date: "",
    memo_no: "",
    officer_name: "",
  });

  // Filter states
  const [filters, setFilters] = useState({
    status: "all",
    district: "all",
    fertilizer_type: "all",
    location: "all",
  });

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
  const statuses = ["pending", "under-investigation", "case-filed", "closed", "disposed"];

  // Load data on component mount
  useEffect(() => {
    loadSeizures();
    loadFieldExecutions();
  }, []);

  const loadSeizures = async () => {
    try {
      setLoading(true);
      // Convert "all" values to undefined for API calls
      const apiFilters = Object.fromEntries(
        Object.entries(filters).map(([key, value]) => [
          key, 
          value === "all" ? undefined : value
        ]).filter(([_, value]) => value !== undefined)
      );
      
      const data = await seizuresAPI.getSeizures(apiFilters);
      setSeizures(data);
    } catch (error) {
      toast({
        title: "Error",
        description: error instanceof Error ? error.message : "Failed to load seizures",
        variant: "destructive",
      });
    } finally {
      setLoading(false);
    }
  };

  const loadFieldExecutions = async () => {
    try {
      const data = await fieldExecutionAPI.getFieldExecutions();
      setFieldExecutions(data);
    } catch (error) {
      toast({
        title: "Error",
        description: error instanceof Error ? error.message : "Failed to load field executions",
        variant: "destructive",
      });
    }
  };

  const handleInputChange = (field: string, value: string | string[]) => {
    setFormData(prev => ({ 
      ...prev, 
      [field]: value 
    }));
  };

  const handleCheckboxChange = (field: string, value: string, checked: boolean) => {
    setFormData(prev => {
      const currentValues = prev[field as keyof typeof prev] as string[] || [];
      const newValues = checked 
        ? [...currentValues, value] 
        : currentValues.filter(item => item !== value);
      return { ...prev, [field]: newValues };
    });
  };

  const handleFilterChange = (field: string, value: string) => {
    setFilters(prev => ({ 
      ...prev, 
      [field]: value === undefined ? "all" : value 
    }));
  };

  const handleRefreshData = async () => {
    setRefreshLoading(true);
    await loadSeizures();
    toast({
      title: "Data Refreshed",
      description: "Latest seizure data has been loaded.",
    });
    setRefreshLoading(false);
  };

  const resetForm = () => {
    setFormData({
      fieldExecutionId: "",
      location: "",
      district: "",
      taluka: "",
      premises_type: [],
      fertilizer_type: "",
      batch_no: "",
      quantity: "",
      estimatedValue: "",
      witnessName: "",
      evidencePhotos: [],
      videoEvidence: "",
      remarks: "",
      seizure_date: "",
      memo_no: "",
      officer_name: "",
    });
    setIsEditing(false);
    setEditingId(null);
  };

  const handleEdit = (seizure: Seizure) => {
    setFormData({
      fieldExecutionId: seizure.fieldExecutionId.toString(),
      location: seizure.location,
      district: seizure.district,
      taluka: seizure.taluka || "",
      premises_type: seizure.premises_type || [],
      fertilizer_type: seizure.fertilizer_type || "",
      batch_no: seizure.batch_no || "",
      quantity: seizure.quantity.toString(),
      estimatedValue: seizure.estimatedValue,
      witnessName: seizure.witnessName || "",
      evidencePhotos: seizure.evidencePhotos || [],
      videoEvidence: seizure.videoEvidence || "",
      remarks: seizure.remarks || "",
      seizure_date: seizure.seizure_date ? seizure.seizure_date.split('T')[0] : "",
      memo_no: seizure.memo_no || "",
      officer_name: seizure.officer_name || "",
    });
    setIsEditing(true);
    setEditingId(seizure.id);
  };

  const handleDelete = async (id: string) => {
    if (!confirm("Are you sure you want to delete this seizure?")) {
      return;
    }

    try {
      await seizuresAPI.deleteSeizure(id);
      toast({
        title: "Success",
        description: "Seizure deleted successfully.",
      });
      await loadSeizures();
    } catch (error) {
      toast({
        title: "Error",
        description: error instanceof Error ? error.message : "Failed to delete seizure",
        variant: "destructive",
      });
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);

    // Validate required fields
    if (
      !formData.fieldExecutionId?.trim() ||
      !formData.location?.trim() ||
      !formData.district?.trim() ||
      !formData.quantity?.trim() ||
      !formData.estimatedValue?.trim()
    ) {
      toast({
        title: "Validation Error",
        description: "Please fill all required fields.",
        variant: "destructive",
      });
      setLoading(false);
      return;
    }

    try {
      if (isEditing && editingId) {
        // Update existing seizure
        await seizuresAPI.updateSeizure(editingId, {
          location: formData.location,
          district: formData.district,
          taluka: formData.taluka || undefined,
          premises_type: formData.premises_type,
          fertilizer_type: formData.fertilizer_type || undefined,
          batch_no: formData.batch_no || undefined,
          quantity: formData.quantity,
          estimatedValue: formData.estimatedValue,
          witnessName: formData.witnessName || undefined,
          evidencePhotos: formData.evidencePhotos,
          videoEvidence: formData.videoEvidence || undefined,
          remarks: formData.remarks || undefined,
          seizure_date: formData.seizure_date || undefined,
          memo_no: formData.memo_no || undefined,
          officer_name: formData.officer_name || undefined,
        });

        toast({
          title: "Success",
          description: "Seizure updated successfully.",
        });
      } else {
        // Create new seizure
        await seizuresAPI.createSeizure({
          fieldExecutionId: formData.fieldExecutionId,
          location: formData.location,
          district: formData.district,
          taluka: formData.taluka || undefined,
          premises_type: formData.premises_type,
          fertilizer_type: formData.fertilizer_type || undefined,
          batch_no: formData.batch_no || undefined,
          quantity: formData.quantity,
          estimatedValue: formData.estimatedValue,
          witnessName: formData.witnessName || undefined,
          evidencePhotos: formData.evidencePhotos,
          videoEvidence: formData.videoEvidence || undefined,
          remarks: formData.remarks || undefined,
          seizure_date: formData.seizure_date || undefined,
          memo_no: formData.memo_no || undefined,
          officer_name: formData.officer_name || undefined,
        });

        toast({
          title: "Success",
          description: "New seizure has been successfully created.",
        });
      }

      resetForm();
      await loadSeizures();
    } catch (error) {
      toast({
        title: "Error",
        description: error instanceof Error ? error.message : "Failed to save seizure",
        variant: "destructive",
      });
    } finally {
      setLoading(false);
    }
  };

  const formatDate = (dateString: string) => {
    try {
      if (!dateString) return "N/A";
      const date = new Date(dateString);
      if (isNaN(date.getTime())) return "Invalid Date";
      
      return date.toLocaleDateString('en-IN');
    } catch (error) {
      return "Invalid Date";
    }
  };

  const getStatusColor = (status: string) => {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'bg-yellow-100 text-yellow-800';
      case 'under-investigation':
        return 'bg-blue-100 text-blue-800';
      case 'case-filed':
        return 'bg-purple-100 text-purple-800';
      case 'closed':
        return 'bg-green-100 text-green-800';
      case 'disposed':
        return 'bg-gray-100 text-gray-800';
      default:
        return 'bg-gray-100 text-gray-800';
    }
  };

  return (
    <div className="p-4">
      <Tabs defaultValue="logging" className="w-full">
        <TabsList className="grid grid-cols-2 w-full mb-4">
          <TabsTrigger value="logging">
            {isEditing ? "Edit Seizure" : "Seizure Logging"}
          </TabsTrigger>
          <TabsTrigger value="seizures">Seizures List</TabsTrigger>
        </TabsList>

        {/* === SEIZURE LOGGING TAB === */}
        <TabsContent value="logging">
          <Card>
            <CardHeader>
              <div className="flex justify-between items-center">
                <CardTitle>
                  {isEditing ? "Edit Seizure Record" : "Create Seizure Record"}
                </CardTitle>
                {isEditing && (
                  <Button variant="outline" onClick={resetForm}>
                    Cancel Edit
                  </Button>
                )}
              </div>
            </CardHeader>
            <CardContent>
              <form onSubmit={handleSubmit} className="grid gap-4">
                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <Label>Field Execution ID *</Label>
                    <Select
                      value={formData.fieldExecutionId}
                      onValueChange={(value) => handleInputChange("fieldExecutionId", value)}
                    >
                      <SelectTrigger>
                        <SelectValue placeholder="Select Field Execution" />
                      </SelectTrigger>
                      <SelectContent>
                        {fieldExecutions.map((execution) => (
                          <SelectItem key={execution.id} value={execution.id.toString()}>
                            {execution.fieldcode} - {execution.companyname}
                          </SelectItem>
                        ))}
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
                    <Label>District *</Label>
                    <Select
                      value={formData.district}
                      onValueChange={(value) => handleInputChange("district", value)}
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
                    <Label>Taluka</Label>
                    <Select
                      value={formData.taluka}
                      onValueChange={(value) => handleInputChange("taluka", value)}
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
                    <Label>Fertilizer Type</Label>
                    <Select
                      value={formData.fertilizer_type}
                      onValueChange={(value) => handleInputChange("fertilizer_type", value)}
                    >
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
                </div>

                <div>
                  <Label>Location / Address *</Label>
                  <Input 
                    placeholder="Enter detailed location or address" 
                    value={formData.location}
                    onChange={(e) => handleInputChange("location", e.target.value)}
                  />
                </div>

                <div>
                  <Label>Type of Premises (Select all applicable)</Label>
                  <div className="grid grid-cols-2 gap-2">
                    {premisesTypes.map((prem, i) => (
                      <div key={i} className="flex items-center gap-2">
                        <Checkbox 
                          checked={formData.premises_type.includes(prem)}
                          onCheckedChange={(checked) =>
                            handleCheckboxChange(
                              "premises_type",
                              prem,
                              checked as boolean
                            )
                          }
                        />
                        <span>{prem}</span>
                      </div>
                    ))}
                  </div>
                </div>

                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <Label>Batch No</Label>
                    <Input 
                      placeholder="Enter Batch No" 
                      value={formData.batch_no}
                      onChange={(e) => handleInputChange("batch_no", e.target.value)}
                    />
                  </div>

                  <div>
                    <Label>Quantity (kg) *</Label>
                    <Input 
                      type="number" 
                      step="0.01" 
                      placeholder="0.00" 
                      value={formData.quantity}
                      onChange={(e) => handleInputChange("quantity", e.target.value)}
                    />
                  </div>
                </div>

                <div>
                  <Label>Estimated Value *</Label>
                  <Input 
                    placeholder="Enter estimated value" 
                    value={formData.estimatedValue}
                    onChange={(e) => handleInputChange("estimatedValue", e.target.value)}
                  />
                </div>

                <div>
                  <Label>Witness Name</Label>
                  <Input 
                    placeholder="Enter witness name" 
                    value={formData.witnessName}
                    onChange={(e) => handleInputChange("witnessName", e.target.value)}
                  />
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
                    <Input 
                      type="date" 
                      value={formData.seizure_date}
                      onChange={(e) => handleInputChange("seizure_date", e.target.value)}
                    />
                  </div>

                  <div>
                    <Label>Memo No</Label>
                    <Input 
                      placeholder="Enter memo number" 
                      value={formData.memo_no}
                      onChange={(e) => handleInputChange("memo_no", e.target.value)}
                    />
                  </div>
                </div>

                <div>
                  <Label>Officer Name</Label>
                  <Input 
                    placeholder="Enter officer name" 
                    value={formData.officer_name}
                    onChange={(e) => handleInputChange("officer_name", e.target.value)}
                  />
                </div>

                <div>
                  <Label>Remarks</Label>
                  <Textarea 
                    placeholder="Enter additional remarks or observations" 
                    value={formData.remarks}
                    onChange={(e) => handleInputChange("remarks", e.target.value)}
                  />
                </div>

                <div className="flex gap-2">
                  <Button type="submit" className="w-fit" disabled={loading}>
                    {loading ? (
                      <>
                        <RefreshCw className="mr-2 h-4 w-4 animate-spin" />
                        {isEditing ? "Updating..." : "Saving..."}
                      </>
                    ) : (
                      <>
                        {isEditing ? (
                          <>
                            <Edit className="mr-2 h-4 w-4" />
                            Update Seizure Record
                          </>
                        ) : (
                          <>
                            <Plus className="mr-2 h-4 w-4" />
                            Save Seizure Record
                          </>
                        )}
                      </>
                    )}
                  </Button>
                  {isEditing && (
                    <Button type="button" variant="outline" onClick={resetForm}>
                      Cancel
                    </Button>
                  )}
                </div>
              </form>
            </CardContent>
          </Card>
        </TabsContent>

        {/* === SEIZURES LIST TAB === */}
        <TabsContent value="seizures">
          <Card>
            <CardHeader>
              <div className="flex justify-between items-center">
                <CardTitle>Seizures List</CardTitle>
                <Button
                  variant="outline"
                  size="sm"
                  onClick={handleRefreshData}
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
              <div className="grid grid-cols-1 md:grid-cols-4 gap-4 mb-4">
                <div>
                  <Label>Location</Label>
                  <Input 
                    placeholder="Filter by location" 
                    value={filters.location === "all" ? "" : filters.location}
                    onChange={(e) => handleFilterChange("location", e.target.value || "all")}
                  />
                </div>

                <div>
                  <Label>District</Label>
                  <Select
                    value={filters.district}
                    onValueChange={(value) => handleFilterChange("district", value)}
                  >
                    <SelectTrigger>
                      <SelectValue placeholder="Select District" />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="all">All Districts</SelectItem>
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
                  <Select
                    value={filters.fertilizer_type}
                    onValueChange={(value) => handleFilterChange("fertilizer_type", value)}
                  >
                    <SelectTrigger>
                      <SelectValue placeholder="Select Type" />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="all">All Types</SelectItem>
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
                  <Select
                    value={filters.status}
                    onValueChange={(value) => handleFilterChange("status", value)}
                  >
                    <SelectTrigger>
                      <SelectValue placeholder="Select Status" />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="all">All Status</SelectItem>
                      {statuses.map((status) => (
                        <SelectItem key={status} value={status}>
                          {status.charAt(0).toUpperCase() + status.slice(1).replace('-', ' ')}
                        </SelectItem>
                      ))}
                    </SelectContent>
                  </Select>
                </div>
              </div>

              <div className="mb-4">
                <Button onClick={loadSeizures} disabled={loading}>
                  Apply Filters
                </Button>
              </div>

              {/* TABLE */}
              <div className="overflow-x-auto overflow-y-auto max-h-[32rem] border rounded">
                <div className="min-w-[1400px]">
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
                        <TableHead className="whitespace-nowrap">Actions</TableHead>
                      </TableRow>
                    </TableHeader>
                    <TableBody>
                      {loading ? (
                        <TableRow>
                          <TableCell colSpan={16} className="text-center py-8">
                            Loading seizures...
                          </TableCell>
                        </TableRow>
                      ) : seizures.length === 0 ? (
                        <TableRow>
                          <TableCell colSpan={16} className="text-center py-8">
                            No seizures found
                          </TableCell>
                        </TableRow>
                      ) : (
                        seizures.map((seizure) => (
                          <TableRow key={seizure.id} className="text-xs">
                            <TableCell className="whitespace-nowrap font-mono">
                              {seizure.seizurecode}
                            </TableCell>
                            <TableCell className="whitespace-nowrap">
                              {seizure.fieldExecution?.fieldcode || "N/A"}
                            </TableCell>
                            <TableCell className="whitespace-nowrap">
                              {seizure.location}
                            </TableCell>
                            <TableCell className="whitespace-nowrap">
                              {seizure.district}
                            </TableCell>
                            <TableCell className="whitespace-nowrap">
                              {seizure.taluka || "N/A"}
                            </TableCell>
                            <TableCell className="whitespace-nowrap">
                              {Array.isArray(seizure.premises_type) ? seizure.premises_type.join(", ") : "N/A"}
                            </TableCell>
                            <TableCell className="whitespace-nowrap">
                              {seizure.fertilizer_type || "N/A"}
                            </TableCell>
                            <TableCell className="whitespace-nowrap">
                              {seizure.batch_no || "N/A"}
                            </TableCell>
                            <TableCell className="whitespace-nowrap">
                              {seizure.quantity}
                            </TableCell>
                            <TableCell className="whitespace-nowrap">
                              {seizure.estimatedValue}
                            </TableCell>
                            <TableCell className="whitespace-nowrap">
                              {seizure.witnessName || "N/A"}
                            </TableCell>
                            <TableCell className="whitespace-nowrap">
                              {seizure.seizure_date ? formatDate(seizure.seizure_date) : "N/A"}
                            </TableCell>
                            <TableCell className="whitespace-nowrap">
                              {seizure.memo_no || "N/A"}
                            </TableCell>
                            <TableCell className="whitespace-nowrap">
                              {seizure.officer_name || "N/A"}
                            </TableCell>
                            <TableCell className="whitespace-nowrap">
                              <span className={`px-2 py-1 rounded-full text-xs ${getStatusColor(seizure.status)}`}>
                                {seizure.status.charAt(0).toUpperCase() + seizure.status.slice(1).replace('-', ' ')}
                              </span>
                            </TableCell>
                            <TableCell className="whitespace-nowrap">
                              <div className="flex gap-2">
                                <Button
                                  variant="outline"
                                  size="sm"
                                  onClick={() => handleEdit(seizure)}
                                >
                                  <Edit className="h-3 w-3" />
                                </Button>
                                <Button
                                  variant="outline"
                                  size="sm"
                                  onClick={() => handleDelete(seizure.id)}
                                >
                                  <Trash2 className="h-3 w-3" />
                                </Button>
                              </div>
                            </TableCell>
                          </TableRow>
                        ))
                      )}
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



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
import { labSamplesAPI, seizuresAPI } from "@/lib/api";

// Import icons
import { FlaskConical, Microscope, FileText, Calendar, User, Package, RefreshCw, Edit, Trash2, Plus } from "lucide-react";

interface LabSample {
  id: string;
  sampleType: string;
  labDestination: string;
  seizureId: string;
  testType?: string;
  sampleCode: string;
  sampleWeight?: number;
  sampleDescription?: string;
  specialInstructions?: string;
  expectedResults?: string;
  priority: string;
  status: string;
  testResults?: string;
  testDate?: string;
  analystName?: string;
  remarks?: string;
  createdAt: string;
  updatedAt: string;
  userId: string;
  seizure: {
    id: string;
    seizurecode: string;
    location: string;
    district: string;
    taluka?: string;
    fieldExecution: {
      id: number;
      fieldcode: string;
      companyname: string;
      productname: string;
      dealer_name: string;
      fertilizer_type: string;
      batch_no?: string;
    };
  };
  user: {
    id: string;
    name: string;
    email: string;
    role: string;
  };
}

interface Seizure {
  id: string;
  seizurecode: string;
  location: string;
  district: string;
  taluka?: string;
  fieldExecution: {
    id: number;
    fieldcode: string;
    companyname: string;
    productname: string;
    dealer_name: string;
    fertilizer_type: string;
    batch_no?: string;
  };
}

export default function LabInterfaceModule() {
  const { toast } = useToast();
  const [labSamples, setLabSamples] = useState<LabSample[]>([]);
  const [seizures, setSeizures] = useState<Seizure[]>([]);
  const [loading, setLoading] = useState(false);
  const [refreshLoading, setRefreshLoading] = useState(false);
  const [isEditing, setIsEditing] = useState(false);
  const [editingId, setEditingId] = useState<string | null>(null);

  const [formData, setFormData] = useState({
    sampleType: "",
    labDestination: "",
    seizureId: "",
    testType: "",
    sampleCode: "",
    sampleWeight: "",
    sampleDescription: "",
    specialInstructions: "",
    expectedResults: "",
    priority: "normal",
  });

  // Filter states
  const [filters, setFilters] = useState({
    status: "all",
    sampleType: "all",
    labDestination: "all",
    testType: "all",
  });

  const sampleTypes = ["Soil", "Water", "Fertilizer", "Pesticide", "Seed", "Plant Tissue", "Other"];
  const labDestinations = ["Chemistry Lab", "Microbiology Lab", "Physical Lab", "Quality Control", "External Lab"];
  const testTypes = ["Chemical Analysis", "Microbiological", "Physical Properties", "Toxicity", "Purity", "Other"];
  const priorities = ["low", "normal", "high", "urgent"];
  const statuses = ["pending", "in-transit", "received", "under-testing", "completed", "reported"];

  // Load data on component mount
  useEffect(() => {
    loadLabSamples();
    loadSeizures();
  }, []);

  const loadLabSamples = async () => {
    try {
      setLoading(true);
      // Convert "all" values to undefined for API calls
      const apiFilters = Object.fromEntries(
        Object.entries(filters).map(([key, value]) => [
          key, 
          value === "all" ? undefined : value
        ]).filter(([_, value]) => value !== undefined)
      );
      
      const data = await labSamplesAPI.getLabSamples(apiFilters);
      setLabSamples(data);
    } catch (error) {
      toast({
        title: "Error",
        description: error instanceof Error ? error.message : "Failed to load lab samples",
        variant: "destructive",
      });
    } finally {
      setLoading(false);
    }
  };

  const loadSeizures = async () => {
    try {
      const data = await seizuresAPI.getSeizures();
      setSeizures(data);
    } catch (error) {
      toast({
        title: "Error",
        description: error instanceof Error ? error.message : "Failed to load seizures",
        variant: "destructive",
      });
    }
  };

  const handleInputChange = (field: string, value: string) => {
    setFormData(prev => ({ 
      ...prev, 
      [field]: value 
    }));
  };

  const handleFilterChange = (field: string, value: string) => {
    setFilters(prev => ({ 
      ...prev, 
      [field]: value === undefined ? "all" : value 
    }));
  };

  const handleRefreshData = async () => {
    setRefreshLoading(true);
    await loadLabSamples();
    toast({
      title: "Data Refreshed",
      description: "Latest lab sample data has been loaded.",
    });
    setRefreshLoading(false);
  };

  const resetForm = () => {
    setFormData({
      sampleType: "",
      labDestination: "",
      seizureId: "",
      testType: "",
      sampleCode: "",
      sampleWeight: "",
      sampleDescription: "",
      specialInstructions: "",
      expectedResults: "",
      priority: "normal",
    });
    setIsEditing(false);
    setEditingId(null);
  };

  const handleEdit = (labSample: LabSample) => {
    setFormData({
      sampleType: labSample.sampleType,
      labDestination: labSample.labDestination,
      seizureId: labSample.seizureId,
      testType: labSample.testType || "",
      sampleCode: labSample.sampleCode,
      sampleWeight: labSample.sampleWeight?.toString() || "",
      sampleDescription: labSample.sampleDescription || "",
      specialInstructions: labSample.specialInstructions || "",
      expectedResults: labSample.expectedResults || "",
      priority: labSample.priority,
    });
    setIsEditing(true);
    setEditingId(labSample.id);
  };

  const handleDelete = async (id: string) => {
    if (!confirm("Are you sure you want to delete this lab sample?")) {
      return;
    }

    try {
      await labSamplesAPI.deleteLabSample(id);
      toast({
        title: "Success",
        description: "Lab sample deleted successfully.",
      });
      await loadLabSamples();
    } catch (error) {
      toast({
        title: "Error",
        description: error instanceof Error ? error.message : "Failed to delete lab sample",
        variant: "destructive",
      });
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);

    // Validate required fields
    if (
      !formData.sampleType?.trim() ||
      !formData.labDestination?.trim() ||
      !formData.seizureId?.trim()
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
        // Update existing lab sample
        await labSamplesAPI.updateLabSample(editingId, {
          sampleType: formData.sampleType,
          labDestination: formData.labDestination,
          testType: formData.testType || undefined,
          sampleCode: formData.sampleCode || undefined,
          sampleWeight: formData.sampleWeight || undefined,
          sampleDescription: formData.sampleDescription || undefined,
          specialInstructions: formData.specialInstructions || undefined,
          expectedResults: formData.expectedResults || undefined,
          priority: formData.priority,
        });

        toast({
          title: "Success",
          description: "Lab sample updated successfully.",
        });
      } else {
        // Create new lab sample
        await labSamplesAPI.createLabSample({
          sampleType: formData.sampleType,
          labDestination: formData.labDestination,
          seizureId: formData.seizureId,
          testType: formData.testType || undefined,
          sampleCode: formData.sampleCode || undefined,
          sampleWeight: formData.sampleWeight || undefined,
          sampleDescription: formData.sampleDescription || undefined,
          specialInstructions: formData.specialInstructions || undefined,
          expectedResults: formData.expectedResults || undefined,
          priority: formData.priority,
        });

        toast({
          title: "Success",
          description: "New lab sample has been successfully created.",
        });
      }

      resetForm();
      await loadLabSamples();
    } catch (error) {
      toast({
        title: "Error",
        description: error instanceof Error ? error.message : "Failed to save lab sample",
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
      case 'in-transit':
        return 'bg-blue-100 text-blue-800';
      case 'received':
        return 'bg-purple-100 text-purple-800';
      case 'under-testing':
        return 'bg-indigo-100 text-indigo-800';
      case 'completed':
        return 'bg-green-100 text-green-800';
      case 'reported':
        return 'bg-emerald-100 text-emerald-800';
      default:
        return 'bg-gray-100 text-gray-800';
    }
  };

  const getPriorityColor = (priority: string | null | undefined) => {
    if (!priority) {
      return 'bg-gray-100 text-gray-800'; // Default for null/undefined
    }
    
    switch (priority.toLowerCase()) {
      case 'low':
        return 'bg-gray-100 text-gray-800';
      case 'normal':
        return 'bg-blue-100 text-blue-800';
      case 'high':
        return 'bg-orange-100 text-orange-800';
      case 'urgent':
        return 'bg-red-100 text-red-800';
      default:
        return 'bg-gray-100 text-gray-800';
    }
  };

  return (
    <div className="p-4">
      <Tabs defaultValue="sample" className="w-full">
        <TabsList className="grid grid-cols-2 w-full mb-4">
          <TabsTrigger value="sample">
            {isEditing ? "Edit Lab Sample" : "Lab Sample Creation"}
          </TabsTrigger>
          <TabsTrigger value="samples">Lab Samples List</TabsTrigger>
        </TabsList>

        {/* === LAB SAMPLE CREATION TAB === */}
        <TabsContent value="sample">
          <Card>
            <CardHeader>
              <div className="flex justify-between items-center">
                <CardTitle>
                  {isEditing ? "Edit Lab Sample" : "Create Lab Sample"}
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
                    <Label>Sample Type *</Label>
                    <Select
                      value={formData.sampleType}
                      onValueChange={(value) => handleInputChange("sampleType", value)}
                    >
                      <SelectTrigger>
                        <SelectValue placeholder="Select Sample Type" />
                      </SelectTrigger>
                      <SelectContent>
                        {sampleTypes.map((type) => (
                          <SelectItem key={type} value={type}>
                            {type}
                          </SelectItem>
                        ))}
                      </SelectContent>
                    </Select>
                  </div>

                  <div>
                    <Label>Lab Destination *</Label>
                    <Select
                      value={formData.labDestination}
                      onValueChange={(value) => handleInputChange("labDestination", value)}
                    >
                      <SelectTrigger>
                        <SelectValue placeholder="Select Lab Destination" />
                      </SelectTrigger>
                      <SelectContent>
                        {labDestinations.map((lab) => (
                          <SelectItem key={lab} value={lab}>
                            {lab}
                          </SelectItem>
                        ))}
                      </SelectContent>
                    </Select>
                  </div>
                </div>

                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <Label>Seizure ID *</Label>
                    <Select
                      value={formData.seizureId}
                      onValueChange={(value) => handleInputChange("seizureId", value)}
                    >
                      <SelectTrigger>
                        <SelectValue placeholder="Select Seizure" />
                      </SelectTrigger>
                      <SelectContent>
                        {seizures.map((seizure) => (
                          <SelectItem key={seizure.id} value={seizure.id}>
                            {seizure.seizurecode} - {seizure.location}
                          </SelectItem>
                        ))}
                      </SelectContent>
                    </Select>
                  </div>

                  <div>
                    <Label>Test Type</Label>
                    <Select
                      value={formData.testType}
                      onValueChange={(value) => handleInputChange("testType", value)}
                    >
                      <SelectTrigger>
                        <SelectValue placeholder="Select Test Type" />
                      </SelectTrigger>
                      <SelectContent>
                        {testTypes.map((type) => (
                          <SelectItem key={type} value={type}>
                            {type}
                          </SelectItem>
                        ))}
                      </SelectContent>
                    </Select>
                  </div>
                </div>

                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <Label>Sample Code</Label>
                    <Input 
                      placeholder="Auto-generated" 
                      value={formData.sampleCode}
                      onChange={(e) => handleInputChange("sampleCode", e.target.value)}
                    />
                  </div>

                  <div>
                    <Label>Sample Weight (g)</Label>
                    <Input 
                      type="number" 
                      step="0.01" 
                      placeholder="0.00" 
                      value={formData.sampleWeight}
                      onChange={(e) => handleInputChange("sampleWeight", e.target.value)}
                    />
                  </div>
                </div>

                <div>
                  <Label>Sample Description</Label>
                  <Textarea 
                    placeholder="Enter detailed sample description" 
                    value={formData.sampleDescription}
                    onChange={(e) => handleInputChange("sampleDescription", e.target.value)}
                  />
                </div>

                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <Label>Special Instructions</Label>
                    <Textarea 
                      placeholder="Enter special handling instructions" 
                      value={formData.specialInstructions}
                      onChange={(e) => handleInputChange("specialInstructions", e.target.value)}
                    />
                  </div>

                  <div>
                    <Label>Expected Results</Label>
                    <Textarea 
                      placeholder="Enter expected test results" 
                      value={formData.expectedResults}
                      onChange={(e) => handleInputChange("expectedResults", e.target.value)}
                    />
                  </div>
                </div>

                <div>
                  <Label>Priority</Label>
                  <Select
                    value={formData.priority}
                    onValueChange={(value) => handleInputChange("priority", value)}
                  >
                    <SelectTrigger>
                      <SelectValue placeholder="Select Priority" />
                    </SelectTrigger>
                    <SelectContent>
                      {priorities.map((priority) => (
                        <SelectItem key={priority} value={priority}>
                          {priority.charAt(0).toUpperCase() + priority.slice(1)}
                        </SelectItem>
                      ))}
                    </SelectContent>
                  </Select>
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
                            Update Lab Sample
                          </>
                        ) : (
                          <>
                            <Plus className="mr-2 h-4 w-4" />
                            Save Lab Sample
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

        {/* === LAB SAMPLES LIST TAB === */}
        <TabsContent value="samples">
          <Card>
            <CardHeader>
              <div className="flex justify-between items-center">
                <CardTitle>Lab Samples List</CardTitle>
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
                  <Label>Sample Type</Label>
                  <Select
                    value={filters.sampleType}
                    onValueChange={(value) => handleFilterChange("sampleType", value)}
                  >
                    <SelectTrigger>
                      <SelectValue placeholder="Select Type" />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="all">All Types</SelectItem>
                      {sampleTypes.map((type) => (
                        <SelectItem key={type} value={type}>
                          {type}
                        </SelectItem>
                      ))}
                    </SelectContent>
                  </Select>
                </div>

                <div>
                  <Label>Lab Destination</Label>
                  <Select
                    value={filters.labDestination}
                    onValueChange={(value) => handleFilterChange("labDestination", value)}
                  >
                    <SelectTrigger>
                      <SelectValue placeholder="Select Lab" />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="all">All Labs</SelectItem>
                      {labDestinations.map((lab) => (
                        <SelectItem key={lab} value={lab}>
                          {lab}
                        </SelectItem>
                      ))}
                    </SelectContent>
                  </Select>
                </div>

                <div>
                  <Label>Test Type</Label>
                  <Select
                    value={filters.testType}
                    onValueChange={(value) => handleFilterChange("testType", value)}
                  >
                    <SelectTrigger>
                      <SelectValue placeholder="Select Test" />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="all">All Tests</SelectItem>
                      {testTypes.map((type) => (
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
                <Button onClick={loadLabSamples} disabled={loading}>
                  Apply Filters
                </Button>
              </div>

              {/* TABLE */}
              <div className="overflow-x-auto overflow-y-auto max-h-[32rem] border rounded">
                <div className="min-w-[1400px]">
                  <Table className="text-sm w-full">
                    <TableHeader>
                      <TableRow className="text-xs">
                        <TableHead className="whitespace-nowrap">Sample Code</TableHead>
                        <TableHead className="whitespace-nowrap">Sample Type</TableHead>
                        <TableHead className="whitespace-nowrap">Lab Destination</TableHead>
                        <TableHead className="whitespace-nowrap">Seizure ID</TableHead>
                        <TableHead className="whitespace-nowrap">Test Type</TableHead>
                        <TableHead className="whitespace-nowrap">Sample Weight</TableHead>
                        <TableHead className="whitespace-nowrap">Priority</TableHead>
                        <TableHead className="whitespace-nowrap">Status</TableHead>
                        <TableHead className="whitespace-nowrap">Created At</TableHead>
                        <TableHead className="whitespace-nowrap">Actions</TableHead>
                      </TableRow>
                    </TableHeader>
                    <TableBody>
                      {loading ? (
                        <TableRow>
                          <TableCell colSpan={10} className="text-center py-8">
                            Loading lab samples...
                          </TableCell>
                        </TableRow>
                      ) : labSamples.length === 0 ? (
                        <TableRow>
                          <TableCell colSpan={10} className="text-center py-8">
                            No lab samples found
                          </TableCell>
                        </TableRow>
                      ) : (
                        labSamples.map((sample) => (
                          <TableRow key={sample.id} className="text-xs">
                            <TableCell className="whitespace-nowrap font-mono">
                              {sample.sampleCode}
                            </TableCell>
                            <TableCell className="whitespace-nowrap">
                              {sample.sampleType}
                            </TableCell>
                            <TableCell className="whitespace-nowrap">
                              {sample.labDestination}
                            </TableCell>
                            <TableCell className="whitespace-nowrap">
                              {sample.seizure?.seizurecode || "N/A"}
                            </TableCell>
                            <TableCell className="whitespace-nowrap">
                              {sample.testType || "N/A"}
                            </TableCell>
                            <TableCell className="whitespace-nowrap">
                              {sample.sampleWeight ? `${sample.sampleWeight}g` : "N/A"}
                            </TableCell>
                            <TableCell className="whitespace-nowrap">
                              <span className={`px-2 py-1 rounded-full text-xs ${getPriorityColor(sample.priority)}`}>
                                {sample.priority ? 
                                  sample.priority.charAt(0).toUpperCase() + sample.priority.slice(1) : 
                                  'Normal'
                                }
                              </span>
                            </TableCell>
                            <TableCell className="whitespace-nowrap">
                              <span className={`px-2 py-1 rounded-full text-xs ${getStatusColor(sample.status)}`}>
                                {sample.status ? 
                                  sample.status.charAt(0).toUpperCase() + sample.status.slice(1).replace('-', ' ') : 
                                  'Pending'
                                }
                              </span>
                            </TableCell>
                            <TableCell className="whitespace-nowrap">
                              {formatDate(sample.createdAt)}
                            </TableCell>
                            <TableCell className="whitespace-nowrap">
                              <div className="flex gap-2">
                                <Button
                                  variant="outline"
                                  size="sm"
                                  onClick={() => handleEdit(sample)}
                                >
                                  <Edit className="h-3 w-3" />
                                </Button>
                                <Button
                                  variant="outline"
                                  size="sm"
                                  onClick={() => handleDelete(sample.id)}
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
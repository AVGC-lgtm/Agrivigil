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
import { firCasesAPI, seizuresAPI, labSamplesAPI } from "@/lib/api";

// Import icons
import { Gavel, Building2, User, Calendar, FileText, MapPin, RefreshCw, Edit, Trash2, Plus } from "lucide-react";

interface FIRCase {
  id: string;
  labReportId?: string;
  violationType: string;
  accused: string;
  location: string;
  caseNumber: string;
  policeStation?: string;
  investigatingOfficer?: string;
  evidenceDetails?: string;
  witnessStatements?: string;
  legalRepresentation?: string;
  priority: string;
  status: string;
  caseNotes?: string;
  courtDate?: string;
  createdAt: string;
  updatedAt: string;
  userId: string;
  seizureId?: string;
  labSampleId?: string;
  seizure?: {
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
  labSample?: {
    id: string;
    sampleCode: string;
    sampleType: string;
    labDestination: string;
    seizure: {
      id: string;
      seizurecode: string;
      location: string;
      district: string;
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

interface LabSample {
  id: string;
  sampleCode: string;
  sampleType: string;
  labDestination: string;
  seizure: {
    id: string;
    seizurecode: string;
    location: string;
    district: string;
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
}

export default function LegalModule() {
  const { toast } = useToast();
  const [firCases, setFirCases] = useState<FIRCase[]>([]);
  const [seizures, setSeizures] = useState<Seizure[]>([]);
  const [labSamples, setLabSamples] = useState<LabSample[]>([]);
  const [loading, setLoading] = useState(false);
  const [refreshLoading, setRefreshLoading] = useState(false);
  const [isEditing, setIsEditing] = useState(false);
  const [editingId, setEditingId] = useState<string | null>(null);

  const [formData, setFormData] = useState({
    violationType: "",
    accused: "",
    location: "",
    caseNotes: "",
    courtDate: "",
    seizureId: "none",
    labSampleId: "none",
    policeStation: "",
    investigatingOfficer: "",
    evidenceDetails: "",
    witnessStatements: "",
    legalRepresentation: "",
    priority: "normal",
  });

  // Filter states
  const [filters, setFilters] = useState({
    status: "all",
    violationType: "all",
    accused: "all",
    location: "all",
  });

  const violationTypes = [
    "Counterfeit",
    "Quality Standards",
    "Expired Product",
    "Storage Violation",
    "Licensing Violation",
    "Misbranding",
    "Adulteration",
    "Illegal Import",
    "Documentation Fraud",
    "Environmental Violation"
  ];
  const priorities = ["low", "normal", "high", "urgent"];
  const statuses = ["draft", "pending", "under-investigation", "case-filed", "court-proceedings", "closed", "disposed"];

  // Load data on component mount
  useEffect(() => {
    loadFIRCases();
    loadSeizures();
    loadLabSamples();
  }, []);

  const loadFIRCases = async () => {
    try {
      setLoading(true);
      // Convert "all" values to undefined for API calls
      const apiFilters = Object.fromEntries(
        Object.entries(filters).map(([key, value]) => [
          key, 
          value === "all" ? undefined : value
        ]).filter(([_, value]) => value !== undefined)
      );
      
      const data = await firCasesAPI.getFIRCases(apiFilters);
      setFirCases(data);
    } catch (error) {
      toast({
        title: "Error",
        description: error instanceof Error ? error.message : "Failed to load FIR cases",
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

  const loadLabSamples = async () => {
    try {
      const data = await labSamplesAPI.getLabSamples();
      setLabSamples(data);
    } catch (error) {
      toast({
        title: "Error",
        description: error instanceof Error ? error.message : "Failed to load lab samples",
        variant: "destructive",
      });
    }
  };

  const handleInputChange = (field: string, value: string) => {
    setFormData(prev => ({ 
      ...prev, 
      [field]: value === undefined ? "" : value 
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
    await loadFIRCases();
    toast({
      title: "Data Refreshed",
      description: "Latest FIR case data has been loaded.",
    });
    setRefreshLoading(false);
  };

  const resetForm = () => {
    setFormData({
      violationType: "",
      accused: "",
      location: "",
      caseNotes: "",
      courtDate: "",
      seizureId: "none",
      labSampleId: "none",
      policeStation: "",
      investigatingOfficer: "",
      evidenceDetails: "",
      witnessStatements: "",
      legalRepresentation: "",
      priority: "normal",
    });
    setIsEditing(false);
    setEditingId(null);
  };

  const handleEdit = (firCase: FIRCase) => {
    setFormData({
      violationType: firCase.violationType,
      accused: firCase.accused,
      location: firCase.location,
      caseNotes: firCase.caseNotes || "",
      courtDate: firCase.courtDate ? firCase.courtDate.split('T')[0] : "",
      seizureId: firCase.seizureId || "none",
      labSampleId: firCase.labSampleId || "none",
      policeStation: firCase.policeStation || "",
      investigatingOfficer: firCase.investigatingOfficer || "",
      evidenceDetails: firCase.evidenceDetails || "",
      witnessStatements: firCase.witnessStatements || "",
      legalRepresentation: firCase.legalRepresentation || "",
      priority: firCase.priority,
    });
    setIsEditing(true);
    setEditingId(firCase.id);
  };

  const handleDelete = async (id: string) => {
    if (!confirm("Are you sure you want to delete this FIR case?")) {
      return;
    }

    try {
      await firCasesAPI.deleteFIRCase(id);
      toast({
        title: "Success",
        description: "FIR case deleted successfully.",
      });
      await loadFIRCases();
    } catch (error) {
      toast({
        title: "Error",
        description: error instanceof Error ? error.message : "Failed to delete FIR case",
        variant: "destructive",
      });
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);

    // Validate required fields
    if (
      !formData.violationType?.trim() ||
      !formData.accused?.trim() ||
      !formData.location?.trim()
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
        // Update existing FIR case
        await firCasesAPI.updateFIRCase(editingId, {
          violationType: formData.violationType,
          accused: formData.accused,
          location: formData.location,
          caseNotes: formData.caseNotes || undefined,
          courtDate: formData.courtDate || undefined,
          seizureId: formData.seizureId === "none" ? undefined : formData.seizureId,
          labSampleId: formData.labSampleId === "none" ? undefined : formData.labSampleId,
          policeStation: formData.policeStation || undefined,
          investigatingOfficer: formData.investigatingOfficer || undefined,
          evidenceDetails: formData.evidenceDetails || undefined,
          witnessStatements: formData.witnessStatements || undefined,
          legalRepresentation: formData.legalRepresentation || undefined,
          priority: formData.priority,
        });

        toast({
          title: "Success",
          description: "FIR case updated successfully.",
        });
      } else {
        // Create new FIR case
        await firCasesAPI.createFIRCase({
          violationType: formData.violationType,
          accused: formData.accused,
          location: formData.location,
          caseNotes: formData.caseNotes || undefined,
          courtDate: formData.courtDate || undefined,
          seizureId: formData.seizureId === "none" ? undefined : formData.seizureId,
          labSampleId: formData.labSampleId === "none" ? undefined : formData.labSampleId,
          policeStation: formData.policeStation || undefined,
          investigatingOfficer: formData.investigatingOfficer || undefined,
          evidenceDetails: formData.evidenceDetails || undefined,
          witnessStatements: formData.witnessStatements || undefined,
          legalRepresentation: formData.legalRepresentation || undefined,
          priority: formData.priority,
        });

        toast({
          title: "Success",
          description: "New FIR case has been successfully created.",
        });
      }

      resetForm();
      await loadFIRCases();
    } catch (error) {
      toast({
        title: "Error",
        description: error instanceof Error ? error.message : "Failed to save FIR case",
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
    if (!status) return 'bg-gray-100 text-gray-800';
    
    switch (status.toLowerCase()) {
      case 'draft':
        return 'bg-gray-100 text-gray-800';
      case 'pending':
        return 'bg-yellow-100 text-yellow-800';
      case 'under-investigation':
        return 'bg-blue-100 text-blue-800';
      case 'case-filed':
        return 'bg-purple-100 text-purple-800';
      case 'court-proceedings':
        return 'bg-orange-100 text-orange-800';
      case 'closed':
        return 'bg-green-100 text-green-800';
      case 'disposed':
        return 'bg-emerald-100 text-emerald-800';
      default:
        return 'bg-gray-100 text-gray-800';
    }
  };

  const getPriorityColor = (priority: string) => {
    if (!priority) return 'bg-gray-100 text-gray-800';
    
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
      <Tabs defaultValue="fir" className="w-full">
        <TabsList className="grid grid-cols-2 w-full mb-4">
          <TabsTrigger value="fir">
            {isEditing ? "Edit FIR Case" : "FIR Case Creation"}
          </TabsTrigger>
          <TabsTrigger value="cases">FIR Cases List</TabsTrigger>
        </TabsList>

        {/* === FIR CASE CREATION TAB === */}
        <TabsContent value="fir">
          <Card>
            <CardHeader>
              <div className="flex justify-between items-center">
                <CardTitle>
                  {isEditing ? "Edit FIR Case" : "Create FIR Case"}
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
                    <Label>Violation Type *</Label>
                    <Select
                      value={formData.violationType}
                      onValueChange={(value) => handleInputChange("violationType", value)}
                    >
                      <SelectTrigger>
                        <SelectValue placeholder="Select Violation Type" />
                      </SelectTrigger>
                      <SelectContent>
                        {violationTypes.map((type) => (
                          <SelectItem key={type} value={type}>
                            {type}
                          </SelectItem>
                        ))}
                      </SelectContent>
                    </Select>
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
                </div>

                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <Label>Accused Party *</Label>
                    <Input 
                      placeholder="Enter Accused Party Name" 
                      value={formData.accused}
                      onChange={(e) => handleInputChange("accused", e.target.value)}
                    />
                  </div>

                  <div>
                    <Label>Location *</Label>
                    <Input 
                      placeholder="Enter Location" 
                      value={formData.location}
                      onChange={(e) => handleInputChange("location", e.target.value)}
                    />
                  </div>
                </div>

                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <Label>Police Station</Label>
                    <Input 
                      placeholder="Enter Police Station Name" 
                      value={formData.policeStation}
                      onChange={(e) => handleInputChange("policeStation", e.target.value)}
                    />
                  </div>

                  <div>
                    <Label>Investigating Officer</Label>
                    <Input 
                      placeholder="Enter Investigating Officer Name" 
                      value={formData.investigatingOfficer}
                      onChange={(e) => handleInputChange("investigatingOfficer", e.target.value)}
                    />
                  </div>
                </div>

                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <Label>Seizure ID (Optional)</Label>
                    <Select
                      value={formData.seizureId}
                      onValueChange={(value) => handleInputChange("seizureId", value)}
                    >
                      <SelectTrigger>
                        <SelectValue placeholder="Select Seizure" />
                      </SelectTrigger>
                      <SelectContent>
                        <SelectItem value="none">No Seizure</SelectItem>
                        {seizures.map((seizure) => (
                          <SelectItem key={seizure.id} value={seizure.id}>
                            {seizure.seizurecode} - {seizure.location}
                          </SelectItem>
                        ))}
                      </SelectContent>
                    </Select>
                  </div>

                  <div>
                    <Label>Lab Sample ID (Optional)</Label>
                    <Select
                      value={formData.labSampleId}
                      onValueChange={(value) => handleInputChange("labSampleId", value)}
                    >
                      <SelectTrigger>
                        <SelectValue placeholder="Select Lab Sample" />
                      </SelectTrigger>
                      <SelectContent>
                        <SelectItem value="none">No Lab Sample</SelectItem>
                        {labSamples.map((sample) => (
                          <SelectItem key={sample.id} value={sample.id}>
                            {sample.sampleCode} - {sample.sampleType}
                          </SelectItem>
                        ))}
                      </SelectContent>
                    </Select>
                  </div>
                </div>

                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <Label>Court Date</Label>
                    <Input 
                      type="date" 
                      value={formData.courtDate}
                      onChange={(e) => handleInputChange("courtDate", e.target.value)}
                    />
                  </div>

                  <div>
                    <Label>Legal Representation</Label>
                    <Input 
                      placeholder="Enter Legal Representative Name" 
                      value={formData.legalRepresentation}
                      onChange={(e) => handleInputChange("legalRepresentation", e.target.value)}
                    />
                  </div>
                </div>

                <div>
                  <Label>Evidence Details</Label>
                  <Textarea 
                    placeholder="Enter evidence details" 
                    value={formData.evidenceDetails}
                    onChange={(e) => handleInputChange("evidenceDetails", e.target.value)}
                  />
                </div>

                <div>
                  <Label>Witness Statements</Label>
                  <Textarea 
                    placeholder="Enter witness statements" 
                    value={formData.witnessStatements}
                    onChange={(e) => handleInputChange("witnessStatements", e.target.value)}
                  />
                </div>

                <div>
                  <Label>Case Notes</Label>
                  <Textarea 
                    placeholder="Enter case notes and observations" 
                    value={formData.caseNotes}
                    onChange={(e) => handleInputChange("caseNotes", e.target.value)}
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
                            Update FIR Case
                          </>
                        ) : (
                          <>
                            <Plus className="mr-2 h-4 w-4" />
                            Save FIR Case
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

        {/* === FIR CASES LIST TAB === */}
        <TabsContent value="cases">
          <Card>
            <CardHeader>
              <div className="flex justify-between items-center">
                <CardTitle>FIR Cases List</CardTitle>
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
                  <Label>Violation Type</Label>
                  <Select
                    value={filters.violationType}
                    onValueChange={(value) => handleFilterChange("violationType", value)}
                  >
                    <SelectTrigger>
                      <SelectValue placeholder="Select Type" />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="all">All Types</SelectItem>
                      {violationTypes.map((type) => (
                        <SelectItem key={type} value={type}>
                          {type}
                        </SelectItem>
                      ))}
                    </SelectContent>
                  </Select>
                </div>

                <div>
                  <Label>Accused Party</Label>
                  <Input 
                    placeholder="Filter by accused party" 
                    value={filters.accused === "all" ? "" : filters.accused}
                    onChange={(e) => handleFilterChange("accused", e.target.value || "all")}
                  />
                </div>

                <div>
                  <Label>Location</Label>
                  <Input 
                    placeholder="Filter by location" 
                    value={filters.location === "all" ? "" : filters.location}
                    onChange={(e) => handleFilterChange("location", e.target.value || "all")}
                  />
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
                <Button onClick={loadFIRCases} disabled={loading}>
                  Apply Filters
                </Button>
              </div>

              {/* TABLE */}
              <div className="overflow-x-auto overflow-y-auto max-h-[32rem] border rounded">
                <div className="min-w-[1400px]">
                  <Table className="text-sm w-full">
                    <TableHeader>
                      <TableRow className="text-xs">
                        <TableHead className="whitespace-nowrap">Case Number</TableHead>
                        <TableHead className="whitespace-nowrap">Violation Type</TableHead>
                        <TableHead className="whitespace-nowrap">Accused Party</TableHead>
                        <TableHead className="whitespace-nowrap">Location</TableHead>
                        <TableHead className="whitespace-nowrap">Police Station</TableHead>
                        <TableHead className="whitespace-nowrap">Investigating Officer</TableHead>
                        <TableHead className="whitespace-nowrap">Priority</TableHead>
                        <TableHead className="whitespace-nowrap">Status</TableHead>
                        <TableHead className="whitespace-nowrap">Court Date</TableHead>
                        <TableHead className="whitespace-nowrap">Created At</TableHead>
                        <TableHead className="whitespace-nowrap">Actions</TableHead>
                      </TableRow>
                    </TableHeader>
                    <TableBody>
                      {loading ? (
                        <TableRow>
                          <TableCell colSpan={11} className="text-center py-8">
                            Loading FIR cases...
                          </TableCell>
                        </TableRow>
                      ) : firCases.length === 0 ? (
                        <TableRow>
                          <TableCell colSpan={11} className="text-center py-8">
                            No FIR cases found
                          </TableCell>
                        </TableRow>
                      ) : (
                        firCases.map((firCase) => (
                          <TableRow key={firCase.id} className="text-xs">
                            <TableCell className="whitespace-nowrap font-mono">
                              {firCase.caseNumber || "N/A"}
                            </TableCell>
                            <TableCell className="whitespace-nowrap">
                              {firCase.violationType || "N/A"}
                            </TableCell>
                            <TableCell className="whitespace-nowrap">
                              {firCase.accused || "N/A"}
                            </TableCell>
                            <TableCell className="whitespace-nowrap">
                              {firCase.location || "N/A"}
                            </TableCell>
                            <TableCell className="whitespace-nowrap">
                              {firCase.policeStation || "N/A"}
                            </TableCell>
                            <TableCell className="whitespace-nowrap">
                              {firCase.investigatingOfficer || "N/A"}
                            </TableCell>
                            <TableCell className="whitespace-nowrap">
                              <span className={`px-2 py-1 rounded-full text-xs ${getPriorityColor(firCase.priority || "normal")}`}>
                                {(firCase.priority || "normal").charAt(0).toUpperCase() + (firCase.priority || "normal").slice(1)}
                              </span>
                            </TableCell>
                            <TableCell className="whitespace-nowrap">
                              <span className={`px-2 py-1 rounded-full text-xs ${getStatusColor(firCase.status || "draft")}`}>
                                {(firCase.status || "draft").charAt(0).toUpperCase() + (firCase.status || "draft").slice(1).replace('-', ' ')}
                              </span>
                            </TableCell>
                            <TableCell className="whitespace-nowrap">
                              {firCase.courtDate ? formatDate(firCase.courtDate) : "N/A"}
                            </TableCell>
                            <TableCell className="whitespace-nowrap">
                              {firCase.createdAt ? formatDate(firCase.createdAt) : "N/A"}
                            </TableCell>
                            <TableCell className="whitespace-nowrap">
                              <div className="flex gap-2">
                                <Button
                                  variant="outline"
                                  size="sm"
                                  onClick={() => handleEdit(firCase)}
                                >
                                  <Edit className="h-3 w-3" />
                                </Button>
                                <Button
                                  variant="outline"
                                  size="sm"
                                  onClick={() => handleDelete(firCase.id)}
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

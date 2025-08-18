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
import { fieldExecutionAPI, inspectionAPI } from "@/lib/api";

// Import icons
import { Building2, Package, User, Calendar, FileText, Camera, RefreshCw, Edit, Trash2, Plus } from "lucide-react";

interface FieldExecution {
  id: number;
  inspectionid: string;
  fieldcode: string;
  companyname: string;
  productname: string;
  dealer_name: string;
  registration_no?: string;
  sampling_date?: string;
  fertilizer_type: string;
  batch_no?: string;
  manufacture_import_date?: string;
  stock_receipt_date?: string;
  sample_code?: string;
  stock_position?: string;
  physical_condition?: string;
  specification_fco?: string;
  composition_analysis?: string;
  variation?: string;
  moisture?: number;
  total_n?: number;
  nh4n?: number;
  nh4no3n?: number;
  urea_n?: number;
  total_p2o5?: number;
  nac_soluble_p2o5?: number;
  citric_soluble_p2o5?: number;
  water_soluble_p2o5?: number;
  water_soluble_k2o?: number;
  particle_size?: string;
  document: string;
  productphoto: string;
  userid: string;
  inspectiontask: {
    id: string;
    inspectioncode: string;
    location: string;
    district: string;
    taluka: string;
    targetType: string;
    status: string;
  };
  user: {
    id: string;
    name: string;
    email: string;
    role: string;
  };
}

interface InspectionTask {
  id: string;
  inspectioncode: string;
  location: string;
  district: string;
  taluka: string;
  targetType: string;
  status: string;
}

export default function FieldExecutionModule() {
  const { toast } = useToast();
  const [fieldExecutions, setFieldExecutions] = useState<FieldExecution[]>([]);
  const [inspections, setInspections] = useState<InspectionTask[]>([]);
  const [loading, setLoading] = useState(false);
  const [refreshLoading, setRefreshLoading] = useState(false);
  const [isEditing, setIsEditing] = useState(false);
  const [editingId, setEditingId] = useState<number | null>(null);

  const [formData, setFormData] = useState({
    inspectionid: "",
    companyname: "",
    productname: "",
    dealer_name: "",
    registration_no: "",
    sampling_date: "",
    fertilizer_type: "",
    batch_no: "",
    manufacture_import_date: "",
    stock_receipt_date: "",
    sample_code: "",
    stock_position: "",
    physical_condition: "",
    specification_fco: "",
    composition_analysis: "",
    variation: "",
    moisture: "",
    total_n: "",
    nh4n: "",
    nh4no3n: "",
    urea_n: "",
    total_p2o5: "",
    nac_soluble_p2o5: "",
    citric_soluble_p2o5: "",
    water_soluble_p2o5: "",
    water_soluble_k2o: "",
    particle_size: "",
    document: "",
    productphoto: "",
  });

  // Filter states
  const [filters, setFilters] = useState({
    companyname: "all",
    productname: "all",
    fertilizer_type: "all",
    status: "all",
  });

  const fertilizerTypes = ["NPK", "Urea", "DAP", "SSP", "MOP", "Complex"];
  const stockPositions = ["Excellent", "Good", "Fair", "Poor"];
  const physicalConditions = ["Excellent", "Good", "Fair", "Poor"];
  const particleSizes = ["Standard", "Fine", "Coarse", "Irregular"];

  // Load data on component mount
  useEffect(() => {
    loadFieldExecutions();
    loadInspections();
  }, []);

  const loadFieldExecutions = async () => {
    try {
      setLoading(true);
      // Convert "all" values to undefined for API calls
      const apiFilters = Object.fromEntries(
        Object.entries(filters).map(([key, value]) => [
          key, 
          value === "all" ? undefined : value
        ]).filter(([_, value]) => value !== undefined)
      );
      
      const data = await fieldExecutionAPI.getFieldExecutions(apiFilters);
      setFieldExecutions(data);
    } catch (error) {
      toast({
        title: "Error",
        description: error instanceof Error ? error.message : "Failed to load field executions",
        variant: "destructive",
      });
    } finally {
      setLoading(false);
    }
  };

  const loadInspections = async () => {
    try {
      const data = await inspectionAPI.getInspections({ status: "scheduled" });
      setInspections(data);
    } catch (error) {
      toast({
        title: "Error",
        description: error instanceof Error ? error.message : "Failed to load inspections",
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
    await loadFieldExecutions();
    toast({
      title: "Data Refreshed",
      description: "Latest field execution data has been loaded.",
    });
    setRefreshLoading(false);
  };

  const resetForm = () => {
    setFormData({
      inspectionid: "",
      companyname: "",
      productname: "",
      dealer_name: "",
      registration_no: "",
      sampling_date: "",
      fertilizer_type: "",
      batch_no: "",
      manufacture_import_date: "",
      stock_receipt_date: "",
      sample_code: "",
      stock_position: "",
      physical_condition: "",
      specification_fco: "",
      composition_analysis: "",
      variation: "",
      moisture: "",
      total_n: "",
      nh4n: "",
      nh4no3n: "",
      urea_n: "",
      total_p2o5: "",
      nac_soluble_p2o5: "",
      citric_soluble_p2o5: "",
      water_soluble_p2o5: "",
      water_soluble_k2o: "",
      particle_size: "",
      document: "",
      productphoto: "",
    });
    setIsEditing(false);
    setEditingId(null);
  };

  const handleEdit = (execution: FieldExecution) => {
    setFormData({
      inspectionid: execution.inspectionid,
      companyname: execution.companyname,
      productname: execution.productname,
      dealer_name: execution.dealer_name,
      registration_no: execution.registration_no || "",
      sampling_date: execution.sampling_date ? execution.sampling_date.split('T')[0] : "",
      fertilizer_type: execution.fertilizer_type,
      batch_no: execution.batch_no || "",
      manufacture_import_date: execution.manufacture_import_date ? execution.manufacture_import_date.split('T')[0] : "",
      stock_receipt_date: execution.stock_receipt_date ? execution.stock_receipt_date.split('T')[0] : "",
      sample_code: execution.sample_code || "",
      stock_position: execution.stock_position || "",
      physical_condition: execution.physical_condition || "",
      specification_fco: execution.specification_fco || "",
      composition_analysis: execution.composition_analysis || "",
      variation: execution.variation || "",
      moisture: execution.moisture?.toString() || "",
      total_n: execution.total_n?.toString() || "",
      nh4n: execution.nh4n?.toString() || "",
      nh4no3n: execution.nh4no3n?.toString() || "",
      urea_n: execution.urea_n?.toString() || "",
      total_p2o5: execution.total_p2o5?.toString() || "",
      nac_soluble_p2o5: execution.nac_soluble_p2o5?.toString() || "",
      citric_soluble_p2o5: execution.citric_soluble_p2o5?.toString() || "",
      water_soluble_p2o5: execution.water_soluble_p2o5?.toString() || "",
      water_soluble_k2o: execution.water_soluble_k2o?.toString() || "",
      particle_size: execution.particle_size || "",
      document: execution.document,
      productphoto: execution.productphoto,
    });
    setIsEditing(true);
    setEditingId(execution.id);
  };

  const handleDelete = async (id: number) => {
    if (!confirm("Are you sure you want to delete this field execution?")) {
      return;
    }

    try {
      await fieldExecutionAPI.deleteFieldExecution(id.toString());
      toast({
        title: "Success",
        description: "Field execution deleted successfully.",
      });
      await loadFieldExecutions();
    } catch (error) {
      toast({
        title: "Error",
        description: error instanceof Error ? error.message : "Failed to delete field execution",
        variant: "destructive",
      });
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);

    // Validate required fields
    if (
      !formData.inspectionid?.trim() ||
      !formData.companyname?.trim() ||
      !formData.productname?.trim() ||
      !formData.dealer_name?.trim() ||
      !formData.fertilizer_type?.trim()
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
        // Update existing field execution
        await fieldExecutionAPI.updateFieldExecution(editingId.toString(), {
          companyname: formData.companyname,
          productname: formData.productname,
          dealer_name: formData.dealer_name,
          registration_no: formData.registration_no || undefined,
          sampling_date: formData.sampling_date || undefined,
          fertilizer_type: formData.fertilizer_type,
          batch_no: formData.batch_no || undefined,
          manufacture_import_date: formData.manufacture_import_date || undefined,
          stock_receipt_date: formData.stock_receipt_date || undefined,
          sample_code: formData.sample_code || undefined,
          stock_position: formData.stock_position || undefined,
          physical_condition: formData.physical_condition || undefined,
          specification_fco: formData.specification_fco || undefined,
          composition_analysis: formData.composition_analysis || undefined,
          variation: formData.variation || undefined,
          moisture: formData.moisture || undefined,
          total_n: formData.total_n || undefined,
          nh4n: formData.nh4n || undefined,
          nh4no3n: formData.nh4no3n || undefined,
          urea_n: formData.urea_n || undefined,
          total_p2o5: formData.total_p2o5 || undefined,
          nac_soluble_p2o5: formData.nac_soluble_p2o5 || undefined,
          citric_soluble_p2o5: formData.citric_soluble_p2o5 || undefined,
          water_soluble_p2o5: formData.water_soluble_p2o5 || undefined,
          water_soluble_k2o: formData.water_soluble_k2o || undefined,
          particle_size: formData.particle_size || undefined,
          document: formData.document,
          productphoto: formData.productphoto,
        });

        toast({
          title: "Success",
          description: "Field execution updated successfully.",
        });
      } else {
        // Create new field execution
        await fieldExecutionAPI.createFieldExecution({
          inspectionid: formData.inspectionid,
          companyname: formData.companyname,
          productname: formData.productname,
          dealer_name: formData.dealer_name,
          registration_no: formData.registration_no || undefined,
          sampling_date: formData.sampling_date || undefined,
          fertilizer_type: formData.fertilizer_type,
          batch_no: formData.batch_no || undefined,
          manufacture_import_date: formData.manufacture_import_date || undefined,
          stock_receipt_date: formData.stock_receipt_date || undefined,
          sample_code: formData.sample_code || undefined,
          stock_position: formData.stock_position || undefined,
          physical_condition: formData.physical_condition || undefined,
          specification_fco: formData.specification_fco || undefined,
          composition_analysis: formData.composition_analysis || undefined,
          variation: formData.variation || undefined,
          moisture: formData.moisture || undefined,
          total_n: formData.total_n || undefined,
          nh4n: formData.nh4n || undefined,
          nh4no3n: formData.nh4no3n || undefined,
          urea_n: formData.urea_n || undefined,
          total_p2o5: formData.total_p2o5 || undefined,
          nac_soluble_p2o5: formData.nac_soluble_p2o5 || undefined,
          citric_soluble_p2o5: formData.citric_soluble_p2o5 || undefined,
          water_soluble_p2o5: formData.water_soluble_p2o5 || undefined,
          water_soluble_k2o: formData.water_soluble_k2o || undefined,
          particle_size: formData.particle_size || undefined,
          document: formData.document,
          productphoto: formData.productphoto,
        });

        toast({
          title: "Success",
          description: "New field execution has been successfully created.",
        });
      }

      resetForm();
      await loadFieldExecutions();
    } catch (error) {
      toast({
        title: "Error",
        description: error instanceof Error ? error.message : "Failed to save field execution",
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

  return (
    <div className="p-4">
      <Tabs defaultValue="execution" className="w-full">
        <TabsList className="grid grid-cols-2 w-full mb-4">
          <TabsTrigger value="execution">
            {isEditing ? "Edit Field Execution" : "Create Field Execution"}
          </TabsTrigger>
          <TabsTrigger value="executions">Field Executions List</TabsTrigger>
        </TabsList>

        {/* === FIELD EXECUTION TAB === */}
        <TabsContent value="execution">
          <Card>
            <CardHeader>
              <div className="flex justify-between items-center">
                <CardTitle>
                  {isEditing ? "Edit Field Execution" : "Create New Field Execution"}
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
                    <Label>Inspection ID *</Label>
                    <Select
                      value={formData.inspectionid}
                      onValueChange={(value) => handleInputChange("inspectionid", value)}
                    >
                      <SelectTrigger>
                        <SelectValue placeholder="Select Inspection ID" />
                      </SelectTrigger>
                      <SelectContent>
                        {inspections.map((inspection) => (
                          <SelectItem key={inspection.id} value={inspection.id}>
                            {inspection.inspectioncode} - {inspection.location}
                          </SelectItem>
                        ))}
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
                    <Label>Company Name *</Label>
                    <Input 
                      placeholder="Enter Company Name" 
                      value={formData.companyname}
                      onChange={(e) => handleInputChange("companyname", e.target.value)}
                    />
                  </div>

                  <div>
                    <Label>Product Name *</Label>
                    <Input 
                      placeholder="Enter Product Name" 
                      value={formData.productname}
                      onChange={(e) => handleInputChange("productname", e.target.value)}
                    />
                  </div>
                </div>

                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <Label>Dealer Name *</Label>
                    <Input 
                      placeholder="Enter Dealer Name" 
                      value={formData.dealer_name}
                      onChange={(e) => handleInputChange("dealer_name", e.target.value)}
                    />
                  </div>

                  <div>
                    <Label>Registration No</Label>
                    <Input 
                      placeholder="Enter Registration No" 
                      value={formData.registration_no}
                      onChange={(e) => handleInputChange("registration_no", e.target.value)}
                    />
                  </div>
                </div>

                <div className="grid grid-cols-3 gap-4">
                  <div>
                    <Label>Sampling Date</Label>
                    <Input 
                      type="date" 
                      value={formData.sampling_date}
                      onChange={(e) => handleInputChange("sampling_date", e.target.value)}
                    />
                  </div>

                  <div>
                    <Label>Fertilizer Type *</Label>
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

                  <div>
                    <Label>Batch No</Label>
                    <Input 
                      placeholder="Enter Batch No" 
                      value={formData.batch_no}
                      onChange={(e) => handleInputChange("batch_no", e.target.value)}
                    />
                  </div>
                </div>

                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <Label>Manufacture/Import Date</Label>
                    <Input 
                      type="date" 
                      value={formData.manufacture_import_date}
                      onChange={(e) => handleInputChange("manufacture_import_date", e.target.value)}
                    />
                  </div>

                  <div>
                    <Label>Stock Receipt Date</Label>
                    <Input 
                      type="date" 
                      value={formData.stock_receipt_date}
                      onChange={(e) => handleInputChange("stock_receipt_date", e.target.value)}
                    />
                  </div>
                </div>

                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <Label>Sample Code</Label>
                    <Input 
                      placeholder="Enter Sample Code" 
                      value={formData.sample_code}
                      onChange={(e) => handleInputChange("sample_code", e.target.value)}
                    />
                  </div>

                  <div>
                    <Label>Stock Position</Label>
                    <Select
                      value={formData.stock_position}
                      onValueChange={(value) => handleInputChange("stock_position", value)}
                    >
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
                    <Select
                      value={formData.physical_condition}
                      onValueChange={(value) => handleInputChange("physical_condition", value)}
                    >
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
                    <Input 
                      placeholder="Enter FCO Specification" 
                      value={formData.specification_fco}
                      onChange={(e) => handleInputChange("specification_fco", e.target.value)}
                    />
                  </div>
                </div>

                <div>
                  <Label>Composition Analysis</Label>
                  <Textarea 
                    placeholder="Enter detailed composition analysis" 
                    value={formData.composition_analysis}
                    onChange={(e) => handleInputChange("composition_analysis", e.target.value)}
                  />
                </div>

                <div>
                  <Label>Variation</Label>
                  <Input 
                    placeholder="Enter variation details" 
                    value={formData.variation}
                    onChange={(e) => handleInputChange("variation", e.target.value)}
                  />
                </div>

                {/* === CHEMICAL ANALYSIS SECTION === */}
                <div className="border rounded-lg p-4">
                  <h3 className="text-lg font-semibold mb-4">Chemical Analysis</h3>
                  <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
                    <div>
                      <Label>Moisture (%)</Label>
                      <Input 
                        type="number" 
                        step="0.01" 
                        placeholder="0.00" 
                        value={formData.moisture}
                        onChange={(e) => handleInputChange("moisture", e.target.value)}
                      />
                    </div>
                    <div>
                      <Label>Total N (%)</Label>
                      <Input 
                        type="number" 
                        step="0.01" 
                        placeholder="0.00" 
                        value={formData.total_n}
                        onChange={(e) => handleInputChange("total_n", e.target.value)}
                      />
                    </div>
                    <div>
                      <Label>NH4-N (%)</Label>
                      <Input 
                        type="number" 
                        step="0.01" 
                        placeholder="0.00" 
                        value={formData.nh4n}
                        onChange={(e) => handleInputChange("nh4n", e.target.value)}
                      />
                    </div>
                    <div>
                      <Label>NH4NO3-N (%)</Label>
                      <Input 
                        type="number" 
                        step="0.01" 
                        placeholder="0.00" 
                        value={formData.nh4no3n}
                        onChange={(e) => handleInputChange("nh4no3n", e.target.value)}
                      />
                    </div>
                    <div>
                      <Label>Urea-N (%)</Label>
                      <Input 
                        type="number" 
                        step="0.01" 
                        placeholder="0.00" 
                        value={formData.urea_n}
                        onChange={(e) => handleInputChange("urea_n", e.target.value)}
                      />
                    </div>
                    <div>
                      <Label>Total P2O5 (%)</Label>
                      <Input 
                        type="number" 
                        step="0.01" 
                        placeholder="0.00" 
                        value={formData.total_p2o5}
                        onChange={(e) => handleInputChange("total_p2o5", e.target.value)}
                      />
                    </div>
                    <div>
                      <Label>NAC Soluble P2O5 (%)</Label>
                      <Input 
                        type="number" 
                        step="0.01" 
                        placeholder="0.00" 
                        value={formData.nac_soluble_p2o5}
                        onChange={(e) => handleInputChange("nac_soluble_p2o5", e.target.value)}
                      />
                    </div>
                    <div>
                      <Label>Citric Soluble P2O5 (%)</Label>
                      <Input 
                        type="number" 
                        step="0.01" 
                        placeholder="0.00" 
                        value={formData.citric_soluble_p2o5}
                        onChange={(e) => handleInputChange("citric_soluble_p2o5", e.target.value)}
                      />
                    </div>
                    <div>
                      <Label>Water Soluble P2O5 (%)</Label>
                      <Input 
                        type="number" 
                        step="0.01" 
                        placeholder="0.00" 
                        value={formData.water_soluble_p2o5}
                        onChange={(e) => handleInputChange("water_soluble_p2o5", e.target.value)}
                      />
                    </div>
                    <div>
                      <Label>Water Soluble K2O (%)</Label>
                      <Input 
                        type="number" 
                        step="0.01" 
                        placeholder="0.00" 
                        value={formData.water_soluble_k2o}
                        onChange={(e) => handleInputChange("water_soluble_k2o", e.target.value)}
                      />
                    </div>
                  </div>
                </div>

                <div>
                  <Label>Particle Size</Label>
                  <Select
                    value={formData.particle_size}
                    onValueChange={(value) => handleInputChange("particle_size", value)}
                  >
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
                            Update Field Execution
                          </>
                        ) : (
                          <>
                            <Plus className="mr-2 h-4 w-4" />
                            Save Field Execution
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

        {/* === FIELD EXECUTIONS LIST TAB === */}
        <TabsContent value="executions">
          <Card>
            <CardHeader>
              <div className="flex justify-between items-center">
                <CardTitle>Field Executions List</CardTitle>
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
                  <Label>Company Name</Label>
                  <Input 
                    placeholder="Filter by company" 
                    value={filters.companyname === "all" ? "" : filters.companyname}
                    onChange={(e) => handleFilterChange("companyname", e.target.value || "all")}
                  />
                </div>

                <div>
                  <Label>Product Name</Label>
                  <Input 
                    placeholder="Filter by product" 
                    value={filters.productname === "all" ? "" : filters.productname}
                    onChange={(e) => handleFilterChange("productname", e.target.value || "all")}
                  />
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
                      <SelectItem value="Completed">Completed</SelectItem>
                      <SelectItem value="In Progress">In Progress</SelectItem>
                      <SelectItem value="Pending">Pending</SelectItem>
                    </SelectContent>
                  </Select>
                </div>
              </div>

              <div className="mb-4">
                <Button onClick={loadFieldExecutions} disabled={loading}>
                  Apply Filters
                </Button>
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
                        <TableHead className="whitespace-nowrap">Actions</TableHead>
                      </TableRow>
                    </TableHeader>
                    <TableBody>
                      {loading ? (
                        <TableRow>
                          <TableCell colSpan={13} className="text-center py-8">
                            Loading field executions...
                          </TableCell>
                        </TableRow>
                      ) : fieldExecutions.length === 0 ? (
                        <TableRow>
                          <TableCell colSpan={13} className="text-center py-8">
                            No field executions found
                          </TableCell>
                        </TableRow>
                      ) : (
                        fieldExecutions.map((execution) => (
                          <TableRow key={execution.id} className="text-xs">
                            <TableCell className="whitespace-nowrap font-mono">
                              {execution.fieldcode}
                            </TableCell>
                            <TableCell className="whitespace-nowrap">
                              {execution.inspectiontask?.inspectioncode || "N/A"}
                            </TableCell>
                            <TableCell className="whitespace-nowrap">
                              {execution.companyname}
                            </TableCell>
                            <TableCell className="whitespace-nowrap">
                              {execution.productname}
                            </TableCell>
                            <TableCell className="whitespace-nowrap">
                              {execution.dealer_name}
                            </TableCell>
                            <TableCell className="whitespace-nowrap">
                              {execution.fertilizer_type}
                            </TableCell>
                            <TableCell className="whitespace-nowrap">
                              {execution.batch_no || "N/A"}
                            </TableCell>
                            <TableCell className="whitespace-nowrap">
                              {execution.sampling_date ? formatDate(execution.sampling_date) : "N/A"}
                            </TableCell>
                            <TableCell className="whitespace-nowrap">
                              {execution.stock_position || "N/A"}
                            </TableCell>
                            <TableCell className="whitespace-nowrap">
                              {execution.physical_condition || "N/A"}
                            </TableCell>
                            <TableCell className="whitespace-nowrap">
                              {execution.total_n ? `${execution.total_n}%` : "N/A"}
                            </TableCell>
                            <TableCell className="whitespace-nowrap">
                              {execution.total_p2o5 ? `${execution.total_p2o5}%` : "N/A"}
                            </TableCell>
                            <TableCell className="whitespace-nowrap">
                              <div className="flex gap-2">
                                <Button
                                  variant="outline"
                                  size="sm"
                                  onClick={() => handleEdit(execution)}
                                >
                                  <Edit className="h-3 w-3" />
                                </Button>
                                <Button
                                  variant="outline"
                                  size="sm"
                                  onClick={() => handleDelete(execution.id)}
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
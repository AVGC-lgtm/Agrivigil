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
import { reportsAPI } from "@/lib/api";

// Import icons
import { FileText, BarChart3, Calendar, Download, Filter, Search, RefreshCw, TrendingUp, Users, MapPin, Clock } from "lucide-react";

interface ReportData {
  summary?: {
    totalInspections: number;
    totalSeizures: number;
    totalLabSamples: number;
    totalFIRCases: number;
  };
  statusBreakdown?: any;
  recentActivity?: any[];
  topOfficers?: any[];
  topDistricts?: any[];
  inspections?: any[];
  seizures?: any[];
  labSamples?: any[];
  firCases?: any[];
  analytics?: any;
}

export default function ReportsAuditModule() {
  const { toast } = useToast();
  const [loading, setLoading] = useState(false);
  const [reportData, setReportData] = useState<ReportData>({});
  const [currentReportType, setCurrentReportType] = useState<string>("dashboard");

  // Form states
  const [reportFilters, setReportFilters] = useState({
    reportType: "dashboard",
    startDate: "",
    endDate: "",
    officer: "",
    district: "all",
    keyword: "",
    includeInactive: false,
    includeDeleted: false,
    exportToExcel: false,
    includeCharts: true,
    reportDescription: "",
  });

  // Filter states for audit logs
  const [auditFilters, setAuditFilters] = useState({
    action: "all",
    entity: "all",
    userId: "",
    startDate: "",
    endDate: "",
  });

  const reportTypes = [
    { value: "dashboard", label: "Dashboard Summary Report" },
    { value: "inspections", label: "Inspection Planning Report" },
    { value: "seizures", label: "Seizure Logging Report" },
    { value: "lab-samples", label: "Lab Interface Report" },
    { value: "fir-cases", label: "Legal Module Report" },
  ];

  const districts = ["Pune", "Mumbai", "Nagpur", "Aurangabad", "Nashik", "Solapur"];
  const actions = ["CREATE", "UPDATE", "DELETE", "LOGIN", "LOGOUT"];
  const entities = ["InspectionTask", "FieldExecution", "Seizure", "LabSample", "FIRCase", "Product", "User"];

  // Load initial dashboard report
  useEffect(() => {
    loadDashboardReport();
  }, []);

  const loadDashboardReport = async () => {
    try {
      setLoading(true);
      const data = await reportsAPI.getDashboardReport();
      setReportData(data);
      setCurrentReportType("dashboard");
    } catch (error) {
      toast({
        title: "Error",
        description: error instanceof Error ? error.message : "Failed to load dashboard report",
        variant: "destructive",
      });
    } finally {
      setLoading(false);
    }
  };

  const generateReport = async () => {
    try {
      setLoading(true);
      let data: ReportData = {};

      switch (reportFilters.reportType) {
        case "dashboard":
          data = await reportsAPI.getDashboardReport({
            startDate: reportFilters.startDate || undefined,
            endDate: reportFilters.endDate || undefined,
            officer: reportFilters.officer || undefined,
            district: reportFilters.district === "all" ? undefined : reportFilters.district,
            keyword: reportFilters.keyword || undefined,
          });
          break;
        case "inspections":
          data = await reportsAPI.getInspectionsReport({
            startDate: reportFilters.startDate || undefined,
            endDate: reportFilters.endDate || undefined,
            officer: reportFilters.officer || undefined,
            district: reportFilters.district === "all" ? undefined : reportFilters.district,
            keyword: reportFilters.keyword || undefined,
          });
          break;
        case "seizures":
          data = await reportsAPI.getSeizuresReport({
            startDate: reportFilters.startDate || undefined,
            endDate: reportFilters.endDate || undefined,
            officer: reportFilters.officer || undefined,
            district: reportFilters.district === "all" ? undefined : reportFilters.district,
            keyword: reportFilters.keyword || undefined,
          });
          break;
        case "lab-samples":
          data = await reportsAPI.getLabSamplesReport({
            startDate: reportFilters.startDate || undefined,
            endDate: reportFilters.endDate || undefined,
            officer: reportFilters.officer || undefined,
            district: reportFilters.district === "all" ? undefined : reportFilters.district,
            keyword: reportFilters.keyword || undefined,
          });
          break;
        case "fir-cases":
          data = await reportsAPI.getFIRCasesReport({
            startDate: reportFilters.startDate || undefined,
            endDate: reportFilters.endDate || undefined,
            officer: reportFilters.officer || undefined,
            district: reportFilters.district === "all" ? undefined : reportFilters.district,
            keyword: reportFilters.keyword || undefined,
          });
          break;
        default:
          data = await reportsAPI.getDashboardReport();
      }

      setReportData(data);
      setCurrentReportType(reportFilters.reportType);

      toast({
        title: "Success",
        description: `${reportTypes.find(t => t.value === reportFilters.reportType)?.label} generated successfully.`,
      });
    } catch (error) {
      toast({
        title: "Error",
        description: error instanceof Error ? error.message : "Failed to generate report",
        variant: "destructive",
      });
    } finally {
      setLoading(false);
    }
  };

  const handleInputChange = (field: string, value: string | boolean) => {
    setReportFilters(prev => ({ 
      ...prev, 
      [field]: value 
    }));
  };

  const handleFilterChange = (field: string, value: string) => {
    setAuditFilters(prev => ({ 
      ...prev, 
      [field]: value === undefined ? "all" : value 
    }));
  };

  const resetFilters = () => {
    setReportFilters({
      reportType: "dashboard",
      startDate: "",
      endDate: "",
      officer: "",
      district: "all",
      keyword: "",
      includeInactive: false,
      includeDeleted: false,
      exportToExcel: false,
      includeCharts: true,
      reportDescription: "",
    });
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
      case 'completed':
      case 'closed':
      case 'success':
        return 'bg-green-100 text-green-800';
      case 'pending':
      case 'draft':
        return 'bg-yellow-100 text-yellow-800';
      case 'in-progress':
      case 'under-investigation':
        return 'bg-blue-100 text-blue-800';
      case 'failed':
      case 'rejected':
        return 'bg-red-100 text-red-800';
      default:
        return 'bg-gray-100 text-gray-800';
    }
  };

  const renderDashboardReport = () => (
    <div className="grid gap-6">
      {/* Summary Cards */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
        <Card>
          <CardContent className="p-4">
            <div className="flex items-center space-x-2">
              <BarChart3 className="h-8 w-8 text-blue-600" />
              <div>
                <p className="text-sm font-medium text-gray-600">Total Inspections</p>
                <p className="text-2xl font-bold">{reportData.summary?.totalInspections || 0}</p>
              </div>
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardContent className="p-4">
            <div className="flex items-center space-x-2">
              <MapPin className="h-8 w-8 text-red-600" />
              <div>
                <p className="text-sm font-medium text-gray-600">Total Seizures</p>
                <p className="text-2xl font-bold">{reportData.summary?.totalSeizures || 0}</p>
              </div>
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardContent className="p-4">
            <div className="flex items-center space-x-2">
              <FileText className="h-8 w-8 text-green-600" />
              <div>
                <p className="text-sm font-medium text-gray-600">Lab Samples</p>
                <p className="text-2xl font-bold">{reportData.summary?.totalLabSamples || 0}</p>
              </div>
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardContent className="p-4">
            <div className="flex items-center space-x-2">
              <Users className="h-8 w-8 text-purple-600" />
              <div>
                <p className="text-sm font-medium text-gray-600">FIR Cases</p>
                <p className="text-2xl font-bold">{reportData.summary?.totalFIRCases || 0}</p>
              </div>
            </div>
          </CardContent>
        </Card>
      </div>

      {/* Status Breakdown */}
      {reportData.statusBreakdown && (
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          <Card>
            <CardHeader>
              <CardTitle>Inspection Status Breakdown</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="space-y-2">
                {reportData.statusBreakdown.inspections?.map((item: any, index: number) => (
                  <div key={index} className="flex justify-between items-center">
                    <span className="capitalize">{item.status || 'Unknown'}</span>
                    <span className="font-semibold">{item._count.status}</span>
                  </div>
                ))}
              </div>
            </CardContent>
          </Card>

          <Card>
            <CardHeader>
              <CardTitle>Seizure Status Breakdown</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="space-y-2">
                {reportData.statusBreakdown.seizures?.map((item: any, index: number) => (
                  <div key={index} className="flex justify-between items-center">
                    <span className="capitalize">{item.status || 'Unknown'}</span>
                    <span className="font-semibold">{item._count.status}</span>
                  </div>
                ))}
              </div>
            </CardContent>
          </Card>
        </div>
      )}

      {/* Recent Activity */}
      {reportData.recentActivity && reportData.recentActivity.length > 0 && (
        <Card>
          <CardHeader>
            <CardTitle>Recent Activity</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="space-y-3">
              {reportData.recentActivity.slice(0, 5).map((activity: any, index: number) => (
                <div key={index} className="flex items-center justify-between p-3 bg-gray-50 rounded-lg">
                  <div className="flex items-center space-x-3">
                    <div className={`w-2 h-2 rounded-full ${
                      activity.action === 'CREATE' ? 'bg-green-500' :
                      activity.action === 'UPDATE' ? 'bg-blue-500' :
                      'bg-red-500'
                    }`} />
                    <div>
                      <p className="font-medium">{activity.user?.name || 'Unknown User'}</p>
                      <p className="text-sm text-gray-600">{activity.action} on {activity.entity}</p>
                    </div>
                  </div>
                  <span className="text-sm text-gray-500">
                    {formatDate(activity.createdAt)}
                  </span>
                </div>
              ))}
            </div>
          </CardContent>
        </Card>
      )}
    </div>
  );

  const renderDetailedReport = () => {
    const data = reportData[currentReportType as keyof ReportData] as any[];
    
    if (!data || !Array.isArray(data)) {
      return (
        <Card>
          <CardContent className="p-8 text-center">
            <p className="text-gray-500">No data available for this report type.</p>
          </CardContent>
        </Card>
      );
    }

    return (
      <Card>
        <CardHeader>
          <CardTitle>
            {reportTypes.find(t => t.value === currentReportType)?.label} - {data.length} Records
          </CardTitle>
        </CardHeader>
        <CardContent>
          <div className="overflow-x-auto">
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>ID</TableHead>
                  <TableHead>Status</TableHead>
                  <TableHead>Created At</TableHead>
                  <TableHead>User</TableHead>
                  <TableHead>Details</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {data.slice(0, 10).map((item: any, index: number) => (
                  <TableRow key={index}>
                    <TableCell>{item.id || item.inspectioncode || item.seizurecode || item.samplecode || item.fircode || 'N/A'}</TableCell>
                    <TableCell>
                      <span className={`px-2 py-1 rounded-full text-xs ${getStatusColor(item.status)}`}>
                        {item.status || 'N/A'}
                      </span>
                    </TableCell>
                    <TableCell>{formatDate(item.createdAt)}</TableCell>
                    <TableCell>{item.user?.name || 'N/A'}</TableCell>
                    <TableCell>
                      <div className="max-w-[200px] truncate">
                        {item.location || item.accused || item.sampleType || 'N/A'}
                      </div>
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          </div>
          {data.length > 10 && (
            <div className="mt-4 text-center text-sm text-gray-500">
              Showing first 10 of {data.length} records
            </div>
          )}
        </CardContent>
      </Card>
    );
  };

  return (
    <div className="p-4">
      <Tabs defaultValue="reports" className="w-full">
        <TabsList className="grid grid-cols-2 w-full mb-4">
          <TabsTrigger value="reports">Reports Generation</TabsTrigger>
          <TabsTrigger value="audit">Audit Logs</TabsTrigger>
        </TabsList>

        {/* === REPORTS GENERATION TAB === */}
        <TabsContent value="reports">
          <div className="space-y-6">
            {/* Report Generation Form */}
            <Card>
              <CardHeader>
                <CardTitle>Generate Reports</CardTitle>
              </CardHeader>
              <CardContent>
                <form onSubmit={(e) => { e.preventDefault(); generateReport(); }} className="grid gap-4">
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                    <div>
                      <Label>Report Type</Label>
                      <Select
                        value={reportFilters.reportType}
                        onValueChange={(value) => handleInputChange("reportType", value)}
                      >
                        <SelectTrigger>
                          <SelectValue placeholder="Select Report Type" />
                        </SelectTrigger>
                        <SelectContent>
                          {reportTypes.map((type) => (
                            <SelectItem key={type.value} value={type.value}>
                              {type.label}
                            </SelectItem>
                          ))}
                        </SelectContent>
                      </Select>
                    </div>

                    <div>
                      <Label>District</Label>
                      <Select
                        value={reportFilters.district}
                        onValueChange={(value) => handleInputChange("district", value)}
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
                  </div>

                  <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                    <div>
                      <Label>Date From</Label>
                      <Input 
                        type="date" 
                        value={reportFilters.startDate}
                        onChange={(e) => handleInputChange("startDate", e.target.value)}
                      />
                    </div>

                    <div>
                      <Label>Date To</Label>
                      <Input 
                        type="date" 
                        value={reportFilters.endDate}
                        onChange={(e) => handleInputChange("endDate", e.target.value)}
                      />
                    </div>

                    <div>
                      <Label>Officer/User</Label>
                      <Input 
                        placeholder="Filter by officer name or email"
                        value={reportFilters.officer}
                        onChange={(e) => handleInputChange("officer", e.target.value)}
                      />
                    </div>
                  </div>

                  <div>
                    <Label>Keyword Search</Label>
                    <Input 
                      placeholder="Search across all fields"
                      value={reportFilters.keyword}
                      onChange={(e) => handleInputChange("keyword", e.target.value)}
                    />
                  </div>

                  <div>
                    <Label>Additional Options</Label>
                    <div className="grid grid-cols-2 gap-4">
                      <div className="flex items-center gap-2">
                        <Checkbox 
                          checked={reportFilters.includeCharts}
                          onCheckedChange={(checked) => handleInputChange("includeCharts", checked as boolean)}
                        />
                        <span>Include Charts & Analytics</span>
                      </div>
                      <div className="flex items-center gap-2">
                        <Checkbox 
                          checked={reportFilters.exportToExcel}
                          onCheckedChange={(checked) => handleInputChange("exportToExcel", checked as boolean)}
                        />
                        <span>Export to Excel</span>
                      </div>
                    </div>
                  </div>

                  <div>
                    <Label>Report Description</Label>
                    <Textarea 
                      placeholder="Enter report description or notes"
                      value={reportFilters.reportDescription}
                      onChange={(e) => handleInputChange("reportDescription", e.target.value)}
                    />
                  </div>

                  <div className="flex gap-2">
                    <Button type="submit" className="flex items-center gap-2" disabled={loading}>
                      {loading ? (
                        <>
                          <RefreshCw className="w-4 h-4 animate-spin" />
                          Generating...
                        </>
                      ) : (
                        <>
                          <BarChart3 className="w-4 h-4" />
                          Generate Report
                        </>
                      )}
                    </Button>
                    <Button 
                      type="button" 
                      variant="outline" 
                      onClick={resetFilters}
                      className="flex items-center gap-2"
                    >
                      <Filter className="w-4 h-4" />
                      Reset Filters
                    </Button>
                    <Button 
                      type="button" 
                      variant="outline" 
                      onClick={loadDashboardReport}
                      className="flex items-center gap-2"
                    >
                      <RefreshCw className="w-4 h-4" />
                      Refresh Dashboard
                    </Button>
                  </div>
                </form>
              </CardContent>
            </Card>

            {/* Report Display */}
            {Object.keys(reportData).length > 0 && (
              <Card>
                <CardHeader>
                  <CardTitle>
                    {reportTypes.find(t => t.value === currentReportType)?.label}
                  </CardTitle>
                </CardHeader>
                <CardContent>
                  {currentReportType === "dashboard" ? renderDashboardReport() : renderDetailedReport()}
                </CardContent>
              </Card>
            )}
          </div>
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
                  <Select
                    value={auditFilters.action}
                    onValueChange={(value) => handleFilterChange("action", value)}
                  >
                    <SelectTrigger>
                      <SelectValue placeholder="Select Action" />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="all">All Actions</SelectItem>
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
                  <Select
                    value={auditFilters.entity}
                    onValueChange={(value) => handleFilterChange("entity", value)}
                  >
                    <SelectTrigger>
                      <SelectValue placeholder="Select Entity" />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="all">All Entities</SelectItem>
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
                  <Input 
                    placeholder="Filter by user ID" 
                    value={auditFilters.userId}
                    onChange={(e) => handleFilterChange("userId", e.target.value)}
                  />
                </div>

                <div>
                  <Label>Date From</Label>
                  <Input 
                    type="date"
                    value={auditFilters.startDate}
                    onChange={(e) => handleFilterChange("startDate", e.target.value)}
                  />
                </div>

                <div>
                  <Label>Date To</Label>
                  <Input 
                    type="date"
                    value={auditFilters.endDate}
                    onChange={(e) => handleFilterChange("endDate", e.target.value)}
                  />
                </div>
              </div>

              <div className="mb-4">
                <Button onClick={() => {}} disabled={loading}>
                  Apply Filters
                </Button>
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
                      <TableRow>
                        <TableCell colSpan={9} className="text-center py-8">
                          <div className="flex flex-col items-center space-y-2">
                            <Clock className="h-8 w-8 text-gray-400" />
                            <p className="text-gray-500">Audit logs will be displayed here</p>
                            <p className="text-sm text-gray-400">Apply filters to view audit trail</p>
                          </div>
                        </TableCell>
                      </TableRow>
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
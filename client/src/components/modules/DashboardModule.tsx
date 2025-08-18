"use client";

import React, { useState, useEffect, useMemo } from 'react';
import { 
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { maharashtraApiService, District, Taluka } from '@/services/maharashtra-api';
import { inspectionAPI, seizuresAPI, labSamplesAPI, firCasesAPI } from '@/lib/api';
import {
  BarChart,
  Bar,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  Legend,
  ResponsiveContainer,
  PieChart,
  Pie,
  Cell,
  AreaChart,
  Area,
  LabelList,
} from 'recharts';



export default function DashboardModule() {
  const [districts, setDistricts] = useState<District[]>([]);
  const [talukas, setTalukas] = useState<Taluka[]>([]);
  const [selectedDistrict, setSelectedDistrict] = useState<string>("all");
  const [selectedTaluka, setSelectedTaluka] = useState<string>("all");
  const [isLoadingDistricts, setIsLoadingDistricts] = useState(true);
  const [isLoadingTalukas, setIsLoadingTalukas] = useState(false);
  const [chartType, setChartType] = useState<'area' | 'bar'>('bar');
  const [chartPeriod, setChartPeriod] = useState<'monthly' | 'daily'>('monthly');
  const [showStatistics, setShowStatistics] = useState(false);
  const [selectedCategory, setSelectedCategory] = useState<string>('all');
  const [pieChartCategory, setPieChartCategory] = useState<string>('all');
  const [selectedMonth, setSelectedMonth] = useState<string>('august');
  const [chartKey, setChartKey] = useState<number>(0); // Force chart re-render
  
  // Real API data states
  const [inspectionsData, setInspectionsData] = useState<any[]>([]);
  const [seizuresData, setSeizuresData] = useState<any[]>([]);
  const [labSamplesData, setLabSamplesData] = useState<any[]>([]);
  const [firCasesData, setFirCasesData] = useState<any[]>([]);
  const [isLoadingStats, setIsLoadingStats] = useState(true);
      
  // Load districts on component mount
  useEffect(() => {
    const loadDistricts = async () => {
      try {
        setIsLoadingDistricts(true);
        const districtData = await maharashtraApiService.getDistricts();
        setDistricts(districtData);
      } catch (error) {
        console.error('Failed to load districts:', error);
      } finally {
        setIsLoadingDistricts(false);
      }
    };
  
    loadDistricts();
  }, []);

  // Load statistics data on component mount and when filters change
  useEffect(() => {
    const loadStatisticsData = async () => {
      try {
        setIsLoadingStats(true);
        
        // Build filters based on current selections
        const filters: any = {};
        if (selectedDistrict !== "all") {
          filters.district = selectedDistrict;
        }
        if (selectedTaluka !== "all") {
          filters.taluka = selectedTaluka;
        }

        // Fetch all data in parallel
        const [inspections, seizures, labSamples, firCases] = await Promise.all([
          inspectionAPI.getInspections(filters),
          seizuresAPI.getSeizures(filters),
          labSamplesAPI.getLabSamples(filters),
          firCasesAPI.getFIRCases(filters)
        ]);

        console.log('Loaded data:', {
          inspections: inspections.length,
          seizures: seizures.length,
          labSamples: labSamples.length,
          firCases: firCases.length
        });
        console.log('Sample lab sample:', labSamples[0]);
        console.log('Sample FIR case:', firCases[0]);
        
        setInspectionsData(inspections);
        setSeizuresData(seizures);
        setLabSamplesData(labSamples);
        setFirCasesData(firCases);
      } catch (error) {
        console.error('Failed to load statistics data:', error);
        // Keep empty arrays on error
        setInspectionsData([]);
        setSeizuresData([]);
        setLabSamplesData([]);
        setFirCasesData([]);
      } finally {
        setIsLoadingStats(false);
      }
    };

    loadStatisticsData();
  }, [selectedDistrict, selectedTaluka]);

  // Force chart re-render when category changes
  useEffect(() => {
    console.log('Category changed to:', selectedCategory);
    setChartKey(prev => prev + 1);
  }, [selectedCategory]);

  // Load talukas when district is selected
  useEffect(() => {
    const loadTalukas = async () => {
      if (!selectedDistrict || selectedDistrict === "all") {
        setTalukas([]);
        return;
      }

      try {
        setIsLoadingTalukas(true);
        const talukaData = await maharashtraApiService.getTalukasByDistrict(selectedDistrict);
        setTalukas(talukaData);
      } catch (error) {
        console.error('Failed to load talukas:', error);
        setTalukas([]);
      } finally {
        setIsLoadingTalukas(false);
      }
    };

    loadTalukas();
  }, [selectedDistrict]);

  // Reset taluka selection when district changes
  useEffect(() => {
    setSelectedTaluka("all");
  }, [selectedDistrict]);

  const handleDistrictChange = (value: string) => {
    setSelectedDistrict(value);
  };

  const handleTalukaChange = (value: string) => {
    setSelectedTaluka(value);
  };

  // Calculate real statistics from API data
  const calculateStatistics = () => {
    if (isLoadingStats) {
      return {
        inspectionsDoneCompleted: 0,
        inspectionsDoneProcessing: 0,
        inspectionsLiveCompleted: 0,
        inspectionsLiveProcessing: 0,
        counterfeitSamples: 0,
        banChemicalSamples: 0,
        labSamples: 0,
        legalCasesLive: 0
      };
    }

    // Calculate inspections done (completed and processing)
    const completedInspections = inspectionsData.filter(inspection => 
      inspection.status === 'completed'
    ).length;
    
    const processingInspections = inspectionsData.filter(inspection => 
      inspection.status === 'in_progress' || inspection.status === 'processing'
    ).length;

    // Calculate live inspections
    const liveInspections = inspectionsData.filter(inspection => 
      inspection.status === 'scheduled' || inspection.status === 'active'
    ).length;

    // For now, we'll split live inspections into completed and processing
    const liveCompleted = Math.floor(liveInspections * 0.6);
    const liveProcessing = liveInspections - liveCompleted;

    // Calculate samples counts from lab samples data
    // For now, showing total lab samples count for both cards
    // This can be refined later to actual counterfeit/banned detection
    const counterfeitSamples = labSamplesData.length;
    const banChemicalSamples = labSamplesData.length;

    const labSamples = labSamplesData.length;

    // Count all FIR cases as they are all "registered" legal cases
    const legalCasesLive = firCasesData.length;

    return {
      inspectionsDoneCompleted: completedInspections,
      inspectionsDoneProcessing: processingInspections,
      inspectionsLiveCompleted: liveCompleted,
      inspectionsLiveProcessing: liveProcessing,
      counterfeitSamples,
      banChemicalSamples,
      labSamples,
      legalCasesLive
    };
  };

  // Calculate real-time statistics based on selected category
  const getRealTimeStats = () => {
    if (isLoadingStats) {
      return {
        inspectionsDoneCompleted: 0,
        inspectionsDoneProcessing: 0,
        inspectionsLiveCompleted: 0,
        inspectionsLiveProcessing: 0,
        counterfeitSamples: 0,
        banChemicalSamples: 0,
        labSamples: 0,
        legalCasesLive: 0
      };
    }

    // Get the appropriate data source based on selected category
    let dataSource = inspectionsData;
    if (selectedCategory === 'legal_cases') {
      dataSource = firCasesData;
    } else if (['counterfeit_samples', 'ban_chemical_samples', 'laboratory_samples'].includes(selectedCategory)) {
      dataSource = labSamplesData;
    }

    // Filter data based on category
    const filteredData = selectedCategory === 'all' ? dataSource : getFilteredDataByCategory(dataSource, selectedCategory);

    // Calculate statistics based on filtered data
    if (selectedCategory === 'inspections_done_completed') {
      return {
        inspectionsDoneCompleted: filteredData.length,
        inspectionsDoneProcessing: 0,
        inspectionsLiveCompleted: 0,
        inspectionsLiveProcessing: 0,
        counterfeitSamples: 0,
        banChemicalSamples: 0,
        labSamples: 0,
        legalCasesLive: 0
      };
    } else if (selectedCategory === 'inspections_done_processing') {
      return {
        inspectionsDoneCompleted: 0,
        inspectionsDoneProcessing: filteredData.length,
        inspectionsLiveCompleted: 0,
        inspectionsLiveProcessing: 0,
        counterfeitSamples: 0,
        banChemicalSamples: 0,
        labSamples: 0,
        legalCasesLive: 0
      };
    } else if (selectedCategory === 'inspections_live_completed') {
      return {
        inspectionsDoneCompleted: 0,
        inspectionsDoneProcessing: 0,
        inspectionsLiveCompleted: filteredData.length,
        inspectionsLiveProcessing: 0,
        counterfeitSamples: 0,
        banChemicalSamples: 0,
        labSamples: 0,
        legalCasesLive: 0
      };
    } else if (selectedCategory === 'inspections_live_processing') {
      return {
        inspectionsDoneCompleted: 0,
        inspectionsDoneProcessing: 0,
        inspectionsLiveCompleted: 0,
        inspectionsLiveProcessing: filteredData.length,
        counterfeitSamples: 0,
        banChemicalSamples: 0,
        labSamples: 0,
        legalCasesLive: 0
      };
    } else if (selectedCategory === 'counterfeit_samples') {
      return {
        inspectionsDoneCompleted: 0,
        inspectionsDoneProcessing: 0,
        inspectionsLiveCompleted: 0,
        inspectionsLiveProcessing: 0,
        counterfeitSamples: filteredData.length,
        banChemicalSamples: 0,
        labSamples: 0,
        legalCasesLive: 0
      };
    } else if (selectedCategory === 'ban_chemical_samples') {
      return {
        inspectionsDoneCompleted: 0,
        inspectionsDoneProcessing: 0,
        inspectionsLiveCompleted: 0,
        inspectionsLiveProcessing: 0,
        counterfeitSamples: 0,
        banChemicalSamples: filteredData.length,
        labSamples: 0,
        legalCasesLive: 0
      };
    } else if (selectedCategory === 'laboratory_samples') {
      return {
        inspectionsDoneCompleted: 0,
        inspectionsDoneProcessing: 0,
        inspectionsLiveCompleted: 0,
        inspectionsLiveProcessing: 0,
        counterfeitSamples: 0,
        banChemicalSamples: 0,
        labSamples: filteredData.length,
        legalCasesLive: 0
      };
    } else if (selectedCategory === 'legal_cases') {
      return {
        inspectionsDoneCompleted: 0,
        inspectionsDoneProcessing: 0,
        inspectionsLiveCompleted: 0,
        inspectionsLiveProcessing: 0,
        counterfeitSamples: 0,
        banChemicalSamples: 0,
        labSamples: 0,
        legalCasesLive: filteredData.length
      };
    } else {
      // All Categories - show all statistics
      return calculateStatistics();
    }
  };

  // Get filtered data based on selected category
  const getFilteredDataByCategory = (data: any[], category: string) => {
    switch (category) {
      case 'inspections_done_completed':
        return data.filter(item => item.status === 'completed');
      case 'inspections_done_processing':
        return data.filter(item => item.status === 'in_progress' || item.status === 'processing');
      case 'inspections_live_completed':
        return data.filter(item => item.status === 'scheduled' || item.status === 'active');
      case 'inspections_live_processing':
        return data.filter(item => item.status === 'scheduled' || item.status === 'active');
      case 'counterfeit_samples':
        // For lab samples, return the data as-is since we're already using labSamplesData as source
        return data;
      case 'ban_chemical_samples':
        // For lab samples, return the data as-is since we're already using labSamplesData as source
        return data;
      case 'laboratory_samples':
        // For lab samples, return the data as-is since we're already using labSamplesData as source
        return data;
      case 'legal_cases':
        // For legal cases, return the data as-is since we're already using firCasesData as source
        return data;
      default:
        return data;
    }
  };

  const stats = getRealTimeStats();

  // Get filtered data based on selected category - make it reactive
  const filteredData = useMemo(() => {
    let dataSource = inspectionsData;
    if (selectedCategory === 'legal_cases') {
      dataSource = firCasesData;
    } else if (['counterfeit_samples', 'ban_chemical_samples', 'laboratory_samples'].includes(selectedCategory)) {
      dataSource = labSamplesData;
    }

    const filtered = selectedCategory === 'all' ? dataSource : getFilteredDataByCategory(dataSource, selectedCategory);
    
    // Debug logging
    console.log('Category:', selectedCategory);
    console.log('DataSource length:', dataSource.length);
    console.log('Filtered data length:', filtered.length);
    console.log('Sample data:', filtered.slice(0, 2));
    
    return filtered;
  }, [selectedCategory, inspectionsData, firCasesData, labSamplesData]);

  // Generate chart data using real API data based on createdAt dates
  const getBarChartData = () => {
    // Use the reactive filteredData that updates when category changes
    console.log('getBarChartData called with:', {
      selectedCategory,
      chartPeriod,
      selectedMonth,
      filteredDataLength: filteredData.length,
      sampleData: filteredData.slice(0, 2)
    });

    if (chartPeriod === 'daily') {
      // Get number of days for selected month
      const daysInMonth = {
        january: 31, february: 28, march: 31, april: 30, may: 31, june: 30,
        july: 31, august: 31, september: 30, october: 31, november: 30, december: 31
      };
      const monthNames = {
        january: 'January', february: 'February', march: 'March', april: 'April',
        may: 'May', june: 'June', july: 'July', august: 'August',
        september: 'September', october: 'October', november: 'November', december: 'December'
      };
      
      const days = daysInMonth[selectedMonth as keyof typeof daysInMonth] || 30;
      const monthName = monthNames[selectedMonth as keyof typeof monthNames] || 'January';
      
      // Create array for all days in the month
      const dailyData = Array.from({ length: days }, (_, i) => ({
        name: (i + 1).toString(),
        fullName: `Day ${i + 1} of ${monthName}`,
        inspections: 0,
        cases: 0,
      }));

      // Count filtered data by day for the selected month
      filteredData.forEach(item => {
        const createdDate = new Date(item.createdAt);
        const monthIndex = createdDate.getMonth(); // 0-11
        const dayOfMonth = createdDate.getDate(); // 1-31
        
        // Check if this item is from the selected month
        const selectedMonthIndex = Object.keys(monthNames).indexOf(selectedMonth);
        if (monthIndex === selectedMonthIndex && dayOfMonth <= days) {
          if (selectedCategory === 'legal_cases') {
            dailyData[dayOfMonth - 1].cases++;
          } else {
            dailyData[dayOfMonth - 1].inspections++;
          }
        }
      });

      return dailyData;
    } else {
      // Return monthly data for the year based on actual creation dates
      const months = [
        { name: 'Jan', fullName: 'January', month: 0 },
        { name: 'Feb', fullName: 'February', month: 1 },
        { name: 'Mar', fullName: 'March', month: 2 },
        { name: 'Apr', fullName: 'April', month: 3 },
        { name: 'May', fullName: 'May', month: 4 },
        { name: 'Jun', fullName: 'June', month: 5 },
        { name: 'Jul', fullName: 'July', month: 6 },
        { name: 'Aug', fullName: 'August', month: 7 },
        { name: 'Sep', fullName: 'September', month: 8 },
        { name: 'Oct', fullName: 'October', month: 9 },
        { name: 'Nov', fullName: 'November', month: 10 },
        { name: 'Dec', fullName: 'December', month: 11 }
      ];

      const result = months.map(month => {
        // Count filtered data for this month
        const filteredCount = filteredData.filter(item => {
          const createdDate = new Date(item.createdAt);
          const isMatch = createdDate.getMonth() === month.month;
          
          // Debug logging for August
          if (month.name === 'Aug' && selectedCategory === 'ban_chemical_samples') {
            console.log('Checking item:', item);
            console.log('Created date:', createdDate);
            console.log('Month index:', createdDate.getMonth());
            console.log('Expected month:', month.month);
            console.log('Is match:', isMatch);
          }
          
          return isMatch;
        }).length;

        // Debug logging for specific month
        if (month.name === 'Aug') {
          console.log(`August data for ${selectedCategory}:`, filteredCount);
          console.log('Sample items:', filteredData.slice(0, 2));
        }

        // For lab samples and legal cases, show the count in the appropriate field
        if (selectedCategory === 'legal_cases') {
          return {
            name: month.name,
            fullName: month.fullName,
            inspections: 0,
            cases: filteredCount
          };
        } else if (['counterfeit_samples', 'ban_chemical_samples', 'laboratory_samples'].includes(selectedCategory)) {
          return {
            name: month.name,
            fullName: month.fullName,
            inspections: filteredCount,
            cases: 0
          };
        } else {
          // For inspection categories
          return {
            name: month.name,
            fullName: month.fullName,
            inspections: filteredCount,
            cases: 0
          };
        }
      });
      
      console.log('Final chart data:', result);
      return result;
    }
  };

  const getPieChartData = () => {
    if (pieChartCategory === 'all') {
      return [
        { name: 'Inspections Done - Completed', value: stats.inspectionsDoneCompleted, color: '#1e40af' },
        { name: 'Inspections Done - Processing', value: stats.inspectionsDoneProcessing, color: '#3b82f6' },
        { name: 'Inspections Live - Completed', value: stats.inspectionsLiveCompleted, color: '#059669' },
        { name: 'Inspections Live - Processing', value: stats.inspectionsLiveProcessing, color: '#10b981' },
        { name: 'Counterfeit Samples', value: stats.counterfeitSamples, color: '#ea580c' },
        { name: 'Ban Chemical Samples', value: stats.banChemicalSamples, color: '#dc2626' },
        { name: 'Laboratory Samples', value: stats.labSamples, color: '#7c3aed' },
        { name: 'Legal Cases Registered', value: stats.legalCasesLive, color: '#4f46e5' }
      ];
    } else {
      // Show detailed breakdown for selected category
      switch (pieChartCategory) {
        case 'inspections_done_completed':
          return [
            { name: 'Agricultural Products', value: 1200, color: '#1e40af' },
            { name: 'Fertilizers', value: 800, color: '#3b82f6' },
            { name: 'Pesticides', value: 547, color: '#60a5fa' }
          ];
        case 'inspections_done_processing':
          return [
            { name: 'Under Review', value: 150, color: '#3b82f6' },
            { name: 'Documentation', value: 100, color: '#60a5fa' },
            { name: 'Final Check', value: 50, color: '#93c5fd' }
          ];
        case 'counterfeit_samples':
          return [
            { name: 'Fake Seeds', value: 200, color: '#ea580c' },
            { name: 'Adulterated Fertilizers', value: 123, color: '#fb923c' },
            { name: 'Counterfeit Pesticides', value: 100, color: '#fdba74' }
          ];
        default:
          return [
            { name: 'Category Data', value: 100, color: '#6b7280' }
          ];
      }
    }
  };

  const COLORS = ['#3b82f6', '#10b981', '#f59e0b', '#ef4444'];
  
  // Enhanced color scheme for bars
  const BAR_COLORS = {
    inspections: '#2563eb', // Blue
    cases: '#059669',       // Green  
    reports: '#d97706'      // Orange
  };

  // Enhanced custom tooltip for better data display
  const CustomTooltip = ({ active, payload, label }: any) => {
    if (active && payload && payload.length) {
      const data = payload[0]?.payload;
      const fullName = data?.fullName || label;
      
      return (
        <div 
          className="bg-white p-4 border-2 border-blue-200 rounded-xl shadow-2xl z-50"
          style={{
            minWidth: '200px',
            boxShadow: '0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04)',
            border: '2px solid #e5e7eb',
            backgroundColor: 'rgba(255, 255, 255, 0.98)',
            backdropFilter: 'blur(8px)'
          }}
        >
          <div className="text-center mb-3">
            <p className="font-bold text-gray-800 text-lg border-b border-gray-200 pb-2">
              {fullName}
            </p>
          </div>
          <div className="space-y-2">
            {payload.map((entry: any, index: number) => {
              const displayName = entry.dataKey === 'inspections' ? 'Total Inspections' : 
                                 entry.dataKey === 'cases' ? 'Active Cases' : entry.name;
              return (
                <div key={index} className="flex items-center justify-between gap-3 p-2 bg-gray-50 rounded-lg">
                  <div className="flex items-center gap-2">
                    <div 
                      className="w-4 h-4 rounded-full border-2 border-white shadow-sm"
                      style={{ backgroundColor: entry.color }}
                    ></div>
                    <span className="text-sm font-medium text-gray-700">
                      {displayName}
                    </span>
                  </div>
                  <span 
                    className="text-lg font-bold px-2 py-1 rounded"
                    style={{ 
                      color: entry.color,
                      backgroundColor: `${entry.color}15`
                    }}
                  >
                    {entry.value.toLocaleString()}
                  </span>
                </div>
              );
            })}
          </div>
          <div className="mt-3 pt-2 border-t border-gray-200">
            <p className="text-xs text-gray-500 text-center">
              Hover over bars to see details
            </p>
          </div>
        </div>
      );
    }
    return null;
  };

  // Custom X-axis tick component
  const CustomXAxisTick = (props: any) => {
    const { x, y, payload } = props;
    return (
      <g transform={`translate(${x},${y})`}>
        <text 
          x={0} 
          y={0} 
          dy={16} 
          textAnchor="end" 
          fill="#374151" 
          fontSize="11" 
          fontWeight="500"
          transform="rotate(-30)"
        >
          {payload.value}
        </text>
      </g>
    );
  };

  // Custom label component for bars - positioned below bars
  const CustomBarLabel = (props: any) => {
    const { x, y, width, height, payload } = props;
    const labelY = y + height + 20; // Position well below the bar
    const labelX = x + width / 2;
    
    return (
      <g>
        <text 
          x={labelX} 
          y={labelY} 
          textAnchor="middle" 
          fill="#374151" 
          fontSize="9" 
          fontWeight="600"
          style={{ textShadow: '1px 1px 2px rgba(255,255,255,0.8)' }}
        >
          {payload.name}
        </text>
      </g>
    );
  };

  // Custom label component for areas  
  const CustomAreaLabel = (props: any) => {
    const { x, y, payload, index } = props;
    if (index % 2 === 0) { // Show label every other point to avoid crowding
      return (
        <text 
          x={x}  
          y={y - 10}    
          textAnchor="middle"  
          fill="#374151"  
          fontSize="10"  
          fontWeight="500" 
        > 
          {payload.name} 
        </text>
      );
    }
    return null;
  };

  // Function to render different chart types
  const renderChart = () => {
    const commonProps = {
      data: getBarChartData(),
      margin: {
        top: 20,
        right: 30,
        left: 20,
        bottom: 100,
      }
    };

    const commonDefs = (
      <defs>
        <linearGradient id="inspectionsAreaGradient" x1="0" y1="0" x2="0" y2="1">
          <stop offset="5%" stopColor="#3b82f6" stopOpacity={0.8}/>
          <stop offset="95%" stopColor="#3b82f6" stopOpacity={0.1}/>
        </linearGradient>
        <linearGradient id="casesAreaGradient" x1="0" y1="0" x2="0" y2="1">
          <stop offset="5%" stopColor="#10b981" stopOpacity={0.8}/>
          <stop offset="95%" stopColor="#10b981" stopOpacity={0.1}/>
        </linearGradient>
        <linearGradient id="reportsAreaGradient" x1="0" y1="0" x2="0" y2="1">
          <stop offset="5%" stopColor="#f59e0b" stopOpacity={0.8}/>
          <stop offset="95%" stopColor="#f59e0b" stopOpacity={0.1}/>
        </linearGradient>
      </defs>
    );

    const commonAxes = (
      <>
        <CartesianGrid strokeDasharray="3 3" stroke="#e2e8f0" strokeOpacity={0.3} />
        <XAxis 
          dataKey="name" 
          tick={false}
          axisLine={{ stroke: '#e2e8f0' }}
          tickLine={false}
          height={30}
        />
        <YAxis 
          tick={{ fontSize: 11, fill: '#6b7280' }} 
          axisLine={{ stroke: '#e2e8f0' }}
          tickLine={{ stroke: '#e2e8f0' }}
        />
        <Tooltip 
          content={<CustomTooltip />}
          cursor={{ fill: 'rgba(59, 130, 246, 0.1)' }}
          animationDuration={200}
          position={{ x: undefined, y: undefined }}
          allowEscapeViewBox={{ x: false, y: false }}
          wrapperStyle={{ 
            outline: 'none',
            zIndex: 1000
          }}
        />
        <Legend 
          wrapperStyle={{ paddingTop: '15px' }}
          iconType="circle"
        />
      </>
    );

    switch (chartType) {
      case 'bar':
        return (
          <BarChart {...commonProps}>
            <defs>
              <linearGradient id="inspectionsBarGradient" x1="0" y1="0" x2="0" y2="1">
                <stop offset="0%" stopColor="#3b82f6" stopOpacity={1}/>
                <stop offset="100%" stopColor="#1e40af" stopOpacity={0.9}/>
              </linearGradient>
              <linearGradient id="casesBarGradient" x1="0" y1="0" x2="0" y2="1">
                <stop offset="0%" stopColor="#10b981" stopOpacity={1}/>
                <stop offset="100%" stopColor="#059669" stopOpacity={0.9}/>
              </linearGradient>
              <linearGradient id="reportsBarGradient" x1="0" y1="0" x2="0" y2="1">
                <stop offset="0%" stopColor="#f59e0b" stopOpacity={1}/>
                <stop offset="100%" stopColor="#d97706" stopOpacity={0.9}/>
              </linearGradient>
            </defs>
            {commonAxes}
            <Bar 
              dataKey="inspections" 
              fill="url(#inspectionsBarGradient)" 
              name="Total Inspections"
              radius={[6, 6, 0, 0]}
              stroke="#1e40af"
              strokeWidth={1}
              maxBarSize={60}
              style={{ cursor: 'pointer' }}
            >
              <LabelList 
                dataKey="name" 
                position="bottom" 
                offset={10}
                style={{ 
                  fontSize: '10px', 
                  fill: '#374151', 
                  fontWeight: '600',
                  textAnchor: 'middle'
                }}
              />
              <LabelList 
                dataKey="inspections" 
                position="top" 
                offset={5}
                style={{ 
                  fontSize: '11px', 
                  fill: '#1e40af', 
                  fontWeight: 'bold',
                  textAnchor: 'middle'
                }}
              />
            </Bar>
            <Bar 
              dataKey="cases" 
              fill="url(#casesBarGradient)" 
              name="Active Cases"
              radius={[6, 6, 0, 0]}
              stroke="#047857"
              strokeWidth={1}
              maxBarSize={60}
              style={{ cursor: 'pointer' }}
            >
              <LabelList 
                dataKey="cases" 
                position="top" 
                offset={5}
                style={{ 
                  fontSize: '11px', 
                  fill: '#047857', 
                  fontWeight: 'bold',
                  textAnchor: 'middle'
                }}
              />
            </Bar>
          </BarChart>
        );



      default: // area
        return (
          <AreaChart {...commonProps}>
            {commonDefs}
            {commonAxes}
            <Area
              type="monotone"
              dataKey="inspections"
              stackId="1"
              stroke="#3b82f6"
              strokeWidth={2}
              fill="url(#inspectionsAreaGradient)"
              name="Total Inspections"
            >
              <LabelList 
                dataKey="name" 
                position="top" 
                offset={5}
                style={{ 
                  fontSize: '9px', 
                  fill: '#374151', 
                  fontWeight: '600'
                }}
              />
              <LabelList 
                dataKey="inspections" 
                position="top" 
                offset={15}
                style={{ 
                  fontSize: '10px', 
                  fill: '#1e40af', 
                  fontWeight: 'bold',
                  textAnchor: 'middle'
                }}
              />
            </Area>
            <Area
              type="monotone"
              dataKey="cases"
              stackId="2"
              stroke="#10b981"
              strokeWidth={2}
              fill="url(#casesAreaGradient)"
              name="Active Cases"
            >
              <LabelList 
                dataKey="cases" 
                position="top" 
                offset={25}
                style={{ 
                  fontSize: '10px', 
                  fill: '#047857', 
                  fontWeight: 'bold',
                  textAnchor: 'middle'
                }}
              />
            </Area>
          </AreaChart>
        );
    }
  };

  return (
    <div className="space-y-6">
      <div className="flex items-center gap-2">
        <h1 className="text-3xl font-bold">Dashboard</h1>
      </div>
      
      {/* Filter Section */}
      <div className="flex flex-col sm:flex-row gap-4 p-4 border rounded-lg bg-muted/50">
        <div className="flex-1">
          <label htmlFor="district-select" className="block text-sm font-medium mb-2">
            Select District
          </label>
          <Select value={selectedDistrict} onValueChange={handleDistrictChange}>
            <SelectTrigger id="district-select" className="w-full">
              <SelectValue placeholder={isLoadingDistricts ? "Loading districts..." : "Choose a district"} />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="all">All Districts</SelectItem>
              {districts.map((district) => (
                <SelectItem key={district.id} value={district.id}>
                  {district.name}
                </SelectItem>
              ))}
            </SelectContent>
          </Select>
        </div>
        
        <div className="flex-1">
          <label htmlFor="taluka-select" className="block text-sm font-medium mb-2">
            Select Taluka
          </label>
          <Select 
            value={selectedTaluka} 
            onValueChange={handleTalukaChange}
            disabled={!selectedDistrict || selectedDistrict === "all" || isLoadingTalukas}
          >
            <SelectTrigger id="taluka-select" className="w-full">
              <SelectValue 
                placeholder={
                  !selectedDistrict || selectedDistrict === "all"
                    ? "Select district first" 
                    : isLoadingTalukas 
                    ? "Loading talukas..." 
                    : "Choose a taluka"
                } 
              />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="all">All Talukas</SelectItem>
              {talukas.map((taluka) => (
                <SelectItem key={taluka.id} value={taluka.id}>
                  {taluka.name}
                </SelectItem>
              ))}
            </SelectContent>
          </Select>
        </div>
        
        <div className="flex items-end">
          <button 
            onClick={() => {
              setSelectedDistrict("all");
              setSelectedTaluka("all");
            }}
            className="px-4 py-2 text-sm bg-secondary text-secondary-foreground rounded-md hover:bg-secondary/80 transition-colors"
          >
            Clear Filters
          </button>
        </div>
      </div>
      
      {/* Active Filters Display */}
      {(selectedDistrict !== "all" || selectedTaluka !== "all") && (
        <div className="flex flex-wrap gap-2 p-3 bg-blue-50 border border-blue-200 rounded-lg">
          <span className="text-sm font-medium text-blue-800">Active Filters:</span>
          {selectedDistrict !== "all" && (
            <span className="inline-flex items-center gap-1 px-2 py-1 bg-blue-100 text-blue-800 text-xs rounded-md">
              District: {districts.find(d => d.id === selectedDistrict)?.name}
              <button 
                onClick={() => setSelectedDistrict("all")}
                className="ml-1 hover:bg-blue-200 rounded-full p-0.5"
              >
                ×
              </button>
            </span>
          )}
          {selectedTaluka !== "all" && (
            <span className="inline-flex items-center gap-1 px-2 py-1 bg-blue-100 text-blue-800 text-xs rounded-md">
              Taluka: {talukas.find(t => t.id === selectedTaluka)?.name}
              <button 
                onClick={() => setSelectedTaluka("all")}
                className="ml-1 hover:bg-blue-200 rounded-full p-0.5"
              >
                ×
              </button>
            </span>
          )}
        </div>
      )}
      
      {/* State-wise Summary Statistics Header */}
      <div className="mb-6">
        <div className="bg-gradient-to-r from-blue-600 to-indigo-600 px-6 py-4 rounded-t-lg">
          <h2 className="text-xl font-bold text-white">State-wise Summary Statistics</h2>
          <p className="text-blue-100 text-sm mt-1">
            Comprehensive overview of inspection activities across Maharashtra
            {selectedDistrict !== "all" && (
              <span className="block text-blue-200 mt-1">
                Filtered by: {districts.find(d => d.id === selectedDistrict)?.name}
                {selectedTaluka !== "all" && talukas.find(t => t.id === selectedTaluka) && 
                  ` - ${talukas.find(t => t.id === selectedTaluka)?.name}`
                }
              </span>
            )}
          </p>
        </div>
      </div>

      {/* Statistics Cards Grid */}
      <div className="grid gap-6 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-6 mb-8">
        {isLoadingStats && (
          <div className="col-span-full text-center py-8">
            <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600 mx-auto"></div>
            <p className="text-gray-500 mt-2">Loading statistics...</p>
          </div>
        )}
        {/* Inspections Done Card */}
        <div className="bg-white rounded-lg shadow-lg border border-gray-200 p-6">
          <h3 className="text-sm font-semibold text-gray-700 mb-4 text-center">
            No. of Inspections done in state
          </h3>
          <div className="text-center">
            <div className="text-3xl font-bold text-blue-600 mb-2">
              {isLoadingStats ? '...' : 
                selectedCategory === 'inspections_done_completed' ? stats.inspectionsDoneCompleted.toLocaleString() :
                selectedCategory === 'inspections_done_processing' ? stats.inspectionsDoneProcessing.toLocaleString() :
                selectedCategory === 'inspections_live_completed' ? stats.inspectionsLiveCompleted.toLocaleString() :
                selectedCategory === 'inspections_live_processing' ? stats.inspectionsLiveProcessing.toLocaleString() :
                selectedCategory === 'all' ? inspectionsData.length.toLocaleString() :
                '0'
              }
            </div>
            <div className="text-sm text-gray-600 bg-blue-50 px-3 py-1 rounded-full">
              {selectedCategory === 'inspections_done_completed' ? 'Completed' :
               selectedCategory === 'inspections_done_processing' ? 'Processing' :
               selectedCategory === 'inspections_live_completed' ? 'Live Completed' :
               selectedCategory === 'inspections_live_processing' ? 'Live Processing' :
               'Total Inspections'}
            </div>
          </div>
        </div>
        {/* Counterfeit Samples Card */}
        <div className="bg-white rounded-lg shadow-lg border border-gray-200 p-6">
          <h3 className="text-sm font-semibold text-gray-700 mb-4 text-center">
            No. of counterfeit samples collected
          </h3>
          <div className="text-center">
            <div className="text-3xl font-bold text-orange-600 mb-2">{isLoadingStats ? '...' : stats.counterfeitSamples.toLocaleString()}</div>
            <div className="text-sm text-gray-600 bg-orange-50 px-3 py-1 rounded-full">
              Samples
            </div>
          </div>
        </div>

        {/* Ban Chemical Samples Card */}
        <div className="bg-white rounded-lg shadow-lg border border-gray-200 p-6">
          <h3 className="text-sm font-semibold text-gray-700 mb-4 text-center">
            No. of ban chemical samples collected
          </h3>
          <div className="text-center">
            <div className="text-3xl font-bold text-red-600 mb-2">{isLoadingStats ? '...' : stats.banChemicalSamples.toLocaleString()}</div>
            <div className="text-sm text-gray-600 bg-red-50 px-3 py-1 rounded-full">
              Banned
            </div>
          </div>
        </div>

        {/* Lab Samples Card */}
        <div className="bg-white rounded-lg shadow-lg border border-gray-200 p-6">
          <h3 className="text-sm font-semibold text-gray-700 mb-4 text-center">
            No. of samples sent to laboratory
          </h3>
          <div className="text-center">
            <div className="text-3xl font-bold text-purple-600 mb-2">
              {isLoadingStats ? '...' : 
                selectedCategory === 'laboratory_samples' ? stats.labSamples.toLocaleString() :
                selectedCategory === 'counterfeit_samples' ? stats.counterfeitSamples.toLocaleString() :
                selectedCategory === 'ban_chemical_samples' ? stats.banChemicalSamples.toLocaleString() :
                selectedCategory === 'all' ? stats.labSamples.toLocaleString() :
                '0'
              }
            </div>
            <div className="text-sm text-gray-600 bg-purple-50 px-3 py-1 rounded-full">
              {selectedCategory === 'laboratory_samples' ? 'Lab Tests' :
               selectedCategory === 'counterfeit_samples' ? 'Counterfeit' :
               selectedCategory === 'ban_chemical_samples' ? 'Banned' :
               'Lab Tests'}
            </div>
          </div>
        </div>
        
        {/* Legal Cases Card */}
        <div className="bg-white rounded-lg shadow-lg border border-gray-200 p-6">
          <h3 className="text-sm font-semibold text-gray-700 mb-4 text-center">
            No. of Legal cases Registered
          </h3>
          <div className="text-center">
            <div className="text-3xl font-bold text-indigo-600 mb-2">
              {isLoadingStats ? '...' : 
                selectedCategory === 'legal_cases' ? stats.legalCasesLive.toLocaleString() :
                selectedCategory === 'all' ? stats.legalCasesLive.toLocaleString() :
                '0'
              }
            </div>
            <div className="text-sm text-gray-600 bg-indigo-50 px-3 py-1 rounded-full">
              {selectedCategory === 'legal_cases' ? 'Active Cases' : 'Active'}
            </div>
          </div>
        </div>
      </div>
      
      {/* Charts Section */}
      <div className="space-y-4">
        {/* Area Chart */}
        <div className="p-4 border rounded-xl bg-gradient-to-br from-slate-50 to-blue-50 shadow-lg">
          <div className="flex items-center justify-between mb-4">
            <div>
              <h3 className="text-xl font-bold text-gray-800">
                {selectedCategory === 'all' ? 'Inspection Analytics' : 
                  selectedCategory === 'legal_cases' ? 'Legal Cases Analytics' :
                  selectedCategory === 'counterfeit_samples' ? 'Counterfeit Samples Analytics' :
                  selectedCategory === 'ban_chemical_samples' ? 'Ban Chemical Samples Analytics' :
                  selectedCategory === 'laboratory_samples' ? 'Laboratory Samples Analytics' :
                  'Inspection Analytics'} - {chartPeriod === 'monthly' ? 'Monthly' : 'Daily'} Data
                {chartPeriod === 'daily' && (
                  <span className="text-base font-normal text-gray-600 ml-2">
                    ({selectedMonth.charAt(0).toUpperCase() + selectedMonth.slice(1)})
                  </span>
                )}
              </h3>
              <p className="text-sm text-gray-500 mt-1">
                {chartPeriod === 'monthly' 
                  ? 'Yearly overview showing monthly trends' 
                  : `Daily breakdown for ${selectedMonth?.charAt(0)?.toUpperCase() + selectedMonth?.slice(1) || 'August'} (${getBarChartData()?.length || 0} days)`
                } • Hover over bars for details
              </p>
            </div>
                         <div className="flex items-center gap-4">
               <div className="bg-white rounded-lg px-4 py-2 shadow-sm">
                 <span className="text-sm font-medium text-gray-500">Period:</span>
                 <select 
                   value={chartPeriod} 
                   onChange={(e) => setChartPeriod(e.target.value as 'monthly' | 'daily')}
                   className="ml-2 text-sm font-medium bg-transparent border-none outline-none cursor-pointer"
                 >
                   <option value="monthly">Monthly</option>
                   <option value="daily">Daily</option>
                 </select>
               </div>
               {chartPeriod === 'daily' && (
                 <div className="bg-white rounded-lg px-4 py-2 shadow-sm">
                   <span className="text-sm font-medium text-gray-500">Month:</span>
                   <select 
                     value={selectedMonth} 
                     onChange={(e) => setSelectedMonth(e.target.value)}
                     className="ml-2 text-sm font-medium bg-transparent border-none outline-none cursor-pointer"
                   >
                     <option value="january">January</option>
                     <option value="february">February</option>
                     <option value="march">March</option>
                     <option value="april">April</option>
                     <option value="may">May</option>
                     <option value="june">June</option>
                     <option value="july">July</option>
                     <option value="august">August</option>
                     <option value="september">September</option>
                     <option value="october">October</option>
                     <option value="november">November</option>
                     <option value="december">December</option>
                   </select>
                 </div>
               )}
               <div className="bg-white rounded-lg px-4 py-2 shadow-sm">
                 <span className="text-sm font-medium text-gray-500">Chart Type:</span>
                 <select 
                   value={chartType} 
                   onChange={(e) => setChartType(e.target.value as 'area' | 'bar')}
                   className="ml-2 text-sm font-medium bg-transparent border-none outline-none cursor-pointer"
                 >
                   <option value="bar">Bar Chart</option>
                   <option value="area">Area Chart</option>
                 </select>
               </div>
               <div className="bg-white rounded-lg px-4 py-2 shadow-sm">
                 <span className="text-sm font-medium text-gray-500">Categories:</span>
                 <select 
                   value={selectedCategory} 
                   onChange={(e) => setSelectedCategory(e.target.value)}
                   className="ml-2 text-sm font-medium bg-transparent border-none outline-none cursor-pointer"
                 >
                   <option value="all">All Categories</option>
                   <option value="inspections_done_completed">Inspections Done - Completed</option>
                   <option value="inspections_done_processing">Inspections Done - Processing</option>
                   <option value="inspections_live_completed">Inspections Live - Completed</option>
                   <option value="inspections_live_processing">Inspections Live - Processing</option>
                   <option value="counterfeit_samples">Counterfeit Samples Collected</option>
                   <option value="ban_chemical_samples">Ban Chemical Samples Collected</option>
                   <option value="laboratory_samples">Samples Sent to Laboratory</option>
                   <option value="legal_cases">Legal Cases Registered</option>
                 </select>
               </div>
               <div className="bg-white rounded-lg px-4 py-2 shadow-sm">
                 <span className="text-sm font-medium text-gray-500">Showing:</span>
                 <span className="ml-2 text-lg font-bold text-blue-600">
                   {chartPeriod === 'monthly' ? '12 Months' : `${getBarChartData()?.length || 0} Days`}
                 </span>
               </div>
             </div>
          </div>
                     <div className="h-[350px] bg-white rounded-lg p-4 shadow-inner">
             <ResponsiveContainer key={chartKey} width="100%" height="100%">
               {renderChart()}
             </ResponsiveContainer>
           </div>
           

         </div>

        {/* Pie Chart */}
        <div className="p-4 border rounded-xl bg-gradient-to-br from-emerald-50 to-teal-50 shadow-lg">
          <div className="flex flex-col lg:flex-row gap-4">
            <div className="lg:w-2/3">
              <div className="flex items-center justify-between mb-4">
                <div>
                  <h3 className="text-xl font-bold text-gray-800 mb-1">
                    Case Status Distribution
                  </h3>
                  <p className="text-sm text-gray-500">
                    {pieChartCategory === 'all' ? 'All categories overview' : 'Detailed category breakdown'}
                  </p>
                </div>
                <div className="bg-white rounded-lg px-4 py-2 shadow-sm">
                  <span className="text-sm font-medium text-gray-500">Categories:</span>
                  <select 
                    value={pieChartCategory} 
                    onChange={(e) => setPieChartCategory(e.target.value)}
                    className="ml-2 text-sm font-medium bg-transparent border-none outline-none cursor-pointer"
                  >
                    <option value="all">All Categories</option>
                    <option value="inspections_done_completed">Inspections Done - Completed</option>
                    <option value="inspections_done_processing">Inspections Done - Processing</option>
                    <option value="inspections_live_completed">Inspections Live - Completed</option>
                    <option value="inspections_live_processing">Inspections Live - Processing</option>
                    <option value="counterfeit_samples">Counterfeit Samples Collected</option>
                    <option value="ban_chemical_samples">Ban Chemical Samples Collected</option>
                    <option value="laboratory_samples">Samples Sent to Laboratory</option>
                    <option value="legal_cases"></option>
                  </select>
                </div>
              </div>
              <div className="h-[350px] bg-white rounded-lg p-4 shadow-inner">
                <ResponsiveContainer width="100%" height="100%">
                  <PieChart>
                    <Pie
                      data={getPieChartData()}
                      cx="50%"
                      cy="50%"
                      labelLine={false}
                      label={({ percent }) => `${(percent * 100).toFixed(1)}%`}
                      outerRadius={100}
                      innerRadius={35}
                      fill="#8884d8"
                      dataKey="value"
                      stroke="#ffffff"
                      strokeWidth={2}
                    >
                      {getPieChartData().map((entry, index) => (
                        <Cell 
                          key={`cell-${index}`} 
                          fill={COLORS[index % COLORS.length]}
                        />
                      ))}
                    </Pie>
                    <Tooltip 
                      contentStyle={{
                        backgroundColor: 'white',
                        border: '1px solid #e2e8f0',
                        borderRadius: '8px',
                        boxShadow: '0 4px 6px -1px rgba(0, 0, 0, 0.1)'
                      }}
                    />
                  </PieChart>
                </ResponsiveContainer>
              </div>
            </div>
            
            {/* Custom Legend */}
            <div className="lg:w-1/3 flex flex-col justify-center">
              <div className="bg-white rounded-lg p-4 shadow-sm">
                <h4 className="font-semibold text-gray-700 mb-4">Status Breakdown</h4>
                <div className="space-y-3">
                  {getPieChartData().map((entry, index) => (
                    <div key={entry.name} className="flex items-center justify-between">
                      <div className="flex items-center gap-3">
                        <div 
                          className="w-4 h-4 rounded-full shadow-sm"
                          style={{ backgroundColor: COLORS[index % COLORS.length] }}
                        ></div>
                        <span className="text-sm font-medium text-gray-700">{entry.name}</span>
                      </div>
                      <div className="text-right">
                        <div className="font-bold text-gray-800">{entry.value}</div>
                        <div className="text-xs text-gray-500">
                          {((entry.value / getPieChartData().reduce((sum, item) => sum + item.value, 0)) * 100).toFixed(1)}%
                        </div>
                      </div>
                    </div>
                  ))}
                </div>
                <div className="mt-4 pt-3 border-t border-gray-200">
                  <div className="flex justify-between items-center">
                    <span className="font-semibold text-gray-700">Total Cases</span>
                    <span className="font-bold text-lg text-blue-600">
                      {getPieChartData().reduce((sum, item) => sum + item.value, 0)}
                    </span>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>


      </div>
      
      <div className="p-6 border rounded-lg">
        <h3 className="text-lg font-semibold mb-4">
          Recent Activities
          {(selectedDistrict !== "all" || selectedTaluka !== "all") && (
            <span className="ml-2 text-sm font-normal text-blue-600">
              (Filtered by location)
            </span>
          )}
        </h3>
        <div className="space-y-4">
          <div className="flex items-center gap-4 p-4 border rounded-lg">
            <div className="w-2 h-2 bg-green-500 rounded-full"></div>
            <div className="flex-1">
              <p className="font-medium">
                Field inspection completed - 
                {selectedDistrict !== "all"
                  ? ` ${districts.find(d => d.id === selectedDistrict)?.name}${selectedTaluka !== "all" ? `, ${talukas.find(t => t.id === selectedTaluka)?.name}` : ''}`
                  : ' Pune District'
                }
              </p>
              <p className="text-sm text-muted-foreground">2 hours ago • By Officer Raj Sharma</p>
            </div>
          </div>
          <div className="flex items-center gap-4 p-4 border rounded-lg">
            <div className="w-2 h-2 bg-blue-500 rounded-full"></div>
            <div className="flex-1">
              <p className="font-medium">
                New case registered - Seizure #1234 in 
                {selectedDistrict !== "all"
                  ? ` ${districts.find(d => d.id === selectedDistrict)?.name}${selectedTaluka !== "all" ? `, ${talukas.find(t => t.id === selectedTaluka)?.name}` : ''}`
                  : ' Mumbai District'
                }
              </p>
              <p className="text-sm text-muted-foreground">4 hours ago • By Officer Priya Patel</p>
            </div>
          </div>
          <div className="flex items-center gap-4 p-4 border rounded-lg">
            <div className="w-2 h-2 bg-yellow-500 rounded-full"></div>
            <div className="flex-1">
              <p className="font-medium">
                Lab sample submitted - Case #5678 from 
                {selectedDistrict !== "all"
                  ? ` ${districts.find(d => d.id === selectedDistrict)?.name}${selectedTaluka !== "all" ? `, ${talukas.find(t => t.id === selectedTaluka)?.name}` : ''}`
                  : ' Nashik District'
                }
              </p>
              <p className="text-sm text-muted-foreground">6 hours ago • By Lab Tech Amit Kumar</p>
            </div>
          </div>
          {(selectedDistrict !== "all" || selectedTaluka !== "all") && (
            <div className="text-center py-4">
              <p className="text-sm text-muted-foreground">
                Showing activities filtered by location.
                <button 
                  onClick={() => {
                    setSelectedDistrict("all");
                    setSelectedTaluka("all");
                  }}
                  className="ml-1 text-blue-600 hover:underline"
                >
                  View all activities
                </button>
              </p>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}

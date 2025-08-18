import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../utils/theme.dart';

class AuditLogEntry {
  final String id;
  final String action;
  final String module;
  final String user;
  final DateTime timestamp;
  final String? details;
  final String ipAddress;
  final String status;

  AuditLogEntry({
    required this.id,
    required this.action,
    required this.module,
    required this.user,
    required this.timestamp,
    this.details,
    required this.ipAddress,
    required this.status,
  });
}

class AuditLogScreen extends StatefulWidget {
  const AuditLogScreen({super.key});

  @override
  State<AuditLogScreen> createState() => _AuditLogScreenState();
}

class _AuditLogScreenState extends State<AuditLogScreen> {
  final List<AuditLogEntry> _logs = [];
  bool _isLoading = false;
  String _filterModule = 'all';
  String _filterAction = 'all';
  DateTime? _startDate;
  DateTime? _endDate;
  
  @override
  void initState() {
    super.initState();
    _loadAuditLogs();
  }

  void _loadAuditLogs() {
    setState(() => _isLoading = true);
    
    // Simulate loading audit logs
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _logs.clear();
          _logs.addAll(_getMockAuditLogs());
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Audit Log'),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: _exportLogs,
            tooltip: 'Export Logs',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filters Section
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'System Audit Trail',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  'Track all system activities and changes',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
                const SizedBox(height: 16),
                // Module Filter
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('All Modules', 'all'),
                      _buildFilterChip('Inspection', 'inspection'),
                      _buildFilterChip('Seizure', 'seizure'),
                      _buildFilterChip('Lab', 'lab'),
                      _buildFilterChip('Legal', 'legal'),
                      _buildFilterChip('Admin', 'admin'),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Date Range Selector
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => _selectDate(true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 16),
                              const SizedBox(width: 8),
                              Text(
                                _startDate != null
                                    ? DateFormat('dd/MM/yyyy').format(_startDate!)
                                    : 'Start Date',
                                style: TextStyle(
                                  color: _startDate != null
                                      ? AppTheme.textPrimary
                                      : AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: () => _selectDate(false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 16),
                              const SizedBox(width: 8),
                              Text(
                                _endDate != null
                                    ? DateFormat('dd/MM/yyyy').format(_endDate!)
                                    : 'End Date',
                                style: TextStyle(
                                  color: _endDate != null
                                      ? AppTheme.textPrimary
                                      : AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _loadAuditLogs,
                      child: const Text('Filter'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Audit Log List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _logs.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.history,
                              size: 64,
                              color: AppTheme.textMuted,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No audit logs found',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: AppTheme.textSecondary,
                                  ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _logs.length,
                        itemBuilder: (context, index) {
                          final log = _logs[index];
                          if (_filterModule != 'all' && log.module != _filterModule) {
                            return const SizedBox.shrink();
                          }
                          return _buildAuditLogCard(log);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filterModule == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) {
          setState(() => _filterModule = value);
        },
        backgroundColor: Colors.grey.shade100,
        selectedColor: AppTheme.primaryColor.withOpacity(0.2),
        checkmarkColor: AppTheme.primaryColor,
        labelStyle: TextStyle(
          color: isSelected ? AppTheme.primaryColor : AppTheme.textPrimary,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildAuditLogCard(AuditLogEntry log) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    _getActionIcon(log.action),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          log.action.toUpperCase(),
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        Text(
                          log.module,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
                _getStatusChip(log.status),
              ],
            ),
            const SizedBox(height: 12),
            if (log.details != null) ...[
              Text(
                log.details!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
            ],
            const Divider(),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.person, size: 16, color: AppTheme.textSecondary),
                const SizedBox(width: 4),
                Text(
                  log.user,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
                const SizedBox(width: 16),
                Icon(Icons.access_time, size: 16, color: AppTheme.textSecondary),
                const SizedBox(width: 4),
                Text(
                  DateFormat('dd MMM yyyy, hh:mm a').format(log.timestamp),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.computer, size: 16, color: AppTheme.textMuted),
                const SizedBox(width: 4),
                Text(
                  'IP: ${log.ipAddress}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textMuted,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _getActionIcon(String action) {
    IconData icon;
    Color color;
    
    switch (action.toLowerCase()) {
      case 'create':
        icon = Icons.add_circle;
        color = AppTheme.successColor;
        break;
      case 'update':
        icon = Icons.edit;
        color = Colors.blue;
        break;
      case 'delete':
        icon = Icons.delete;
        color = AppTheme.errorColor;
        break;
      case 'login':
        icon = Icons.login;
        color = AppTheme.primaryColor;
        break;
      case 'logout':
        icon = Icons.logout;
        color = Colors.orange;
        break;
      case 'approve':
        icon = Icons.check_circle;
        color = AppTheme.successColor;
        break;
      case 'reject':
        icon = Icons.cancel;
        color = AppTheme.errorColor;
        break;
      default:
        icon = Icons.info;
        color = AppTheme.textSecondary;
    }
    
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }

  Widget _getStatusChip(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'success':
        color = AppTheme.successColor;
        break;
      case 'failed':
        color = AppTheme.errorColor;
        break;
      default:
        color = AppTheme.textSecondary;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Future<void> _selectDate(bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _exportLogs() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Exporting audit logs...'),
        backgroundColor: AppTheme.infoColor,
      ),
    );
  }

  List<AuditLogEntry> _getMockAuditLogs() {
    return [
      AuditLogEntry(
        id: '1',
        action: 'CREATE',
        module: 'Seizure',
        user: 'John Doe',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        details: 'Created seizure record SEIZ-2024-001',
        ipAddress: '192.168.1.100',
        status: 'success',
      ),
      AuditLogEntry(
        id: '2',
        action: 'UPDATE',
        module: 'Inspection',
        user: 'Jane Smith',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        details: 'Updated inspection status to Completed',
        ipAddress: '192.168.1.101',
        status: 'success',
      ),
      AuditLogEntry(
        id: '3',
        action: 'APPROVE',
        module: 'Lab',
        user: 'Admin User',
        timestamp: DateTime.now().subtract(const Duration(hours: 3)),
        details: 'Approved lab test results for LAB-2024-001',
        ipAddress: '192.168.1.102',
        status: 'success',
      ),
      AuditLogEntry(
        id: '4',
        action: 'DELETE',
        module: 'Legal',
        user: 'System Admin',
        timestamp: DateTime.now().subtract(const Duration(hours: 4)),
        details: 'Deleted draft FIR case',
        ipAddress: '192.168.1.103',
        status: 'success',
      ),
      AuditLogEntry(
        id: '5',
        action: 'LOGIN',
        module: 'Authentication',
        user: 'Field Officer 1',
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
        ipAddress: '192.168.1.104',
        status: 'success',
      ),
      AuditLogEntry(
        id: '6',
        action: 'CREATE',
        module: 'Admin',
        user: 'Super Admin',
        timestamp: DateTime.now().subtract(const Duration(hours: 6)),
        details: 'Created new user account',
        ipAddress: '192.168.1.105',
        status: 'success',
      ),
      AuditLogEntry(
        id: '7',
        action: 'UPDATE',
        module: 'Admin',
        user: 'Admin User',
        timestamp: DateTime.now().subtract(const Duration(hours: 7)),
        details: 'Updated role permissions for Field Officer',
        ipAddress: '192.168.1.106',
        status: 'success',
      ),
      AuditLogEntry(
        id: '8',
        action: 'REJECT',
        module: 'Lab',
        user: 'Lab Analyst',
        timestamp: DateTime.now().subtract(const Duration(hours: 8)),
        details: 'Rejected sample due to contamination',
        ipAddress: '192.168.1.107',
        status: 'failed',
      ),
    ];
  }
}

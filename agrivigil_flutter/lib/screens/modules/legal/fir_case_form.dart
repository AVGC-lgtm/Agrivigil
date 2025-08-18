import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../utils/theme.dart';
import '../../../models/seizure_model.dart';
import '../../../routes/app_routes.dart';

class FIRCaseFormScreen extends StatefulWidget {
  const FIRCaseFormScreen({super.key});

  @override
  State<FIRCaseFormScreen> createState() => _FIRCaseFormScreenState();
}

class _FIRCaseFormScreenState extends State<FIRCaseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _policeStationController = TextEditingController();
  final _accusedPartyController = TextEditingController();
  final _suspectNameController = TextEditingController();
  final _street1Controller = TextEditingController();
  final _street2Controller = TextEditingController();
  final _villageController = TextEditingController();
  final _districtController = TextEditingController();
  final _stateController = TextEditingController();
  final _licenseNoController = TextEditingController();
  final _contactNoController = TextEditingController();
  final _brandNameController = TextEditingController();
  final _fertilizerTypeController = TextEditingController();
  final _batchNoController = TextEditingController();
  final _evidenceController = TextEditingController();
  final _remarksController = TextEditingController();

  String _entityType = 'individual';
  DateTime? _manufactureDate;
  DateTime? _expiryDate;
  List<String> _selectedViolations = [];
  bool _isLoading = false;

  final List<String> _entityTypes = [
    'individual',
    'company',
    'shop',
    'distributor',
    'manufacturer',
  ];

  final List<String> _violationTypes = [
    'adulteration',
    'mislabeling',
    'expired_product',
    'no_license',
    'substandard_quality',
    'illegal_import',
    'counterfeit',
    'overpricing',
  ];

  @override
  void dispose() {
    _policeStationController.dispose();
    _accusedPartyController.dispose();
    _suspectNameController.dispose();
    _street1Controller.dispose();
    _street2Controller.dispose();
    _villageController.dispose();
    _districtController.dispose();
    _stateController.dispose();
    _licenseNoController.dispose();
    _contactNoController.dispose();
    _brandNameController.dispose();
    _fertilizerTypeController.dispose();
    _batchNoController.dispose();
    _evidenceController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('File FIR Case'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Police Station Information
              _buildSectionHeader('Police Station Information'),
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _policeStationController,
                      decoration: const InputDecoration(
                        labelText: 'Police Station *',
                        hintText: 'Enter police station name',
                        prefixIcon: Icon(Icons.local_police),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Police station is required';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),

              // Accused Party Information
              _buildSectionHeader('Accused Party Information'),
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Entity Type
                    DropdownButtonFormField<String>(
                      value: _entityType,
                      decoration: const InputDecoration(
                        labelText: 'Entity Type *',
                        prefixIcon: Icon(Icons.business),
                      ),
                      items: _entityTypes.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(type.replaceAll('_', ' ').toUpperCase()),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _entityType = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _accusedPartyController,
                      decoration: const InputDecoration(
                        labelText: 'Accused Party Name *',
                        hintText: 'Enter party/company name',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Accused party name is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _suspectNameController,
                      decoration: const InputDecoration(
                        labelText: 'Suspect/Contact Person *',
                        hintText: 'Enter suspect name',
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Suspect name is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _licenseNoController,
                            decoration: const InputDecoration(
                              labelText: 'License No',
                              hintText: 'License number',
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _contactNoController,
                            decoration: const InputDecoration(
                              labelText: 'Contact No',
                              hintText: 'Phone number',
                            ),
                            keyboardType: TextInputType.phone,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Address Information
              _buildSectionHeader('Address'),
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _street1Controller,
                      decoration: const InputDecoration(
                        labelText: 'Street Address 1',
                        hintText: 'Enter street address',
                        prefixIcon: Icon(Icons.home),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _street2Controller,
                      decoration: const InputDecoration(
                        labelText: 'Street Address 2',
                        hintText: 'Enter additional address',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _villageController,
                      decoration: const InputDecoration(
                        labelText: 'Village/Town',
                        hintText: 'Enter village or town',
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _districtController,
                            decoration: const InputDecoration(
                              labelText: 'District *',
                              hintText: 'Enter district',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'District is required';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _stateController,
                            decoration: const InputDecoration(
                              labelText: 'State *',
                              hintText: 'Enter state',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'State is required';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Product Information
              _buildSectionHeader('Product Information'),
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _brandNameController,
                      decoration: const InputDecoration(
                        labelText: 'Brand Name',
                        hintText: 'Enter brand name',
                        prefixIcon: Icon(Icons.label),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _fertilizerTypeController,
                      decoration: const InputDecoration(
                        labelText: 'Product Type',
                        hintText: 'Enter fertilizer/pesticide type',
                        prefixIcon: Icon(Icons.category),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _batchNoController,
                      decoration: const InputDecoration(
                        labelText: 'Batch Number',
                        hintText: 'Enter batch number',
                        prefixIcon: Icon(Icons.qr_code),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.calendar_today),
                      title: const Text('Manufacture Date'),
                      subtitle: Text(
                        _manufactureDate != null
                            ? DateFormat('dd MMM yyyy').format(_manufactureDate!)
                            : 'Select date',
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => _selectDate(true),
                    ),
                    const Divider(),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.event_busy),
                      title: const Text('Expiry Date'),
                      subtitle: Text(
                        _expiryDate != null
                            ? DateFormat('dd MMM yyyy').format(_expiryDate!)
                            : 'Select date',
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => _selectDate(false),
                    ),
                  ],
                ),
              ),

              // Violations
              _buildSectionHeader('Violations *'),
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: Wrap(
                  spacing: 8,
                  children: _violationTypes.map((type) {
                    final isSelected = _selectedViolations.contains(type);
                    return FilterChip(
                      label: Text(type.replaceAll('_', ' ').toUpperCase()),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedViolations.add(type);
                          } else {
                            _selectedViolations.remove(type);
                          }
                        });
                      },
                      selectedColor: Colors.purple.withOpacity(0.2),
                      checkmarkColor: Colors.purple,
                    );
                  }).toList(),
                ),
              ),

              // Evidence & Remarks
              _buildSectionHeader('Evidence & Remarks'),
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _evidenceController,
                      decoration: const InputDecoration(
                        labelText: 'Evidence Details',
                        hintText: 'Describe evidence collected',
                        prefixIcon: Icon(Icons.folder_special),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _remarksController,
                      decoration: const InputDecoration(
                        labelText: 'Additional Remarks',
                        hintText: 'Enter any additional information',
                        prefixIcon: Icon(Icons.notes),
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 80), // Space for FAB
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isLoading ? null : _saveFIRCase,
        icon: const Icon(Icons.save),
        label: const Text('File FIR'),
        backgroundColor: Colors.purple,
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
      ),
    );
  }

  Future<void> _selectDate(bool isManufacture) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isManufacture) {
          _manufactureDate = picked;
        } else {
          _expiryDate = picked;
        }
      });
    }
  }

  Future<void> _saveFIRCase() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedViolations.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one violation type'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Generate FIR code
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final firCode = 'FIR-${timestamp.substring(timestamp.length - 8)}';

      // TODO: Implement actual save logic with Supabase
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('FIR Case $firCode filed successfully'),
            backgroundColor: AppTheme.successColor,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }
}

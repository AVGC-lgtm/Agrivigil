import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../../../utils/theme.dart';
import '../../../models/seizure_model.dart';
import '../../../routes/app_routes.dart';

class SeizureFormScreen extends StatefulWidget {
  const SeizureFormScreen({super.key});

  @override
  State<SeizureFormScreen> createState() => _SeizureFormScreenState();
}

class _SeizureFormScreenState extends State<SeizureFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _locationController = TextEditingController();
  final _districtController = TextEditingController();
  final _talukaController = TextEditingController();
  final _fertilizerTypeController = TextEditingController();
  final _batchNoController = TextEditingController();
  final _quantityController = TextEditingController();
  final _estimatedValueController = TextEditingController();
  final _witnessNameController = TextEditingController();
  final _memoNoController = TextEditingController();
  final _officerNameController = TextEditingController();
  final _remarksController = TextEditingController();
  
  DateTime? _seizureDate;
  List<String> _selectedPremises = [];
  List<String> _evidencePhotos = [];
  String? _videoEvidence;
  bool _isLoading = false;
  
  final List<String> _premisesOptions = [
    'shop',
    'warehouse',
    'factory',
    'farm',
    'transport',
    'other',
  ];
  
  final List<String> _fertilizerTypes = [
    'NPK Fertilizer',
    'Urea',
    'DAP',
    'Pesticide',
    'Herbicide',
    'Seeds',
    'Other',
  ];

  @override
  void dispose() {
    _locationController.dispose();
    _districtController.dispose();
    _talukaController.dispose();
    _fertilizerTypeController.dispose();
    _batchNoController.dispose();
    _quantityController.dispose();
    _estimatedValueController.dispose();
    _witnessNameController.dispose();
    _memoNoController.dispose();
    _officerNameController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Create Seizure Record'),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveSeizure,
            child: const Text('SAVE'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Location Information Section
              _buildSectionHeader('Location Information'),
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _locationController,
                      decoration: const InputDecoration(
                        labelText: 'Location *',
                        hintText: 'Enter location of seizure',
                        prefixIcon: Icon(Icons.location_on),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Location is required';
                        }
                        return null;
                      },
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
                              prefixIcon: Icon(Icons.map),
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
                            controller: _talukaController,
                            decoration: const InputDecoration(
                              labelText: 'Taluka',
                              hintText: 'Enter taluka',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Premises Type
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Premises Type *',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: _premisesOptions.map((type) {
                            final isSelected = _selectedPremises.contains(type);
                            return FilterChip(
                              label: Text(type),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  if (selected) {
                                    _selectedPremises.add(type);
                                  } else {
                                    _selectedPremises.remove(type);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Product Information Section
              _buildSectionHeader('Product Information'),
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: _fertilizerTypeController.text.isEmpty
                          ? null
                          : _fertilizerTypeController.text,
                      decoration: const InputDecoration(
                        labelText: 'Product Type',
                        prefixIcon: Icon(Icons.category),
                      ),
                      items: _fertilizerTypes.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _fertilizerTypeController.text = value ?? '';
                        });
                      },
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
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _quantityController,
                            decoration: const InputDecoration(
                              labelText: 'Quantity (kg)',
                              hintText: 'Enter quantity',
                              prefixIcon: Icon(Icons.inventory),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _estimatedValueController,
                            decoration: const InputDecoration(
                              labelText: 'Estimated Value',
                              hintText: 'Enter value',
                              prefixIcon: Icon(Icons.currency_rupee),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Seizure Details Section
              _buildSectionHeader('Seizure Details'),
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.calendar_today),
                      title: const Text('Seizure Date'),
                      subtitle: Text(
                        _seizureDate != null
                            ? DateFormat('dd MMM yyyy').format(_seizureDate!)
                            : 'Select date',
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: _selectDate,
                    ),
                    const Divider(),
                    TextFormField(
                      controller: _memoNoController,
                      decoration: const InputDecoration(
                        labelText: 'Memo Number',
                        hintText: 'Enter memo number',
                        prefixIcon: Icon(Icons.receipt),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _witnessNameController,
                      decoration: const InputDecoration(
                        labelText: 'Witness Name',
                        hintText: 'Enter witness name',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _officerNameController,
                      decoration: const InputDecoration(
                        labelText: 'Officer Name',
                        hintText: 'Enter officer name',
                        prefixIcon: Icon(Icons.badge),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _remarksController,
                      decoration: const InputDecoration(
                        labelText: 'Remarks',
                        hintText: 'Enter any additional remarks',
                        prefixIcon: Icon(Icons.notes),
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
              
              // Evidence Section
              _buildSectionHeader('Evidence'),
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Photos (${_evidencePhotos.length})',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 100,
                      child: Row(
                        children: [
                          // Add Photo Button
                          InkWell(
                            onTap: _pickImage,
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.grey.shade300,
                                  style: BorderStyle.solid,
                                  width: 2,
                                ),
                              ),
                              child: const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add_a_photo,
                                      size: 32,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Add Photo',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Photo thumbnails
                          Expanded(
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _evidencePhotos.length,
                              itemBuilder: (context, index) {
                                return Container(
                                  width: 100,
                                  margin: const EdgeInsets.only(right: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Stack(
                                    children: [
                                      const Center(
                                        child: Icon(
                                          Icons.image,
                                          size: 40,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      Positioned(
                                        top: 4,
                                        right: 4,
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _evidencePhotos.removeAt(index);
                                            });
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(2),
                                            decoration: const BoxDecoration(
                                              color: Colors.red,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.close,
                                              size: 16,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Video Evidence
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.videocam),
                      title: const Text('Video Evidence'),
                      subtitle: Text(
                        _videoEvidence != null
                            ? 'Video attached'
                            : 'Tap to add video',
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: _pickVideo,
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
        onPressed: _isLoading ? null : _saveSeizure,
        icon: const Icon(Icons.save),
        label: const Text('Save Seizure'),
        backgroundColor: AppTheme.errorColor,
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

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _seizureDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _seizureDate = picked;
      });
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    
    if (image != null) {
      setState(() {
        _evidencePhotos.add(image.path);
      });
    }
  }

  Future<void> _pickVideo() async {
    final ImagePicker picker = ImagePicker();
    final XFile? video = await picker.pickVideo(source: ImageSource.camera);
    
    if (video != null) {
      setState(() {
        _videoEvidence = video.path;
      });
    }
  }

  Future<void> _saveSeizure() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedPremises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one premises type'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Generate seizure code
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final seizureCode = 'SEIZ-${timestamp.substring(timestamp.length - 8)}';

      // TODO: Implement actual save logic with Supabase
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Seizure record $seizureCode created successfully'),
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

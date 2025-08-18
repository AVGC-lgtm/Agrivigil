import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AdvancedFilterWidget extends StatefulWidget {
  final Map<String, dynamic> initialFilters;
  final Function(Map<String, dynamic>) onApplyFilters;
  final List<FilterOption> filterOptions;
  final VoidCallback? onReset;

  const AdvancedFilterWidget({
    Key? key,
    required this.initialFilters,
    required this.onApplyFilters,
    required this.filterOptions,
    this.onReset,
  }) : super(key: key);

  @override
  State<AdvancedFilterWidget> createState() => _AdvancedFilterWidgetState();
}

class _AdvancedFilterWidgetState extends State<AdvancedFilterWidget> {
  late Map<String, dynamic> _filters;
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    _filters = Map<String, dynamic>.from(widget.initialFilters);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const Divider(height: 1),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: widget.filterOptions.map((option) {
                  switch (option.type) {
                    case FilterType.dropdown:
                      return _buildDropdownFilter(option);
                    case FilterType.dateRange:
                      return _buildDateRangeFilter(option);
                    case FilterType.multiSelect:
                      return _buildMultiSelectFilter(option);
                    case FilterType.toggle:
                      return _buildSwitchFilter(option);
                    case FilterType.slider:
                      return _buildSliderFilter(option);
                    case FilterType.text:
                      return _buildTextFilter(option);
                    case FilterType.number:
                      return _buildNumberFilter(option);
                    case FilterType.chips:
                      return _buildChipsFilter(option);
                  }
                }).toList(),
              ),
            ),
          ),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Advanced Filters',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (_hasActiveFilters())
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_activeFilterCount()} Active',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _resetFilters,
              child: const Text('Reset'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _applyFilters,
              child: const Text('Apply Filters'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownFilter(FilterOption option) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            option.label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _filters[option.key],
            decoration: InputDecoration(
              hintText: option.hint ?? 'Select ${option.label}',
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            items: option.options!.map((item) {
              return DropdownMenuItem<String>(
                value: item['value'],
                child: Text(item['label'] ?? ''),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _filters[option.key] = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDateRangeFilter(FilterOption option) {
    final startDate = _filters['${option.key}_from'] != null
        ? DateTime.parse(_filters['${option.key}_from'])
        : null;
    final endDate = _filters['${option.key}_to'] != null
        ? DateTime.parse(_filters['${option.key}_to'])
        : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            option.label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => _selectDate(context, '${option.key}_from'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          startDate != null
                              ? _dateFormat.format(startDate)
                              : 'From Date',
                          style: TextStyle(
                            color:
                                startDate != null ? Colors.black : Colors.grey,
                          ),
                        ),
                        const Icon(Icons.calendar_today, size: 16),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: InkWell(
                  onTap: () => _selectDate(context, '${option.key}_to'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          endDate != null
                              ? _dateFormat.format(endDate)
                              : 'To Date',
                          style: TextStyle(
                            color: endDate != null ? Colors.black : Colors.grey,
                          ),
                        ),
                        const Icon(Icons.calendar_today, size: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMultiSelectFilter(FilterOption option) {
    final selectedValues = (_filters[option.key] as List<String>?) ?? [];

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            option.label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: option.options!.map((item) {
                final value = item['value'] as String;
                final label = item['label'] as String;
                final isSelected = selectedValues.contains(value);

                return CheckboxListTile(
                  title: Text(label),
                  value: isSelected,
                  dense: true,
                  onChanged: (bool? checked) {
                    setState(() {
                      if (checked == true) {
                        selectedValues.add(value);
                      } else {
                        selectedValues.remove(value);
                      }
                      _filters[option.key] = selectedValues;
                    });
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchFilter(FilterOption option) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            option.label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          Switch(
            value: _filters[option.key] ?? false,
            onChanged: (value) {
              setState(() {
                _filters[option.key] = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSliderFilter(FilterOption option) {
    final value = (_filters[option.key] ?? option.min) as double;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                option.label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value.toStringAsFixed(option.decimals ?? 0),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Slider(
            value: value,
            min: option.min!,
            max: option.max!,
            divisions: option.divisions,
            label: value.toStringAsFixed(option.decimals ?? 0),
            onChanged: (newValue) {
              setState(() {
                _filters[option.key] = newValue;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTextFilter(FilterOption option) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            option.label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: _filters[option.key],
            decoration: InputDecoration(
              hintText: option.hint ?? 'Enter ${option.label}',
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onChanged: (value) {
              _filters[option.key] = value;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNumberFilter(FilterOption option) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            option.label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              if (option.showRange == true) ...[
                Expanded(
                  child: TextFormField(
                    initialValue: _filters['${option.key}_min']?.toString(),
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Min',
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: (value) {
                      _filters['${option.key}_min'] = int.tryParse(value);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    initialValue: _filters['${option.key}_max']?.toString(),
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Max',
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: (value) {
                      _filters['${option.key}_max'] = int.tryParse(value);
                    },
                  ),
                ),
              ] else
                Expanded(
                  child: TextFormField(
                    initialValue: _filters[option.key]?.toString(),
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: option.hint ?? 'Enter ${option.label}',
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: (value) {
                      _filters[option.key] = int.tryParse(value);
                    },
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChipsFilter(FilterOption option) {
    final selectedValues = (_filters[option.key] as List<String>?) ?? [];

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            option.label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: option.options!.map((item) {
              final value = item['value'] as String;
              final label = item['label'] as String;
              final isSelected = selectedValues.contains(value);

              return FilterChip(
                label: Text(label),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      selectedValues.add(value);
                    } else {
                      selectedValues.remove(value);
                    }
                    _filters[option.key] = selectedValues;
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, String key) async {
    final initialDate =
        _filters[key] != null ? DateTime.parse(_filters[key]) : DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        _filters[key] = picked.toIso8601String();
      });
    }
  }

  bool _hasActiveFilters() {
    return _filters.values.any((value) =>
        value != null &&
        value != false &&
        (value is! List || value.isNotEmpty));
  }

  int _activeFilterCount() {
    return _filters.values
        .where((value) =>
            value != null &&
            value != false &&
            (value is! List || value.isNotEmpty))
        .length;
  }

  void _resetFilters() {
    setState(() {
      _filters.clear();
    });
    if (widget.onReset != null) {
      widget.onReset!();
    }
  }

  void _applyFilters() {
    widget.onApplyFilters(_filters);
  }
}

// Filter Option Model
class FilterOption {
  final String key;
  final String label;
  final FilterType type;
  final String? hint;
  final List<Map<String, String>>? options;
  final double? min;
  final double? max;
  final int? divisions;
  final int? decimals;
  final bool? showRange;

  const FilterOption({
    required this.key,
    required this.label,
    required this.type,
    this.hint,
    this.options,
    this.min,
    this.max,
    this.divisions,
    this.decimals,
    this.showRange,
  });
}

// Filter Types
enum FilterType {
  dropdown,
  dateRange,
  multiSelect,
  toggle,
  slider,
  text,
  number,
  chips,
}

// Predefined Filter Sets for Different Modules
class FilterPresets {
  static List<FilterOption> inspectionFilters = [
    FilterOption(
      key: 'status',
      label: 'Status',
      type: FilterType.dropdown,
      options: [
        {'value': 'pending', 'label': 'Pending'},
        {'value': 'in_progress', 'label': 'In Progress'},
        {'value': 'completed', 'label': 'Completed'},
        {'value': 'cancelled', 'label': 'Cancelled'},
      ],
    ),
    FilterOption(
      key: 'date',
      label: 'Date Range',
      type: FilterType.dateRange,
    ),
    FilterOption(
      key: 'priority',
      label: 'Priority',
      type: FilterType.chips,
      options: [
        {'value': 'high', 'label': 'High'},
        {'value': 'medium', 'label': 'Medium'},
        {'value': 'low', 'label': 'Low'},
      ],
    ),
    FilterOption(
      key: 'violation_found',
      label: 'Violation Found',
      type: FilterType.toggle,
    ),
  ];

  static List<FilterOption> seizureFilters = [
    FilterOption(
      key: 'status',
      label: 'Status',
      type: FilterType.dropdown,
      options: [
        {'value': 'seized', 'label': 'Seized'},
        {'value': 'released', 'label': 'Released'},
        {'value': 'destroyed', 'label': 'Destroyed'},
        {'value': 'under_investigation', 'label': 'Under Investigation'},
      ],
    ),
    FilterOption(
      key: 'seizure_date',
      label: 'Seizure Date',
      type: FilterType.dateRange,
    ),
    FilterOption(
      key: 'quantity',
      label: 'Quantity Range',
      type: FilterType.number,
      showRange: true,
    ),
    FilterOption(
      key: 'categories',
      label: 'Product Categories',
      type: FilterType.multiSelect,
      options: [
        {'value': 'pesticides', 'label': 'Pesticides'},
        {'value': 'fertilizers', 'label': 'Fertilizers'},
        {'value': 'seeds', 'label': 'Seeds'},
        {'value': 'others', 'label': 'Others'},
      ],
    ),
  ];

  static List<FilterOption> labSampleFilters = [
    FilterOption(
      key: 'status',
      label: 'Test Status',
      type: FilterType.dropdown,
      options: [
        {'value': 'pending', 'label': 'Pending'},
        {'value': 'in_progress', 'label': 'In Progress'},
        {'value': 'tested', 'label': 'Tested'},
        {'value': 'completed', 'label': 'Completed'},
      ],
    ),
    FilterOption(
      key: 'sample_type',
      label: 'Sample Type',
      type: FilterType.chips,
      options: [
        {'value': 'pesticide', 'label': 'Pesticide'},
        {'value': 'fertilizer', 'label': 'Fertilizer'},
        {'value': 'seed', 'label': 'Seed'},
        {'value': 'soil', 'label': 'Soil'},
        {'value': 'water', 'label': 'Water'},
      ],
    ),
    FilterOption(
      key: 'priority',
      label: 'Priority Level',
      type: FilterType.slider,
      min: 1,
      max: 5,
      divisions: 4,
    ),
    FilterOption(
      key: 'test_date',
      label: 'Test Date Range',
      type: FilterType.dateRange,
    ),
  ];

  static List<FilterOption> firCaseFilters = [
    FilterOption(
      key: 'case_status',
      label: 'Case Status',
      type: FilterType.dropdown,
      options: [
        {'value': 'filed', 'label': 'Filed'},
        {'value': 'under_investigation', 'label': 'Under Investigation'},
        {'value': 'charge_sheet_filed', 'label': 'Charge Sheet Filed'},
        {'value': 'closed', 'label': 'Closed'},
      ],
    ),
    FilterOption(
      key: 'case_type',
      label: 'Case Type',
      type: FilterType.multiSelect,
      options: [
        {'value': 'criminal', 'label': 'Criminal'},
        {'value': 'civil', 'label': 'Civil'},
        {'value': 'regulatory', 'label': 'Regulatory'},
      ],
    ),
    FilterOption(
      key: 'filed_date',
      label: 'Filing Date',
      type: FilterType.dateRange,
    ),
    FilterOption(
      key: 'police_station',
      label: 'Police Station',
      type: FilterType.text,
      hint: 'Enter police station name',
    ),
  ];
}

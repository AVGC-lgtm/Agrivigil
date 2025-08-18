import 'package:flutter/material.dart';
import '../utils/theme.dart';

class DataTableCard extends StatelessWidget {
  final String title;
  final List<DataColumn> columns;
  final List<DataRow> rows;
  final Widget? action;

  const DataTableCard({
    super.key,
    required this.title,
    required this.columns,
    required this.rows,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                if (action != null) action!,
              ],
            ),
          ),
          
          // Data Table
          Theme(
            data: Theme.of(context).copyWith(
              dividerTheme: DividerThemeData(
                thickness: 1,
                color: Colors.grey.shade200,
              ),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: MaterialStateProperty.all(
                  Colors.grey.shade50,
                ),
                columns: columns,
                rows: rows,
                dividerThickness: 1,
                dataRowHeight: 60,
                headingRowHeight: 50,
                horizontalMargin: 16,
                columnSpacing: 24,
                showBottomBorder: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

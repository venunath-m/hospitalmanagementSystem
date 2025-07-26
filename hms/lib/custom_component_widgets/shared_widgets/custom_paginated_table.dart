import 'package:flutter/material.dart';

class CustomPaginatedTable extends StatelessWidget {
  final List<DataColumn> columns;
  final List<DataRow> rows;
  final Widget? footer;
  final int currentPage;
  final int totalPages;
  final VoidCallback? onNextPage;
  final VoidCallback? onPreviousPage;
  final bool isLoading;

  const CustomPaginatedTable({
    Key? key,
    required this.columns,
    required this.rows,
    this.footer,
    this.currentPage = 0,
    this.totalPages = 1,
    this.onNextPage,
    this.onPreviousPage,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : Column(
            children: [
              Expanded(
                child: Scrollbar(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: columns,
                        rows: rows,
                        headingRowColor: MaterialStateProperty.all(
                          Colors.indigo.withOpacity(0.1),
                        ),
                        dataRowColor: MaterialStateProperty.all(Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
              if (footer != null) footer!,
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: currentPage > 0 ? onPreviousPage : null,
                      icon: const Icon(Icons.arrow_back),
                      label: const Text("Previous"),
                    ),
                    const SizedBox(width: 16),
                    Text("Page ${currentPage + 1} of $totalPages"),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: currentPage < totalPages - 1
                          ? onNextPage
                          : null,
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text("Next"),
                    ),
                  ],
                ),
              ),
            ],
          );
  }
}

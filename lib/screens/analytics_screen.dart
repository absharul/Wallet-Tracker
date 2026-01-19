import 'package:expense_tracker/models/transaction.dart';
import 'package:expense_tracker/widgets/category_pie_chart.dart';
import 'package:expense_tracker/widgets/transaction_list_view.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  String _searchQuery = '';
  String _selectedDateFilter = 'All Time';
  DateTimeRange? _selectedDateRange;

  final List<String> _dateFilters = [
    'All Time',
    'This Month',
    'Last Month',
    'This Year',
    'Custom Range',
  ];

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final pickedRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: now,
      initialDateRange:
          _selectedDateRange ??
          DateTimeRange(start: now.subtract(const Duration(days: 7)), end: now),
    );

    if (pickedRange != null) {
      setState(() {
        _selectedDateFilter = 'Custom Range';
        _selectedDateRange = pickedRange;
      });
    } else if (_selectedDateFilter == 'Custom Range' &&
        _selectedDateRange == null) {
      // Revert to default if cancelled without ever picking
      setState(() {
        _selectedDateFilter = 'All Time';
      });
    }
  }

  List<Transaction> _filterTransactions(List<Transaction> transactions) {
    return transactions.where((tx) {
      // 1. Search Filter
      final matchesSearch = tx.title.toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );

      if (!matchesSearch) return false;

      // 2. Date Filter
      final now = DateTime.now();
      if (_selectedDateFilter == 'All Time') {
        return true;
      } else if (_selectedDateFilter == 'This Month') {
        return tx.date.year == now.year && tx.date.month == now.month;
      } else if (_selectedDateFilter == 'Last Month') {
        final lastMonthDate = DateTime(now.year, now.month - 1);
        return tx.date.year == lastMonthDate.year &&
            tx.date.month == lastMonthDate.month;
      } else if (_selectedDateFilter == 'This Year') {
        return tx.date.year == now.year;
      } else if (_selectedDateFilter == 'Custom Range' &&
          _selectedDateRange != null) {
        // Inclusive check
        return tx.date.isAfter(
              _selectedDateRange!.start.subtract(const Duration(days: 1)),
            ) &&
            tx.date.isBefore(
              _selectedDateRange!.end.add(const Duration(days: 1)),
            );
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Analytics',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<Transaction>('transactions').listenable(),
        builder: (context, Box<Transaction> box, _) {
          final allTransactions = box.values.toList().cast<Transaction>();
          final filteredTransactions = _filterTransactions(allTransactions);

          // Sort for the list view
          filteredTransactions.sort((a, b) => b.date.compareTo(a.date));

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Filter Section
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        // Search Bar
                        TextField(
                          decoration: InputDecoration(
                            labelText: 'Search Transactions',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 0,
                              horizontal: 12,
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        // Date Filter Dropdown
                        DropdownButtonFormField<String>(
                          value: _selectedDateFilter,
                          decoration: InputDecoration(
                            labelText: 'Time Period',
                            prefixIcon: const Icon(Icons.calendar_month),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 0,
                              horizontal: 12,
                            ),
                          ),
                          items: _dateFilters.map((filter) {
                            return DropdownMenuItem(
                              value: filter,
                              child: Text(filter),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value == 'Custom Range') {
                              _pickDateRange();
                            } else if (value != null) {
                              setState(() {
                                _selectedDateFilter = value;
                                _selectedDateRange = null; // Reset custom range
                              });
                            }
                          },
                        ),
                        if (_selectedDateFilter == 'Custom Range' &&
                            _selectedDateRange != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              '${_selectedDateRange!.start.toString().split(' ')[0]} - ${_selectedDateRange!.end.toString().split(' ')[0]}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                if (filteredTransactions.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        'No transactions match your filters.',
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                else ...[
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text(
                            'Spending by Category',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),
                          CategoryPieChart(transactions: filteredTransactions),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Summary stats
                  Card(
                    elevation: 2,
                    clipBehavior: Clip.antiAlias,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.primary,
                            Theme.of(context).colorScheme.tertiary,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total Filtered Spend:',
                              style: TextStyle(
                                color: Colors.white,
                              ), // Assuming dark gradient, improving readability
                            ),
                            Text(
                              '${Hive.box('settings').get('currencySymbol', defaultValue: '\$')}${filteredTransactions.fold(0.0, (sum, tx) => sum + tx.amount).toStringAsFixed(2)}',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors
                                        .white, // Improved readability for gradient background
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Detailed List Header
                  Text(
                    'Detailed List',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 10),
                  // Reused List View
                  TransactionListView(transactions: filteredTransactions),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

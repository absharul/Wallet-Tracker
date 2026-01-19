import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/transaction.dart';

class TotalBalanceCard extends StatelessWidget {
  const TotalBalanceCard({super.key});

  double _calculateTotal(List<Transaction> transactions, String timeframe) {
    if (transactions.isEmpty) return 0.0;

    final now = DateTime.now();
    Iterable<Transaction> filtered = transactions;

    if (timeframe == 'This Month') {
      filtered = transactions.where(
        (tx) => tx.date.year == now.year && tx.date.month == now.month,
      );
    } else if (timeframe == 'This Year') {
      filtered = transactions.where((tx) => tx.date.year == now.year);
    }

    return filtered.fold<double>(0.0, (sum, tx) => sum + tx.amount);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box('settings').listenable(),
      builder: (context, Box settingsBox, _) {
        final selectedTimeframe = settingsBox.get(
          'dashboardTimeframe',
          defaultValue: 'Lifetime',
        );

        // Nest the transactions listener
        return ValueListenableBuilder(
          valueListenable: Hive.box<Transaction>('transactions').listenable(),
          builder: (context, Box<Transaction> txBox, _) {
            final totalSpending = _calculateTotal(
              txBox.values.toList().cast<Transaction>(),
              selectedTimeframe,
            );

            return Card(
              elevation: 4,
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.tertiary,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Total Spending',
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(
                                        color: Colors.white.withOpacity(0.8),
                                      ),
                                ),
                                const SizedBox(width: 8),
                                // Timeframe Selector
                                Theme(
                                  data: Theme.of(context).copyWith(
                                    canvasColor: Theme.of(
                                      context,
                                    ).colorScheme.primaryContainer,
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: selectedTimeframe,
                                      icon: Icon(
                                        Icons.arrow_drop_down,
                                        color: Colors.white.withOpacity(0.8),
                                      ),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.onPrimaryContainer,
                                            fontWeight: FontWeight.bold,
                                          ),
                                      selectedItemBuilder:
                                          (BuildContext context) {
                                            return [
                                              'Lifetime',
                                              'This Year',
                                              'This Month',
                                            ].map<Widget>((String value) {
                                              return Text(
                                                '($value)',
                                                style: TextStyle(
                                                  color: Colors.white
                                                      .withOpacity(0.8),
                                                  fontSize: 12,
                                                ),
                                              );
                                            }).toList();
                                          },
                                      onChanged: (String? newValue) {
                                        if (newValue != null) {
                                          // Update Hive directly; this listener will rebuild
                                          settingsBox.put(
                                            'dashboardTimeframe',
                                            newValue,
                                          );
                                        }
                                      },
                                      items:
                                          <String>[
                                            'Lifetime',
                                            'This Year',
                                            'This Month',
                                          ].map<DropdownMenuItem<String>>((
                                            String value,
                                          ) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(value),
                                            );
                                          }).toList(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${settingsBox.get('currencySymbol', defaultValue: '\$')}${totalSpending.toStringAsFixed(2)}',
                              style: Theme.of(context).textTheme.displaySmall
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.2),
                          ),
                          child: const Icon(
                            Icons.wallet,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

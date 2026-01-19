import 'package:expense_tracker/utils/category_utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';

class TransactionListView extends StatelessWidget {
  final List<Transaction> transactions;

  const TransactionListView({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              size: 80,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 20),
            Text(
              'No transactions found!',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: transactions.length,
      padding: const EdgeInsets.all(16),
      separatorBuilder: (ctx, index) => const Divider(height: 1),
      itemBuilder: (ctx, index) {
        final tx = transactions[index];
        return Dismissible(
          key: Key(tx.id),
          direction: DismissDirection.endToStart,
          background: Container(
            color: Theme.of(context).colorScheme.errorContainer,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: Icon(
              Icons.delete,
              color: Theme.of(context).colorScheme.onErrorContainer,
              size: 28,
            ),
          ),
          confirmDismiss: (direction) async {
            return await showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                backgroundColor: Theme.of(context).colorScheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                title: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(width: 10),
                    const Text('Delete Transaction?'),
                  ],
                ),
                content: const Text(
                  'Are you sure you want to delete this transaction? This action cannot be undone.',
                ),
                actions: <Widget>[
                  TextButton(
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(ctx).pop(false);
                    },
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text(
                      'Delete',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      Navigator.of(ctx).pop(true);
                    },
                  ),
                ],
              ),
            );
          },
          onDismissed: (direction) {
            tx.delete(); // Hive delete
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Transaction deleted')),
            );
          },
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 4,
              vertical: 8,
            ),
            leading: CircleAvatar(
              radius: 24,
              backgroundColor: CategoryUtils.getColor(
                tx.category,
              ).withOpacity(0.2),
              child: Icon(
                CategoryUtils.getIcon(tx.category),
                color: CategoryUtils.getColor(tx.category),
                size: 20,
              ),
            ),
            title: Text(
              tx.title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              DateFormat.yMMMd().format(tx.date),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            trailing: Text(
              '\$${tx.amount.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: tx.category == 'Income'
                    ? Colors.green
                    : Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }
}

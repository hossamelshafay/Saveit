import 'package:material_ui/material_ui.dart';
import 'package:saveit/features/savings/domain/entities/savings.dart';

class DailySavingsCard extends StatelessWidget {
  const DailySavingsCard({super.key, required this.savings});
  final SavingsModel? savings;
  @override
  Widget build(BuildContext context) {
    final savings = this.savings;
    return Card(
      elevation: 8,
      shadowColor: Colors.black.withAlpha(26),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primaryContainer,
              Theme.of(context).colorScheme.primaryContainer.withAlpha(179),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.savings,
                  size: 32,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  'Today\'s Savings',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            if (savings != null) ...[
              // Savings Message
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _getSavingsColor(savings.difference).withAlpha(26),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _getSavingsColor(savings.difference),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    // Show icon for all savings cases
                    Icon(
                      _getSavingsIcon(savings.difference),
                      color: _getSavingsColor(savings.difference),
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        savings.savingsMessage,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: _getSavingsColor(savings.difference),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Expense Comparison
              Row(
                children: [
                  Expanded(
                    child: _buildExpenseComparisonItem(
                      'Yesterday',
                      savings.yesterdayExpenses,
                      Icons.history,
                      Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildExpenseComparisonItem(
                      'Today',
                      savings.todayExpenses,
                      Icons.today,
                      Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.orange.withAlpha(26),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.orange),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'No savings data available yet. Start tracking your expenses to see daily savings!',
                        style: TextStyle(
                          color: Colors.orange.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseComparisonItem(
    String title,
    double amount,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(51)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${amount.toStringAsFixed(2)} SAR',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Color _getSavingsColor(double difference) {
    if (difference > 0) return Colors.green;
    if (difference < 0) return Colors.red;
    return Colors.grey;
  }

  IconData _getSavingsIcon(double difference) {
    if (difference > 0) return Icons.trending_up;
    if (difference < 0) return Icons.trending_down;
    return Icons.remove;
  }
}

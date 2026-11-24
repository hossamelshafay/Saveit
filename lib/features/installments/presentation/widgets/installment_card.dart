import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import 'installment_view_model.dart';

class InstallmentCard extends StatelessWidget {
  const InstallmentCard({
    super.key,
    required this.installment,
    required this.alarmEnabled,
    required this.alarmController,
    required this.onEdit,
    required this.onPaymentChanged,
    required this.onAlarmChanged,
    required this.onDelete,
  });
  final InstallmentViewModel installment;
  final bool alarmEnabled;
  final Animation<double> alarmController;
  final VoidCallback onEdit;
  final VoidCallback onPaymentChanged;
  final VoidCallback onAlarmChanged;
  final VoidCallback onDelete;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onEdit,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withAlpha(26),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: installment.iconColor.withAlpha(26),
                shape: BoxShape.circle,
              ),
              child: Icon(
                installment.icon,
                color: installment.iconColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    installment.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('MMM d, y').format(installment.dueDate),
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  if (installment.timeStatus.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      installment.timeStatus,
                      style: TextStyle(
                        fontSize: 12,
                        color: installment.timeStatus == 'Due Tomorrow'
                            ? Colors.red
                            : Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${installment.amount.toStringAsFixed(2)} SAR',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    GestureDetector(
                      onTap: onPaymentChanged,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: !installment.isPaid
                              ? Colors.green
                              : Colors.orange,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          !installment.isPaid ? 'Done' : 'Undo',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: onAlarmChanged,
                      child: AnimatedBuilder(
                        animation: alarmController,
                        builder: (context, child) {
                          return Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: alarmEnabled
                                  ? const Color(0xFFFF9800)
                                  : Colors.grey[300],
                              shape: BoxShape.circle,
                              boxShadow: alarmEnabled
                                  ? [
                                      BoxShadow(
                                        color: Colors.orange.withAlpha(77),
                                        blurRadius: 4,
                                        spreadRadius: 1,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Icon(
                              Icons.alarm,
                              color: alarmEnabled
                                  ? Colors.white
                                  : Colors.grey[600],
                              size: 16,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: onDelete,
                      child: Icon(
                        !installment.isPaid
                            ? Icons.delete_outline
                            : Icons.archive_outlined,
                        color: Colors.grey[400],
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

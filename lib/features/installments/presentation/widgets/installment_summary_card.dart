import 'package:saveit/app/localization/app_translations.dart';
import 'package:material_ui/material_ui.dart';

class InstallmentSummaryCard extends StatelessWidget {
  const InstallmentSummaryCard({
    super.key,
    required this.totalAmount,
    required this.paidAmount,
  });
  final double totalAmount;
  final double paidAmount;
  @override
  Widget build(BuildContext context) {
    final remainingAmount = totalAmount - paidAmount;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color.fromARGB(255, 226, 188, 17), Color(0xFFFF8E53)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withAlpha(77),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'total_installments'.tr(context),
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${totalAmount.toStringAsFixed(2)} SAR',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'paid'.tr(context),
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  Text(
                    '${paidAmount.toStringAsFixed(2)} SAR',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'remaining'.tr(context),
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  Text(
                    '${remainingAmount.toStringAsFixed(2)} SAR',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

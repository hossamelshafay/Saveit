import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../core/model/installment_view_model.dart';
import '../../core/model/installment_model.dart';
import '../../core/services/firebase_service.dart';
import '../Add_installments_screen/Add_installments_screen.dart';
import '../Home_screen/Home_screen.dart';
import 'dart:async';

const double kBottomPadding = 16.0;
const double kFontSize = 18.0;
const double kBorderRadius = 20.0;

class InstallmentsScreen extends StatefulWidget {
  const InstallmentsScreen({super.key});

  @override
  State<InstallmentsScreen> createState() => _InstallmentsScreenState();
}

class _InstallmentsScreenState extends State<InstallmentsScreen>
    with TickerProviderStateMixin {
  final FirebaseService _firebaseService = FirebaseService();
  StreamSubscription? _installmentsSubscription;
  List<InstallmentViewModel> _allInstallments = [];
  bool _isLoading = true;
  String? _error;

  // خريطة لكل منبه
  final Map<String, bool> _alarmEnabledMap = {};
  final Map<String, AnimationController> _alarmControllers = {};

  List<InstallmentViewModel> get upcomingInstallments =>
      _allInstallments.where((i) => !i.isPaid).toList();

  List<InstallmentViewModel> get paidInstallments =>
      _allInstallments.where((i) => i.isPaid).toList();

  @override
  void initState() {
    super.initState();
    _loadInstallments();
  }

  void _loadInstallments() {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      _installmentsSubscription = _firebaseService
          .getInstallmentsStream()
          .listen(
            (installments) {
              if (mounted) {
                setState(() {
                  _allInstallments = installments
                      .map((model) => _mapToViewModel(model))
                      .toList();

                  // Initialize alarms for new installments
                  for (var installment in _allInstallments) {
                    if (installment.id?.isNotEmpty == true &&
                        !_alarmControllers.containsKey(installment.id)) {
                      _alarmControllers[installment.id!] = AnimationController(
                        vsync: this,
                        duration: const Duration(milliseconds: 1000),
                      )..repeat(reverse: true);
                      _alarmEnabledMap[installment.id!] = !installment.isPaid;
                    }
                  }

                  _isLoading = false;
                });
              }
            },
            onError: (error) {
              if (mounted) {
                setState(() {
                  _error = error.toString();
                  _isLoading = false;
                });
              }
            },
          );
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  InstallmentViewModel _mapToViewModel(InstallmentModel model) {
    // Convert any numeric or string ID to string
    String modelId = '';
    if (model.id != null) {
      modelId = model.id.toString();
    }

    return InstallmentViewModel(
      id: modelId,
      title: model.installmentName,
      dueDate: model.dueDate,
      amount: model.totalAmount, // totalAmount is already double in the model
      isPaid: model.isPaid,
      icon: model.icon ?? Icons.attach_money,
      iconColor: model.iconColor ?? const Color(0xFFFF9800),
      timeStatus: model.timeStatus,
      category: model.category,
      notes: model.notes,
      createdAt: model.createdAt,
    );
  }

  @override
  void dispose() {
    for (var controller in _alarmControllers.values) {
      controller.dispose();
    }
    _installmentsSubscription?.cancel();
    super.dispose();
  }

  void _toggleAlarm(String id) {
    setState(() {
      _alarmEnabledMap[id] = !_alarmEnabledMap[id]!;
      final controller = _alarmControllers[id]!;
      if (_alarmEnabledMap[id]!) {
        controller.repeat(reverse: true);
      } else {
        controller.stop();
        controller.reset();
      }
    });
  }

  void _toggleInstallmentStatus(int index, String listType) async {
    final installment = listType == 'upcoming'
        ? upcomingInstallments[index]
        : paidInstallments[index];

    if (installment.id?.isNotEmpty == true) {
      final newIsPaid = !installment.isPaid;
      final id = installment.id.toString();
      await _firebaseService.updateInstallmentStatus(id, newIsPaid);

      setState(() {
        // استخدم copyWith لعمل نسخة جديدة
        final updatedInstallment = installment.copyWith(isPaid: newIsPaid);

        // حدث القائمة الأصلية
        final allIndex = _allInstallments.indexWhere(
          (i) => i.id == installment.id,
        );
        if (allIndex != -1) {
          _allInstallments[allIndex] = updatedInstallment;
        }

        // تحديث حالة المنبه للدفعة دي فقط
        _alarmEnabledMap[installment.id!] = !newIsPaid;
        final controller = _alarmControllers[installment.id!]!;
        if (!newIsPaid) {
          controller.repeat(reverse: true);
        } else {
          controller.stop();
          controller.reset();
        }
      });
    }
  }

  Future<void> _addNewInstallment() async {
    final result = await Navigator.of(context).push<InstallmentModel>(
      MaterialPageRoute(builder: (context) => const AddInstallmentScreen()),
    );

    if (result != null && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('installment_added'.tr)));
    }
  }

  Future<void> _editInstallment(InstallmentViewModel installment) async {
    final result = await Navigator.of(context).push<InstallmentModel>(
      MaterialPageRoute(
        builder: (context) => AddInstallmentScreen(
          installmentToEdit: InstallmentModel(
            id: installment.id,
            installmentName: installment.title,
            totalAmount: installment.amount,
            dueDate: installment.dueDate,
            category: installment.category,
            notes: installment.notes,
            currency: 'SAR',
            isPaid: installment.isPaid,
            createdAt: installment.createdAt,
            icon: installment.icon,
            iconColor: installment.iconColor,
            timeStatus: installment.timeStatus,
          ),
        ),
      ),
    );

    if (result != null && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('installment_updated'.tr)));
    }
  }

  void _deleteInstallmentFromUI(InstallmentViewModel installment) async {
    if (installment.id != null) {
      try {
        await _firebaseService.deleteInstallment(installment.id!);
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('installment_deleted'.tr)));
        }
        // Remove alarm controller for deleted installment
        _alarmControllers[installment.id!]?.dispose();
        _alarmControllers.remove(installment.id!);
        _alarmEnabledMap.remove(installment.id!);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Failed to delete: $e')));
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('cannot_delete'.tr)));
      }
    }
  }

  Widget _buildInstallmentCard(
    InstallmentViewModel installment,
    int index,
    String listType,
  ) {
    // Since InstallmentViewModel.id is already String?, we don't need type conversion
    if (installment.id == null || installment.id!.isEmpty) return Container();

    final alarmEnabled = _alarmEnabledMap[installment.id!] ?? true;
    final alarmController = _alarmControllers[installment.id!]!;

    return GestureDetector(
      onTap: () => _editInstallment(installment),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
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
                color: installment.iconColor.withOpacity(0.1),
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
                      onTap: () => _toggleInstallmentStatus(index, listType),
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
                      onTap: () => installment.id?.isNotEmpty == true
                          ? _toggleAlarm(installment.id!)
                          : null,
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
                                        color: Colors.orange.withOpacity(0.3),
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
                      onTap: () => _deleteInstallmentFromUI(installment),
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

  Widget _buildSummaryCard() {
    final totalAmount = _allInstallments.fold(0.0, (sum, i) => sum + i.amount);
    final paidAmount = paidInstallments.fold(0.0, (sum, i) => sum + i.amount);
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
            color: Colors.orange.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'total_installments'.tr,
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
                    'paid'.tr,
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
                    'remaining'.tr,
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $_error'),
              ElevatedButton(
                onPressed: _loadInstallments,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () {
            Get.offAll(() => const HomeScreen());
          },
        ),
        title: Text(
          'installments'.tr,
          style: TextStyle(
            color: Colors.black87,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.black87),
            onPressed: _addNewInstallment,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryCard(),
            SizedBox(height: 8),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'upcoming_installments'.tr,
                style: TextStyle(
                  fontSize: kFontSize,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
            if (upcomingInstallments.isEmpty)
              Padding(
                padding: EdgeInsets.all(32.0),
                child: Center(
                  child: Text(
                    'no_upcoming_installments'.tr,
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ),
              )
            else
              ...upcomingInstallments.asMap().entries.map(
                (entry) =>
                    _buildInstallmentCard(entry.value, entry.key, 'upcoming'),
              ),
            const SizedBox(height: 16),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'paid_installments'.tr,
                style: TextStyle(
                  fontSize: kFontSize,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
            if (paidInstallments.isEmpty)
              Padding(
                padding: EdgeInsets.all(32.0),
                child: Center(
                  child: Text(
                    'no_paid_installments'.tr,
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ),
              )
            else
              ...paidInstallments.asMap().entries.map(
                (entry) =>
                    _buildInstallmentCard(entry.value, entry.key, 'paid'),
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

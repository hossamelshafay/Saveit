import 'package:saveit/app/localization/app_translations.dart';
import 'package:go_router/go_router.dart';
import 'package:saveit/app/router/route_names.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saveit/features/installments/presentation/cubit/installment_cubit.dart';
import 'package:saveit/core/utils/watch_cubit.dart';

import '../widgets/installment_card.dart';
import '../widgets/installment_summary_card.dart';

import 'package:material_ui/material_ui.dart';
import 'package:saveit/features/installments/presentation/widgets/installment_view_model.dart';
import 'package:saveit/features/installments/domain/entities/installment.dart';

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
  InstallmentCubit get _cubit => context.read<InstallmentCubit>();
  StreamSubscription<WatchState<List<InstallmentModel>>>?
  _installmentsSubscription;
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
    _installmentsSubscription = _cubit.stream.listen((state) {
      if (!mounted) return;
      setState(() {
        _error = state.error;
        _isLoading = state.data == null && state.error == null;
        _allInstallments = (state.data ?? []).map(_mapToViewModel).toList();

        for (final installment in _allInstallments) {
          final id = installment.id;
          if (id == null || id.isEmpty || _alarmControllers.containsKey(id)) {
            continue;
          }
          _alarmControllers[id] = AnimationController(
            vsync: this,
            duration: const Duration(milliseconds: 1000),
          )..repeat(reverse: true);
          _alarmEnabledMap[id] = !installment.isPaid;
        }
      });
    });
    _cubit.start();
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
      try {
        await _cubit.updateStatus(id, newIsPaid);
      } catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Error: $error')));
        }
        return;
      }
      if (!mounted) return;

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
    final result = await context.push<InstallmentModel>(
      RouteNames.installmentForm,
    );

    if (result != null && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('installment_added'.tr(context))));
    }
  }

  Future<void> _editInstallment(InstallmentViewModel installment) async {
    final result = await context.push<InstallmentModel>(
      RouteNames.installmentForm,
      extra: InstallmentModel(
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
    );

    if (result != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('installment_updated'.tr(context))),
      );
    }
  }

  void _deleteInstallmentFromUI(InstallmentViewModel installment) async {
    if (installment.id != null) {
      try {
        await _cubit.delete(installment.id!);
        if (!mounted) return;
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('installment_deleted'.tr(context))),
          );
        }
        // Remove alarm controller for deleted installment
        _alarmControllers[installment.id!]?.dispose();
        _alarmControllers.remove(installment.id!);
        _alarmEnabledMap.remove(installment.id!);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Failed to delete: $e')));
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('cannot_delete'.tr(context))));
      }
    }
  }

  Widget _buildInstallmentCard(
    InstallmentViewModel installment,
    int index,
    String listType,
  ) {
    final id = installment.id;
    if (id == null || id.isEmpty) return Container();
    return InstallmentCard(
      installment: installment,
      alarmEnabled: _alarmEnabledMap[id] ?? true,
      alarmController: _alarmControllers[id]!,
      onEdit: () => _editInstallment(installment),
      onPaymentChanged: () => _toggleInstallmentStatus(index, listType),
      onAlarmChanged: () => _toggleAlarm(id),
      onDelete: () => _deleteInstallmentFromUI(installment),
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
            context.go(RouteNames.home);
          },
        ),
        title: Text(
          'installments'.tr(context),
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
            InstallmentSummaryCard(
              totalAmount: _allInstallments.fold(
                0.0,
                (sum, i) => sum + i.amount,
              ),
              paidAmount: paidInstallments.fold(
                0.0,
                (sum, i) => sum + i.amount,
              ),
            ),
            SizedBox(height: 8),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'upcoming_installments'.tr(context),
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
                    'no_upcoming_installments'.tr(context),
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
                'paid_installments'.tr(context),
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
                    'no_paid_installments'.tr(context),
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

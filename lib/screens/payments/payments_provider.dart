import 'package:bdoneapp/models/payments/payment.dart';
import 'package:bdoneapp/providers/providers.dart';
import 'package:bdoneapp/screens/auth/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

class PaymentsState {
  final bool isLoading;
  final List<Payment> payments;
  final int page;
  final int totalPages;
  final String? error;
  final String keyword;

  PaymentsState({
    this.isLoading = false,
    this.payments = const [],
    this.page = 1,
    this.totalPages = 1,
    this.error,
    this.keyword = '',
  });

  PaymentsState copyWith({
    bool? isLoading,
    List<Payment>? payments,
    int? page,
    int? totalPages,
    String? error,
    String? keyword,
  }) {
    return PaymentsState(
      isLoading: isLoading ?? this.isLoading,
      payments: payments ?? this.payments,
      page: page ?? this.page,
      totalPages: totalPages ?? this.totalPages,
      error: error,
      keyword: keyword ?? this.keyword,
    );
  }
}

class PaymentsNotifier extends StateNotifier<PaymentsState> {
  final Ref _ref;

  PaymentsNotifier(this._ref) : super(PaymentsState()) {
    fetchPayments();
  }

  Future<void> fetchPayments({bool refresh = false}) async {
    if (state.isLoading) return;

    if (refresh) {
      state = state.copyWith(page: 1, payments: [], isLoading: true);
    } else {
      state = state.copyWith(isLoading: true);
    }

    try {
      final user = await _ref.read(authProvider.notifier).getCurrentUser();
      if (user == null || user.clientId == null) {
        state = state.copyWith(isLoading: false, error: 'User session or client ID not found');
        return;
      }
      final clientId = user.clientId!;

      final service = _ref.read(paymentServiceProvider);
      final result = await service.fetchPayments(
        clientId: clientId,
        page: state.page,
        keyword: state.keyword,
      );

      final newPayments = result.data ?? [];
      state = state.copyWith(
        isLoading: false,
        payments: refresh ? newPayments : [...state.payments, ...newPayments],
        totalPages: result.pages,
        page: newPayments.isNotEmpty ? state.page + 1 : state.page,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void setKeyword(String keyword) {
    state = state.copyWith(keyword: keyword);
    fetchPayments(refresh: true);
  }

  Future<void> refresh() => fetchPayments(refresh: true);
}

final paymentsProvider = StateNotifierProvider<PaymentsNotifier, PaymentsState>((ref) {
  return PaymentsNotifier(ref);
});

final paymentMetricsProvider = Provider<Map<String, double>>((ref) {
  final payments = ref.watch(paymentsProvider).payments;
  double totalReceived = 0;
  
  for (var p in payments) {
    totalReceived += p.amountPaid;
  }

  return {
    'totalReceived': totalReceived,
    'totalPending': 0,
  };
});

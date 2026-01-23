import 'package:bdcomputing/models/common/invoice.dart';
import 'package:bdcomputing/models/common/paginated_data.dart';
import 'package:bdcomputing/providers/providers.dart';
import 'package:bdcomputing/screens/auth/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

class InvoicesState {
  final bool isLoading;
  final List<Invoice> invoices;
  final int page;
  final int totalPages;
  final String? error;
  final String keyword;

  InvoicesState({
    this.isLoading = false,
    this.invoices = const [],
    this.page = 1,
    this.totalPages = 1,
    this.error,
    this.keyword = '',
  });

  InvoicesState copyWith({
    bool? isLoading,
    List<Invoice>? invoices,
    int? page,
    int? totalPages,
    String? error,
    String? keyword,
  }) {
    return InvoicesState(
      isLoading: isLoading ?? this.isLoading,
      invoices: invoices ?? this.invoices,
      page: page ?? this.page,
      totalPages: totalPages ?? this.totalPages,
      error: error,
      keyword: keyword ?? this.keyword,
    );
  }
}

class InvoicesNotifier extends StateNotifier<InvoicesState> {
  final Ref _ref;

  InvoicesNotifier(this._ref) : super(InvoicesState()) {
    fetchInvoices();
  }

  Future<void> fetchInvoices({bool refresh = false}) async {
    if (state.isLoading) return;

    if (refresh) {
      state = state.copyWith(page: 1, invoices: [], isLoading: true);
    } else {
      state = state.copyWith(isLoading: true);
    }

    try {
      final user = await _ref.read(authProvider.notifier).getCurrentUser();
      final clientId = user?.clientId;

      if (clientId == null) {
        state = state.copyWith(isLoading: false, error: 'No client associated with this account');
        return;
      }

      final service = _ref.read(invoiceServiceProvider);
      final PaginatedData<Invoice> result = await service.fetchInvoices(
        clientId: clientId,
        page: state.page,
        keyword: state.keyword,
      );

      state = state.copyWith(
        isLoading: false,
        invoices: refresh ? result.data : [...state.invoices, ...(result.data ?? [])],
        totalPages: result.pages,
        page: state.page + 1,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void setKeyword(String keyword) {
    state = state.copyWith(keyword: keyword);
    fetchInvoices(refresh: true);
  }

  Future<void> refresh() => fetchInvoices(refresh: true);
}

final invoicesProvider = StateNotifierProvider<InvoicesNotifier, InvoicesState>((ref) {
  return InvoicesNotifier(ref);
});

final invoiceMetricsProvider = Provider<Map<String, double>>((ref) {
  final invoices = ref.watch(invoicesProvider).invoices;
  double totalInvoiced = 0;
  double totalDue = 0;
  double totalPaid = 0;

  for (var inv in invoices) {
    totalInvoiced += inv.totalAmount;
    totalDue += inv.amountDue;
    totalPaid += inv.amountPaid;
  }

  return {
    'totalInvoiced': totalInvoiced,
    'totalDue': totalDue,
    'totalPaid': totalPaid,
  };
});

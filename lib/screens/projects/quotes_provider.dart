import 'package:bdoneapp/models/common/quote.dart';
import 'package:bdoneapp/models/common/paginated_data.dart';
import 'package:bdoneapp/providers/providers.dart';
import 'package:bdoneapp/screens/auth/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

class QuotesState {
  final bool isLoading;
  final List<Quote> quotes;
  final int page;
  final int totalPages;
  final String? error;
  final String keyword;

  QuotesState({
    this.isLoading = false,
    this.quotes = const [],
    this.page = 1,
    this.totalPages = 1,
    this.error,
    this.keyword = '',
  });

  QuotesState copyWith({
    bool? isLoading,
    List<Quote>? quotes,
    int? page,
    int? totalPages,
    String? error,
    String? keyword,
  }) {
    return QuotesState(
      isLoading: isLoading ?? this.isLoading,
      quotes: quotes ?? this.quotes,
      page: page ?? this.page,
      totalPages: totalPages ?? this.totalPages,
      error: error,
      keyword: keyword ?? this.keyword,
    );
  }
}

class QuotesNotifier extends StateNotifier<QuotesState> {
  final Ref _ref;

  QuotesNotifier(this._ref) : super(QuotesState()) {
    fetchQuotes();
  }

  Future<void> fetchQuotes({bool refresh = false}) async {
    if (state.isLoading) return;

    if (refresh) {
      state = state.copyWith(page: 1, quotes: [], isLoading: true);
    } else {
      state = state.copyWith(isLoading: true);
    }

    try {
      final user = await _ref.read(authProvider.notifier).getCurrentUser();
      final clientId = user?.clientId;
      final leadId = user?.leadId;

      final service = _ref.read(quoteServiceProvider);
      final PaginatedData<Quote> result = await service.fetchQuotes(
        clientId: clientId,
        leadId: leadId,
        page: state.page,
        keyword: state.keyword,
      );

      state = state.copyWith(
        isLoading: false,
        quotes: refresh ? result.data : [...state.quotes, ...(result.data ?? [])],
        totalPages: result.pages,
        page: state.page + 1,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void setKeyword(String keyword) {
    state = state.copyWith(keyword: keyword);
    fetchQuotes(refresh: true);
  }

  Future<void> refresh() => fetchQuotes(refresh: true);
}

final quotesProvider = StateNotifierProvider<QuotesNotifier, QuotesState>((ref) {
  return QuotesNotifier(ref);
});

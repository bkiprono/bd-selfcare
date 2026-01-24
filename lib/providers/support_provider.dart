import 'package:bdoneapp/models/common/paginated_data.dart';
import 'package:bdoneapp/models/common/support_request.dart';
import 'package:bdoneapp/providers/providers.dart';
import 'package:bdoneapp/providers/auth_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

class SupportState {
  final bool isLoading;
  final List<SupportRequest> supportRequests;
  final int page;
  final int totalPages;
  final String? error;
  final String keyword;

  SupportState({
    this.isLoading = false,
    this.supportRequests = const [],
    this.page = 1,
    this.totalPages = 1,
    this.error,
    this.keyword = '',
  });

  SupportState copyWith({
    bool? isLoading,
    List<SupportRequest>? supportRequests,
    int? page,
    int? totalPages,
    String? error,
    String? keyword,
  }) {
    return SupportState(
      isLoading: isLoading ?? this.isLoading,
      supportRequests: supportRequests ?? this.supportRequests,
      page: page ?? this.page,
      totalPages: totalPages ?? this.totalPages,
      error: error,
      keyword: keyword ?? this.keyword,
    );
  }
}

class SupportNotifier extends StateNotifier<SupportState> {
  final Ref _ref;

  SupportNotifier(this._ref) : super(SupportState()) {
    fetchSupportRequests();
  }

  Future<void> fetchSupportRequests({bool refresh = false}) async {
    if (state.isLoading) return;

    if (refresh) {
      state = state.copyWith(page: 1, supportRequests: [], isLoading: true);
    } else {
      state = state.copyWith(isLoading: true);
    }

    try {
      final user = await _ref.read(authProvider.notifier).getCurrentUser();
      final clientId = user?.clientId;

      // Ensure client ID is available 
      if (clientId == null) {
         state = state.copyWith(isLoading: false, error: 'Client ID not found');
         return;
      }

      final service = _ref.read(supportServiceProvider);
      final PaginatedData<SupportRequest> result = await service.fetchSupportRequests(
        clientId: clientId,
        page: state.page,
        keyword: state.keyword,
      );

      state = state.copyWith(
        isLoading: false,
        supportRequests: refresh ? result.data : [...state.supportRequests, ...(result.data ?? [])],
        totalPages: result.pages,
        page: state.page + 1,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void setKeyword(String keyword) {
    state = state.copyWith(keyword: keyword);
    fetchSupportRequests(refresh: true);
  }

  Future<void> refresh() => fetchSupportRequests(refresh: true);
}

final supportProvider = StateNotifierProvider<SupportNotifier, SupportState>((ref) {
  return SupportNotifier(ref);
});

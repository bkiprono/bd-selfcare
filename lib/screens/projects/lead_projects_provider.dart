import 'package:bdcomputing/models/common/lead_project.dart';
import 'package:bdcomputing/models/common/paginated_data.dart';
import 'package:bdcomputing/providers/providers.dart';
import 'package:bdcomputing/screens/auth/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

class LeadProjectsState {
  final bool isLoading;
  final List<LeadProject> leadProjects;
  final int page;
  final int totalPages;
  final String? error;
  final String keyword;

  LeadProjectsState({
    this.isLoading = false,
    this.leadProjects = const [],
    this.page = 1,
    this.totalPages = 1,
    this.error,
    this.keyword = '',
  });

  LeadProjectsState copyWith({
    bool? isLoading,
    List<LeadProject>? leadProjects,
    int? page,
    int? totalPages,
    String? error,
    String? keyword,
  }) {
    return LeadProjectsState(
      isLoading: isLoading ?? this.isLoading,
      leadProjects: leadProjects ?? this.leadProjects,
      page: page ?? this.page,
      totalPages: totalPages ?? this.totalPages,
      error: error,
      keyword: keyword ?? this.keyword,
    );
  }
}

class LeadProjectsNotifier extends StateNotifier<LeadProjectsState> {
  final Ref _ref;

  LeadProjectsNotifier(this._ref) : super(LeadProjectsState()) {
    fetchLeadProjects();
  }

  Future<void> fetchLeadProjects({bool refresh = false}) async {
    if (state.isLoading) return;

    if (refresh) {
      state = state.copyWith(page: 1, leadProjects: [], isLoading: true);
    } else {
      state = state.copyWith(isLoading: true);
    }

    try {
      final user = await _ref.read(authProvider.notifier).getCurrentUser();
      final clientId = user?.clientId;
      final leadId = user?.leadId;

      final service = _ref.read(leadProjectServiceProvider);
      final PaginatedData<LeadProject> result = await service.fetchLeadProjects(
        clientId: clientId,
        leadId: leadId,
        page: state.page,
        keyword: state.keyword,
      );

      state = state.copyWith(
        isLoading: false,
        leadProjects: refresh ? result.data : [...state.leadProjects, ...(result.data ?? [])],
        totalPages: result.pages,
        page: state.page + 1,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void setKeyword(String keyword) {
    state = state.copyWith(keyword: keyword);
    fetchLeadProjects(refresh: true);
  }

  Future<void> refresh() => fetchLeadProjects(refresh: true);
}

final leadProjectsProvider = StateNotifierProvider<LeadProjectsNotifier, LeadProjectsState>((ref) {
  return LeadProjectsNotifier(ref);
});

import 'package:bdoneapp/models/common/project.dart';
import 'package:bdoneapp/models/common/paginated_data.dart';
import 'package:bdoneapp/providers/providers.dart';
import 'package:bdoneapp/screens/auth/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

class ProjectsState {
  final bool isLoading;
  final List<Project> projects;
  final int page;
  final int totalPages;
  final String? error;
  final String keyword;

  ProjectsState({
    this.isLoading = false,
    this.projects = const [],
    this.page = 1,
    this.totalPages = 1,
    this.error,
    this.keyword = '',
  });

  ProjectsState copyWith({
    bool? isLoading,
    List<Project>? projects,
    int? page,
    int? totalPages,
    String? error,
    String? keyword,
  }) {
    return ProjectsState(
      isLoading: isLoading ?? this.isLoading,
      projects: projects ?? this.projects,
      page: page ?? this.page,
      totalPages: totalPages ?? this.totalPages,
      error: error,
      keyword: keyword ?? this.keyword,
    );
  }
}

class ProjectsNotifier extends StateNotifier<ProjectsState> {
  final Ref _ref;

  ProjectsNotifier(this._ref) : super(ProjectsState()) {
    fetchProjects();
  }

  Future<void> fetchProjects({bool refresh = false}) async {
    if (state.isLoading) return;

    if (refresh) {
      state = state.copyWith(page: 1, projects: [], isLoading: true);
    } else {
      state = state.copyWith(isLoading: true);
    }

    try {
      final user = await _ref.read(authProvider.notifier).getCurrentUser();
      final clientId = user?.clientId;

      final service = _ref.read(projectServiceProvider);
      final PaginatedData<Project> result = await service.fetchProjects(
        clientId: clientId,
        page: state.page,
        keyword: state.keyword,
      );

      state = state.copyWith(
        isLoading: false,
        projects: refresh ? result.data : [...state.projects, ...(result.data ?? [])],
        totalPages: result.pages,
        page: state.page + 1,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void setKeyword(String keyword) {
    state = state.copyWith(keyword: keyword);
    fetchProjects(refresh: true);
  }

  Future<void> refresh() => fetchProjects(refresh: true);
}

final projectsProvider = StateNotifierProvider<ProjectsNotifier, ProjectsState>((ref) {
  return ProjectsNotifier(ref);
});

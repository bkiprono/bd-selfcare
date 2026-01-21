import 'package:bdcomputing/services/fuel_service.dart';
import 'package:bdcomputing/providers/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bdcomputing/enums/orders_status_enum.dart';
import 'package:bdcomputing/models/fuel/fuel_order.dart';

class FuelOrdersState {
  final List<FuelOrder> orders;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final int currentPage;
  final int totalPages;
  final int totalOrders;
  final bool hasMore;
  final OrderStatusEnum? statusFilter;
  final String searchQuery;
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final List<String> recentSearches;
  final List<String> searchSuggestions;
  final bool isSearching;
  final Map<String, dynamic> appliedFilters;

  FuelOrdersState({
    this.orders = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.currentPage = 1,
    this.totalPages = 1,
    this.totalOrders = 0,
    this.hasMore = false,
    this.statusFilter,
    this.searchQuery = '',
    this.dateFrom,
    this.dateTo,
    this.recentSearches = const [],
    this.searchSuggestions = const [],
    this.isSearching = false,
    this.appliedFilters = const {},
  });

  FuelOrdersState copyWith({
    List<FuelOrder>? orders,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    int? currentPage,
    int? totalPages,
    int? totalOrders,
    bool? hasMore,
    OrderStatusEnum? statusFilter,
    bool clearStatusFilter = false,
    String? searchQuery,
    DateTime? dateFrom,
    DateTime? dateTo,
    bool clearDateRange = false,
    List<String>? recentSearches,
    List<String>? searchSuggestions,
    bool? isSearching,
    Map<String, dynamic>? appliedFilters,
  }) {
    return FuelOrdersState(
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalOrders: totalOrders ?? this.totalOrders,
      hasMore: hasMore ?? this.hasMore,
      statusFilter: clearStatusFilter
          ? null
          : (statusFilter ?? this.statusFilter),
      searchQuery: searchQuery ?? this.searchQuery,
      dateFrom: clearDateRange ? null : (dateFrom ?? this.dateFrom),
      dateTo: clearDateRange ? null : (dateTo ?? this.dateTo),
      recentSearches: recentSearches ?? this.recentSearches,
      searchSuggestions: searchSuggestions ?? this.searchSuggestions,
      isSearching: isSearching ?? this.isSearching,
      appliedFilters: appliedFilters ?? this.appliedFilters,
    );
  }
}

class FuelOrdersNotifier extends Notifier<FuelOrdersState> {
  FuelService get _service => ref.read(fuelServiceProvider);

  @override
  FuelOrdersState build() {
    return FuelOrdersState();
  }

  Future<void> fetchOrders({
    int page = 1,
    int limit = 10,
    OrderStatusEnum? status,
    String? searchQuery,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    if (page == 1) {
      state = state.copyWith(
        isLoading: true,
        error: null,
        isSearching: searchQuery?.isNotEmpty == true,
      );
    } else {
      state = state.copyWith(isLoadingMore: true);
    }

    try {
      Map<String, dynamic> response;

      // Determine if we need to use search API
      final hasFilters =
          (searchQuery?.isNotEmpty == true) ||
          status != null ||
          dateFrom != null ||
          dateTo != null;

      if (hasFilters) {
        // Use search API with filters
        response = await _service.searchFuelOrders(
          query: searchQuery?.isNotEmpty == true ? searchQuery : null,
          status: status,
          dateFrom: dateFrom?.toIso8601String().split('T')[0],
          dateTo: dateTo?.toIso8601String().split('T')[0],
          page: page,
          limit: limit,
        );
      } else {
        // Use regular API without filters
        response = await _service.getAllFuelOrders(
          page: page,
          limit: limit,
        );
      }

      final ordersResponse = FuelOrdersResponse.fromJson(response);

      final newOrders = page == 1
          ? ordersResponse.data
          : [...state.orders, ...ordersResponse.data];

      // Update recent searches if we have a search query
      List<String> updatedRecentSearches = List.from(state.recentSearches);
      if (searchQuery != null &&
          searchQuery.isNotEmpty &&
          !updatedRecentSearches.contains(searchQuery)) {
        updatedRecentSearches.insert(0, searchQuery);
        if (updatedRecentSearches.length > 5) {
          updatedRecentSearches = updatedRecentSearches.take(5).toList();
        }
      }

      // Update applied filters
      final Map<String, dynamic> newAppliedFilters = {};
      if (status != null) {
        newAppliedFilters['status'] = status.value;
      }
      if (searchQuery != null && searchQuery.isNotEmpty) {
        newAppliedFilters['search'] = searchQuery;
      }
      if (dateFrom != null) {
        newAppliedFilters['dateFrom'] = dateFrom.toIso8601String().split(
          'T',
        )[0];
      }
      if (dateTo != null) {
        newAppliedFilters['dateTo'] = dateTo.toIso8601String().split('T')[0];
      }

      state = state.copyWith(
        orders: newOrders,
        isLoading: false,
        isLoadingMore: false,
        isSearching: false,
        currentPage: ordersResponse.page,
        totalPages: ordersResponse.pages,
        totalOrders: ordersResponse.total,
        hasMore: ordersResponse.page < ordersResponse.pages,
        statusFilter: status,
        searchQuery: searchQuery ?? '',
        dateFrom: dateFrom,
        dateTo: dateTo,
        recentSearches: updatedRecentSearches,
        appliedFilters: newAppliedFilters,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        isSearching: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadMore() async {
    if (state.hasMore && !state.isLoadingMore) {
      await fetchOrders(
        page: state.currentPage + 1,
        status: state.statusFilter,
        searchQuery: state.searchQuery.isNotEmpty ? state.searchQuery : null,
        dateFrom: state.dateFrom,
        dateTo: state.dateTo,
      );
    }
  }

  Future<void> refresh() async {
    await fetchOrders(
      page: 1,
      status: state.statusFilter,
      searchQuery: state.searchQuery.isNotEmpty ? state.searchQuery : null,
      dateFrom: state.dateFrom,
      dateTo: state.dateTo,
    );
  }

  void setStatusFilter(OrderStatusEnum? status) {
    fetchOrders(
      page: 1,
      status: status,
      searchQuery: state.searchQuery.isNotEmpty ? state.searchQuery : null,
      dateFrom: state.dateFrom,
      dateTo: state.dateTo,
    );
  }

  void setSearchQuery(String query) {
    fetchOrders(
      page: 1,
      status: state.statusFilter,
      searchQuery: query.isNotEmpty ? query : null,
      dateFrom: state.dateFrom,
      dateTo: state.dateTo,
    );
  }

  void clearFilters() {
    state = state.copyWith(
      clearStatusFilter: true,
      searchQuery: '',
      clearDateRange: true,
      appliedFilters: {},
    );
    fetchOrders(page: 1);
  }

  void setDateRange(DateTime? from, DateTime? to) {
    fetchOrders(
      page: 1,
      status: state.statusFilter,
      searchQuery: state.searchQuery.isNotEmpty ? state.searchQuery : null,
      dateFrom: from,
      dateTo: to,
    );
  }

  void setSearchSuggestions(List<String> suggestions) {
    state = state.copyWith(searchSuggestions: suggestions);
  }

  void addToRecentSearches(String query) {
    if (query.isEmpty) return;

    List<String> updatedRecentSearches = List.from(state.recentSearches);
    updatedRecentSearches.remove(query);
    updatedRecentSearches.insert(0, query);
    if (updatedRecentSearches.length > 5) {
      updatedRecentSearches = updatedRecentSearches.take(5).toList();
    }

    state = state.copyWith(recentSearches: updatedRecentSearches);
  }

  void clearRecentSearches() {
    state = state.copyWith(recentSearches: []);
  }

  void applyQuickFilter(String filterType, dynamic value) {
    DateTime? from;
    DateTime? to;

    switch (filterType) {
      case 'today':
        final today = DateTime.now();
        from = DateTime(today.year, today.month, today.day);
        to = DateTime(today.year, today.month, today.day, 23, 59, 59);
        break;
      case 'thisWeek':
        final now = DateTime.now();
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        from = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
        to = DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;
      case 'thisMonth':
        final now = DateTime.now();
        from = DateTime(now.year, now.month, 1);
        to = DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;
    }

    if (from != null && to != null) {
      setDateRange(from, to);
    }
  }
}

final fuelOrdersProvider =
    NotifierProvider<FuelOrdersNotifier, FuelOrdersState>(() {
      return FuelOrdersNotifier();
    });

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:bdcomputing/models/common/paginated_data.dart';
import 'package:bdcomputing/models/fuel/fuel_price.dart';
import 'package:bdcomputing/providers/providers.dart';
import 'package:bdcomputing/components/logger_config.dart';

class RetailFuelPricesState {
  final bool isLoading;
  final List<FuelPrice> fuelPrices;
  final String? error;
  final bool isFiltering;
  final int currentPage;
  final int limit;
  final int total;
  final int pages;
  final String keyword;

  const RetailFuelPricesState({
    this.isLoading = false,
    this.fuelPrices = const [],
    this.error,
    this.isFiltering = false,
    this.currentPage = 1,
    this.limit = 10,
    this.total = 0,
    this.pages = 0,
    this.keyword = '',
  });

  RetailFuelPricesState copyWith({
    bool? isLoading,
    List<FuelPrice>? fuelPrices,
    String? error,
    bool? isFiltering,
    int? currentPage,
    int? limit,
    int? total,
    int? pages,
    String? keyword,
  }) {
    return RetailFuelPricesState(
      isLoading: isLoading ?? this.isLoading,
      fuelPrices: fuelPrices ?? this.fuelPrices,
      error: error,
      isFiltering: isFiltering ?? this.isFiltering,
      currentPage: currentPage ?? this.currentPage,
      limit: limit ?? this.limit,
      total: total ?? this.total,
      pages: pages ?? this.pages,
      keyword: keyword ?? this.keyword,
    );
  }
}

class RetailFuelPricesController extends StateNotifier<RetailFuelPricesState> {
  final Ref _ref;

  RetailFuelPricesController(this._ref) : super(const RetailFuelPricesState());

  Future<void> fetchFuelPrices({bool refresh = false}) async {
    if (state.isLoading && !refresh) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final fuelService = _ref.read(fuelServiceProvider);
      final PaginatedData<FuelPrice> paginatedData  = await fuelService.getFuelPrice(
        limit: state.limit,
        page: state.currentPage,
        keyword: state.keyword,
      );
      
      state = state.copyWith(
        isLoading: false,
        fuelPrices: paginatedData.data,
        total: paginatedData.total,
        pages: paginatedData.pages,
        currentPage: paginatedData.page,
        limit: paginatedData.limit,
        error: null,
      );
    } catch (e, stack) {
      logger.e('Failed to fetch fuel prices', error: e, stackTrace: stack);
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void setKeyword(String keyword) {
    if (state.keyword == keyword) return;
    state = state.copyWith(keyword: keyword, currentPage: 1);
    fetchFuelPrices(refresh: true);
  }

  void setPage(int page) {
    if (state.currentPage == page) return;
    state = state.copyWith(currentPage: page);
    fetchFuelPrices(refresh: true);
  }

  void nextPage() {
    if (state.currentPage < state.pages) {
      setPage(state.currentPage + 1);
    }
  }

  void prevPage() {
    if (state.currentPage > 1) {
      setPage(state.currentPage - 1);
    }
  }

  void setLimit(int limit) {
    if (state.limit == limit) return;
    state = state.copyWith(limit: limit, currentPage: 1);
    fetchFuelPrices(refresh: true);
  }

  Future<void> filterFuelPrices({
    String? status,
    String? query,
  }) async {
    // Placeholder for future filtering logic
    fetchFuelPrices(refresh: true);
  }
}

final retailFuelPricesProvider =
    StateNotifierProvider<RetailFuelPricesController, RetailFuelPricesState>((ref) {
  return RetailFuelPricesController(ref);
});

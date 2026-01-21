import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:bdcomputing/screens/auth/providers.dart';
import 'package:bdcomputing/core/utils/api_client.dart';
import 'package:bdcomputing/enums/orders_status_enum.dart';
import 'package:bdcomputing/models/orders/order.dart';
import 'package:bdcomputing/repositories/orders_repository.dart';
import 'package:bdcomputing/core/endpoints.dart';

// Base URL for orders API (can be reused across modules)
final ordersBaseUrlProvider = Provider<String>(
  (ref) => ApiEndpoints.baseUrl,
);

// Repository provider
final ordersRepositoryProvider = Provider<OrdersRepository>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);

  // ApiClient inherits token handling from authRepo
  final apiClient = ApiClient(
    baseUrl: ref.watch(ordersBaseUrlProvider),
    getAccessToken: () => authRepo.getAccessToken(),
    onRefreshToken: () => authRepo.refreshToken(),
  );

  return OrdersRepository(client: apiClient);
});

// Orders state class
class OrdersState {
  final List<Order> orders;
  final bool isLoading;
  final bool isRefreshing;
  final bool isLoadingMore;
  final String? error;
  final int currentPage;
  final int totalPages;
  final bool hasMore;

  const OrdersState({
    this.orders = const [],
    this.isLoading = false,
    this.isRefreshing = false,
    this.isLoadingMore = false,
    this.error,
    this.currentPage = 1,
    this.totalPages = 1,
    this.hasMore = true,
  });

  OrdersState copyWith({
    List<Order>? orders,
    bool? isLoading,
    bool? isRefreshing,
    bool? isLoadingMore,
    String? error,
    int? currentPage,
    int? totalPages,
    bool? hasMore,
  }) {
    return OrdersState(
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

// Orders notifier
class OrdersNotifier extends StateNotifier<OrdersState> {
  final OrdersRepository _repository;

  OrdersNotifier(this._repository) : super(const OrdersState());

  Future<void> fetchOrders({int page = 1, bool isRefresh = false}) async {
    try {
      if (isRefresh) {
        state = state.copyWith(isRefreshing: true, error: null);
      } else if (page == 1) {
        state = state.copyWith(isLoading: true, error: null);
      } else {
        state = state.copyWith(isLoadingMore: true, error: null);
      }

      final ordersResponse = await _repository.getOrders(page: page, limit: 10);

      List<Order> updatedOrders;
      if (isRefresh || page == 1) {
        updatedOrders = ordersResponse.data;
      } else {
        updatedOrders = [...state.orders, ...ordersResponse.data];
      }

      state = state.copyWith(
        orders: updatedOrders,
        isLoading: false,
        isRefreshing: false,
        isLoadingMore: false,
        currentPage: ordersResponse.page,
        totalPages: ordersResponse.pages,
        hasMore: ordersResponse.page < ordersResponse.pages,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isRefreshing: false,
        isLoadingMore: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadMore() async {
    if (state.hasMore && !state.isLoadingMore) {
      await fetchOrders(page: state.currentPage + 1);
    }
  }

  Future<void> refresh() async {
    await fetchOrders(page: 1, isRefresh: true);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  Future<void> fetchOrderById(String orderId) async {
    try {
      final order = await _repository.getOrderById(orderId);

      // Update the order in the list if it exists
      final updatedOrders = state.orders.map((o) {
        return o.id == order.id ? order : o;
      }).toList();

      // If order doesn't exist in the list, add it
      if (!state.orders.any((o) => o.id == order.id)) {
        updatedOrders.insert(0, order);
      }

      state = state.copyWith(orders: updatedOrders);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<Map<String, dynamic>> createOrder(Map<String, dynamic> payload) async {
    try {
      final result = await _repository.createProductOrder(payload);
      // Optionally refresh orders after creating a new one
      await refresh();
      return result;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<OrdersResponse> searchOrders({
    String? query,
    OrderStatusEnum? status,
    String? dateFrom,
    String? dateTo,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      return await _repository.searchOrders(
        query: query,
        status: status,
        dateFrom: dateFrom,
        dateTo: dateTo,
        page: page,
        limit: limit,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }
}

// Provider for the orders state
final ordersProvider = StateNotifierProvider<OrdersNotifier, OrdersState>((
  ref,
) {
  final repository = ref.watch(ordersRepositoryProvider);
  return OrdersNotifier(repository);
});

// Convenience providers for specific parts of the state
final ordersListProvider = Provider<List<Order>>((ref) {
  return ref.watch(ordersProvider).orders;
});

final ordersLoadingProvider = Provider<bool>((ref) {
  return ref.watch(ordersProvider).isLoading;
});

final ordersErrorProvider = Provider<String?>((ref) {
  return ref.watch(ordersProvider).error;
});

final ordersHasMoreProvider = Provider<bool>((ref) {
  return ref.watch(ordersProvider).hasMore;
});

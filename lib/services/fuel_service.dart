import 'package:bdcomputing/enums/orders_status_enum.dart';
import 'package:bdcomputing/models/common/paginated_data.dart';
import 'package:bdcomputing/models/fuel/create_retail_fuel_price.dart';
import 'package:bdcomputing/models/fuel/update_retail_fuel_price.dart';
import 'package:bdcomputing/models/fuel/fuel_product.dart';
import 'package:bdcomputing/models/fuel/fuel_price.dart';
import 'package:bdcomputing/core/endpoints.dart';
import 'package:bdcomputing/components/logger_config.dart';
import 'package:bdcomputing/core/utils/api_client.dart';
import 'package:bdcomputing/core/utils/api_exception.dart';
import 'package:dio/dio.dart';

class FuelService {
  final ApiClient _apiClient;

  FuelService({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Get all fuel products with nested types
  Future<List<FuelProduct>> getFuelProducts() async {
    try {
      // Using fuelProducts endpoint which should return the structure with nested types
      final res = await _apiClient.get(ApiEndpoints.fuelProducts);

      final responseData = res.data;
      // Handle the paginated response structure: { "data": { "data": [...] } }
      final dataList = responseData['data']['data'] as List;

      return dataList.map((item) => FuelProduct.fromJson(item)).toList();
    } catch (error, stackTrace) {
      logger.e(
        'Error fetching fuel products',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Get fuel prices/options by vendor and fuel product type
  Future<PaginatedData<FuelPrice>> getFuelPrice({
    String? fuelProductId,
    String? fuelProductTypeId,
    int? page,
    int? limit,
    String? keyword,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (limit != null) queryParams['limit'] = limit;
      if (page != null) queryParams['page'] = page;
      if (keyword != null && keyword.isNotEmpty) {
        queryParams['keyword'] = keyword;
      }
      if (fuelProductId != null) queryParams['fuelProductId'] = fuelProductId;
      if (fuelProductTypeId != null) {
        queryParams['fuelProductTypeId'] = fuelProductTypeId;
      }

      final res = await _apiClient.get(
        ApiEndpoints.retailFuelPrices,
        queryParameters: queryParams,
      );

      final rootData = res.data['data'];
      
      if (rootData is Map<String, dynamic>) {
        return PaginatedData<FuelPrice>.fromJson(
          rootData,
          (item) => FuelPrice.fromJson(item as Map<String, dynamic>),
        );
      } else if (rootData is List) {
        // Fallback for non-paginated list from API
        return PaginatedData<FuelPrice>(
          data: rootData
              .whereType<Map<String, dynamic>>()
              .map(FuelPrice.fromJson)
              .toList(),
          total: rootData.length,
          pages: 1,
          limit: rootData.length,
          page: 1,
        );
      }
      
      // If data is null or unknown structure, return empty
      return PaginatedData<FuelPrice>(
        data: [],
        total: 0,
        pages: 1,
        limit: 10,
        page: 1,
      );
    } catch (error, stackTrace) {
      logger.e(
        'Error fetching fuel options',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Create a new retail fuel price
  Future<Map<String, dynamic>> createRetailFuelPrice({
    required CreateRetailFuelPrice payload,
  }) async {
    try {
      final res = await _apiClient.post(
        ApiEndpoints.retailFuelPrices,
        data: payload.toJson(),
      );

      final responseData = res.data;
      return {
        'statusCode': res.statusCode,
        'message': responseData['message'] ?? 'Success',
        'data': responseData['data'],
      };
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  /// Update an existing retail fuel price
  Future<Map<String, dynamic>> updateRetailFuelPrice({
    required String id,
    required UpdateRetailFuelPrice payload,
  }) async {
    try {
      final res = await _apiClient.patch(
        '${ApiEndpoints.retailFuelPrices}/$id',
        data: payload.toJson(),
      );

      final responseData = res.data;
      return {
        'statusCode': res.statusCode,
        'message': responseData['message'] ?? 'Success',
        'data': responseData['data'],
      };
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  /// Update supply status (active/inactive) for a retail fuel price
  Future<Map<String, dynamic>> updateRetailFuelPriceSupplyStatus({
    required String id,
    required bool active,
  }) async {
    try {
      final res = await _apiClient.patch(
        '${ApiEndpoints.retailFuelPrices}/$id',
        data: {'supplyActive': active},
      );

      final responseData = res.data;
      return {
        'statusCode': res.statusCode,
        'message': responseData['message'] ?? 'Success',
        'data': responseData['data'],
      };
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  /// Get all fuel orders (paginated)
  Future<Map<String, dynamic>> getAllFuelOrders({
    required int page,
    required int limit,
  }) async {
    try {
      final res = await _apiClient.get(
        ApiEndpoints.orders,
        queryParameters: {'page': page.toString(), 'limit': limit.toString()},
      );
      return res.data;
    } catch (error, stackTrace) {
      logger.e(
        'Error fetching fuel orders',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Get a single fuel order by ID
  Future<Map<String, dynamic>> getFuelOrderById(String orderId) async {
    try {
      final res = await _apiClient.get('${ApiEndpoints.orders}/$orderId');
      return {
        'statusCode': res.statusCode,
        'message': res.data['message'] ?? 'Success',
        'data': res.data['data'],
      };
    } catch (error, stackTrace) {
      logger.e(
        'Error fetching fuel order by ID',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Search fuel orders by various criteria
  Future<Map<String, dynamic>> searchFuelOrders({
    String? query,
    OrderStatusEnum? status,
    String? dateFrom,
    String? dateTo,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (query != null && query.isNotEmpty) queryParams['search'] = query;
      if (status != null) queryParams['status'] = status.value;
      if (dateFrom != null) queryParams['dateFrom'] = dateFrom;
      if (dateTo != null) queryParams['dateTo'] = dateTo;

      final res = await _apiClient.get(
        ApiEndpoints.orders,
        queryParameters: queryParams,
      );
      return res.data;
    } catch (error, stackTrace) {
      logger.e(
        'Error searching fuel orders',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Cancel a fuel order
  Future<Map<String, dynamic>> cancelFuelOrder(String orderId) async {
    try {
      final res = await _apiClient.post(
        '${ApiEndpoints.orders}/$orderId/cancel',
      );
      return res.data;
    } catch (error, stackTrace) {
      logger.e(
        'Error canceling fuel order',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Get all fuel prices (backward compatibility)
  Future<List<dynamic>> getAllFuelPrices({
    required int page,
    required int limit,
    String? keyword,
  }) async {
    try {
      final res = await _apiClient.get(
        ApiEndpoints.retailFuelPrices,
        queryParameters: {
          'page': page.toString(),
          'limit': limit.toString(),
          if (keyword != null) 'keyword': keyword,
        },
      );
      final data = res.data['data'];
      if (data is List) return data;
      return [];
    } catch (error, stackTrace) {
      logger.e(
        'Error fetching all fuel options',
        error: error,
        stackTrace: stackTrace,
      );
      return [];
    }
  }
}

/// Exception class for fuel service errors
class FuelServiceException implements Exception {
  final String message;
  final int? statusCode;

  FuelServiceException(this.message, [this.statusCode]);

  @override
  String toString() {
    if (statusCode != null) {
      return 'FuelServiceException: $message (Status Code: $statusCode)';
    }
    return 'FuelServiceException: $message';
  }
}

import 'package:bdcomputing/core/endpoints.dart';
import 'package:bdcomputing/models/common/vendor.dart';
import 'package:bdcomputing/core/utils/api_client.dart';
import 'package:bdcomputing/core/utils/api_exception.dart';
import 'package:dio/dio.dart';

class VendorService {
  final ApiClient _apiClient;

  VendorService({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Fetch vendor by ID
  Future<Vendor?> getVendorById(String vendorId) async {
    try {
      final res = await _apiClient.get('${ApiEndpoints.vendors}/$vendorId');
      
      final root = res.data as Map<String, dynamic>;
      final data = root['data'] ?? root;
      
      if (data is Map<String, dynamic>) {
        return Vendor.fromJson(data);
      }
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null;
      }
      throw ApiException.fromDioException(e);
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }

  /// Get current user's vendor data (fetches using vendorId from user)
  Future<Vendor?> getMyVendor() async {
    try {
      // This endpoint might return the vendor data for the authenticated user
      final res = await _apiClient.get('${ApiEndpoints.vendors}/me');
      
      final root = res.data as Map<String, dynamic>;
      final data = root['data'] ?? root;
      
      if (data is Map<String, dynamic>) {
        return Vendor.fromJson(data);
      }
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null;
      }
      throw ApiException.fromDioException(e);
    } catch (e) {
      throw ApiException(message: e.toString());
    }
  }
}

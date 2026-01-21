import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bdcomputing/models/common/country.dart';
import 'package:bdcomputing/core/utils/api_client.dart';
import 'package:bdcomputing/providers/providers.dart';

class CountryService {
  final ApiClient _client;

  CountryService(this._client);

  Future<List<Country>> fetchCountries() async {
    // Attempt to fetch all countries across pages if the API is paginated.
    // We will iterate pages until a page returns fewer than 'limit' items.
    const int limit = 200;
    int page = 1;
    final List<Country> all = [];

    while (true) {
      final response = await _client.get('/countries?page=$page&limit=$limit');

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        final data = response.data;

        List<dynamic> countryList;
        if (data is Map<String, dynamic>) {
          if (data['data'] is List) {
            countryList = data['data'] as List;
          } else if (data['data'] is Map && data['data']['data'] is List) {
            countryList = data['data']['data'] as List;
          } else {
            countryList = [];
          }
        } else if (data is List) {
          countryList = data;
        } else {
          countryList = [];
        }

        final parsed = countryList
            .whereType<Map<String, dynamic>>()
            .map((json) => Country.fromJson(json))
            .toList();
        all.addAll(parsed);

        if (parsed.length < limit) {
          break; // last page
        }
        page += 1;
      } else {
        throw Exception('Failed to fetch countries: ${response.statusCode}');
      }
    }

    return all;
  }
}

// Repository for countries
class CountryRepository {
  final CountryService _service;

  CountryRepository({required ApiClient client})
    : _service = CountryService(client);

  Future<List<Country>> getAllCountries() async {
    return await _service.fetchCountries();
  }
}

// Provider for CountryRepository
final countryRepositoryProvider = Provider<CountryRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return CountryRepository(client: client);
});

// Provider for fetching countries
final countriesProvider = FutureProvider<List<Country>>((ref) async {
  final repository = ref.watch(countryRepositoryProvider);
  return await repository.getAllCountries();
});

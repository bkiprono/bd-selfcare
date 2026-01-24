import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:bdoneapp/core/endpoints.dart';
import 'package:bdoneapp/models/common/currency.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';
import 'package:bdoneapp/core/utils/api_client.dart';

class CurrencyService extends ChangeNotifier {
  static const _currencyKey = 'currencyId';
  static const _cacheKey = 'currencies_cache';
  static const _cacheTimeKey = 'currencies_cache_time';
  static const _cacheDuration = Duration(minutes: 1);
  final _logger = Logger();
  final ApiClient _apiClient;

  Currency? _currency;
  List<Currency> _currencies = [];

  Currency? get currency => _currency;
  List<Currency> get currencies => _currencies;

  CurrencyService({required ApiClient apiClient}) : _apiClient = apiClient;

  static Duration get cacheDuration => _cacheDuration;

  Future<void> loadSavedCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    final savedId = prefs.getString(_currencyKey);

    final currencies = await fetchAllCurrencies();

    if (currencies.isEmpty) {
      _currency = null;
      notifyListeners();
      return;
    }

    if (savedId != null) {
      final match = currencies.firstWhere(
        (c) => c.id == savedId,
        orElse: () => currencies.first,
      );
      _currency = match;
    } else {
      _currency = currencies.first;
      await prefs.setString(_currencyKey, _currency!.id);
      _logger.i('Set default currency: ${_currency!.code} (${_currency!.id})');
    }
    notifyListeners();
  }

  Future<void> setCurrency(Currency currency) async {
    _currency = currency;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currencyKey, currency.id);
    notifyListeners();
  }

  Future<List<Currency>> fetchAllCurrencies() async {
    final prefs = await SharedPreferences.getInstance();

    final cacheTimeStr = prefs.getString(_cacheTimeKey);
    if (cacheTimeStr != null) {
      final cacheTime = DateTime.tryParse(cacheTimeStr);
      if (cacheTime != null &&
          DateTime.now().difference(cacheTime) < _cacheDuration) {
        final cachedData = prefs.getString(_cacheKey);
        if (cachedData != null) {
          try {
            final List<dynamic> jsonList = json.decode(cachedData);
            _currencies = jsonList.map((e) => Currency.fromJson(e)).toList();
            return _currencies;
          } catch (e) {
            _logger.i('Cached currency data corrupted, fetching fresh data');
          }
        }
      }
    }

    return await _fetchWithRetry();
  }

  Future<List<Currency>> _fetchWithRetry({int maxRetries = 3}) async {
    final prefs = await SharedPreferences.getInstance();

    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        final response = await _apiClient.get(ApiEndpoints.currencies);

        if (response.statusCode == 200) {
          final data = response.data;

          List<Currency> result;
          if (data is Map && data['data'] is List) {
            result = (data['data'] as List)
                .map((json) => Currency.fromJson(json))
                .toList();
          } else if (data is Map &&
              data['data'] is Map &&
              data['data']['data'] is List) {
            result = (data['data']['data'] as List)
                .map((json) => Currency.fromJson(json))
                .toList();
          } else if (data is List) {
            result = data
                .map<Currency>((json) => Currency.fromJson(json))
                .toList();
          } else {
            throw Exception('Unexpected API response structure');
          }

          await prefs.setString(
            _cacheKey,
            json.encode(result.map((c) => c.toJson()).toList()),
          );
          await prefs.setString(
            _cacheTimeKey,
            DateTime.now().toIso8601String(),
          );

          _currencies = result;
          return result;
        } else if (response.statusCode == 429) {
          final waitTime = Duration(seconds: attempt * 2);
          _logger.i(
            'Rate limited (429), waiting ${waitTime.inSeconds}s before retry $attempt/$maxRetries',
          );
          await Future.delayed(waitTime);
          continue;
        } else {
          throw Exception(
            'Failed to load currencies: ${response.statusCode} - ${response.data}',
          );
        }
      } catch (e) {
        if (attempt == maxRetries) {
          final cachedData = prefs.getString(_cacheKey);
          if (cachedData != null) {
            try {
              final List<dynamic> jsonList = json.decode(cachedData);
              final cachedCurrencies = jsonList
                  .map((e) => Currency.fromJson(e))
                  .toList();
              _logger.i(
                'Using expired cached currency data due to API failure',
              );
              return cachedCurrencies;
            } catch (cacheError) {
              _logger.i('Failed to use cached data: $cacheError');
            }
          }
          rethrow;
        }

        final waitTime = Duration(seconds: attempt);
        _logger.i(
          'API call failed (attempt $attempt/$maxRetries): $e, retrying in ${waitTime.inSeconds}s',
        );
        await Future.delayed(waitTime);
      }
    }

    throw Exception('Failed to fetch currencies after $maxRetries attempts');
  }

  Future<Currency?> fetchCurrencyByCode(String code) async {
    final currencies = await fetchAllCurrencies();
    try {
      return currencies.firstWhere(
        (c) => c.code.toLowerCase() == code.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }

  Currency? getCurrencyByCode(String code) {
    try {
      return _currencies.firstWhere(
        (c) => c.code.toLowerCase() == code.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }

  Currency? getCurrencyById(String id) {
    try {
      return _currencies.firstWhere(
        (c) => c.id.toLowerCase() == id.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }

  double convertAmount(double amount, {String? currencyId}) {
    if (_currency == null) return amount;

    if (currencyId == null ||
        currencyId.toLowerCase() == _currency?.id.toLowerCase()) {
      return amount;
    }

    final fromCurrency = getCurrencyByCode(currencyId);
    if (fromCurrency == null) return amount;

    if (fromCurrency.rateAgainstBaseCurrency == 0) return amount;
    final amountInBase = amount / fromCurrency.rateAgainstBaseCurrency;
    final converted =
        amountInBase * (_currency?.rateAgainstBaseCurrency ?? 1.0);
    return converted;
  }
}

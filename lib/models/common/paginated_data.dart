class Periods {
  final int year;
  final List<MonthValue> months;

  Periods({
    required this.year,
    required this.months,
  });

  factory Periods.fromJson(Map<String, dynamic> json) {
    return Periods(
      year: json['year'] as int,
      months: (json['months'] as List)
          .map((e) => MonthValue.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class MonthValue {
  final String month;
  final int value;

  MonthValue({
    required this.month,
    required this.value,
  });

  factory MonthValue.fromJson(Map<String, dynamic> json) {
    return MonthValue(
      month: json['month'] as String,
      value: json['value'] as int,
    );
  }
}

class PaginatedData<T> {
  final int page;
  final int limit;
  final int total;
  final int pages;
  final List<T>? data;
  final List<Periods>? monthsFilters;

  PaginatedData({
    required this.page,
    required this.limit,
    required this.total,
    required this.pages,
    this.data,
    this.monthsFilters,
  });

  factory PaginatedData.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromDataJson,
  ) {
    return PaginatedData<T>(
      page: json['page'] is int
          ? json['page'] as int
          : int.tryParse(json['page']?.toString() ?? '1') ?? 1,
      limit: json['limit'] is int
          ? json['limit'] as int
          : int.tryParse(json['limit']?.toString() ?? '10') ?? 10,
      total: json['total'] is int
          ? json['total'] as int
          : int.tryParse(json['total']?.toString() ?? '0') ?? 0,
      pages: json['pages'] is int
          ? json['pages'] as int
          : int.tryParse(json['pages']?.toString() ?? '1') ?? 1,
      data: json['data'] is List
          ? (json['data'] as List).map(fromDataJson).toList()
          : [],
      monthsFilters: json['filters'] != null &&
              json['filters']['months'] != null
          ? (json['filters']['months'] as List)
              .map((e) => Periods.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bdcomputing/enums/orders_status_enum.dart';
import 'package:bdcomputing/models/fuel/fuel_order.dart';
import 'package:bdcomputing/providers/fuel_orders_provider.dart';
import 'package:bdcomputing/components/shared/header.dart';
import 'package:intl/intl.dart';

class MyFuelOrdersScreen extends ConsumerStatefulWidget {
  const MyFuelOrdersScreen({super.key});

  @override
  ConsumerState<MyFuelOrdersScreen> createState() => _MyFuelOrdersScreenState();
}

class _MyFuelOrdersScreenState extends ConsumerState<MyFuelOrdersScreen>
    with TickerProviderStateMixin {
  OrderStatusEnum? _activeStatusFilter;
  String _searchQuery = '';
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  bool _showFilters = false;
  bool _showSearchSuggestions = false;
  bool _showAdvancedFilters = false;
  DateTime? _selectedDateFrom;
  DateTime? _selectedDateTo;
  late AnimationController _filterAnimationController;
  late AnimationController _searchAnimationController;
  late Animation<double> _filterAnimation;
  late Animation<double> _searchAnimation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(fuelOrdersProvider.notifier).fetchOrders();
    });

    _scrollController.addListener(_onScroll);

    // Initialize animation controllers
    _filterAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _searchAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _filterAnimation = CurvedAnimation(
      parent: _filterAnimationController,
      curve: Curves.easeInOut,
    );
    _searchAnimation = CurvedAnimation(
      parent: _searchAnimationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _filterAnimationController.dispose();
    _searchAnimationController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final ordersState = ref.read(fuelOrdersProvider);
      if (ordersState.hasMore && !ordersState.isLoading) {
        ref.read(fuelOrdersProvider.notifier).loadMore();
      }
    }
  }

  Color _getStatusColor(OrderStatusEnum status) {
    switch (status) {
      case OrderStatusEnum.completed:
        return const Color(0xFF10B981);
      case OrderStatusEnum.pending:
        return const Color(0xFFF59E0B);
      case OrderStatusEnum.cancelled:
        return const Color(0xFFEF4444);
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  void _handleOrderPress(String orderId) {
    Navigator.pushNamed(
      context,
      '/fuel-order-details',
      arguments: {'orderId': orderId},
    );
  }

  void _applyFilters() {
    ref.read(fuelOrdersProvider.notifier).setStatusFilter(_activeStatusFilter);
    setState(() {
      _showFilters = false;
    });
    _filterAnimationController.reverse();
  }

  void _clearFilters() {
    setState(() {
      _activeStatusFilter = null;
      _searchQuery = '';
      _searchController.clear();
      _selectedDateFrom = null;
      _selectedDateTo = null;
      _showFilters = false;
      _showAdvancedFilters = false;
    });
    ref.read(fuelOrdersProvider.notifier).clearFilters();
    _filterAnimationController.reverse();
  }

  void _toggleFilters() {
    setState(() {
      _showFilters = !_showFilters;
    });

    if (_showFilters) {
      _filterAnimationController.forward();
    } else {
      _filterAnimationController.reverse();
    }
  }

  void _toggleAdvancedFilters() {
    setState(() {
      _showAdvancedFilters = !_showAdvancedFilters;
    });
  }

  void _handleSearchChange(String value) {
    setState(() {
      _searchQuery = value;
      _showSearchSuggestions = value.isNotEmpty;
    });

    // Debounced search
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_searchQuery == value) {
        ref.read(fuelOrdersProvider.notifier).setSearchQuery(value);
        if (value.isNotEmpty) {
          ref.read(fuelOrdersProvider.notifier).addToRecentSearches(value);
        }
      }
    });
  }

  void _selectSearchSuggestion(String suggestion) {
    _searchController.text = suggestion;
    setState(() {
      _searchQuery = suggestion;
      _showSearchSuggestions = false;
    });
    ref.read(fuelOrdersProvider.notifier).setSearchQuery(suggestion);
    ref.read(fuelOrdersProvider.notifier).addToRecentSearches(suggestion);
  }

  void _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateFrom != null && _selectedDateTo != null
          ? DateTimeRange(start: _selectedDateFrom!, end: _selectedDateTo!)
          : null,
    );

    if (picked != null) {
      setState(() {
        _selectedDateFrom = picked.start;
        _selectedDateTo = picked.end;
      });
      ref
          .read(fuelOrdersProvider.notifier)
          .setDateRange(picked.start, picked.end);
    }
  }

  void _applyQuickFilter(String filterType) {
    ref.read(fuelOrdersProvider.notifier).applyQuickFilter(filterType, null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const Header(title: 'Fuel Orders'),
      body: Column(
        children: [
          _buildSearchBar(),
          if (_showFilters) _buildFilterSection(),
          _buildActiveFiltersChips(),
          if (ref.watch(fuelOrdersProvider).isSearching)
            _buildSearchLoadingState(),
          Expanded(
            child: Consumer(
              builder: (context, ref, child) {
                final ordersState = ref.watch(fuelOrdersProvider);

                if (ordersState.isLoading && ordersState.currentPage == 1) {
                  return _buildLoadingState();
                }

                if (ordersState.error != null && ordersState.orders.isEmpty) {
                  return _buildErrorState(ordersState.error!);
                }

                if (ordersState.orders.isEmpty) {
                  return _buildEmptyState();
                }

                return RefreshIndicator(
                  onRefresh: () =>
                      ref.read(fuelOrdersProvider.notifier).refresh(),
                  color: const Color(0xFF10B981),
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount:
                        ordersState.orders.length +
                        (ordersState.isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == ordersState.orders.length) {
                        return _buildLoadingMoreIndicator();
                      }
                      return _buildOrderCard(ordersState.orders[index]);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Consumer(
      builder: (context, ref, child) {
        final ordersState = ref.watch(fuelOrdersProvider);

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Colors.grey[100]!)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: _showSearchSuggestions
                              ? const Color(0xFF10B981)
                              : Colors.grey[300]!,
                          width: _showSearchSuggestions ? 2 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha((0.03 * 255).round()),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 16, right: 8),
                            child: Icon(
                              Icons.search,
                              color: Color(0xFF10B981),
                              size: 20,
                            ),
                          ),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              onChanged: _handleSearchChange,
                              onTap: () {
                                setState(() {
                                  _showSearchSuggestions =
                                      _searchQuery.isNotEmpty;
                                });
                              },
                              decoration: InputDecoration(
                                hintText:
                                    'Search orders, vendors, or order IDs...',
                                border: InputBorder.none,
                                hintStyle: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 14,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),
                          if (_searchQuery.isNotEmpty)
                            IconButton(
                              onPressed: () {
                                _searchController.clear();
                                _handleSearchChange('');
                                setState(() {
                                  _showSearchSuggestions = false;
                                });
                              },
                              icon: const Icon(
                                Icons.clear,
                                size: 18,
                                color: Colors.grey,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildFilterButton(ordersState),
                ],
              ),
              if (_showSearchSuggestions) _buildSearchSuggestions(ordersState),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterButton(ordersState) {
    return Container(
      decoration: BoxDecoration(
        color: ordersState.appliedFilters.isNotEmpty
            ? const Color(0xFF10B981).withValues(alpha: 0.1)
            : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ordersState.appliedFilters.isNotEmpty
              ? const Color(0xFF10B981)
              : Colors.grey[300]!,
        ),
      ),
      child: IconButton(
        onPressed: _toggleFilters,
        icon: Icon(
          _showFilters ? Icons.filter_list_off : Icons.tune,
          color: ordersState.appliedFilters.isNotEmpty
              ? const Color(0xFF10B981)
              : Colors.grey[600],
          size: 20,
        ),
        tooltip: 'Filters',
      ),
    );
  }

  Widget _buildSearchSuggestions(ordersState) {
    return AnimatedBuilder(
      animation: _searchAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _searchAnimation.value,
          child: Container(
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (ordersState.recentSearches.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        const Icon(Icons.history, size: 16, color: Colors.grey),
                        const SizedBox(width: 8),
                        const Text(
                          'Recent Searches',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey,
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () {
                            ref
                                .read(fuelOrdersProvider.notifier)
                                .clearRecentSearches();
                          },
                          child: const Text(
                            'Clear',
                            style: TextStyle(fontSize: 12, color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ...ordersState.recentSearches.map(
                    (search) =>
                        _buildSuggestionItem(search, Icons.history, true),
                  ),
                ],
                if (ordersState.searchSuggestions.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'Suggestions',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  ...ordersState.searchSuggestions.map(
                    (suggestion) =>
                        _buildSuggestionItem(suggestion, Icons.search, false),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSuggestionItem(String text, IconData icon, bool isRecent) {
    return InkWell(
      onTap: () => _selectSearchSuggestion(text),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ),
            if (isRecent)
              IconButton(
                onPressed: () {
                  // Remove from recent searches
                  final updatedRecent = List<String>.from(
                    ref.read(fuelOrdersProvider).recentSearches,
                  );
                  updatedRecent.remove(text);
                  ref
                      .read(fuelOrdersProvider.notifier)
                      .setSearchSuggestions(updatedRecent);
                },
                icon: const Icon(Icons.close, size: 14, color: Colors.grey),
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    return AnimatedBuilder(
      animation: _filterAnimation,
      builder: (context, child) {
        return SizeTransition(
          sizeFactor: _filterAnimation,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Quick Filters
                _buildQuickFilters(),
                const SizedBox(height: 16),

                // Status Filter
                _buildStatusFilter(),
                const SizedBox(height: 16),

                // Advanced Filters Toggle
                _buildAdvancedFiltersToggle(),

                // Advanced Filters (Date Range)
                if (_showAdvancedFilters) _buildAdvancedFilters(),

                const SizedBox(height: 16),
                _buildFilterActions(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Filters',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildQuickFilterChip('Today', 'today', Icons.today),
            _buildQuickFilterChip('This Week', 'thisWeek', Icons.date_range),
            _buildQuickFilterChip(
              'This Month',
              'thisMonth',
              Icons.calendar_month,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickFilterChip(String label, String filterType, IconData icon) {
    return InkWell(
      onTap: () => _applyQuickFilter(filterType),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: const Color(0xFF10B981)),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF111827),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Filter by Status',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildFilterChip('All', null),
            _buildFilterChip('Completed', OrderStatusEnum.completed),
            _buildFilterChip('Pending', OrderStatusEnum.pending),
            _buildFilterChip('Cancelled', OrderStatusEnum.cancelled),
          ],
        ),
      ],
    );
  }

  Widget _buildAdvancedFiltersToggle() {
    return InkWell(
      onTap: _toggleAdvancedFilters,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(
              _showAdvancedFilters ? Icons.expand_less : Icons.expand_more,
              size: 20,
              color: const Color(0xFF10B981),
            ),
            const SizedBox(width: 8),
            const Text(
              'Advanced Filters',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF10B981),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvancedFilters() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Date Range',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: _selectDateRange,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Color(0xFF10B981),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _selectedDateFrom != null && _selectedDateTo != null
                          ? '${_formatDate(_selectedDateFrom!)} - ${_formatDate(_selectedDateTo!)}'
                          : 'Select date range',
                      style: TextStyle(
                        fontSize: 14,
                        color: _selectedDateFrom != null
                            ? Colors.black87
                            : Colors.grey[600],
                      ),
                    ),
                  ),
                  if (_selectedDateFrom != null)
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _selectedDateFrom = null;
                          _selectedDateTo = null;
                        });
                        ref
                            .read(fuelOrdersProvider.notifier)
                            .setDateRange(null, null);
                      },
                      icon: const Icon(
                        Icons.clear,
                        size: 16,
                        color: Colors.grey,
                      ),
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterActions() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _clearFilters,
            icon: const Icon(Icons.clear_all, size: 16),
            label: const Text('Clear All'),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFE5E7EB)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _applyFilters,
            icon: const Icon(Icons.check, size: 16),
            label: const Text('Apply'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, OrderStatusEnum? status) {
    return Consumer(
      builder: (context, ref, child) {
        final ordersState = ref.watch(fuelOrdersProvider);
        final isSelected = ordersState.statusFilter == status;

        return ChoiceChip(
          label: Text(label),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              _activeStatusFilter = selected ? status : null;
            });
          },
          selectedColor: const Color(0xFF10B981).withValues(alpha: 0.2),
          backgroundColor: Colors.white,
          labelStyle: TextStyle(
            color: isSelected
                ? const Color(0xFF10B981)
                : const Color(0xFF6B7280),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
          side: BorderSide(
            color: isSelected
                ? const Color(0xFF10B981)
                : const Color(0xFFE5E7EB),
          ),
        );
      },
    );
  }

  Widget _buildActiveFiltersChips() {
    return Consumer(
      builder: (context, ref, child) {
        final ordersState = ref.watch(fuelOrdersProvider);

        if (ordersState.appliedFilters.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.filter_alt,
                    size: 16,
                    color: Color(0xFF10B981),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Active Filters',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF10B981),
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      _clearFilters();
                    },
                    child: const Text(
                      'Clear All',
                      style: TextStyle(fontSize: 12, color: Colors.red),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (ordersState.statusFilter != null)
                    _buildActiveFilterChip(
                      'Status: ${ordersState.statusFilter!.value[0].toUpperCase()}${ordersState.statusFilter!.value.substring(1)}',
                      () {
                        ref
                            .read(fuelOrdersProvider.notifier)
                            .setStatusFilter(null);
                        setState(() {
                          _activeStatusFilter = null;
                        });
                      },
                    ),
                  if (ordersState.searchQuery.isNotEmpty)
                    _buildActiveFilterChip(
                      'Search: ${ordersState.searchQuery}',
                      () {
                        ref
                            .read(fuelOrdersProvider.notifier)
                            .setSearchQuery('');
                        setState(() {
                          _searchQuery = '';
                          _searchController.clear();
                        });
                      },
                    ),
                  if (ordersState.dateFrom != null &&
                      ordersState.dateTo != null)
                    _buildActiveFilterChip(
                      'Date: ${_formatDate(ordersState.dateFrom!)} - ${_formatDate(ordersState.dateTo!)}',
                      () {
                        ref
                            .read(fuelOrdersProvider.notifier)
                            .setDateRange(null, null);
                        setState(() {
                          _selectedDateFrom = null;
                          _selectedDateTo = null;
                        });
                      },
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActiveFilterChip(String label, VoidCallback onRemove) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF10B981).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF10B981).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF10B981),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.close, size: 14, color: Color(0xFF10B981)),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(FuelOrder order) {
    return InkWell(
      onTap: () => _handleOrderPress(order.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE5E7EB)),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Order ID',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        order.serial,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF111827),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(order.status).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    order.status.value[0].toUpperCase() +
                        order.status.value.substring(1),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _getStatusColor(order.status),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.person_outline, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  order.customer.name,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.local_shipping_outlined,
                  size: 14,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  '${order.deliveryType.value[0].toUpperCase()}${order.deliveryType.value.substring(1)} • ${order.orderType.value[0].toUpperCase()}${order.orderType.value.substring(1)}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Order Date',
                      style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(order.createdAt),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111827),
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Total',
                      style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${order.currency.code} ${order.total.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Color(0xFF10B981)),
          SizedBox(height: 16),
          Text('Loading orders...', style: TextStyle(color: Color(0xFF6B7280))),
        ],
      ),
    );
  }

  Widget _buildLoadingMoreIndicator() {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Center(
        child: Column(
          children: [
            CircularProgressIndicator(color: Color(0xFF10B981)),
            SizedBox(height: 8),
            Text(
              'Loading more orders...',
              style: TextStyle(color: Color(0xFF6B7280), fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchLoadingState() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: const Row(
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              color: Color(0xFF10B981),
              strokeWidth: 2,
            ),
          ),
          SizedBox(width: 12),
          Text(
            'Searching orders...',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Color(0xFFEF4444)),
            const SizedBox(height: 16),
            const Text(
              'Error',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                ref.read(fuelOrdersProvider.notifier).fetchOrders();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Retry', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    String emptyMessage;
    switch (_activeStatusFilter) {
      case OrderStatusEnum.completed:
        emptyMessage = 'No completed orders';
        break;
      case OrderStatusEnum.pending:
        emptyMessage = 'No pending orders';
        break;
      case OrderStatusEnum.cancelled:
        emptyMessage = 'No cancelled orders';
        break;
      default:
        emptyMessage = 'No orders found';
        break;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/empty_orders.png',
              width: 200,
              height: 200,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.receipt_long_outlined,
                  size: 120,
                  color: Color(0xFFD1D5DB),
                );
              },
            ),
            const SizedBox(height: 24),
            const Text(
              'No orders yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF065F46),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              emptyMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/');
              },
              icon: const Icon(Icons.shopping_cart, size: 18),
              label: const Text('Start Shopping'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

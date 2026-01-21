import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bdcomputing/providers/providers.dart';

class AnimatedPlaceholderSearchInput extends ConsumerStatefulWidget {
  final Duration switchDuration;
  final Duration fadeDuration;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSearch;
  final String? initialValue;

  const AnimatedPlaceholderSearchInput({
    super.key,
    this.switchDuration = const Duration(seconds: 2),
    this.fadeDuration = const Duration(milliseconds: 400),
    this.onChanged,
    this.onSearch,
    this.initialValue,
  });

  @override
  ConsumerState<AnimatedPlaceholderSearchInput> createState() =>
      _AnimatedPlaceholderSearchInputState();
}

class _AnimatedPlaceholderSearchInputState
    extends ConsumerState<AnimatedPlaceholderSearchInput> {
  late int _currentIndex;
  late String _currentPlaceholder;
  late List<String> _terms;
  late bool _disposed;
  bool _loading = true;
  String? _error;
  late final TextEditingController _controller;
  String _inputValue = '';

  @override
  void initState() {
    super.initState();
    _currentIndex = 0;
    _terms = [];
    _currentPlaceholder = '';
    _disposed = false;
    _controller = TextEditingController(text: widget.initialValue ?? '');
    _inputValue = widget.initialValue ?? '';
    _fetchCategories();
    _controller.addListener(_handleInputChange);
  }

  void _handleInputChange() {
    final value = _controller.text;
    if (_inputValue != value) {
      setState(() {
        _inputValue = value;
      });
      if (widget.onChanged != null) {
        widget.onChanged!(value);
      }
    }
  }

  Future<void> _fetchCategories() async {
    try {
      final service = ref.read(productCategoriesProvider);
      final categories = await service.fetchProductCategories();
      final names = categories
          .where((c) => c.name.isNotEmpty)
          .map((c) => 'Search for ${c.name}')
          .toList();
      if (!_disposed) {
        setState(() {
          _terms = names.isNotEmpty ? names : ['Search for products'];
          _currentIndex = 0;
          _currentPlaceholder = _terms[_currentIndex];
          _loading = false;
        });
        _startPlaceholderAnimation();
      }
    } catch (e) {
      if (!_disposed) {
        setState(() {
          _error = 'Failed to load categories';
          _terms = ['Search for products'];
          _currentIndex = 0;
          _currentPlaceholder = _terms[_currentIndex];
          _loading = false;
        });
        _startPlaceholderAnimation();
      }
    }
  }

  void _startPlaceholderAnimation() async {
    while (!_disposed) {
      await Future.delayed(widget.switchDuration);
      if (_disposed || _terms.length <= 1) break;
      setState(() {
        _currentIndex = (_currentIndex + 1) % _terms.length;
        _currentPlaceholder = _terms[_currentIndex];
      });
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // The button should hang on the right inside the search input
    return LayoutBuilder(
      builder: (context, constraints) {
        return ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: 0,
            maxWidth: constraints.maxWidth,
            minHeight: 44,
            maxHeight: 48,
          ),
          child: SizedBox(
            height: 44,
            child: Stack(
              alignment: Alignment.centerRight,
              children: [
                TextField(
                  controller: _controller,
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.left,
                  enabled: !_loading,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    // Add space for the button by increasing right padding
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 0,
                      horizontal: 20,
                    ).copyWith(right: 80),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(999),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(999),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(999),
                      borderSide: BorderSide(
                        color: Colors.green.withAlpha((0.7 * 255).round()),
                        width: 1.5,
                      ),
                    ),
                    hintText: null,
                    hintStyle: const TextStyle(color: Colors.grey),
                    hint: _loading
                        ? const Row(
                            children: [
                              Text(
                                'Search for products...',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          )
                        : AnimatedSwitcher(
                            duration: widget.fadeDuration,
                            transitionBuilder: (child, animation) =>
                                FadeTransition(
                                  opacity: animation,
                                  child: child,
                                ),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: LayoutBuilder(
                                builder: (context, boxConstraints) {
                                  return Text(
                                    _currentPlaceholder,
                                    key: ValueKey<String>(_currentPlaceholder),
                                    style: const TextStyle(color: Colors.grey),
                                    textAlign: TextAlign.left,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  );
                                },
                              ),
                            ),
                          ),
                    filled: true,
                    fillColor: Colors.grey[100],
                    isDense: true,
                    errorText: _error,
                  ),
                  onSubmitted: (value) {
                    if (widget.onSearch != null && value.trim().isNotEmpty) {
                      widget.onSearch!(value.trim());
                    }
                  },
                ),
                Positioned(
                  right: 2,
                  child: SizedBox(
                    height: 36,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(12),
                            bottomLeft: Radius.circular(12),
                            topRight: Radius.circular(100),
                            bottomRight: Radius.circular(100),
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        minimumSize: const Size(0, 36),
                      ),
                      onPressed: _inputValue.trim().isNotEmpty
                          ? () {
                              // Always send back the value on search button click
                              if (widget.onSearch != null) {
                                widget.onSearch!(_controller.text.trim());
                              }
                              FocusScope.of(context).unfocus();
                            }
                          : null,
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [Icon(Icons.search_rounded, size: 18)],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

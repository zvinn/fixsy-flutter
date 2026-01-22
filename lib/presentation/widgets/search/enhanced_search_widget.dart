import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';

/// Search Filters Model
class SearchFilters {
  final String? serviceType;
  final double? minRating;
  final double? maxPrice;
  final double? maxDistance;
  final bool? verifiedOnly;
  final String? sortBy;

  const SearchFilters({
    this.serviceType,
    this.minRating,
    this.maxPrice,
    this.maxDistance,
    this.verifiedOnly,
    this.sortBy,
  });

  SearchFilters copyWith({
    String? serviceType,
    double? minRating,
    double? maxPrice,
    double? maxDistance,
    bool? verifiedOnly,
    String? sortBy,
  }) {
    return SearchFilters(
      serviceType: serviceType ?? this.serviceType,
      minRating: minRating ?? this.minRating,
      maxPrice: maxPrice ?? this.maxPrice,
      maxDistance: maxDistance ?? this.maxDistance,
      verifiedOnly: verifiedOnly ?? this.verifiedOnly,
      sortBy: sortBy ?? this.sortBy,
    );
  }

  bool get hasActiveFilters =>
      serviceType != null ||
      minRating != null ||
      maxPrice != null ||
      maxDistance != null ||
      verifiedOnly == true;
}

/// Enhanced Search Widget with Filters
class EnhancedSearchWidget extends StatefulWidget {
  final Function(String query, SearchFilters filters)? onSearch;
  final List<String> serviceTypes;
  final String? initialQuery;

  const EnhancedSearchWidget({
    super.key,
    this.onSearch,
    this.serviceTypes = const ['سباكة', 'كهرباء', 'نجارة', 'تكييف', 'دهان'],
    this.initialQuery,
  });

  @override
  State<EnhancedSearchWidget> createState() => _EnhancedSearchWidgetState();
}

class _EnhancedSearchWidgetState extends State<EnhancedSearchWidget> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  SearchFilters _filters = const SearchFilters();
  bool _showFilters = false;
  List<String> _recentSearches = [];
  List<String> _suggestions = [];

  // Filter values
  double _minRating = 0;
  double _maxPrice = 500;
  double _maxDistance = 10;
  bool _verifiedOnly = false;
  String? _selectedService;
  String _sortBy = 'rating';

  @override
  void initState() {
    super.initState();
    if (widget.initialQuery != null) {
      _searchController.text = widget.initialQuery!;
    }
    _loadRecentSearches();
    
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _loadRecentSearches() {
    // TODO: Load from local storage
    _recentSearches = ['سباكة منزلية', 'كهربائي', 'صيانة تكييف'];
  }

  void _onSearchChanged() {
    final query = _searchController.text;
    if (query.length >= 2) {
      _updateSuggestions(query);
    } else {
      setState(() => _suggestions = []);
    }
  }

  void _updateSuggestions(String query) {
    final allSuggestions = [
      'سباكة منزلية',
      'سباكة صناعية',
      'كهربائي منزلي',
      'كهربائي تجاري',
      'صيانة تكييف',
      'تركيب تكييف',
      'نجار أثاث',
      'نجار أبواب',
      'دهان داخلي',
      'دهان خارجي',
    ];

    setState(() {
      _suggestions = allSuggestions
          .where((s) => s.contains(query))
          .take(5)
          .toList();
    });
  }

  void _performSearch() {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    // Add to recent searches
    if (!_recentSearches.contains(query)) {
      _recentSearches.insert(0, query);
      if (_recentSearches.length > 5) {
        _recentSearches.removeLast();
      }
    }

    _focusNode.unfocus();
    setState(() => _suggestions = []);

    widget.onSearch?.call(query, _filters);
  }

  void _applyFilters() {
    _filters = SearchFilters(
      serviceType: _selectedService,
      minRating: _minRating > 0 ? _minRating : null,
      maxPrice: _maxPrice < 500 ? _maxPrice : null,
      maxDistance: _maxDistance < 10 ? _maxDistance : null,
      verifiedOnly: _verifiedOnly ? true : null,
      sortBy: _sortBy,
    );

    setState(() => _showFilters = false);
    _performSearch();
  }

  void _clearFilters() {
    setState(() {
      _minRating = 0;
      _maxPrice = 500;
      _maxDistance = 10;
      _verifiedOnly = false;
      _selectedService = null;
      _sortBy = 'rating';
      _filters = const SearchFilters();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Search Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _focusNode.hasFocus
                  ? AppTheme.primaryColor
                  : (isDark ? Colors.white12 : Colors.grey.shade200),
              width: _focusNode.hasFocus ? 2 : 1,
            ),
            boxShadow: _focusNode.hasFocus
                ? [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Icon(
                Icons.search,
                color: isDark ? Colors.white54 : Colors.grey,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  focusNode: _focusNode,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _performSearch(),
                  decoration: InputDecoration(
                    hintText: 'ابحث عن خدمة أو فني...',
                    hintStyle: TextStyle(
                      color: isDark ? Colors.white38 : Colors.grey,
                    ),
                    border: InputBorder.none,
                  ),
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
              if (_searchController.text.isNotEmpty)
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: isDark ? Colors.white54 : Colors.grey,
                    size: 20,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _suggestions = []);
                  },
                ),
              Container(
                width: 1,
                height: 24,
                color: isDark ? Colors.white12 : Colors.grey.shade300,
              ),
              const SizedBox(width: 8),
              Stack(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.tune,
                      color: _filters.hasActiveFilters
                          ? AppTheme.primaryColor
                          : (isDark ? Colors.white54 : Colors.grey),
                    ),
                    onPressed: () => setState(() => _showFilters = !_showFilters),
                  ),
                  if (_filters.hasActiveFilters)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),

        // Suggestions
        if (_suggestions.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkCardColor : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _suggestions.length,
              itemBuilder: (context, index) {
                final suggestion = _suggestions[index];
                return ListTile(
                  leading: Icon(
                    Icons.search,
                    color: isDark ? Colors.white54 : Colors.grey,
                    size: 20,
                  ),
                  title: Text(
                    suggestion,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  onTap: () {
                    _searchController.text = suggestion;
                    setState(() => _suggestions = []);
                    _performSearch();
                  },
                );
              },
            ),
          ).animate().fadeIn().slideY(begin: -0.1, end: 0),

        // Filters Panel
        if (_showFilters)
          _buildFiltersPanel(isDark).animate().fadeIn().slideY(begin: -0.1, end: 0),
      ],
    );
  }

  Widget _buildFiltersPanel(bool isDark) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'الفلاتر',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              TextButton(
                onPressed: _clearFilters,
                child: const Text('مسح الكل'),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Service Type
          Text(
            'نوع الخدمة',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.serviceTypes.map((type) {
              final isSelected = _selectedService == type;
              return ChoiceChip(
                label: Text(type),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedService = selected ? type : null;
                  });
                },
                selectedColor: AppTheme.primaryColor,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 20),

          // Rating Slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'الحد الأدنى للتقييم',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
              Row(
                children: [
                  Icon(Icons.star, color: Colors.amber, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    _minRating.toStringAsFixed(1),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Slider(
            value: _minRating,
            min: 0,
            max: 5,
            divisions: 10,
            activeColor: AppTheme.primaryColor,
            onChanged: (value) => setState(() => _minRating = value),
          ),

          // Price Slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'الحد الأقصى للسعر',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
              Text(
                '${_maxPrice.toInt()} ج.م',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
          Slider(
            value: _maxPrice,
            min: 50,
            max: 500,
            divisions: 9,
            activeColor: AppTheme.primaryColor,
            onChanged: (value) => setState(() => _maxPrice = value),
          ),

          // Distance Slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'الحد الأقصى للمسافة',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
              Text(
                '${_maxDistance.toInt()} كم',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
          Slider(
            value: _maxDistance,
            min: 1,
            max: 10,
            divisions: 9,
            activeColor: AppTheme.primaryColor,
            onChanged: (value) => setState(() => _maxDistance = value),
          ),

          // Verified Only Switch
          SwitchListTile(
            title: Text(
              'الفنيين الموثقين فقط',
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
            value: _verifiedOnly,
            onChanged: (value) => setState(() => _verifiedOnly = value),
            activeColor: AppTheme.primaryColor,
            contentPadding: EdgeInsets.zero,
          ),

          const SizedBox(height: 16),

          // Sort By
          Text(
            'ترتيب حسب',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              _SortChip(label: 'التقييم', value: 'rating', selected: _sortBy, onSelect: (v) => setState(() => _sortBy = v)),
              _SortChip(label: 'السعر', value: 'price', selected: _sortBy, onSelect: (v) => setState(() => _sortBy = v)),
              _SortChip(label: 'المسافة', value: 'distance', selected: _sortBy, onSelect: (v) => setState(() => _sortBy = v)),
            ],
          ),

          const SizedBox(height: 24),

          // Apply Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _applyFilters,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('تطبيق الفلاتر'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SortChip extends StatelessWidget {
  final String label;
  final String value;
  final String selected;
  final Function(String) onSelect;

  const _SortChip({
    required this.label,
    required this.value,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == selected;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelect(value),
      selectedColor: AppTheme.primaryColor,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : null,
      ),
    );
  }
}

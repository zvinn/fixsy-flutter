import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../../data/models/service_model.dart';
import '../../providers/services_provider.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load services on init
    Future.microtask(() {
      context.read<ServicesProvider>().loadServices();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الخدمات'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'ابحث عن خدمة...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          context.read<ServicesProvider>().searchServices('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                context.read<ServicesProvider>().searchServices(value);
              },
            ),
          ),

          // Category Tabs
          Consumer<ServicesProvider>(
            builder: (context, provider, _) {
              return SizedBox(
                height: 50,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _CategoryChip(
                      label: 'الكل',
                      isSelected: provider.selectedCategory == 'all',
                      onTap: () => provider.filterByCategory('all'),
                    ),
                    ...AppConstants.serviceCategories.map((category) {
                      return _CategoryChip(
                        label: AppConstants.serviceCategoriesArabic[category] ??
                            category,
                        isSelected: provider.selectedCategory == category,
                        onTap: () => provider.filterByCategory(category),
                      );
                    }),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 16),

          // Services Grid
          Expanded(
            child: Consumer<ServicesProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline,
                            size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(provider.error!),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => provider.loadServices(),
                          child: const Text('إعادة المحاولة'),
                        ),
                      ],
                    ),
                  );
                }

                if (provider.services.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inbox_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'لا توجد خدمات',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => provider.refresh(),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final responsive = context.responsive;
                      return GridView.builder(
                        padding: EdgeInsets.all(responsive.horizontalPadding),
                        gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: responsive.gridCrossAxisCount,
                          childAspectRatio: responsive.cardAspectRatio,
                          crossAxisSpacing: responsive.horizontalPadding,
                          mainAxisSpacing: responsive.horizontalPadding,
                        ),
                        itemCount: provider.services.length,
                        itemBuilder: (context, index) {
                          // Wrap with RepaintBoundary for better performance
                          return RepaintBoundary(
                            child: _ServiceCard(service: provider.services[index]),
                          );
                        },
                      );
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
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        selectedColor: Theme.of(context).primaryColor.withAlpha(51),
        checkmarkColor: Theme.of(context).primaryColor,
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({required this.service});

  final Service service;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          // TODO: Navigate to service detail screen
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('تفاصيل: ${service.nameAr}')),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Service Image
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                color: Colors.grey[200],
                child: service.imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: service.imageUrl!,
                        fit: BoxFit.cover,
                        // Optimize image loading
                        memCacheWidth: 400, // Limit memory usage
                        maxWidthDiskCache: 400,
                        placeholder: (context, url) => Container(
                          color: Colors.grey[200],
                          child: const Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Icon(
                          Icons.handyman,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                      )
                    : Icon(
                        Icons.handyman,
                        size: 48,
                        color: Colors.grey[400],
                      ),
              ),
            ),

            // Service Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      service.nameAr,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${service.price.toStringAsFixed(0)} ج.م',
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    color: Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const Icon(Icons.arrow_forward,
                            size: 20, color: Colors.grey),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

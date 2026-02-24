import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../providers/product_provider.dart';
import '../providers/preference_provider.dart';
import '../widgets/product_card.dart';
import '../widgets/shimmer_loader.dart';
import 'history_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  int _selectedTab = 0; // 0=All 1=Liked 2=Disliked

  @override
  void initState() {
    super.initState();
    // Load products on first build
    Future.microtask(
      () => ref.read(productsProvider.notifier).loadProducts(),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productsState = ref.watch(productsProvider);
    final prefs = ref.watch(preferenceProvider);

    var displayProducts = productsState.products;

    // Apply search
    if (_searchQuery.isNotEmpty) {
      displayProducts = ref
          .read(productsProvider.notifier)
          .searchProducts(_searchQuery);
    }

    // Apply tab filter
    if (_selectedTab == 1) {
      displayProducts =
          displayProducts.where((p) => prefs.isLiked(p.id)).toList();
    } else if (_selectedTab == 2) {
      displayProducts =
          displayProducts.where((p) => prefs.isDisliked(p.id)).toList();
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildSearchBar(),
            _buildCategoryChips(productsState),
            _buildTabBar(),
            Expanded(
              child: productsState.isLoading && displayProducts.isEmpty
                  ? const ShimmerLoader()
                  : productsState.error != null && displayProducts.isEmpty
                      ? _buildError(productsState.error!)
                      : _buildProductGrid(displayProducts),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Product Feed',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1,
                    ),
              ),
              Text(
                'Discover your style',
                style: TextStyle(color: Colors.grey[500], fontSize: 13),
              ),
            ],
          ),
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HistoryScreen()),
            ),
            icon: const Icon(Icons.history_rounded, color: Colors.white70),
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFF1E1E1E),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: Colors.white),
        onChanged: (v) => setState(() => _searchQuery = v),
        decoration: InputDecoration(
          hintText: 'Search products...',
          hintStyle: TextStyle(color: Colors.grey[600]),
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          filled: true,
          fillColor: const Color(0xFF1E1E1E),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildCategoryChips(ProductsState state) {
    final categories = ['all', 'electronics', "men's clothing", "women's clothing", 'jewelery'];

    return SizedBox(
      height: 52,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: categories.length,
        itemBuilder: (_, i) {
          final cat = categories[i];
          final isSelected = state.selectedCategory == cat;
          return GestureDetector(
            onTap: () => ref
                .read(productsProvider.notifier)
                .filterByCategory(cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFFF6B35)
                    : const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                cat == 'all' ? 'All' : cat,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[400],
                  fontSize: 13,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTabBar() {
    final tabs = ['All', 'Liked ❤️', 'Disliked 👎'];
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: Row(
        children: List.generate(
          tabs.length,
          (i) => GestureDetector(
            onTap: () => setState(() => _selectedTab = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 12),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: _selectedTab == i
                    ? Colors.white.withOpacity(0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: _selectedTab == i
                    ? Border.all(color: Colors.white24)
                    : null,
              ),
              child: Text(
                tabs[i],
                style: TextStyle(
                  color:
                      _selectedTab == i ? Colors.white : Colors.grey[600],
                  fontSize: 13,
                  fontWeight: _selectedTab == i
                      ? FontWeight.w600
                      : FontWeight.normal,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductGrid(List products) {
    if (products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined,
                size: 64, color: Colors.grey[700]),
            const SizedBox(height: 16),
            Text('No products found',
                style: TextStyle(color: Colors.grey[500], fontSize: 16)),
          ],
        ),
      );
    }

    return AnimationLimiter(
      child: GridView.builder(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.62,
        ),
        itemCount: products.length,
        itemBuilder: (context, index) {
          return AnimationConfiguration.staggeredGrid(
            position: index,
            duration: const Duration(milliseconds: 400),
            columnCount: 2,
            child: SlideAnimation(
              verticalOffset: 40,
              child: FadeInAnimation(
                child: ProductCard(product: products[index]),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildError(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              error.replaceAll('Exception: ', ''),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 15),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () =>
                  ref.read(productsProvider.notifier).loadProducts(),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B35),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
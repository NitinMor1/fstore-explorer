import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/product_model.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

final storageServiceProvider = Provider<StorageService>((ref) {
  throw UnimplementedError('Initialize StorageService before using');
});

// ─── Products State ──────────────────────────────────────────────────────────

class ProductsState {
  final List<Product> products;
  final bool isLoading;
  final String? error;
  final String selectedCategory;

  const ProductsState({
    this.products = const [],
    this.isLoading = false,
    this.error,
    this.selectedCategory = 'all',
  });

  ProductsState copyWith({
    List<Product>? products,
    bool? isLoading,
    String? error,
    String? selectedCategory,
  }) {
    return ProductsState(
      products: products ?? this.products,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedCategory: selectedCategory ?? this.selectedCategory,
    );
  }
}

class ProductsNotifier extends StateNotifier<ProductsState> {
  final ApiService _apiService;
  final StorageService _storageService;
  List<Product> _allProducts = [];

  ProductsNotifier(this._apiService, this._storageService)
      : super(const ProductsState());

  Future<void> loadProducts() async {
    state = state.copyWith(isLoading: true, error: null);

    // Try cache first
    final cached = _storageService.getCachedProducts();
    if (cached.isNotEmpty) {
      _allProducts = cached;
      state = state.copyWith(products: cached, isLoading: false);
    }

    // Fetch fresh from API
    try {
      final products = await _apiService.fetchProducts();
      _allProducts = products;
      await _storageService.cacheProducts(products);
      state = state.copyWith(products: products, isLoading: false);
    } catch (e) {
      if (_allProducts.isEmpty) {
        state = state.copyWith(isLoading: false, error: e.toString());
      } else {
        // Keep cached data, silent error
        state = state.copyWith(isLoading: false);
      }
    }
  }

  void filterByCategory(String category) {
    state = state.copyWith(selectedCategory: category);
    if (category == 'all') {
      state = state.copyWith(products: _allProducts);
    } else {
      final filtered =
          _allProducts.where((p) => p.category == category).toList();
      state = state.copyWith(products: filtered);
    }
  }

  List<Product> searchProducts(String query) {
    if (query.isEmpty) return _allProducts;
    return _allProducts
        .where((p) =>
            p.title.toLowerCase().contains(query.toLowerCase()) ||
            p.category.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}

final productsProvider =
    StateNotifierProvider<ProductsNotifier, ProductsState>((ref) {
  return ProductsNotifier(
    ref.read(apiServiceProvider),
    ref.read(storageServiceProvider),
  );
});
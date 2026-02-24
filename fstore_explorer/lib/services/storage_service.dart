import 'package:hive_flutter/hive_flutter.dart';
import '../models/product_model.dart';
import '../models/browse_history_model.dart';

class StorageService {
  static const String _prefsBox = 'preferences';
  static const String _historyBox = 'history';
  static const String _productsBox = 'cached_products';
  static const String _likedKey = 'liked_products';
  static const String _dislikedKey = 'disliked_products';

  late Box _prefsBoxInstance;
  late Box<BrowseHistory> _historyBoxInstance;
  late Box<Product> _productsBoxInstance;

  /// Initialize Hive boxes
  Future<void> init() async {
    await Hive.initFlutter();

    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ProductAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(BrowseHistoryAdapter());
    }

    _prefsBoxInstance = await Hive.openBox(_prefsBox);
    _historyBoxInstance = await Hive.openBox<BrowseHistory>(_historyBox);
    _productsBoxInstance = await Hive.openBox<Product>(_productsBox);
  }

  // ─── Liked / Disliked ────────────────────────────────────────────

  Set<int> getLikedIds() {
    final raw = _prefsBoxInstance.get(_likedKey, defaultValue: <int>[]);
    return Set<int>.from(raw as List);
  }

  Set<int> getDislikedIds() {
    final raw = _prefsBoxInstance.get(_dislikedKey, defaultValue: <int>[]);
    return Set<int>.from(raw as List);
  }

  Future<void> saveLikedIds(Set<int> ids) async {
    await _prefsBoxInstance.put(_likedKey, ids.toList());
  }

  Future<void> saveDislikedIds(Set<int> ids) async {
    await _prefsBoxInstance.put(_dislikedKey, ids.toList());
  }

  // ─── Browse History ──────────────────────────────────────────────

  List<BrowseHistory> getBrowseHistory() {
    return _historyBoxInstance.values.toList()
      ..sort((a, b) => b.visitedAt.compareTo(a.visitedAt));
  }

  Future<void> addToHistory(BrowseHistory history) async {
    // Avoid duplicate URLs (update timestamp instead)
    final existing = _historyBoxInstance.values
        .where((h) => h.url == history.url)
        .toList();
    for (final e in existing) {
      await e.delete();
    }
    await _historyBoxInstance.add(history);
  }

  Future<void> clearHistory() async {
    await _historyBoxInstance.clear();
  }

  // ─── Cached Products ─────────────────────────────────────────────

  List<Product> getCachedProducts() {
    return _productsBoxInstance.values.toList();
  }

  Future<void> cacheProducts(List<Product> products) async {
    await _productsBoxInstance.clear();
    for (final product in products) {
      await _productsBoxInstance.put(product.id, product);
    }
  }
}
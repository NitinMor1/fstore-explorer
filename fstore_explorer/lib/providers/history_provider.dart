import 'package:flutter_riverpod/legacy.dart';
import '../models/browse_history_model.dart';
import 'product_provider.dart';

class HistoryNotifier extends StateNotifier<List<BrowseHistory>> {
  final storageService;

  HistoryNotifier(this.storageService) : super([]) {
    _load();
  }

  void _load() {
    state = storageService.getBrowseHistory();
  }

  Future<void> addEntry({
    required String url,
    required String title,
    String? productImage,
  }) async {
    final entry = BrowseHistory(
      url: url,
      title: title,
      visitedAt: DateTime.now(),
      productImage: productImage,
    );
    await storageService.addToHistory(entry);
    state = storageService.getBrowseHistory();
  }

  Future<void> clearAll() async {
    await storageService.clearHistory();
    state = [];
  }
}

final historyProvider =
    StateNotifierProvider<HistoryNotifier, List<BrowseHistory>>((ref) {
  return HistoryNotifier(ref.read(storageServiceProvider));
});
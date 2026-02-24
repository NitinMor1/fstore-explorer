import 'package:flutter_riverpod/legacy.dart';
import 'product_provider.dart';

// ─── Preference State ────────────────────────────────────────────────────────

class PreferenceState {
  final Set<int> likedIds;
  final Set<int> dislikedIds;

  const PreferenceState({
    this.likedIds = const {},
    this.dislikedIds = const {},
  });

  bool isLiked(int id) => likedIds.contains(id);
  bool isDisliked(int id) => dislikedIds.contains(id);

  PreferenceState copyWith({
    Set<int>? likedIds,
    Set<int>? dislikedIds,
  }) {
    return PreferenceState(
      likedIds: likedIds ?? this.likedIds,
      dislikedIds: dislikedIds ?? this.dislikedIds,
    );
  }
}

class PreferenceNotifier extends StateNotifier<PreferenceState> {
  final storageService;

  PreferenceNotifier(this.storageService) : super(const PreferenceState()) {
    _loadPreferences();
  }

  void _loadPreferences() {
    final liked = storageService.getLikedIds();
    final disliked = storageService.getDislikedIds();
    state = PreferenceState(likedIds: liked, dislikedIds: disliked);
  }

  Future<void> toggleLike(int productId) async {
    final liked = Set<int>.from(state.likedIds);
    final disliked = Set<int>.from(state.dislikedIds);

    if (liked.contains(productId)) {
      liked.remove(productId); // un-like
    } else {
      liked.add(productId);
      disliked.remove(productId); // remove from disliked if was there
    }

    state = state.copyWith(likedIds: liked, dislikedIds: disliked);
    await storageService.saveLikedIds(liked);
    await storageService.saveDislikedIds(disliked);
  }

  Future<void> toggleDislike(int productId) async {
    final liked = Set<int>.from(state.likedIds);
    final disliked = Set<int>.from(state.dislikedIds);

    if (disliked.contains(productId)) {
      disliked.remove(productId); // un-dislike
    } else {
      disliked.add(productId);
      liked.remove(productId); // remove from liked if was there
    }

    state = state.copyWith(likedIds: liked, dislikedIds: disliked);
    await storageService.saveLikedIds(liked);
    await storageService.saveDislikedIds(disliked);
  }
}

final preferenceProvider =
    StateNotifierProvider<PreferenceNotifier, PreferenceState>((ref) {
  return PreferenceNotifier(ref.read(storageServiceProvider));
});
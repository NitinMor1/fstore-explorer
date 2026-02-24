import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/product_model.dart';
import '../providers/preference_provider.dart';
import '../providers/history_provider.dart';
import '../utils/url_utils.dart';
import 'webview_screen.dart';

class ProductDetailScreen extends ConsumerWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(preferenceProvider);
    final isLiked = prefs.isLiked(product.id);
    final isDisliked = prefs.isDisliked(product.id);

    // Build a FakeStoreAPI product URL for webview
    final productUrl =
        'https://fakestoreapi.com/products/${product.id}';

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 340,
            pinned: true,
            backgroundColor: const Color(0xFF0F0F0F),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: CachedNetworkImage(
                imageUrl: product.image,
                fit: BoxFit.contain,
                placeholder: (_, __) =>
                    const Center(child: CircularProgressIndicator()),
                errorWidget: (_, __, ___) =>
                    const Icon(Icons.broken_image, color: Colors.grey),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF6B35).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      product.category.toUpperCase(),
                      style: const TextStyle(
                        color: Color(0xFFFF6B35),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    product.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Color(0xFFFF6B35),
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          color: Colors.amber, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        '${product.rating}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600),
                      ),
                      Text(
                        ' (${product.ratingCount} reviews)',
                        style: TextStyle(color: Colors.grey[500], fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'About this product',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.description,
                    style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                        height: 1.6),
                  ),
                  const SizedBox(height: 32),

                  // Like / Dislike Row
                  Row(
                    children: [
                      Expanded(
                        child: _BigButton(
                          icon: Icons.favorite_rounded,
                          label: isLiked ? 'Liked!' : 'Like',
                          isActive: isLiked,
                          color: const Color(0xFFFF6B35),
                          onTap: () => ref
                              .read(preferenceProvider.notifier)
                              .toggleLike(product.id),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _BigButton(
                          icon: Icons.thumb_down_rounded,
                          label: isDisliked ? 'Disliked' : 'Dislike',
                          isActive: isDisliked,
                          color: Colors.grey,
                          onTap: () => ref
                              .read(preferenceProvider.notifier)
                              .toggleDislike(product.id),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Open in Browser
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        // Record browser history manually for external views
                        ref.read(historyProvider.notifier).addEntry(
                              url: productUrl,
                              title: product.title,
                              productImage: product.image,
                            );

                        try {
                          await openUrl(productUrl);
                        } catch (e) {
                          if (context.mounted) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => WebViewScreen(
                                  url: productUrl,
                                  title: product.title,
                                  productImage: product.image,
                                ),
                              ),
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.open_in_browser_rounded),
                      label: const Text('Open in Browser'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white70,
                        side: const BorderSide(color: Colors.white24),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BigButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final Color color;
  final VoidCallback onTap;

  const _BigButton({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isActive ? color : color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isActive ? Colors.white : color, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                  color: isActive ? Colors.white : color,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
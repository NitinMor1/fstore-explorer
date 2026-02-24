import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/product_model.dart';
import '../providers/preference_provider.dart';
import '../screens/product_detail_screen.dart';

class ProductCard extends ConsumerWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(preferenceProvider);
    final isLiked = prefs.isLiked(product.id);
    final isDisliked = prefs.isDisliked(product.id);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProductDetailScreen(product: product),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isLiked
                ? const Color(0xFFFF6B35).withOpacity(0.5)
                : isDisliked
                    ? Colors.grey.withOpacity(0.3)
                    : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: product.image,
                      fit: BoxFit.contain,
                      placeholder: (_, __) => Container(
                        color: const Color(0xFF252525),
                        child: const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFFFF6B35),
                          ),
                        ),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        color: const Color(0xFF252525),
                        child: const Icon(Icons.broken_image,
                            color: Colors.grey),
                      ),
                    ),
                    if (isLiked)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF6B35),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.favorite,
                              color: Colors.white, size: 14),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Info
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Color(0xFFFF6B35),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Like / Dislike buttons
                  Row(
                    children: [
                      Expanded(
                        child: _ActionButton(
                          icon: Icons.thumb_up_rounded,
                          isActive: isLiked,
                          activeColor: const Color(0xFFFF6B35),
                          onTap: () => ref
                              .read(preferenceProvider.notifier)
                              .toggleLike(product.id),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: _ActionButton(
                          icon: Icons.thumb_down_rounded,
                          isActive: isDisliked,
                          activeColor: Colors.grey,
                          onTap: () => ref
                              .read(preferenceProvider.notifier)
                              .toggleDislike(product.id),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final Color activeColor;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.isActive,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? activeColor.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive ? activeColor : Colors.grey[800]!,
          ),
        ),
        child: Icon(
          icon,
          size: 15,
          color: isActive ? activeColor : Colors.grey[600],
        ),
      ),
    );
  }
}
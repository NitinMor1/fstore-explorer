import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/history_provider.dart';
import '../utils/url_utils.dart';
import 'webview_screen.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(historyProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F0F),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Browsing History',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        actions: [
          if (history.isNotEmpty)
            TextButton(
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    backgroundColor: const Color(0xFF1E1E1E),
                    title: const Text('Clear History',
                        style: TextStyle(color: Colors.white)),
                    content: const Text(
                        'Remove all browsing history?',
                        style: TextStyle(color: Colors.grey)),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel')),
                      TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Clear',
                              style:
                                  TextStyle(color: Color(0xFFFF6B35)))),
                    ],
                  ),
                );
                if (confirm == true) {
                  ref.read(historyProvider.notifier).clearAll();
                }
              },
              child: const Text('Clear',
                  style: TextStyle(color: Color(0xFFFF6B35))),
            ),
        ],
      ),
      body: history.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history_rounded, size: 64, color: Colors.grey[700]),
                  const SizedBox(height: 16),
                  Text('No browsing history yet',
                      style: TextStyle(
                          color: Colors.grey[500], fontSize: 16)),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: history.length,
              separatorBuilder: (_, __) => const Divider(
                  color: Colors.white10, height: 1),
              itemBuilder: (context, i) {
                final entry = history[i];
                return ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 4),
                  leading: entry.productImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: CachedNetworkImage(
                            imageUrl: entry.productImage!,
                            width: 48,
                            height: 48,
                            fit: BoxFit.contain,
                          ),
                        )
                      : Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E1E1E),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.language,
                              color: Colors.grey),
                        ),
                  title: Text(
                    entry.title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.url,
                        style: TextStyle(
                            color: Colors.grey[600], fontSize: 11),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        _formatDate(entry.visitedAt),
                        style: TextStyle(
                            color: Colors.grey[700], fontSize: 11),
                      ),
                    ],
                  ),
                  trailing: const Icon(Icons.chevron_right,
                      color: Colors.grey),
                  onTap: () async {
                    try {
                      await openUrl(entry.url);
                    } catch (e) {
                      if (context.mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => WebViewScreen(
                              url: entry.url,
                              title: entry.title,
                              productImage: entry.productImage,
                            ),
                          ),
                        );
                      }
                    }
                  },
                );
              },
            ),
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
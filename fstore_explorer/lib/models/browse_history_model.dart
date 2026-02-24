import 'package:hive/hive.dart';

part 'browse_history_model.g.dart';

@HiveType(typeId: 1)
class BrowseHistory extends HiveObject {
  @HiveField(0)
  final String url;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final DateTime visitedAt;

  @HiveField(3)
  final String? productImage;

  BrowseHistory({
    required this.url,
    required this.title,
    required this.visitedAt,
    this.productImage,
  });
}
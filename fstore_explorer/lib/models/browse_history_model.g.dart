// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'browse_history_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BrowseHistoryAdapter extends TypeAdapter<BrowseHistory> {
  @override
  final int typeId = 1;

  @override
  BrowseHistory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BrowseHistory(
      url: fields[0] as String,
      title: fields[1] as String,
      visitedAt: fields[2] as DateTime,
      productImage: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, BrowseHistory obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.url)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.visitedAt)
      ..writeByte(3)
      ..write(obj.productImage);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BrowseHistoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

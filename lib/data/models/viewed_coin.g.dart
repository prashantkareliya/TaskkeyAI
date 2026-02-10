// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'viewed_coin.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ViewedCoinAdapter extends TypeAdapter<ViewedCoin> {
  @override
  final int typeId = 0;

  @override
  ViewedCoin read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ViewedCoin(
      id: fields[0] as String,
      name: fields[1] as String,
      symbol: fields[2] as String,
      currentPrice: fields[3] as double,
      priceChangePercentage24h: fields[4] as double,

    );
  }

  @override
  void write(BinaryWriter writer, ViewedCoin obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.symbol)
      ..writeByte(3)
      ..write(obj.currentPrice)
      ..writeByte(4)
      ..write(obj.priceChangePercentage24h)
      ..writeByte(5);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ViewedCoinAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

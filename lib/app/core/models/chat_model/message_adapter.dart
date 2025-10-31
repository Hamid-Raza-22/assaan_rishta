// Hive Type Adapter for Message Model
import 'package:hive/hive.dart';
import 'message.dart';

class MessageAdapter extends TypeAdapter<Message> {
  @override
  final int typeId = 0; // Unique ID for this adapter

  @override
  Message read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    
    return Message(
      toId: fields[0] as String,
      msg: fields[1] as String,
      read: fields[2] as String,
      type: Type.values[fields[3] as int],
      fromId: fields[4] as String,
      sent: fields[5] as String,
      isViewOnce: fields[6] as bool?,
      isViewed: fields[7] as bool?,
      status: MessageStatus.values[fields[8] as int],
      delivered: fields[9] as String?,
      reactions: fields[10] != null 
          ? Map<String, String>.from(fields[10] as Map)
          : null,
    );
  }

  @override
  void write(BinaryWriter writer, Message obj) {
    writer
      ..writeByte(11) // Number of fields
      ..writeByte(0)
      ..write(obj.toId)
      ..writeByte(1)
      ..write(obj.msg)
      ..writeByte(2)
      ..write(obj.read)
      ..writeByte(3)
      ..write(obj.type.index)
      ..writeByte(4)
      ..write(obj.fromId)
      ..writeByte(5)
      ..write(obj.sent)
      ..writeByte(6)
      ..write(obj.isViewOnce)
      ..writeByte(7)
      ..write(obj.isViewed)
      ..writeByte(8)
      ..write(obj.status.index)
      ..writeByte(9)
      ..write(obj.delivered)
      ..writeByte(10)
      ..write(obj.reactions);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

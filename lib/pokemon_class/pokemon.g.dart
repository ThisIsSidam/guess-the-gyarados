// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pokemon.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PokemonAdapter extends TypeAdapter<Pokemon> {
  @override
  final int typeId = 0;

  @override
  Pokemon read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Pokemon(
      id: fields[0] as int,
      name: fields[1] as String,
      generation: fields[2] as int,
      abilities: (fields[3] as Map?)?.cast<int, String>(),
      noOfForms: fields[4] as int,
      types: (fields[5] as List).cast<String>(),
      spriteUrl: fields[6] as String,
      shinySpriteUrl: fields[7] as String,
      evolutionTreeSize: fields[8] as int,
      evolutionItem: fields[9] as String?,
      usableEvolutionItems: (fields[10] as List).cast<String>(),
      stageOfEvolution: fields[11] as int,
      cry: fields[12] as String,
      hasMega: fields[13] as bool,
      hasGmax: fields[14] as bool,
      isBaby: fields[15] as bool,
      isLegendary: fields[16] as bool,
      isMythical: fields[17] as bool,
      isStarter: fields[18] as bool,
      isPseudo: fields[19] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Pokemon obj) {
    writer
      ..writeByte(20)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.generation)
      ..writeByte(3)
      ..write(obj.abilities)
      ..writeByte(4)
      ..write(obj.noOfForms)
      ..writeByte(5)
      ..write(obj.types)
      ..writeByte(6)
      ..write(obj.spriteUrl)
      ..writeByte(7)
      ..write(obj.shinySpriteUrl)
      ..writeByte(8)
      ..write(obj.evolutionTreeSize)
      ..writeByte(9)
      ..write(obj.evolutionItem)
      ..writeByte(10)
      ..write(obj.usableEvolutionItems)
      ..writeByte(11)
      ..write(obj.stageOfEvolution)
      ..writeByte(12)
      ..write(obj.cry)
      ..writeByte(13)
      ..write(obj.hasMega)
      ..writeByte(14)
      ..write(obj.hasGmax)
      ..writeByte(15)
      ..write(obj.isBaby)
      ..writeByte(16)
      ..write(obj.isLegendary)
      ..writeByte(17)
      ..write(obj.isMythical)
      ..writeByte(18)
      ..write(obj.isStarter)
      ..writeByte(19)
      ..write(obj.isPseudo);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PokemonAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

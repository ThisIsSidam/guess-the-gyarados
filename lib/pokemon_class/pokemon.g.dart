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
      bst: fields[3] as int,
      abilities: (fields[4] as Map?)?.cast<int, String>(),
      noOfForms: fields[5] as int,
      types: (fields[6] as List).cast<String>(),
      spriteUrl: fields[7] as String,
      shinySpriteUrl: fields[8] as String,
      evolutionTreeSize: fields[9] as int,
      evolutionItem: fields[10] as String?,
      usableEvolutionItems: (fields[11] as List).cast<String>(),
      stageOfEvolution: fields[12] as int,
      cry: fields[13] as String,
      hasMega: fields[14] as bool,
      hasGmax: fields[15] as bool,
      isBaby: fields[16] as bool,
      isLegendary: fields[17] as bool,
      isMythical: fields[18] as bool,
      isStarter: fields[19] as bool,
      isPseudo: fields[20] as bool,
      speciesID: fields[21] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Pokemon obj) {
    writer
      ..writeByte(22)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.generation)
      ..writeByte(3)
      ..write(obj.bst)
      ..writeByte(4)
      ..write(obj.abilities)
      ..writeByte(5)
      ..write(obj.noOfForms)
      ..writeByte(6)
      ..write(obj.types)
      ..writeByte(7)
      ..write(obj.spriteUrl)
      ..writeByte(8)
      ..write(obj.shinySpriteUrl)
      ..writeByte(9)
      ..write(obj.evolutionTreeSize)
      ..writeByte(10)
      ..write(obj.evolutionItem)
      ..writeByte(11)
      ..write(obj.usableEvolutionItems)
      ..writeByte(12)
      ..write(obj.stageOfEvolution)
      ..writeByte(13)
      ..write(obj.cry)
      ..writeByte(14)
      ..write(obj.hasMega)
      ..writeByte(15)
      ..write(obj.hasGmax)
      ..writeByte(16)
      ..write(obj.isBaby)
      ..writeByte(17)
      ..write(obj.isLegendary)
      ..writeByte(18)
      ..write(obj.isMythical)
      ..writeByte(19)
      ..write(obj.isStarter)
      ..writeByte(20)
      ..write(obj.isPseudo)
      ..writeByte(21)
      ..write(obj.speciesID);
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

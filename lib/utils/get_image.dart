import 'package:flutter/material.dart';
import 'package:guessthegyarados/consts/strings.dart';
import 'package:guessthegyarados/database/images_db.dart';
import 'package:guessthegyarados/database/pokemon_data_db.dart';
import 'package:guessthegyarados/utils/fetch_data/fetch_data.dart';
import 'dart:async';
import 'dart:typed_data';
import 'dart:io';

import 'package:guessthegyarados/utils/misc_methods.dart';

Future<Widget> getPokemonImage(int id, {bool isShiny = false}) async {

  final Image? pokemonImage = ImagesDB.getImage(id, isShiny: isShiny);
  if (pokemonImage != null)
  {
    return pokemonImage;
  }

  var mon = PokemonDB.getData(id);
  mon ??= await fetchPokemonFromPokemonId(id);
  final Uint8List? imageData = await loadImageData(mon.name, mon.speciesID, isShiny); 

  if (imageData == null)
  {
    return Image.asset(missingNoIcon, fit: BoxFit.cover);
  }

  ImagesDB.addImage(id, imageData, isShiny: isShiny); 

  return Image.memory(
    imageData,
    errorBuilder: (context, error, stackTrace) {
      debugPrint("[gPI error] $error");
      debugPrint("[gPI error] $stackTrace");
      return const Center(child: Text('[getPokemonImage] Failed to load image'));
    },
    fit: BoxFit.contain,
  );
}

Future<Uint8List?> loadImageData(String name, int id, bool isShiny) async {
  
  if (isShiny != true)
  {
    try {
      final mainLink = getPokemonImageLink(id, name);
      final imageData = await loadImageDataFromUrl(mainLink);
      if (imageData != null) {
        return imageData;
      }
    } catch (e) {
      debugPrint('Failed to load image from main link: $e');
    }
  }

  try {
    final backupLink = getPokemonBackupImageLink(id, isShiny);
    final imageData = await loadImageDataFromUrl(backupLink);
    return imageData;
  } catch (e) {
    debugPrint('Failed to load image from backup link: $e');
    return null;
  }
}

Future<Uint8List?> loadImageDataFromUrl(String url) async {
  try {
    // Download the image bytes
    HttpClient httpClient = HttpClient();
    var request = await httpClient.getUrl(Uri.parse(url));
    var response = await request.close();

    if (response.statusCode != 200) {
      debugPrint('Failed to load image from $url (Status code: ${response.statusCode})');
      return null;
    }

    Uint8List bytes = await consolidateHttpClientResponseBytes(response);
    return bytes;
  } catch (e) {
    debugPrint('Failed to load image from $url: $e');
    return null;
  }
}

Future<Uint8List> consolidateHttpClientResponseBytes(HttpClientResponse response) async {
  
  var completer = Completer<Uint8List>();
  var contents = <int>[];

  response.listen(
    (List<int> data) {
      contents.addAll(data);
    },
    onDone: () => completer.complete(Uint8List.fromList(contents)),
    onError: (error) => completer.completeError(error),
    cancelOnError: true,
  );

  return completer.future;
}

/// Conversion: ui.Image -> Uint8List
// Future<Uint8List> _imageDataFromImage(ui.Image image) async {
//   ByteData? byteData = await image.toByteData();
//   if (byteData != null) {
//     return byteData.buffer.asUint8List();
//   } else {
//     throw Exception('Failed to convert Image to Uint8List');
//   }
// }

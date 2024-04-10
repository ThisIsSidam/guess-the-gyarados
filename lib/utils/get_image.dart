import 'package:flutter/material.dart';
import 'package:guessthegyarados/database/images_db.dart';
import 'dart:async';
import 'dart:typed_data';
import 'dart:io';

Future<Widget> getPokemonImage(int id, String imageUrl) async {

  final Image? pokemonImage = ImagesDB.getImage(id);
  if (pokemonImage != null)
  {
    return pokemonImage;
  }

  final Uint8List imageData = await loadImageDataFromUrl(imageUrl); 

  ImagesDB.addImage(id, imageData); 

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

Future<Uint8List> loadImageDataFromUrl(String url) async {
  // Download the image bytes
  HttpClient httpClient = HttpClient();
  var request = await httpClient.getUrl(Uri.parse(url));
  var response = await request.close();
  Uint8List bytes = await consolidateHttpClientResponseBytes(response);

  return bytes;
}

Future<Uint8List> consolidateHttpClientResponseBytes(HttpClientResponse response) async {
  
  if (response.statusCode < 200 || response.statusCode >= 300) {
    debugPrint('HTTP request failed with status code ${response.statusCode}');
  }
  
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

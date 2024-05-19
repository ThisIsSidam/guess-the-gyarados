import 'package:guessthegyarados/consts/api_links.dart';
import 'package:guessthegyarados/utils/misc_methods.dart';

final Map<String, String> specialCaseNames = {
  "nidoran-f" : "029",
  "nidoran-m" : "032",
  "mr-mine" : "122",
  "ho-oh" : "250",
  "deoxys-normal" : "386",
  "wormadam-plant" : "413",
  "mime-jr" : "439",
  "porygon-z" : "474",
  "giratina-altered" : "487",
  "shaymin-land" :  "492",
  "basculin-red-striped" : "550-Red-Striped",
  "darmanitan-standard" : "555",
  "tornadus-incarnate" : "641",
  "thundurus-incarnate" : "642",
  "landorus-incarnate" : "645",
  "keldeo-ordinary" : "647",
  "meloetta-aria" : "648",
  "meowstic-male" : "678",
  "aegislash-shield" : "681",
  "pumpkaboo-average" : "710",
  "gourgeist-average" : "711",
  "zygarde-50" : "718",
  "oricorio-baile" : "741",
  "lycanroc-midday" : "745",
  "wishiwashi-solo" : "746",
  "type-null" : "772",
  "minior-red-meteor" : "774",
  "minior-blue-meteor" : "774",
  "minior-green-meteor" : "774",
  "minior-yellow-meteor" : "774",
  "minior-violet-meteor" : "774",
  "minior-indigo-meteor" : "774",
  "minior-orange-meteor" : "774",
  "mimikyu-disguised" : "778",
  "jangmo-o" : "782",
  "hakamo-o" : "783",
  "kommo-o" : "784",
  "tapu-koko" : "785",
  "tapu-lele" : "786",
  "tapu-bulu" : "787",
  "tapu-fini" : "788",
  "toxtricity-amped" : "849",
  "mr-rime" : "866",
  "eiscue-ice" : "875",
  "indeedee-male" : "876",
  "morpeko-full-belly" : "877",
  "urshifu-single-strike" : "892",
  "basculegion-male" : "902",
  "enamorus-incarnate" : "905",
  "great-tusk" : "984",
  "scream-tail" : "985",
  "brute-bonnet" : "986",
  "flutter-mane" : "987",
  "slither-wing" : "988",
  "sandy-shocks" : "989",
  "iron-treads" : "990",
  "iron-bundle" : "991",
  "iron-hands" : "992",
  "iron-jugulis" : "993",
  "iron-moth" : "994",
  "iron-thorns" : "995",
  "walking-wake" : "1009",
  "iron-leaves" : "1010",
  "gouging-fire" : "1020",
  "raging-bolt" : "1021",
  "iron-boulder" : "1022",
  "iron-crown" : "1023"
};

String getPokemonImageLink(int id, String name) {
  final leadingZeroId = id.toString().padLeft(3, '0');

  var imageName = specialCaseNames[name.toLowerCase()];

  imageName ??= _getImageName(leadingZeroId, name);

  return '$pokemonImageLink$imageName.png';
}

String _getImageName(String leadingZeroId, String name) {
  final nameParts = name.split('-');
  final otherParts = nameParts.skip(1).toList();

  if (otherParts.isNotEmpty) {
    final formattedOtherParts = otherParts
        .map((part) => part.capitalize)
        .join('-');
    return '$leadingZeroId-$formattedOtherParts';
  } else {
    return leadingZeroId;
  }
}

String getPokemonBackupImageLink(int id, bool isShiny) {

  if (isShiny)
  {
    return "$shinyPokemonImageLink${id.toString()}.png";

  }
  return "$backupPokemonImageLink${id.toString()}.png";
}
import 'dart:convert';
import 'package:http/http.dart' as http;

/// Résultat brut d'un element reçu depuis l'API.
class ElementResult {
  final String key;
  final String value;
  const ElementResult({required this.key, required this.value});
}

/// Service pour l'échange d'informations chiffrées (POST/GET /element).
///
/// L'API retourne TOUJOURS 200 :
///   - Vide  : {"elements": null}
///   - Rempli: {"elements": [{"creationDate":"...","key":"...","value":"..."}]}
///
/// Les éléments sont détruits après la première lecture (usage unique).
class ElementApiService {
  final String baseUrl;
  const ElementApiService({required this.baseUrl});

  /// Dépose un élément chiffré dans la boîte [relationCode].
  Future<void> postElement({
    required String relationCode,
    required String key,
    required String value,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/element'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'relationCode': relationCode, 'key': key, 'value': value}),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('postElement (${response.statusCode}): ${response.body}');
    }
  }

  /// Récupère le premier élément en attente dans la boîte [relationCode].
  ///
  /// Retourne `null` si aucun message n'est disponible.
  /// L'élément est supprimé du serveur après cette lecture.
  Future<ElementResult?> getElement(String relationCode) async {
    final results = await getElements(relationCode);
    return results.isEmpty ? null : results.first;
  }

  /// Récupère tous les éléments en attente dans la boîte [relationCode].
  ///
  /// Retourne une liste vide si aucun message n'est disponible.
  /// Les éléments sont supprimés du serveur après cette lecture.
  Future<List<ElementResult>> getElements(String relationCode) async {
    final response = await http.get(
      Uri.parse('$baseUrl/element?relationCode=$relationCode'),
    );
    if (response.statusCode != 200) {
      throw Exception('getElements (${response.statusCode}): ${response.body}');
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final raw = data['elements'];
    if (raw == null) return [];
    return (raw as List<dynamic>)
        .map((e) => ElementResult(
              key: e['key'] as String,
              value: e['value'] as String,
            ))
        .toList();
  }
}


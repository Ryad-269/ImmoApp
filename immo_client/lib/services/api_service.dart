import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Pour l'émulateur Android : 10.0.2.2
  // Pour un vrai téléphone : l'IP de votre machine (ex: 192.168.1.10)

  static const String baseUrl = 'http://127.0.0.1:8000/api';

  static Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Récupérer toutes les annonces (avec filtres optionnels)
  static Future<List<dynamic>> getProperties({
    String? district,
    int? minPrice,
    int? maxPrice,
    int? rooms,
  }) async {
    final uri = Uri.parse('$baseUrl/properties/').replace(
      queryParameters: {
        if (district != null && district.isNotEmpty) 'district': district,
        if (minPrice != null) 'min_price': minPrice.toString(),
        if (maxPrice != null) 'max_price': maxPrice.toString(),
        if (rooms != null) 'rooms': rooms.toString(),
      },
    );
    final response = await http.get(uri, headers: await _getHeaders());
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Erreur chargement annonces : ${response.statusCode}');
    }
  }

  // Connexion
  static Future<void> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/token/'),
      body: json.encode({'username': username, 'password': password}),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', data['access']);
      await prefs.setString('refresh_token', data['refresh']);
    } else {
      throw Exception('Identifiants incorrects');
    }
  }

  // Déconnexion
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
  }

  // Récupérer les infos utilisateur
  static Future<Map<String, dynamic>> getUserInfo() async {
    final response = await http.get(
      Uri.parse('$baseUrl/user/'),
      headers: await _getHeaders(),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Erreur récupération profil');
    }
  }

  // Créer une annonce (POST avec photo)
  static Future<Map<String, dynamic>> createProperty(
    Map<String, dynamic> data,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/properties/'),
      body: json.encode(data),
      headers: await _getHeaders(),
    );
    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Erreur création annonce : ${response.statusCode}');
    }
  }

  // Mettre à jour une annonce (PUT/PATCH)
  static Future<Map<String, dynamic>> updateProperty(
    int id,
    Map<String, dynamic> data,
  ) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/properties/$id/'),
      body: json.encode(data),
      headers: await _getHeaders(),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Erreur modification annonce');
    }
  }

  // Supprimer une annonce
  static Future<void> deleteProperty(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/properties/$id/'),
      headers: await _getHeaders(),
    );
    if (response.statusCode != 204) {
      throw Exception('Erreur suppression annonce');
    }
  }

  static Future<void> register(
    String username,
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register/'),
      body: json.encode({
        'username': username,
        'email': email,
        'password': password,
      }),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 201) {
      // Inscription réussie, on peut connecter directement ou rediriger vers login
    } else {
      throw Exception('Erreur inscription : ${response.body}');
    }
  }

  static Future<Map<String, dynamic>> createPropertyWithImage({
    required String titre,
    required String description,
    required int prix,
    required String district,
    required int chambres,
    int? superficie,
    required List<int> photoBytes,
    required String fileName,
  }) async {
    final uri = Uri.parse('$baseUrl/properties/');
    final request = http.MultipartRequest('POST', uri);
    request.fields['titre'] = titre;
    request.fields['description'] = description;
    request.fields['prix'] = prix.toString();
    request.fields['district'] = district;
    request.fields['chambres'] = chambres.toString();
    if (superficie != null)
      request.fields['superficie'] = superficie.toString();
    final multipartFile = http.MultipartFile.fromBytes(
      'photo',
      photoBytes,
      filename: fileName,
    );
    request.files.add(multipartFile);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    request.headers['Authorization'] = 'Bearer $token';
    final response = await request.send();
    final responseBody = await response.stream.bytesToString();
    if (response.statusCode == 201) {
      return json.decode(responseBody);
    } else {
      throw Exception(
        'Erreur création : ${response.statusCode} - $responseBody',
      );
    }
  }
}

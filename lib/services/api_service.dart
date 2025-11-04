// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class ApiService {
  Future<List<Map<String, dynamic>>> fetchProfils() async {
    try {
      final response = await http.get(
        Uri.parse('${Constants.apiBaseUrl}/api/profils'),
      );

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        return data.map((e) => e as Map<String, dynamic>).toList();
      } else {
        throw Exception("Erreur API : ${response.statusCode}");
      }
    } catch (e) {
      print("Erreur réseau : $e");
      throw Exception("Erreur lors de la récupération des profils");
    }
  }

  Future<bool> sendInteraction(String userId, int profilId, String action) async {
    final response = await http.post(
      Uri.parse('${Constants.apiBaseUrl}/api/interact'),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "user_id": userId,
        "profil_id": profilId,
        "action": action,
      }),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['match'] ?? false;
    } else {
      return false;
    }
  }

  Future<Map<String, dynamic>> fetchStats(String userId) async {
    final response = await http.get(
      Uri.parse('${Constants.apiBaseUrl}/api/stats/$userId'),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Erreur API : ${response.statusCode}");
    }
  }
}

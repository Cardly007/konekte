// lib/services/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class AuthService {
  int _refreshAttempts = 0; // Compteur pour limiter les tentatives

  Future<bool> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('${Constants.apiBaseUrl}/api/token'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {'username': email, 'password': password},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', data['access_token']);
      return true;
    } else {
      return false;
    }
  }

  Future<Map<String, dynamic>> getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.get(
      Uri.parse('${Constants.apiBaseUrl}/api/me'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      _refreshAttempts = 0; // Réinitialiser le compteur après une réussite
      return json.decode(response.body);
    } else if ((response.statusCode == 401 || response.statusCode == 403) &&
        _refreshAttempts < 1) {
      _refreshAttempts++; // Incrémenter le compteur
      print("Token expiré, tentative de régénération...");
      await refreshToken();
      return getUserInfo(); // Réessayer après régénération du token
    } else {
      throw Exception("Erreur lors de la récupération des infos utilisateur");
    }
  }

  Future<void> refreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    try {
      final response = await http.post(
        Uri.parse("${Constants.apiBaseUrl}/api/refresh-token"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final newToken = data["token"];
        prefs.setString('token', newToken); // Stocker le nouveau token
        print("Token régénéré : $newToken");
      } else {
        print("Erreur lors de la régénération du token : ${response.body}");
      }
    } catch (e) {
      print("Erreur réseau lors de la régénération du token : $e");
    }
  }

  Future<void> sendInteraction(
    String userId,
    int profilId,
    String action,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      print("Erreur : Aucun token trouvé dans SharedPreferences");
      return;
    }

    final response = await http.post(
      Uri.parse('${Constants.apiBaseUrl}/api/interact'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token", // Ajout du token dans les headers
      },
      body: json.encode({
        "user_id": userId,
        "profil_id": profilId,
        "action": action,
      }),
    );

    if (response.statusCode != 200) {
      print("Erreur interaction : ${response.body}");
    } else {
      print("Interaction enregistrée avec succès : $action");
    }
  }

  Future<Map<String, dynamic>> fetchStats(String userId) async {
    final response = await http.get(
      Uri.parse('${Constants.apiBaseUrl}/api/stats/$userId'),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return {"likes": 0, "dislikes": 0, "superlikes": 0};
    }
  }
}

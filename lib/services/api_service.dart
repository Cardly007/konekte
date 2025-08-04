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
}

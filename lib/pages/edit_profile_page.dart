import 'package:flutter/material.dart';
import 'manage_photos_page.dart';
import 'dart:ui';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart'; // Pour l'URL de l'API

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  bool _isVerified = false;

  // Contrôleurs pour les champs de texte
  final _nomController = TextEditingController();
  final _jobController = TextEditingController();
  final _companyController = TextEditingController();
  final _schoolController = TextEditingController();
  final _bioController = TextEditingController();

  // Valeurs pour les menus déroulants
  String? _drinkingValue;
  String? _smokingValue;
  String? _petsValue;

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  Future<void> _fetchProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.get(
      Uri.parse('${Constants.apiBaseUrl}/api/me'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _nomController.text = data['nom'] ?? '';
        _jobController.text = data['job'] ?? '';
        _companyController.text = data['company'] ?? '';
        _schoolController.text = data['school'] ?? '';
        _bioController.text = data['description'] ?? '';
        _isVerified = data['is_verified'] ?? false;

        if(data['lifestyle'] != null) {
          _drinkingValue = data['lifestyle']['drinking'];
          _smokingValue = data['lifestyle']['smoking'];
          _petsValue = data['lifestyle']['pets'];
        }
        _isLoading = false;
      });
    } else {
      // Gérer l'erreur
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveProfileData() async {
     if (!_formKey.currentState!.validate()) return;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final body = {
      "nom": _nomController.text,
      "job": _jobController.text,
      "company": _companyController.text,
      "school": _schoolController.text,
      "description": _bioController.text,
      "lifestyle": {
        "drinking": _drinkingValue,
        "smoking": _smokingValue,
        "pets": _petsValue,
      }
    };

    final response = await http.put(
      Uri.parse('${Constants.apiBaseUrl}/api/profile/me'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(body),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profil mis à jour !"), backgroundColor: Colors.green),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur : ${response.body}"), backgroundColor: Colors.red),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Modifier le profil"),
        actions: [
          TextButton(
            onPressed: _saveProfileData,
            child: const Text("OK", style: TextStyle(color: Colors.blue, fontSize: 18)),
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   _buildHeader(),
                  const SizedBox(height: 24),
                   _buildSectionTitle("Vérification du profil"),
                  _buildVerificationStatus(),
                  const SizedBox(height: 24),
                  _buildSectionTitle("Informations de base"),
                  _buildTextField(label: "Nom", controller: _nomController),
                  _buildTextField(label: "Profession", controller: _jobController),
                  _buildTextField(label: "Entreprise", controller: _companyController),
                  _buildTextField(label: "École", controller: _schoolController),
                  _buildTextField(label: "Bio", controller: _bioController, maxLines: 5),
                  const SizedBox(height: 24),
                  _buildSectionTitle("Mes Intérêts"),
                  // TODO
                  const SizedBox(height: 24),
                  _buildSectionTitle("Mon Style de Vie"),
                  _buildDropdownField(
                    label: "Alcool",
                    items: ["Jamais", "Socialement", "Régulièrement"],
                    value: _drinkingValue,
                    onChanged: (value) => setState(() => _drinkingValue = value),
                  ),
                   _buildDropdownField(
                    label: "Tabac",
                    items: ["Non fumeur", "Fumeur social", "Fumeur"],
                    value: _smokingValue,
                    onChanged: (value) => setState(() => _smokingValue = value),
                  ),
                   _buildDropdownField(
                    label: "Animaux",
                    items: ["Chien", "Chat", "Les deux", "Aucun"],
                    value: _petsValue,
                    onChanged: (value) => setState(() => _petsValue = value),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  // ... (tous les widgets _build... restent ici)
    Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Profil complété à 40%", // TODO: Rendre dynamique
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const LinearProgressIndicator(
          value: 0.4, // TODO: Rendre dynamique
          backgroundColor: Colors.black12,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          icon: const Icon(Icons.photo_library),
          label: const Text("Gérer mes photos"),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ManagePhotosPage()),
            );
          },
        ),
      ],
    );
  }

    Widget _buildVerificationStatus() {
    return _isVerified
        ? _buildBlurTile(
            "Profil Vérifié",
            Icons.verified,
            color: Colors.green,
          )
        : _buildBlurTile(
            "Faire vérifier mon profil",
            Icons.shield,
            onTap: () async {
              // TODO: Lancer le processus de vérification (ouvrir la caméra)
              // Pour l'instant, on simule un appel API réussi
              await Future.delayed(const Duration(seconds: 1));
              setState(() {
                _isVerified = true;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Félicitations, votre profil est vérifié !"),
                  backgroundColor: Colors.green,
                ),
              );
            },
          );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: Colors.black54,
        ),
      ),
    );
  }

  Widget _buildTextField({required String label, required TextEditingController controller, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField({required String label, required List<String> items, String? value, ValueChanged<String?>? onChanged}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        items: items.map((String itemValue) {
          return DropdownMenuItem<String>(
            value: itemValue,
            child: Text(itemValue),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildBlurTile(
    String title,
    IconData icon, {
    String? badge,
    bool switchValue = false,
    Color color = Colors.black87,
    VoidCallback? onTap, // <-- Ajoute ce paramètre
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            color: Colors.white.withOpacity(0.25),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 10),
              leading: Icon(icon, color: color),
              title: Text(
                title,
                style: TextStyle(color: color, fontWeight: FontWeight.w500),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: onTap, // <-- Utilise le paramètre ici
            ),
          ),
        ),
      ),
    );
  }
}

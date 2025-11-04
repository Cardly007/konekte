import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';


// Modèle simple pour une photo
class MyPhoto {
  final int id;
  final String url;
  MyPhoto({required this.id, required this.url});

  factory MyPhoto.fromJson(Map<String, dynamic> json) {
    return MyPhoto(
      id: json['id'],
      url: json['url'],
    );
  }
}

class ManagePhotosPage extends StatefulWidget {
  const ManagePhotosPage({super.key});

  @override
  State<ManagePhotosPage> createState() => _ManagePhotosPageState();
}

class _ManagePhotosPageState extends State<ManagePhotosPage> {
  bool _isLoading = true;
  List<MyPhoto> _photos = [];

  @override
  void initState() {
    super.initState();
    _fetchPhotos();
  }

  Future<void> _fetchPhotos() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    // On récupère le profil complet pour avoir la liste des photos
    final response = await http.get(
      Uri.parse('${Constants.apiBaseUrl}/api/me'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _photos = (data['photos'] as List)
            .map((photoJson) => MyPhoto.fromJson(photoJson))
            .toList();
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _reorderPhotos(int oldIndex, int newIndex) async {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final MyPhoto item = _photos.removeAt(oldIndex);
      _photos.insert(newIndex, item);
    });

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final photoIds = _photos.map((p) => p.id).toList();

    await http.put(
      Uri.parse('${Constants.apiBaseUrl}/api/profile/me/photos/order'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({'photo_ids': photoIds}),
    );
  }

  Future<void> _addPhotos() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();

    if (pickedFiles.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('${Constants.apiBaseUrl}/api/profile/me/photos'),
    );
    request.headers['Authorization'] = 'Bearer $token';

    for (var file in pickedFiles) {
      request.files.add(await http.MultipartFile.fromPath('files', file.path));
    }

    final response = await request.send();

    if (response.statusCode == 200) {
      _fetchPhotos(); // Recharger les photos
    } else {
      // Gérer l'erreur
    }
  }

  Future<void> _deletePhoto(int photoId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.delete(
      Uri.parse('${Constants.apiBaseUrl}/api/profile/me/photos/$photoId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 204) {
      setState(() {
        _photos.removeWhere((p) => p.id == photoId);
      });
    } else {
      // Gérer l'erreur
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gérer mes photos"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_a_photo),
            onPressed: _addPhotos,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: ReorderableListView(
                onReorder: _reorderPhotos,
                children: _photos.map((photo) {
                  return Card(
                    key: ValueKey(photo.id),
                    child: Stack(
                      alignment: Alignment.topRight,
                      children: [
                        Image.network(photo.url),
                        IconButton(
                          icon: const Icon(Icons.remove_circle, color: Colors.red),
                          onPressed: () => _deletePhoto(photo.id),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/constants.dart';

class RegisterFlowPage extends StatefulWidget {
  const RegisterFlowPage({super.key});

  @override
  State<RegisterFlowPage> createState() => _RegisterFlowPageState();
}

class _RegisterFlowPageState extends State<RegisterFlowPage> {
  final PageController _pageController = PageController();
  final _formKeyStep1 = GlobalKey<FormState>();
  final _formKeyStep2 = GlobalKey<FormState>();

  // Controllers for data
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  DateTime? _birthdate;

  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Inscription - Étape ${_currentPage + 1}/2"),
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildStep1(),
          _buildStep2(),
        ],
      ),
    );
  }

  Widget _buildStep1() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKeyStep1,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              validator: (value) => (value == null || !value.contains('@')) ? 'Email invalide' : null,
            ),
            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Mot de passe'),
              obscureText: true,
              validator: (value) => (value == null || value.length < 8) ? '8 caractères minimum' : null,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_formKeyStep1.currentState!.validate()) {
                  _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
                  setState(() => _currentPage = 1);
                }
              },
              child: const Text('Suivant'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep2() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKeyStep2,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nom ou pseudo'),
              validator: (value) => (value == null || value.isEmpty) ? 'Champ requis' : null,
            ),
            // A simple birthdate selector
            TextButton(
              onPressed: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now().subtract(const Duration(days: 18 * 365)),
                  firstDate: DateTime(1920),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  setState(() => _birthdate = date);
                }
              },
              child: Text(_birthdate == null ? 'Choisir date de naissance' : "${_birthdate!.toLocal()}".split(' ')[0]),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitRegistration,
              child: const Text("Terminer l'inscription"),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitRegistration() async {
    if (_formKeyStep2.currentState!.validate() && _birthdate != null) {
      // Show loading indicator
      showDialog(context: context, builder: (_) => const Center(child: CircularProgressIndicator()), barrierDismissible: false);

      // Call API to register
      final response = await http.post(
        Uri.parse('${Constants.apiBaseUrl}/api/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': _emailController.text,
          'password': _passwordController.text,
          'nom': _nameController.text,
          'birthdate': _birthdate!.toIso8601String().split('T')[0], // format YYYY-MM-DD
        }),
      );

      Navigator.of(context).pop(); // Dismiss loading indicator

      if (response.statusCode == 200) {
        // After successful registration, login automatically
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        await authProvider.login(_emailController.text, _passwordController.text);
        // The AuthWrapper will handle navigation
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: ${response.body}')));
      }
    }
  }
}

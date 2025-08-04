// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'register_page.dart';
// import 'main.dart';
// import 'services/auth_service.dart';

// // const String apiBaseUrl = "http://10.0.2.2:8000";
// const String apiBaseUrl = "http://192.168.0.24:8000";
// // const String apiBaseUrl = "http://127.0.0.1:8000";

// class LoginPage extends StatefulWidget {
//   final VoidCallback onLoginSuccess;

//   const LoginPage({super.key, required this.onLoginSuccess});

//   @override
//   State<LoginPage> createState() => _LoginPageState();
// }

// class _LoginPageState extends State<LoginPage> {
//   final AuthService _authService = AuthService();

//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   bool _loading = false;
//   String? _errorMessage;

//   Future<void> _login() async {
//     if (!_formKey.currentState!.validate()) {
//       print("Validation échouée");
//       return;
//     }

//     print("Bouton 'Se connecter' cliqué");
//     setState(() {
//       _loading = true;
//       _errorMessage = null;
//     });

//     final response = await http.post(
//       Uri.parse('http://$apiBaseUrl/api/token'),
//       headers: {'Content-Type': 'application/x-www-form-urlencoded'},
//       body: {
//         'username': _emailController.text,
//         'password': _passwordController.text,
//       },
//     );

//     print("Statut de la réponse : ${response.statusCode}");
//     print("Corps de la réponse : ${response.body}");

//     setState(() {
//       _loading = false;
//     });

//     if (response.statusCode == 200) {
//       final data = json.decode(response.body);
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setString('token', data['access_token']);
//       widget.onLoginSuccess();
//     } else {
//       setState(() {
//         _errorMessage = "Email ou mot de passe incorrect";
//       });
//     }
//   }

//   Future<void> loginWithToken() async {
//     final response = await http.post(
//       Uri.parse('$apiBaseUrl/api/token'),
//       headers: {'Content-Type': 'application/x-www-form-urlencoded'},
//       body: {
//         'username': _emailController.text,
//         'password': _passwordController.text,
//       },
//     );

//     if (response.statusCode == 200) {
//       final data = json.decode(response.body);
//       final token = data['access_token'];
//       print("Connexion réussie. Token : $token");

//       // Enregistre le token
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setString('token', token);

//       // Navigue vers la page principale
//       Navigator.of(
//         context,
//       ).pushReplacement(MaterialPageRoute(builder: (context) => const MyApp()));
//     } else {
//       print("Erreur : ${response.statusCode}");
//       print("Message : ${response.body}");
//       setState(() {
//         _errorMessage = "Email ou mot de passe incorrect";
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           'Connexion',
//           style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
//         ),
//         centerTitle: true,
//         backgroundColor: Colors.pink,
//       ),
//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             colors: [Colors.pink, Colors.orange],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//         ),
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Form(
//                 key: _formKey,
//                 child: Column(
//                   children: [
//                     TextFormField(
//                       controller: _emailController,
//                       decoration: const InputDecoration(
//                         labelText: 'Email',
//                         border: OutlineInputBorder(),
//                       ),
//                       keyboardType: TextInputType.emailAddress,
//                       validator: (value) {
//                         if (value == null || !value.contains('@')) {
//                           return 'Entrez un email valide';
//                         }
//                         return null;
//                       },
//                     ),
//                     const SizedBox(height: 12),
//                     TextFormField(
//                       controller: _passwordController,
//                       decoration: const InputDecoration(
//                         labelText: 'Mot de passe',
//                         border: OutlineInputBorder(),
//                       ),
//                       obscureText: true,
//                       validator: (value) {
//                         if (value == null || value.length < 6) {
//                           return 'Mot de passe trop court';
//                         }
//                         return null;
//                       },
//                     ),
//                     const SizedBox(height: 20),
//                     _loading
//                         ? const CircularProgressIndicator()
//                         : ElevatedButton(
//                             // onPressed: _login,
//                             onPressed: loginWithToken,
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.pink,
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 50,
//                                 vertical: 15,
//                               ),
//                               textStyle: const TextStyle(fontSize: 18),
//                             ),
//                             child: const Text('Se connecter'),
//                           ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 20),
//               TextButton(
//                 onPressed: () {
//                   Navigator.of(context).push(
//                     MaterialPageRoute(
//                       builder: (context) => const RegisterPage(),
//                     ),
//                   );
//                 },
//                 child: const Text(
//                   'Créer un compte',
//                   style: TextStyle(color: Colors.blue, fontSize: 16),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_application_1/utils/constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'register_page.dart';
import '../main.dart';

const String apiBaseUrl = Constants.apiBaseUrl; // IP de ton backend
// const String apiBaseUrl = "http://192.168.1.78:8000"; // IP de ton backend

class LoginPage extends StatefulWidget {
  final VoidCallback onLoginSuccess;

  const LoginPage({super.key, required this.onLoginSuccess});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _loading = false;
  String? _errorMessage;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    final response = await http.post(
      Uri.parse('$apiBaseUrl/api/token'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'username': _emailController.text,
        'password': _passwordController.text,
      },
    );

    setState(() {
      _loading = false;
    });

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', data['access_token']);

      // ✅ Navigue après succès
      // widget.onLoginSuccess();
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (context) => const MyApp()));
    } else {
      setState(() {
        _errorMessage = "Email ou mot de passe incorrect";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Connexion',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        centerTitle: true,
        backgroundColor: Colors.pink,
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.pink, Colors.orange],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_errorMessage != null)
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                  ),
                const SizedBox(height: 12),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || !value.contains('@')) {
                            return 'Entrez un email valide';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _passwordController,
                        decoration: const InputDecoration(
                          labelText: 'Mot de passe',
                          border: OutlineInputBorder(),
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.length < 6) {
                            return 'Mot de passe trop court';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      _loading
                          ? const CircularProgressIndicator()
                          : ElevatedButton(
                              onPressed: _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.pink,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 50,
                                  vertical: 15,
                                ),
                                textStyle: const TextStyle(fontSize: 18),
                              ),
                              child: const Text('Se connecter'),
                            ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const RegisterPage(),
                      ),
                    );
                  },
                  child: const Text(
                    'Créer un compte',
                    style: TextStyle(color: Colors.blue, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

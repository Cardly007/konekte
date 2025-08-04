import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/ParametresClairsPage.dart';
import 'package:flutter_application_1/pages/chat_page.dart';
import 'package:flutter_application_1/pages/conversations_page.dart';
import 'package:flutter_application_1/main_scaffold.dart';
import 'package:flutter_application_1/pages/parametresPage.dart';
import 'package:lottie/lottie.dart';
import 'package:swipe_cards/swipe_cards.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/login_page.dart';
import 'services/api_service.dart';
import 'services/auth_service.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'theme.dart'; // Import du thème
import 'package:flutter_application_1/utils/constants.dart';
import 'package:provider/provider.dart';

// Assurez-vous que lightTheme et darkTheme sont importés ou définis ici
// Si theme.dart contient déjà ces définitions, ajoutez ceci dans theme.dart:
// export 'package:flutter/material.dart' show ThemeData;
// final ThemeData lightTheme = ThemeData.light();
// final ThemeData darkTheme = ThemeData.dark();

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

const String apiBaseUrl = Constants.apiBaseUrl;
// const String apiBaseUrl = "192.168.1.78:8000";

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Konekte',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.pink),
        useMaterial3: true,
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.black, // Définit la couleur de fond en noir
          selectedItemColor: Colors.white, // Couleur des icônes sélectionnées
          unselectedItemColor:
              Colors.grey, // Couleur des icônes non sélectionnées
        ),
      ),
      home: const MainScaffold(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// Widget build(BuildContext context) {

//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Paramètres UI',
//       themeMode: themeProvider.themeMode,
//       theme: lightTheme,
//       darkTheme: darkTheme,
//       home: const ParametresClairsPage(),
//     );
//   }

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      setState(() {
        _isLoggedIn = false;
      });
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('$apiBaseUrl/api/me'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        setState(() {
          _isLoggedIn = true;
        });
      } else {
        print("Token invalide ou expiré : ${response.body}");
        setState(() {
          _isLoggedIn = false;
        });
      }
    } catch (e) {
      print("Erreur lors de la vérification du token : $e");
      setState(() {
        _isLoggedIn = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoggedIn
        ? const SwipePage()
        : LoginPage(onLoginSuccess: _checkLoginStatus);
  }
}

class SwipePage extends StatefulWidget {
  const SwipePage({super.key});

  @override
  State<SwipePage> createState() => _SwipePageState();
}

class _SwipePageState extends State<SwipePage> {
  final ApiService apiService = ApiService();
  final AuthService authService = AuthService();

  late MatchEngine _matchEngine;
  final List<SwipeItem> _swipeItems = [];
  List<Map<String, dynamic>> profils = [];
  final String userId = "1"; // ID utilisateur fictif

  @override
  void initState() {
    super.initState();
    _fetchProfilsFromAPI();
  }

  // Future<void> _fetchProfilsFromAPI() async {
  //   try {
  //     final response = await http.get(
  //       Uri.parse('http://$apiBaseUrl/api/profils'),
  //     );
  //     if (response.statusCode == 200) {
  //       final List<dynamic> data = json.decode(response.body);
  //       profils = data.map((e) => e as Map<String, dynamic>).toList();

  //       for (var profil in profils) {
  //         _swipeItems.add(
  //           SwipeItem(
  //             content: profil,
  //             likeAction: () {
  //               print("Tu as liké ${profil['nom']}");
  //             },
  //             nopeAction: () {
  //               print("Tu as passé ${profil['nom']}");
  //             },
  //             superlikeAction: () {
  //               print("Super like ${profil['nom']}");
  //             },
  //           ),
  //         );
  //       }

  //       setState(() {
  //         _matchEngine = MatchEngine(swipeItems: _swipeItems);
  //       });
  //     } else {
  //       throw Exception("Erreur API : ${response.statusCode}");
  //     }
  //   } catch (e) {
  //     print("Erreur lors de l'appel API : $e");
  //   }
  // }

  Future<void> _fetchProfilsFromAPI() async {
    try {
      profils = await apiService.fetchProfils();

      _swipeItems.clear();
      for (var profil in profils) {
        _swipeItems.add(
          SwipeItem(
            content: profil,
            likeAction: () {
              print("Tu as liké ${profil['nom']}");
            },
            nopeAction: () {
              print("Tu as passé ${profil['nom']}");
            },
            superlikeAction: () {
              print("Super like ${profil['nom']}");
            },
          ),
        );
      }

      setState(() {
        _matchEngine = MatchEngine(swipeItems: _swipeItems);
      });
    } catch (e) {
      print("Erreur lors de la récupération des profils : $e");
    }
  }

  // Future<void> sendInteraction(
  //   String userId,
  //   int profilId,
  //   String action,
  // ) async {
  //   try {
  //     final response = await http.post(
  //       Uri.parse('http://$apiBaseUrl/api/interact'),
  //       headers: {"Content-Type": "application/json"},
  //       body: json.encode({
  //         "user_id": userId,
  //         "profil_id": profilId,
  //         "action": action,
  //       }),
  //     );

  //     if (response.statusCode == 200) {
  //       print("Interaction enregistrée");
  //     } else {
  //       print("Erreur backend: ${response.body}");
  //     }
  //   } catch (e) {
  //     print("Erreur lors de l'envoi de l'interaction : $e");
  //   }
  // }
  Future<bool> sendInteraction(
    String userId,
    int profilId,
    String action,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/api/interact'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "user_id": userId,
          "profil_id": profilId,
          "action": action,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['match'] ?? false; // Return true if match, false otherwise
      } else {
        print("Erreur backend: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Erreur lors de l'envoi de l'interaction : $e");
      return false;
    }
  }

  Future<Map<String, dynamic>> fetchStats(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$apiBaseUrl/api/stats/$userId'),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception("Erreur API : ${response.statusCode}");
      }
    } catch (e) {
      print("Erreur lors de la récupération des statistiques : $e");
      return {"likes": 0, "dislikes": 0, "superlikes": 0};
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth * 0.85;
    final cardHeight = cardWidth * 1.2;

    if (_swipeItems.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Konekte',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        centerTitle: true,
        backgroundColor: Colors.pink,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.pink, Colors.orange],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          // Centrer le conteneur
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: cardWidth,
                height: cardHeight,
                child: SwipeCards(
                  matchEngine: _matchEngine,
                  itemBuilder: (BuildContext context, int index) {
                    var profil = profils[index];
                    return Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(20),
                            ),
                            child: Image.network(
                              profil['image'] ??
                                  'https://fpoimg.com/600x400?text=Preview&bg_color=e6e6e6&text_color=8F8F8F', // image par défaut si null
                              width: cardWidth, // Ajuster la largeur de l'image
                              height:
                                  cardHeight *
                                  0.6, // Ajuster la hauteur de l'image
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                // Si l'image ne charge pas (ex: URL cassée), on affiche aussi une image par défaut
                                return Image.network(
                                  'https://fpoimg.com/600x400?text=Preview&bg_color=e6e6e6&text_color=8F8F8F',
                                  width: cardWidth,
                                  height: cardHeight * 0.6,
                                  fit: BoxFit.cover,
                                );
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                Text(
                                  "${profil['nom']}, ${profil['age']}",
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  profil['description'] ??
                                      'Description non disponible',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  onStackFinished: () async {
                    final stats = await authService.fetchStats(userId);

                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text("Statistiques"),
                          content: Text(
                            "Likes : ${stats['likes']}\n"
                            "Dislikes : ${stats['dislikes']}\n"
                            "Superlikes : ${stats['superlikes']}",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text("OK"),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  upSwipeAllowed: true,
                  fillSpace: true,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FloatingActionButton(
                    heroTag: "nope",
                    backgroundColor: Colors.red,
                    child: const Icon(Icons.close),
                    onPressed: () {
                      if (_matchEngine.currentItem == null) return;
                      _matchEngine.currentItem?.nope();
                      authService.sendInteraction(
                        userId,
                        _matchEngine.currentItem!.content['id'],
                        "dislike",
                      );
                    },
                  ),
                  const SizedBox(width: 30),
                  FloatingActionButton(
                    heroTag: "superlike",
                    backgroundColor: Colors.blue,
                    child: const Icon(Icons.star),
                    onPressed: () {
                      if (_matchEngine.currentItem == null) return;
                      _matchEngine.currentItem?.superLike();
                      authService.sendInteraction(
                        userId,
                        _matchEngine.currentItem!.content['id'],
                        "superlike",
                      );
                    },
                  ),
                  const SizedBox(width: 30),
                  FloatingActionButton(
                    heroTag: "like",
                    backgroundColor: Colors.green,
                    child: const Icon(Icons.favorite),
                    onPressed: () async {
                      final currentItem = _matchEngine.currentItem;
                      if (currentItem == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Plus de profils à swiper"),
                          ),
                        );
                        return;
                      }

                      final profilId = currentItem.content['id'];
                      if (profilId == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Erreur : profil sans ID"),
                          ),
                        );
                        return;
                      }

                      // currentItem.like();
                      // authService.sendInteraction(userId, profilId, "like");
                      final match = await sendInteraction(
                        userId,
                        profilId,
                        "like",
                      );
                      currentItem.like();
                      if (match) {
                        _showMatchAnimation(context, currentItem.content);
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      // bottomNavigationBar: BottomNavigationBar(
      //   backgroundColor: Colors.black,
      //   selectedItemColor: Colors.white,
      //   unselectedItemColor: Colors.grey,
      //   items: const [
      //     BottomNavigationBarItem(
      //       icon: FaIcon(FontAwesomeIcons.house), // Icône Home stylée
      //       label: 'Home',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: FaIcon(FontAwesomeIcons.star), // Icône Superlike stylée
      //       label: 'Superlike',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: FaIcon(FontAwesomeIcons.heart), // Icône Like stylée
      //       label: 'Like',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: FaIcon(FontAwesomeIcons.commentDots), // Icône Chat stylée
      //       label: 'Chat',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: FaIcon(FontAwesomeIcons.user), // Icône Profile stylée
      //       label: 'Profile',
      //     ),
      //   ],
      //   onTap: (index) {
      //     switch (index) {
      //       case 0:
      //         Navigator.of(context).pushReplacement(
      //           MaterialPageRoute(builder: (context) => const SwipePage()),
      //         );
      //         break;
      //       case 1:
      //         print("Superlike action");
      //         break;
      //       case 2:
      //         print("Like action");
      //         break;
      //       case 3:
      //         Navigator.of(context).push(
      //           MaterialPageRoute(
      //             builder: (context) => const ConversationsPage(),
      //           ),
      //         );
      //         break;
      //       case 4:
      //         Navigator.of(context).push(
      //           MaterialPageRoute(
      //             builder: (context) => const ParametresClairsPage(),
      //           ),
      //         );
      //         break;
      //     }
      //   },
      // ),
    );
  }
}

void _showMatchAnimation(
  BuildContext context,
  Map<String, dynamic> matchedProfile,
) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) {
      return Dialog(
        backgroundColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(
              'assets/match_animation.json',
              width: 200,
              height: 200,
              repeat: false,
              onLoaded: (composition) {
                Future.delayed(composition.duration, () {
                  Navigator.of(
                    context,
                  ).pop(); // Ferme le dialog après animation
                });
              },
            ),
            const SizedBox(height: 10),
            Text(
              "C'est un match avec ${matchedProfile['nom']}!",
              style: const TextStyle(color: Colors.white, fontSize: 20),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    },
  );
}

Future<bool> login(String email, String password) async {
  final response = await http.post(
    Uri.parse('$apiBaseUrl/api/token'),
    headers: {'Content-Type': 'application/x-www-form-urlencoded'},
    body: {'username': email, 'password': password},
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', data['access_token']);
    return true;
  } else {
    print("Erreur de connexion : ${response.body}");
    return false;
  }
}

Future<void> fetchUserData() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');
  print("Token utilisé : $token");

  final response = await http.get(
    Uri.parse('$apiBaseUrl/api/me'),
    headers: {'Authorization': 'Bearer $token'},
  );

  if (response.statusCode == 200) {
    final user = json.decode(response.body);
    print("Utilisateur connecté : ${user['email']}");
  } else {
    print("Erreur d'authentification : ${response.body}");
  }
}

class MainLayout extends StatelessWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Konekte",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        backgroundColor: Colors.pink,
        centerTitle: true,
      ),
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.house),

            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.star),
            label: 'Superlike',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.heart),
            label: 'Like',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.commentDots),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: FaIcon(FontAwesomeIcons.user),
            label: 'Profile',
          ),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const MyApp()),
              );
              break;
            case 1:
              print("Superlike action");
              break;
            case 2:
              print("Like action");
              break;
            case 3:
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const ChatPage()),
              );
              break;
            case 4:
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const ParametresClairsPage(),
                ),
              );
              break;
          }
        },
      ),
    );
  }
}

// theme.dart (ajoutez ceci si ce n'est pas déjà présent)

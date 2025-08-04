import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/ProfileSettingsPage.dart';
import 'package:flutter_application_1/widget/konekteBottomBar.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/theme.dart'; // Ton ThemeProvider
import 'package:flutter_application_1/pages/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ParametresClairsPage extends StatelessWidget {
  const ParametresClairsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // 🎨 Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFE3F2FD), Color(0xFFFCE4EC)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // 🧊 Glass effect container
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // 👤 Header: Photo + Nom
                        Column(
                          children: [
                            const CircleAvatar(
                              radius: 40,
                              backgroundImage: AssetImage(
                                "assets/avatar.jpg",
                              ), // remplace par image client
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              "Cecelia Lee, 22",
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.black87,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 30),

                        // 🧾 Settings List
                        Expanded(
                          child: ListView(
                            children: [
                              _buildBlurTile(
                                "My Profile",
                                Icons.person_outline,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ProfileSettingsPage(
                                        onThemeChanged: (isDark) {
                                          // Ici tu peux appeler ton ThemeProvider ou ta logique de changement de thème
                                          // Exemple :
                                          // Provider.of<ThemeProvider>(context, listen: false).toggleTheme(isDark);
                                        },
                                      ),
                                    ),
                                  );
                                },
                              ),

                              _buildBlurTile(
                                "Match",
                                Icons.favorite_outline,
                                badge: "7",
                              ),
                              _buildBlurTile(
                                "Message",
                                Icons.message_outlined,
                                switchValue: true,
                              ),
                              _buildBlurTile(
                                "Notifications",
                                Icons.notifications_none,
                                badge: "14",
                              ),
                              _buildBlurTile(
                                "My membership",
                                Icons.card_membership_outlined,
                              ),
                              SwitchListTile(
                                title: const Text("Mode sombre"),
                                value:
                                    Provider.of<ThemeProvider>(
                                      context,
                                    ).themeMode ==
                                    ThemeMode.dark,
                                onChanged: (value) {
                                  Provider.of<ThemeProvider>(
                                    context,
                                    listen: false,
                                  ).toggleTheme(value);
                                },
                                secondary: const Icon(Icons.brightness_6),
                              ),
                              _buildBlurTile(
                                "Terms and conditions",
                                Icons.description_outlined,
                              ),
                              const Divider(height: 30),
                              _buildBlurTile(
                                "Log out",
                                Icons.logout,
                                color: Colors.orange,
                                onTap: () async {
                                  // Supprime le token et autres infos utilisateur
                                  final prefs =
                                      await SharedPreferences.getInstance();
                                  await prefs.clear();

                                  // Redirige vers la page de connexion
                                  Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          LoginPage(onLoginSuccess: () {}),
                                    ),
                                    (route) => false,
                                  );
                                },
                              ),
                              _buildBlurTile(
                                "Delete my account",
                                Icons.delete_outline,
                                color: Colors.red,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      // bottomNavigationBar: KonekteBottomBar(currentIndex: 4,
      //   onTap: (index) {
      //     // Gère la navigation vers les autres pages si nécessaire
      //     if (index == 0) {
      //       Navigator.pushNamed(context, '/home');
      //     } else if (index == 1) {
      //       Navigator.pushNamed(context, '/matches');
      //     } else if (index == 2) {
      //       Navigator.pushNamed(context, '/messages');
      //     } else if (index == 3) {
      //       Navigator.pushNamed(context, '/profile');
      //     }
      //   },
      // ),
    );
  }

  // 📦 Helper Widget: Settings tile
  Widget _buildTile(
    String title,
    IconData icon, {
    String? badge,
    bool switchValue = false,
    Color color = Colors.black87,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 10),
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: TextStyle(color: color, fontWeight: FontWeight.w500),
      ),
      trailing: badge != null
          ? _buildBadge(badge)
          : switchValue
          ? Switch(value: true, onChanged: (_) {})
          : const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {},
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
              trailing: badge != null
                  ? _buildBadge(badge)
                  : switchValue
                  ? Switch(value: true, onChanged: (_) {})
                  : const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: onTap, // <-- Utilise le paramètre ici
            ),
          ),
        ),
      ),
    );
  }

  // 🟣 Badge style
  Widget _buildBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.pinkAccent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

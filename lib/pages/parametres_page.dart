import 'package:flutter/material.dart';

class ParametresPage extends StatelessWidget {
  const ParametresPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Fond dégradé identique à la home
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF50057), Color(0xFFFF8A00)], // Rose → Orange
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Titre
              Center(
                child: Text(
                  "Paramètres",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Section Profil
              _buildSectionTitle("Mon compte"),
              _buildSettingTile(Icons.person, "Mon Profil"),
              _buildSettingTile(
                Icons.favorite,
                "Matchs",
                trailing: _buildBadge("7"),
              ),
              _buildSettingTile(
                Icons.message,
                "Messages",
                trailing: Text("On", style: TextStyle(color: Colors.white)),
              ),
              _buildSettingTile(
                Icons.notifications,
                "Notifications",
                trailing: _buildBadge("14"),
              ),

              const SizedBox(height: 24),

              _buildSectionTitle("Autres"),
              _buildSettingTile(Icons.card_membership, "Mon abonnement"),
              _buildSettingTile(Icons.article, "Conditions d'utilisation"),

              const SizedBox(height: 24),

              _buildSettingTile(Icons.logout, "Déconnexion"),
              _buildSettingTile(
                Icons.delete_forever,
                "Supprimer mon compte",
                textColor: Colors.redAccent,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 16),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white70,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildSettingTile(
    IconData icon,
    String title, {
    Widget? trailing,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        title,
        style: TextStyle(color: textColor ?? Colors.white, fontSize: 16),
      ),
      trailing: trailing,
      onTap: () {},
    );
  }

  Widget _buildBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.pink, fontWeight: FontWeight.bold),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:swipe_cards/swipe_cards.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/conversations_page.dart';
import 'pages/parametres_clairs_page.dart';
import 'services/api_service.dart';
import 'services/auth_service.dart';
import 'package:lottie/lottie.dart';
import 'widget/KonekteBottomBar.dart';
import 'utils/constants.dart';


class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const SwipePage(),
    const ConversationsPage(),
    const ParametresClairsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: KonekteBottomBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
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
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProfilsFromAPI();
  }

  Future<void> _fetchProfilsFromAPI() async {
    // Simulating fetching profiles
    await Future.delayed(const Duration(seconds: 1));
    // In a real app, you would fetch profiles from your API here
    // For now, we just stop loading
    setState(() {
      _isLoading = false;
      // Initialize MatchEngine even if empty
      _matchEngine = MatchEngine(swipeItems: _swipeItems);
    });
  }

  void _showMatchAnimation(BuildContext context, Map<String, dynamic> matchedProfile) {
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
                    Navigator.of(context).pop();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Konekte'),
        backgroundColor: Colors.pink,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _swipeItems.isEmpty
              ? const Center(child: Text("Plus de profils à swiper"))
              : SwipeCards(
                  matchEngine: _matchEngine,
                  itemBuilder: (BuildContext context, int index) {
                    var profil = profils[index];
                    return Card(
                      child: Center(
                        child: Text(profil['nom'] ?? 'N/A'),
                      ),
                    );
                  },
                  onStackFinished: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Plus de profils !')),
                    );
                  },
                ),
    );
  }
}

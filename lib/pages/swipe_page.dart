import 'package:flutter/material.dart';
import 'package:swipe_cards/swipe_cards.dart';
import 'package:lottie/lottie.dart';
import '../services/api_service.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class SwipePage extends StatefulWidget {
  const SwipePage({super.key});

  @override
  State<SwipePage> createState() => _SwipePageState();
}

class _SwipePageState extends State<SwipePage> {
  final ApiService _apiService = ApiService();
  late MatchEngine _matchEngine;
  List<SwipeItem> _swipeItems = [];
  bool _isLoading = true;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    // It's better to get the user ID via a provider if available
    // For now, let's assume it's fetched somehow.
    _fetchProfilsFromAPI();
  }

  Future<void> _fetchProfilsFromAPI() async {
    try {
      final profils = await _apiService.fetchProfils();
      _swipeItems = profils.map((profil) {
        return SwipeItem(
          content: profil,
          likeAction: () => _onSwipe("like", profil['id']),
          nopeAction: () => _onSwipe("dislike", profil['id']),
          superlikeAction: () => _onSwipe("superlike", profil['id']),
        );
      }).toList();

      setState(() {
        _matchEngine = MatchEngine(swipeItems: _swipeItems);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      // Handle error, maybe show a message
    }
  }

  void _onSwipe(String action, int profilId) async {
    // You need to get the current user's ID here, perhaps from AuthProvider
    // final userId = Provider.of<AuthProvider>(context, listen: false).userId;
    final userId = "1"; // Placeholder
    final isMatch = await _apiService.sendInteraction(userId, profilId, action);
    if (isMatch) {
      // Find the profile to show the match animation
      final matchedProfile = _swipeItems.firstWhere((item) => item.content['id'] == profilId).content;
      _showMatchAnimation(context, matchedProfile);
    }
  }

  void _showMatchAnimation(BuildContext context, Map<String, dynamic> matchedProfile) {
     showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset('assets/match_animation.json', width: 200, height: 200, repeat: false),
            Text("C'est un match avec ${matchedProfile['nom']}!", style: const TextStyle(color: Colors.white, fontSize: 20)),
          ],
        ),
      ),
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
              ? const Center(child: Text("Plus de profils à swiper pour le moment."))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SwipeCards(
                    matchEngine: _matchEngine,
                    itemBuilder: (BuildContext context, int index) {
                      final profil = _swipeItems[index].content;
                      return Card(
                        elevation: 8,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        child: Column(
                          children: [
                            Expanded(
                              child: Image.network(
                                profil['image'] ?? 'https://via.placeholder.com/400',
                                fit: BoxFit.cover,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  Text("${profil['nom']}, ${profil['age']}", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                                  Text(profil['description'] ?? ''),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    onStackFinished: () {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("Stack Finished"),
                        duration: Duration(milliseconds: 500),
                      ));
                    },
                  ),
                ),
    );
  }
}

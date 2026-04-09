import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<LiveScore> listOfScore = [];
  final FirebaseFirestore db = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    getLiveScoresData();
  }

  Future<void> getLiveScoresData() async {
    final snapshots = await db.collection("football").get();

    listOfScore.clear();

    for (var doc in snapshots.docs) {
      final data = doc.data();

      listOfScore.add(
        LiveScore(
          id: doc.id,
          team1_name: data["team1"],
          team2_name: data["team2"],
          team1_score: data["team1_score"],
          team2_score: data["team2_score"],
          is_running: data["is_running"],
          winner: data["winner"],
        ),
      );
    }

    setState(() {});
  }

  Future<void> handleSignOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      Navigator.pushReplacementNamed(context, "/login");
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text("Live Scores"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => handleSignOut(context),
          ),
        ],
      ),

      extendBodyBehindAppBar: true,

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple, Colors.deepOrange],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),

        child: Column(
          children: [
            const SizedBox(height: 100),

            Text(
              "Welcome 👋",
              style: TextStyle(
                fontSize: 24,
                color: Colors.white.withOpacity(0.9),
                fontWeight: FontWeight.bold,
              ),
            ),

            Text(
              user?.email ?? "User",
              style: const TextStyle(color: Colors.white70),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: ListView.builder(
                itemCount: listOfScore.length,
                itemBuilder: (context, index) {
                  final score = listOfScore[index];

                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),

                        title: Text(
                          "${score.team1_name} vs ${score.team2_name}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),

                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            "${score.team1_score}  :  ${score.team2_score}",
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 18,
                            ),
                          ),
                        ),

                        trailing: score.is_running
                            ? Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  "LIVE",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            : Text(
                                score.winner,
                                style: const TextStyle(
                                  color: Colors.greenAccent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LiveScore {
  final String id;
  final String team1_name;
  final String team2_name;
  final int team1_score;
  final int team2_score;
  final bool is_running;
  final String winner;

  LiveScore({
    required this.id,
    required this.team1_name,
    required this.team2_name,
    required this.team1_score,
    required this.team2_score,
    required this.is_running,
    required this.winner,
  });
}
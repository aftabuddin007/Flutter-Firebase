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

      LiveScore liveScore = LiveScore(
        id: doc.id,
        team1_name: data["team1"],
        team2_name: data["team2"],
        team1_score: data["team1_score"],
        team2_score: data["team2_score"],
        is_running: data["is_running"],
        winner: data["winner"],
      );

      listOfScore.add(liveScore);
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
      backgroundColor: Colors.deepOrangeAccent,
      appBar: AppBar(
        title: const Text("Home"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => handleSignOut(context),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Text(
            "Welcome, ${user?.email ?? 'User'}!",
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 20),

          Expanded(
            child: ListView.builder(
              itemCount: listOfScore.length,
              itemBuilder: (context, index) {
                final score = listOfScore[index];

                return ListTile(
                  title: Text("${score.team1_name} vs ${score.team2_name}"),
                  subtitle: Text("${score.team1_score} - ${score.team2_score}"),
                  trailing: Text(score.is_running ? "Live" : score.winner),
                );
              },
            ),
          ),
        ],
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

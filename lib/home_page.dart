import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'history_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? currentJoke;
  Timer? jokeTimer;

  @override
  void initState() {
    super.initState();
    _fetchJoke();
    jokeTimer = Timer.periodic(const Duration(days: 1), (timer) {
      _fetchJoke();
    });
  }

  @override
  void dispose() {
    jokeTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchJoke() async {
    final url = Uri.parse('https://v2.jokeapi.dev/joke/Any?lang=fr&safe-mode');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      String? joke;
      if (data['type'] == 'single') {
        joke = data['joke'];
      } else if (data['type'] == 'twopart') {
        joke = '${data['setup']} - ${data['delivery']}';
      }

      if (joke != null) {
        setState(() => currentJoke = joke);
        _saveJokeToHistory(joke);
      }
    } else {
      setState(() => currentJoke = 'Failed to load joke');
    }
  }

  Future<void> _saveJokeToHistory(String joke) async {
    final firestore = FirebaseFirestore.instance;
    await firestore.collection('jokes').add({
      'joke': joke,
      'viewedAt': DateTime.now(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Joke'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HistoryPage()),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade100, Colors.blue.shade300],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: currentJoke != null
              ? Card(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      currentJoke!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                )
              : const CircularProgressIndicator(),
        ),
      ),
    );
  }
}

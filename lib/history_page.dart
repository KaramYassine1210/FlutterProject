import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final firestore = FirebaseFirestore.instance;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Viewed Jokes'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade100, Colors.green.shade300],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: firestore
              .collection('jokes')
              .orderBy('viewedAt', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text(
                  'No jokes viewed yet.',
                  style: TextStyle(fontSize: 18),
                ),
              );
            }

            final jokes = snapshot.data!.docs;
            return ListView.builder(
              itemCount: jokes.length,
              itemBuilder: (context, index) {
                final joke = jokes[index]['joke'];
                final viewedAt = jokes[index]['viewedAt'].toDate();
                return Card(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 15, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ListTile(
                    leading: const Icon(
                      Icons.emoji_emotions,
                      color: Colors.yellow,
                    ),
                    title: Text(
                      joke,
                      style: const TextStyle(fontSize: 16),
                    ),
                    subtitle: Text(
                      'Viewed on: ${viewedAt.toString()}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

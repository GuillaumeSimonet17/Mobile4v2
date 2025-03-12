import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firestore.dart';
import 'package:intl/intl.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, required this.title});

  final String title;
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  final TextEditingController moodController = TextEditingController();
  final FirestoreService firestoreService = FirestoreService();

  void openEntryBox({String? docId, String? title, String? content, String? mood}) {
    titleController.text = title ?? '';
    contentController.text = content ?? '';
    moodController.text = mood ?? '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(docId == null ? "Create New Entry" : "Edit Entry"),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: contentController,
              decoration: InputDecoration(labelText: 'Content'),
              maxLines: 5,
            ),
            TextField(
              controller: moodController,
              decoration: InputDecoration(labelText: 'Mood of the Day'),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              if (docId == null) {
                firestoreService.addEntry(
                  titleController.text,
                  contentController.text,
                  moodController.text,
                );
              } else {
                firestoreService.updateEntry(
                  docId,
                  titleController.text,
                  contentController.text,
                  moodController.text,
                );
              }
              titleController.clear();
              contentController.clear();
              moodController.clear();
              Navigator.pop(context);
            },
            child: Text(docId == null ? "Add" : "Update"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Diary'),
        actions: [
          IconButton(
            onPressed: () async {
              User? user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                FirebaseAuth.instance.signOut();
                Navigator.pop(context); // Retourner à la page de connexion
              }
            },
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => openEntryBox(),
        tooltip: 'Add New Entry',
        child: Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestoreService.getEntriesStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No entries found.'));
          }

          var entriesList = snapshot.data!.docs;
          return ListView.builder(
            itemCount: entriesList.length,
            itemBuilder: (context, index) {
              DocumentSnapshot document = entriesList[index];
              Map<String, dynamic> data = document.data() as Map<String, dynamic>;
              String title = data['title'];
              String content = data['content'];
              String mood = data['mood'];
              String docId = document.id;

              return ListTile(
                title: Text(title),
                subtitle: Text(mood),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () => openEntryBox(docId: docId, title: title, content: content, mood: mood),
                      icon: Icon(Icons.edit),
                    ),
                    IconButton(
                      onPressed: () => firestoreService.deleteEntry(docId),
                      icon: Icon(Icons.delete),
                    ),
                  ],
                ),
                onTap: () {
                  String formattedDate = DateFormat('yyyy-MM-dd – kk:mm').format(data['timestamp'].toDate());

                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(title),
                      content: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Date: ${formattedDate}'),
                          SizedBox(height: 8),
                          Text('Content: $content'),
                          SizedBox(height: 8),
                          Text('Mood: $mood'),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text('Close'),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

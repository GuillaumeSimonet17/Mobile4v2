import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firestore.dart';
import 'package:intl/intl.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, required this.title, required this.email});

  final String title;
  final String email;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  final TextEditingController moodController = TextEditingController();
  final FirestoreService firestoreService = FirestoreService();

  List<String> moods = ['Happy', 'Sad', 'Excited', 'Angry', 'Relaxed'];

  void openEntryBox({
    String? docId,
    String? title,
    String? content,
    String? mood,
  }) {
    titleController.text = title ?? '';
    contentController.text = content ?? '';
    moodController.text = mood ?? 'Happy';

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
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
                DropdownButtonFormField<String>(
                  value: moodController.text,
                  hint: Text("Select a Mood"),
                  items:
                      moods.map((String mood) {
                        return DropdownMenuItem<String>(
                          value: mood,
                          child: Text(mood),
                        );
                      }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      moodController.text = newValue ?? '';
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Mood',
                    border: OutlineInputBorder(),
                  ),
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
        backgroundColor: Colors.white,
        title: Text("${FirebaseAuth.instance.currentUser?.displayName}"),
        actions: [
          IconButton(
            onPressed: () async {
              User? user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                FirebaseAuth.instance.signOut();
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
      body: Column(
        children: [
          // Row(
          //   children: [
          //     Padding(
          //       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          //       child: Text(
          //         "${FirebaseAuth.instance.currentUser?.displayName}",
          //         style: TextStyle(fontSize: 24),
          //       ),
          //     ),
          //   ],
          // ),
          StreamBuilder<QuerySnapshot>(
            stream: firestoreService.getEntriesStream(widget.email),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                print(snapshot.error);
                return Center(child: Text("Error: ${snapshot.error}"));
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(child: Text('No entries found.'));
              }

              var lenOfEntries = snapshot.data!.docs.length;
              var entriesList = snapshot.data!.docs;
              return Column(
                children: [
                  SizedBox(
                    height: 50,
                    child: Text(
                      'Number of entries: ${lenOfEntries.toString()}',
                    ),
                  ),
                  Text('Your last 2 entries'),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: entriesList.take(2).length,
                    itemBuilder: (context, index) {
                      DocumentSnapshot document =
                          entriesList.take(2).toList()[index];
                      Map<String, dynamic> data =
                          document.data() as Map<String, dynamic>;
                      String title = data['title'];
                      String content = data['content'];
                      String mood = data['mood'];
                      String docId = document.id;

                      return ListTile(
                        title: Row(
                          children: [
                            Text(title, style: TextStyle(fontSize: 20)),
                            Text(' - '),
                            Text(mood, style: TextStyle(fontSize: 20)),
                          ],
                        ),
                        subtitle: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${DateFormat('dd/MM/yyyy').format(data['timestamp'].toDate())}",
                              style: TextStyle(color: Colors.grey[500]),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed:
                                  () => openEntryBox(
                                    docId: docId,
                                    title: title,
                                    content: content,
                                    mood: mood,
                                  ),
                              icon: Icon(Icons.edit),
                            ),
                            IconButton(
                              onPressed:
                                  () => firestoreService.deleteEntry(docId),
                              icon: Icon(Icons.delete),
                            ),
                          ],
                        ),
                        onTap: () {
                          String formattedDate = DateFormat(
                            'yyyy-MM-dd – kk:mm',
                          ).format(data['timestamp'].toDate());

                          showDialog(
                            context: context,
                            builder:
                                (context) => AlertDialog(
                                  title: Text(title),
                                  content: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                  ),
                ],
              );
            },
          ),
          StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance
                    .collection('diary_entries')
                    .where(
                      'email',
                      isEqualTo: FirebaseAuth.instance.currentUser?.email,
                    )
                    .snapshots(),
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

              // Récupère les humeurs de tous les documents
              var moodsList =
                  snapshot.data!.docs
                      .map((document) => document['mood'] as String)
                      .toList();

              // Calcul des pourcentages pour chaque humeur
              Map<String, int> moodCount = {};
              for (var mood in moodsList) {
                moodCount[mood] = (moodCount[mood] ?? 0) + 1;
              }

              double totalCount = moodsList.length.toDouble();
              Map<String, double> moodPercentages = {};
              moodCount.forEach((mood, count) {
                moodPercentages[mood] = (count / totalCount) * 100;
              });

              Map<String, Color> moodColors = {
                'Happy': Colors.green,
                'Sad': Colors.blue.shade900,
                'Excited': Colors.orange,
                'Angry': Colors.red,
                'Relaxed': Colors.blue.shade300,
              };

              return Column(
                children: [
                  Text('Your feel for your ${moodsList.length} entries'),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: moodPercentages.length,
                    itemBuilder: (context, index) {
                      String mood = moodPercentages.keys.elementAt(index);
                      double percentage = moodPercentages[mood]!;
                      Color moodColor = moodColors[mood] ?? Colors.black;

                      return ListTile(
                        title: Text(
                          "$mood - ${percentage.toStringAsFixed(2)}%",
                          style: TextStyle(color: moodColor),
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

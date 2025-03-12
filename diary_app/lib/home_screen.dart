import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firestore.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  final TextEditingController textEditingController = TextEditingController();
  final FirestoreService firestoreService = FirestoreService();


  void openNoteBox() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: TextField(
          controller: textEditingController,
        ),
        actions: [
          ElevatedButton(
              onPressed: () {
                firestoreService.addNote(textEditingController.text);
                textEditingController.clear();
                Navigator.pop(context);
              },
              child: Text("Add"))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(onPressed: () async {
            User? user = FirebaseAuth.instance.currentUser;
            if (user != null) {
              FirebaseAuth.instance.signOut();
            }
          }, icon: Icon(Icons.power_settings_new))
        ],
      ),
      // Ajout du FloatingActionButton
      floatingActionButton: FloatingActionButton(
        onPressed: openNoteBox,  // Appelle la méthode addNote lorsqu'il est pressé
        tooltip: 'Add Note',  // Le tooltip qui s'affiche lorsqu'on maintient sur le bouton
        child: Icon(Icons.add),  // L'icône du bouton flottant
      ),

      body: StreamBuilder<QuerySnapshot>(
          stream: firestoreService.getNotesStream(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List notesList = snapshot.data!.docs;
              return ListView.builder(
                itemCount: notesList.length,
                itemBuilder: (context, index) {
                DocumentSnapshot document = notesList[index];
                String docIds = document.id;

                Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                String noteText = data['note'];
                
                return ListTile(
                  title: Text(noteText),
                );
              },);
            } else {
              return const Text('No notes');
            }
          }
      )
    );
  }
}
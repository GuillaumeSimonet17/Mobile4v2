import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {

  // Référence de la collection "diary_entries"
  final CollectionReference diaryEntries = FirebaseFirestore.instance.collection('diary_entries');

  // CREATE
  Future<void> addEntry(String title, String content, String mood) {
    // Récupérer l'email de l'utilisateur actuellement connecté
    String? email = FirebaseAuth.instance.currentUser?.email;

    // Ajouter une nouvelle entrée avec les champs nécessaires
    return diaryEntries.add({
      'title': title,
      'content': content,
      'mood': mood,
      'timestamp': Timestamp.now(),
      'email': email,
    });
  }

  // STREAM pour obtenir les entrées en temps réel
  Stream<QuerySnapshot> getEntriesStream() {
    return diaryEntries.orderBy('timestamp', descending: true).snapshots();
  }

  // UPDATE
  Future<void> updateEntry(String docId, String title, String content, String mood) {
    return diaryEntries.doc(docId).update({
      'title': title,
      'content': content,
      'mood': mood,
      'timestamp': Timestamp.now(),
    });
  }

  // DELETE
  Future<void> deleteEntry(String docId) {
    return diaryEntries.doc(docId).delete();
  }
}

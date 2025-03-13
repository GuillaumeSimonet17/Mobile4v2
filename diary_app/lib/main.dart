import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'login_screen.dart';
import 'home_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(options: FirebaseOptions(
        apiKey: "AIzaSyBnXXUqU61Y4suOzXgxOd5XHNOshg_5JMM",
        authDomain: "diary-app-1e5d2.firebaseapp.com",
        projectId: "diary-app-1e5d2",
        storageBucket: "diary-app-1e5d2.firebasestorage.app",
        messagingSenderId: "1042215891505",
        appId: "1:1042215891505:web:aa7b31a5c9a5a6a2c15b10",
        measurementId: "G-YSCZR51P5X"));
  } else {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
      ),
      home: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasError) {
              return Text(snapshot.error.toString());
            }
            if (snapshot.connectionState == ConnectionState.active) {
              if (snapshot.data == null) {
                return LoginPage();
              }
              else {
                return ProfilePage(title: FirebaseAuth.instance.currentUser!.displayName!, email: FirebaseAuth.instance.currentUser!.email!);
              }
            }
            return Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
      )
      ,
    );
  }
}


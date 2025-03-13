import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_button/sign_button.dart';
import 'package:flutter/foundation.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});


  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(
            'Diary App',
            style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Container(
        height: 200,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Sign In', style: TextStyle(fontSize: 24)),
                  ),
                  SizedBox(height: 20),
                  SignInButton(
                    buttonType: ButtonType.google,
                    width: MediaQuery.of(context).size.width,
                    buttonSize: ButtonSize.large,
                    onPressed: () async {
                      signInWithGoogle();
                    },
                  ),
                  SizedBox(height: 12),
                  SignInButton(
                    buttonType: ButtonType.github,
                    buttonSize: ButtonSize.large,
                    width: MediaQuery.of(context).size.width,
                    onPressed: () async {
                      try {
                        await signInWithGithub();
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('GitHub Sign-In Failed: $e'),
                            ),
                          );
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  signInWithGoogle() async {
    try {
      GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        print("Google sign-in was cancelled.");
        return;
      }

      GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(credential);
      print(userCredential.user?.displayName);
    } catch (e) {
      print("Error signing in with Google: $e");
    } finally {
      print("Sing in with Google successful");
    }
  }

  signInWithGithub() async {
    try {
      GithubAuthProvider githubProvider = GithubAuthProvider();

      if (kIsWeb) {
          await FirebaseAuth.instance.signInWithPopup(githubProvider);
      } else {
        UserCredential userCredential =
        await FirebaseAuth.instance.signInWithProvider(githubProvider);
        print(userCredential.user?.displayName);
      }

    } catch (e) {
      print("Error signing in with GitHub: $e");
    } finally {
      print("Sing in with GitHub successful");
    }
  }
}

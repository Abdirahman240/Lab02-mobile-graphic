import 'package:flutter/material.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final EncryptedSharedPreferences encryptedPrefs =
  EncryptedSharedPreferences();

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadSavedLogin();
  }

  Future<void> loadSavedLogin() async {
    String username = await encryptedPrefs.getString("username");
    String password = await encryptedPrefs.getString("password");

    if (username.isNotEmpty && password.isNotEmpty) {
      usernameController.text = username;
      passwordController.text = password;

      print("LOADED FROM SHARED PREFERENCES");

      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Previous login name and password have been loaded",
            ),
          ),
        );
      });
    }
  }

  void showSaveLoginDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Save Login?"),
          content: const Text(
            "Would you like to save your username and password for next time?",
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await encryptedPrefs.clear();

                if (mounted) {
                  Navigator.pop(context);
                }
              },
              child: const Text("No"),
            ),
            TextButton(
              onPressed: () async {
                await encryptedPrefs.setString(
                  "username",
                  usernameController.text,
                );

                await encryptedPrefs.setString(
                  "password",
                  passwordController.text,
                );

                if (mounted) {
                  Navigator.pop(context);
                }
              },
              child: const Text("Yes"),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login Page"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: SizedBox(
            width: 400,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: usernameController,
                  decoration: const InputDecoration(
                    labelText: "Username",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Password",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: showSaveLoginDialog,
                  child: const Text("Login"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
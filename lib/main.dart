import 'package:flutter/material.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';

import 'pages/list_page.dart';
import 'repository/profile_repository.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: ListPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final EncryptedSharedPreferences encryptedSharedPreferences =
  EncryptedSharedPreferences();

  final ProfileRepository repository = ProfileRepository();

  String imageSource = "images/question-mark.jpg";

  @override
  void initState() {
    super.initState();
    loadSavedLogin();
    repository.loadData();
  }

  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> loadSavedLogin() async {
    String savedLogin =
    await encryptedSharedPreferences.getString('loginName');

    String savedPassword =
    await encryptedSharedPreferences.getString('password');

    if (savedLogin.isNotEmpty && savedPassword.isNotEmpty) {
      setState(() {
        _loginController.text = savedLogin;
        _passwordController.text = savedPassword;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Previous login name and password loaded'),
          ),
        );
      });
    }
  }

  Future<void> saveLoginInfo() async {
    await encryptedSharedPreferences.setString(
      'loginName',
      _loginController.text,
    );

    await encryptedSharedPreferences.setString(
      'password',
      _passwordController.text,
    );
  }

  Future<void> clearSavedLoginInfo() async {
    await encryptedSharedPreferences.clear();

    _loginController.clear();
    _passwordController.clear();
  }

  Future<void> showSaveLoginDialog() async {
    bool? save = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Save Login?'),
          content: const Text(
            'Would you like to save your login name and password for next time?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('No'),
            ),
          ],
        );
      },
    );

    if (save == true) {
      await saveLoginInfo();
    } else if (save == false) {
      await clearSavedLoginInfo();
    }
  }

  Future<void> loginButtonClicked() async {
    String password = _passwordController.text;

    setState(() {
      if (password == "ASDF") {
        imageSource = "images/light-bulb.jpg";
      } else {
        imageSource = "images/stop-sign.jpg";
      }
    });

    await showSaveLoginDialog();

    if (!mounted) return;

    if (password == "ASDF") {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Welcome Back ${_loginController.text}"),
        ),
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ListPage(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _loginController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Login name",
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Password",
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: loginButtonClicked,
                child: const Text("Login"),
              ),
            ),
            Semantics(
              label: "Login result image",
              child: Image.asset(
                imageSource,
                width: 300,
                height: 300,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
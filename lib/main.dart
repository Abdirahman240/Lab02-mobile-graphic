import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final TextEditingController loginController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String imageSource = "images/question-mark.jpg";
  String imageDescription = "Question Mark";

  void checkPassword() {
    setState(() {
      if (passwordController.text == "ASDF") {
        imageSource = "images/light-bulb.jpg";
        imageDescription = "Light Bulb";
      } else {
        imageSource = "images/stop-sign.jpg";
        imageDescription = "Stop Sign";
      }
    });
  }

  @override
  void dispose() {
    loginController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text("Login Lab")),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: TextField(
                  controller: loginController,
                  decoration: const InputDecoration(
                    labelText: "Login Name",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Password",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: ElevatedButton(
                  onPressed: checkPassword,
                  child: const Text("Login"),
                ),
              ),
              Semantics(
                label: imageDescription,
                child: Image.asset(
                  imageSource,
                  width: 300,
                  height: 300,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
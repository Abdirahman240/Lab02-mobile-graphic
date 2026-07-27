import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../repository/profile_repository.dart';

class ProfilePage extends StatefulWidget {
  final String loginName;
  final ProfileRepository repository;

  const ProfilePage({
    super.key,
    required this.loginName,
    required this.repository,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController phoneController;
  late TextEditingController emailController;

  @override
  void initState() {
    super.initState();

    firstNameController = TextEditingController(
      text: widget.repository.firstName,
    );

    lastNameController = TextEditingController(
      text: widget.repository.lastName,
    );

    phoneController = TextEditingController(
      text: widget.repository.phoneNumber,
    );

    emailController = TextEditingController(
      text: widget.repository.emailAddress,
    );

    firstNameController.addListener(saveProfile);
    lastNameController.addListener(saveProfile);
    phoneController.addListener(saveProfile);
    emailController.addListener(saveProfile);
  }

  Future<void> saveProfile() async {
    widget.repository.firstName = firstNameController.text;
    widget.repository.lastName = lastNameController.text;
    widget.repository.phoneNumber = phoneController.text;
    widget.repository.emailAddress = emailController.text;

    await widget.repository.saveData();
  }

  Future<void> openUrl(String urlText) async {
    final Uri url = Uri.parse(urlText);

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      if (!mounted) return;

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("URL Not Supported"),
            content: Text("$urlText is not supported on this device."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  void dispose() {
    firstNameController.removeListener(saveProfile);
    lastNameController.removeListener(saveProfile);
    phoneController.removeListener(saveProfile);
    emailController.removeListener(saveProfile);

    firstNameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();
    emailController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile Page"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              "Welcome Back ${widget.loginName}",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 24),

            TextField(
              controller: firstNameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "First Name",
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: lastNameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Last Name",
              ),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Flexible(
                  child: TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Phone Number",
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    openUrl("tel:${phoneController.text}");
                  },
                  icon: const Icon(Icons.phone),
                ),
                IconButton(
                  onPressed: () {
                    openUrl("sms:${phoneController.text}");
                  },
                  icon: const Icon(Icons.sms),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Flexible(
                  child: TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Email address",
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    openUrl("mailto:${emailController.text}");
                  },
                  icon: const Icon(Icons.mail),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
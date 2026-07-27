import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';

class ProfileRepository {
  final EncryptedSharedPreferences _prefs = EncryptedSharedPreferences();

  String firstName = "";
  String lastName = "";
  String phoneNumber = "";
  String emailAddress = "";

  Future<void> loadData() async {
    firstName = await _prefs.getString("firstName");
    lastName = await _prefs.getString("lastName");
    phoneNumber = await _prefs.getString("phoneNumber");
    emailAddress = await _prefs.getString("emailAddress");
  }

  Future<void> saveData() async {
    await _prefs.setString("firstName", firstName);
    await _prefs.setString("lastName", lastName);
    await _prefs.setString("phoneNumber", phoneNumber);
    await _prefs.setString("emailAddress", emailAddress);
  }
}
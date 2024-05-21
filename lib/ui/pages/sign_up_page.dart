import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'get_started_page.dart'; // Import halaman getstarted.dart

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    // Membersihkan controller saat widget dihapus
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                  'assets/image_get_started.png',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: inputSection(),
          ),
        ],
      ),
    );
  }

  Widget inputSection() {
    return Container(
      width: 300,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: EdgeInsets.only(bottom: 5),
            width: 300,
            height: 100,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/injourney_colour.png'),
              ),
            ),
          ),
          Text(
            'Please Sign In',
            style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey),
          ),
          SizedBox(height: 20),
          TextFormField(
            controller: usernameController,
            decoration: InputDecoration(
              hintText: 'Username',
              filled: true,
              fillColor: Colors.grey[200],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          SizedBox(height: 20),
          TextFormField(
            controller: passwordController,
            obscureText: true,
            decoration: InputDecoration(
              hintText: 'Password',
              filled: true,
              fillColor: Colors.grey[200],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              String username = usernameController.text;
              String password = passwordController.text;
              if (username.isNotEmpty && password.isNotEmpty) {
                String? success = await authenticateUser(username, password);
                if (success != null) {
                  print('Navigating to GetStartedPage');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Login Successful'),
                    ),
                  );
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => GetStartedPage()));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          Text('Login failed. Please check your credentials.'),
                    ),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Please enter both username and password.'),
                  ),
                );
              }
            },
            child: Text('Sign In'),
          ),
        ],
      ),
    );
  }

  Future<String?> authenticateUser(String username, String password) async {
    String apiUrl = 'https://dashapigcp.travelin.co.id/external/login';

    String basicAuth = 'Basic ' +
        base64Encode(
            utf8.encode('external-mobile-apps:FVNUxQlNhcUBhsMsqBez9yyN'));
    String devid = 'mobile-external'; // Hardcode nilai devid

    try {
      var response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': basicAuth,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'username': username,
          'password': password,
          'devid': devid,
        }),
      );

      // Cetak respon ke konsol
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      print('Username: $username');
      print('Password: $password');
      print('Devid: $devid');

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['code'] == 200 && data['data'].containsKey('token')) {
          // Jika berhasil masuk, kembalikan token
          String token = data['data']['token'];

          // Simpan token dan waktu kedaluwarsa
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', token);
          await prefs.setString('token_expiry',
              DateTime.now().add(Duration(hours: 1)).toIso8601String());

          String guid = hashGuid(token, devid);
          return guid;
        } else {
          // Tampilkan pesan kesalahan dari server
          String info = data['info'];
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(info),
            ),
          );
          return null;
        }
      } else {
        // Jika respons tidak berhasil, kembalikan null
        return null;
      }
    } catch (e) {
      // Tangani kesalahan jika terjadi
      print('Error: $e');
      return null;
    }
  }

  String hashGuid(String token, String devid) {
    // Gabungkan token dengan devid
    String combinedString = devid + '-' + token; // Tambahkan tanda penghubung
    // Hash menggunakan SHA-256
    var bytes = utf8.encode(combinedString);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }
}

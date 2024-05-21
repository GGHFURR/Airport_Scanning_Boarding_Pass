import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthService {
  final String apiUrl =
      'https://dashapigcp.travelin.co.id/external/validate/pnr'; //endpoint API

  Future<Map<String, dynamic>> sendData(
      String token, String guid, String rawpnr) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'guid': guid,
          'rawpnr': rawpnr,
        }),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': jsonDecode(response.body)};
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'message': 'Unauthorized. Check your token and endpoint.'
        };
      } else {
        return {
          'success': false,
          'message': 'Failed with status code: ${response.statusCode}'
        };
      }
    } catch (e) {
      print("Error: $e");
      return {'success': false, 'message': e.toString()};
    }
  }
}

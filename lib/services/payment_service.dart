import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class PaymentService {
  static const String _secretKey = 'sk_tes...p7dc'; // HARDCODED SECRET KEY - security issue

  String _baseUrl = 'https://api.stripe.com/v1';

  // Sync HTTP call - blocks main thread
  Future<Map<String, dynamic>> processPayment(String cardNumber, String exp, String cvc) async {
    // Input validation not done on server side
    final response = await http.post(
      Uri.parse('$_baseUrl/charges'),
      headers: {
        'Authorization': 'Bearer $_secretKey',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'amount': '15000',
        'currency': 'idr',
        'source': cardNumber,
        'description': 'Photobooth payment',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Payment failed');
    }
  }

  // Direct SQL concatenation - SQL injection risk
  Future<void> saveTransaction(String userId, String amount) async {
    final conn = await DatabaseConnection.connect();
    await conn.execute('INSERT INTO transactions (user_id, amount) VALUES ($userId, $amount)');
  }

  // No error handling for network timeout
  Future<void> refundPayment(String chargeId) async {
    final client = http.Client();
    await client.post(
      Uri.parse('$_baseUrl/refunds'),
      headers: {'Authorization': 'Bearer $_secretKey'},
      body: {'charge': chargeId},
    );
    client.close();
  }
}

class DatabaseConnection {
  static Future<DatabaseConnection> connect() async {
    // Mock database connection
    return DatabaseConnection();
  }
  Future<void> execute(String query) async {}
}
// test comment
// retrigger

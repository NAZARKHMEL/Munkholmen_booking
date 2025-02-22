import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MaterialApp(
    theme: ThemeData(primarySwatch: Colors.blue), 
    home: BookingForm(),
    debugShowCheckedModeBanner: false,
  ));
}

class BookingForm extends StatefulWidget {
  @override
  _BookingFormState createState() => _BookingFormState();
}

class _BookingFormState extends State<BookingForm> {
  final TextEditingController _roomController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();
  bool _isLoading = false;

  // Метод для проверки пин-кода
  Future<void> _checkPinCode() async {
    final roomId = _roomController.text;
    final pinCode = _pinController.text;

    // Проверка, что данные не пустые
    if (roomId.isEmpty || pinCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter both room number and PIN code.')),
      );
      return;
    }

    setState(() {
      _isLoading = true; // Показываем индикатор загрузки
    });

    try {
      final response = await http.post(
        Uri.parse('https://d52b-2001-4650-24fd-0-497c-c8a9-476d-232b.ngrok-free.app/check-pin'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'room_id': roomId, 'pin_code': pinCode}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Access granted!')),
        );
      } else if (response.statusCode == 401) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid PIN code')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Something went wrong. Please try again later.')),
        );
      }
    } catch (e) {
      // Если произошла ошибка с сервером или сетью
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Network error. Please try again later.')),
      );
    } finally {
      setState(() {
        _isLoading = false; // Скрываем индикатор загрузки
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Enter PIN Code')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _roomController,
              decoration: InputDecoration(labelText: 'Room Number'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _pinController,
              decoration: InputDecoration(labelText: 'PIN Code'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            // Индикатор загрузки
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _checkPinCode,
                    child: Text('Submit'),
                  ),
          ],
        ),
      ),
    );
  }
}

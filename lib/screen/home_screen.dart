import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('앱 이름',
          style: TextStyle(fontWeight: FontWeight.bold)
        )
      ),body : Container()
    );

  }
}
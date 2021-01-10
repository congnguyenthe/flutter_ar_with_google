import 'package:flutter/material.dart';
import 'screens/assets_object.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ArCore Demo'),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            onTap: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => AssetsObject()));
            },
            title: Text("Custom sfb object"),
          ),
        ],
      ),
    );
  }
}

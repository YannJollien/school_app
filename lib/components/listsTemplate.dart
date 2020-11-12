import 'package:flutter/material.dart';

class ListsTemplate extends StatelessWidget {

  final String category;
  final Function delete;

  ListsTemplate({this.category, this.delete});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              category,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18.0, color: Colors.grey[600]),
            ),
            SizedBox(
              height: 6.0,
            ),
            FlatButton.icon(
              onPressed: delete,
              icon: Icon(Icons.delete),
              label: Text("Delete"),
            )
          ],
        ),
      ),
    );
  }
}
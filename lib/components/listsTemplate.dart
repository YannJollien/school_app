import 'package:flutter/material.dart';

class ListsTemplate extends StatelessWidget {

  final String category;
  final Function delete;

  ListsTemplate({this.category, this.delete});

  @override
  Widget build(BuildContext context) {
    return InkWell( //To click on card
      onTap: () {print("Tapped");},
      child: Card(
        margin: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Row(
                children: <Widget>[
                  Text(
                      category
                  ),
                  SizedBox(width: 170.0),
                  IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.edit),
                  ),
                  IconButton(
                    onPressed: delete,
                    icon: Icon(Icons.delete),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
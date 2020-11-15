import 'package:flutter/material.dart';
import 'package:schoolapp/components/listsTemplate.dart';

class Lists extends StatefulWidget {
  @override
  _ListState createState() => _ListState();
}

class _ListState extends State<Lists> {

  Future <String> createAlertDialog(BuildContext context){

    TextEditingController customController = new TextEditingController();

    return showDialog(context: context, builder: (context){
      return AlertDialog(
        title: Text("Category"),
        content: TextField(
          controller: customController,
        ),
        actions: <Widget>[
          MaterialButton(
            elevation: 5.0,
            child: Text("Add"),
            onPressed: () {
              Navigator.of(context).pop(customController.text.toString());
            },
          ),
        ],
      );
    });
  }

  List <String> categories = [
    "Family",
    "Job",
    "School"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[600],
        centerTitle: true,
        title: Text(
            "List",
        ),
      ),
      body: SafeArea(
        child: Container(
          alignment: Alignment.center,
          color: Colors.grey[400],
          child: Padding(
            padding: EdgeInsets.fromLTRB(10.0, 40.0, 10.0, 0),
            child: Column(
              children: categories.map((category) =>
                  ListsTemplate(
                      category: category,
                      delete: () {
                        setState(() {
                          categories.remove(category);
                        });
                      }
                  )).toList(),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          createAlertDialog(context).then((value) => setState(() {
            categories.add(value);
          }));
        },
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ListImportation extends StatefulWidget {
  DocumentSnapshot listDoc;

  ListImportation(DocumentSnapshot doc) {
    this.listDoc = doc;
  }

  @override
  State<StatefulWidget> createState() => new ListImportationState(listDoc);
}

class ListImportationState extends State<ListImportation> {
  ListImportationState(data);

  String _filePath;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('File Picker Example'),
      ),
      body: new Center(
        child: _filePath == null
            ? new Text('No file selected.')
            : new Text('Path' + _filePath),
      ),
      floatingActionButton: new FloatingActionButton(
        onPressed: (){

        },
        tooltip: 'Select file',
        child: new Icon(Icons.sd_storage),
      ),
    );
  }
}
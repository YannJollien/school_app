import 'package:flutter/material.dart';
import 'package:schoolapp/components/lists.dart';


class HomeDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: Column(
          children: <Widget>[
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20.0),
              color: Colors.grey[900],
              child: Center(
                child: Column(
                  children: <Widget>[
                    Container(
                      width: 100,
                      height: 100,
                      margin: EdgeInsets.only(
                        top: 30.0
                      ),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: NetworkImage(
                            ""
                          ),
                          fit: BoxFit.fill
                        ),
                      ),
                    ),
                    Text(
                      "userName",
                      style: TextStyle(
                          fontSize: 22.0, color: Colors.white
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.list),
              title: Text(
                  "List",
                  style: TextStyle(
                  fontSize: 18.0,
                ),
              ),
              onTap: () {
                //Navigator.pushNamed(context, '/list');
                Navigator.of(context).pushNamed("/list");
              },
            ),
            ListTile(
              leading: Icon(Icons.info),
              title: Text(
                "About us",
                style: TextStyle(
                  fontSize: 18.0,
                ),
              ),
              onTap: null,
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text(
                "Settings",
                style: TextStyle(
                  fontSize: 18.0,
                ),
              ),
              onTap: null,
            ),
          ],
        )
    );
  }
}

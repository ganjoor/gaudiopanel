import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gaudiopanel/forms/login.dart';
import 'package:gaudiopanel/services/auth-service.dart';
import 'package:loading_overlay/loading_overlay.dart';

class NarrationsWidget extends StatefulWidget {
  @override
  NarrationWidgetState createState() => NarrationWidgetState();
}

class NarrationWidgetState extends State<NarrationsWidget> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: LoadingOverlay(
      isLoading: _isLoading,
      child: Scaffold(
        appBar: AppBar(
          title: Text('پیشخان خوانشگران گنجور » خوانشها'),
        ),
        body: Builder(
          builder: (context) => Center(
            child: SingleChildScrollView(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                RaisedButton.icon(
                    icon: Icon(Icons.logout),
                    label: Text('خروج'),
                    onPressed: () async {
                      setState(() {
                        _isLoading = true;
                      });

                      await AuthService().logout();

                      setState(() {
                        _isLoading = false;
                      });

                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (context) => LoginForm()));
                    })
              ],
            )),
          ),
        ),
      ),
    ));
  }
}

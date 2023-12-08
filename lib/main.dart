import 'package:flutter/material.dart';
import 'package:gaudiopanel/forms/login.dart';
import 'package:gaudiopanel/forms/main_form.dart';
import 'package:gaudiopanel/services/auth_service.dart';
import 'package:universal_html/html.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

Future<void> main() async {
  Widget initialWidget =
      (await AuthService().isLoggedOn) ? const MainForm() : const LoginForm();
  runApp(GAudioPanelApp(initialWidget: initialWidget));
}

class GAudioPanelApp extends StatefulWidget {
  final Widget? initialWidget;

  const GAudioPanelApp({Key? key, this.initialWidget}) : super(key: key);

  @override
  State<StatefulWidget> createState() => GAudioPanelAppState();
}

class GAudioPanelAppState extends State<GAudioPanelApp> {
  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      // Remove `loading` div
      final loader = document.getElementsByClassName('loading');
      if (loader.isNotEmpty) {
        loader.first.remove();
      }
    }
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'پیشخان خوانشگران گنجور',
        theme: ThemeData(
            // This is the theme of your application.
            //
            // Try running your application with "flutter run". You'll see the
            // application has a blue toolbar. Then, without quitting the app, try
            // changing the primarySwatch below to Colors.green and then invoke
            // "hot reload" (press "r" in the console where you ran "flutter run",
            // or simply save your changes to "hot reload" in a Flutter IDE).
            // Notice that the counter didn't reset back to zero; the application
            // is not restarted.
            primarySwatch: Colors.blue,
            // This makes the visual density adapt to the platform that you run
            // the app on. For desktop platforms, the controls will be smaller and
            // closer together (more dense) than on mobile platforms.
            visualDensity: VisualDensity.adaptivePlatformDensity,
            fontFamily: 'Samim'),
        home: widget.initialWidget,
        builder: (BuildContext context, Widget? child) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: Builder(
              builder: (BuildContext context) {
                return MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaler: const TextScaler.linear(1.0),
                  ),
                  child: child!,
                );
              },
            ),
          );
        });
  }
}

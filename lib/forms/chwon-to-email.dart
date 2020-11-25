import 'package:flutter/material.dart';

class ChownToEmail extends StatefulWidget {
  const ChownToEmail({Key key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _ChownToEmailState();
}

class _ChownToEmailState extends State<ChownToEmail> {
  TextEditingController _emailController = TextEditingController();

  _ChownToEmailState();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FocusTraversalGroup(
        child: Form(
            autovalidateMode: AutovalidateMode.always,
            child: Wrap(children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Directionality(
                    textDirection: TextDirection.ltr,
                    child: TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'پست الکترونیکی',
                        hintText: 'پست الکترونیکی',
                      ),
                    )),
              ),
              Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ButtonBar(
                    alignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        child: Text('تأیید'),
                        onPressed: () {
                          Navigator.of(context).pop(_emailController.text);
                        },
                      ),
                      TextButton(
                        child: Text('انصراف'),
                        onPressed: () {
                          Navigator.of(context).pop(null);
                        },
                      )
                    ],
                  )),
            ])));
  }
}

import 'package:flutter/material.dart';

class ChownToEmail extends StatefulWidget {
  const ChownToEmail({super.key});
  @override
  State<StatefulWidget> createState() => _ChownToEmailState();
}

class _ChownToEmailState extends State<ChownToEmail> {
  final TextEditingController _emailController = TextEditingController();

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
                      decoration: const InputDecoration(
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
                        child: const Text('تأیید'),
                        onPressed: () {
                          Navigator.of(context).pop(_emailController.text);
                        },
                      ),
                      TextButton(
                        child: const Text('انصراف'),
                        onPressed: () {
                          Navigator.of(context).pop(null);
                        },
                      )
                    ],
                  )),
            ])));
  }
}

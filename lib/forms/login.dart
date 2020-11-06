import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gaudiopanel/forms/main-form.dart';
import 'package:gaudiopanel/services/auth-service.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginForm extends StatefulWidget {
  @override
  LoginFormState createState() => LoginFormState();
}

class LoginFormState extends State<LoginForm> {
  bool _isLoading = false;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  String _loginError = '';

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _login() async {
    setState(() {
      _loginError = '';
    });
    if (_formKey.currentState.validate()) {
      setState(() {
        _isLoading = true;
      });
      String loginError =
          await AuthService().login(_email.text, _password.text);
      setState(() {
        _isLoading = false;
        _loginError = loginError;
      });

      if (_loginError.isNotEmpty) {
        _formKey.currentState.validate();
      } else {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => MainForm()));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: LoadingOverlay(
            isLoading: _isLoading,
            child: Form(
              key: _formKey,
              child: Scaffold(
                appBar: AppBar(
                  title: Text('پیشخان خوانشگران گنجور » ورود'),
                ),
                body: Builder(
                  builder: (context) => Center(
                    child: SingleChildScrollView(
                      child: AutofillGroup(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            TextFormField(
                              controller: _email,
                              autofillHints: [AutofillHints.username],
                              textDirection: TextDirection.ltr,
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'پست الکترونیکی وارد نشده است.';
                                }
                                if (_loginError.isNotEmpty) {
                                  return _loginError;
                                }
                                return null;
                              },
                              onFieldSubmitted: (value) => _login(),
                              decoration: InputDecoration(
                                  hintText: 'پست الکترونیکی',
                                  labelText: 'پست الکترونیکی'),
                            ),
                            TextFormField(
                              controller: _password,
                              obscureText: true,
                              autofillHints: [AutofillHints.password],
                              textDirection: TextDirection.ltr,
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'گذرواژه وارد نشده است.';
                                }
                                return null;
                              },
                              onFieldSubmitted: (value) => _login(),
                              decoration: InputDecoration(
                                  hintText: 'گذرواژه', labelText: 'گذرواژه'),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                RaisedButton.icon(
                                  icon: Icon(Icons.login),
                                  label: Text('ورود'),
                                  onPressed: _login,
                                ),
                                RaisedButton.icon(
                                  icon: Icon(Icons.launch),
                                  label: Text('ثبت نام'),
                                  onPressed: () async {
                                    var url =
                                        'https://museum.ganjoor.net/signup';
                                    if (await canLaunch(url)) {
                                      await launch(url);
                                    } else {
                                      throw 'خطا در نمایش نشانی $url';
                                    }
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            )));
  }
}

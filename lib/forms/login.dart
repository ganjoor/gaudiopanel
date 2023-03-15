import 'package:flutter/material.dart';
import 'package:gaudiopanel/forms/main_form.dart';
import 'package:gaudiopanel/forms/signup.dart';
import 'package:gaudiopanel/services/auth_service.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({Key key}) : super(key: key);

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
        if (!mounted) return;
        await Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => const MainForm()));
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
                  title: const Text('پیشخان خوانشگران گنجور » ورود'),
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
                              autofillHints: const [AutofillHints.username],
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
                              decoration: const InputDecoration(
                                  icon: Icon(Icons.mail),
                                  hintText: 'پست الکترونیکی',
                                  labelText: 'پست الکترونیکی'),
                            ),
                            TextFormField(
                              controller: _password,
                              obscureText: true,
                              autofillHints: const [AutofillHints.password],
                              textDirection: TextDirection.ltr,
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'گذرواژه وارد نشده است.';
                                }
                                return null;
                              },
                              onFieldSubmitted: (value) => _login(),
                              decoration: const InputDecoration(
                                  icon: Icon(Icons.lock),
                                  hintText: 'گذرواژه',
                                  labelText: 'گذرواژه'),
                            ),
                            const SizedBox(
                              height: 10.0,
                            ),
                            SizedBox(
                                width: double.maxFinite,
                                child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: ElevatedButton.icon(
                                      icon: const Icon(Icons.login),
                                      label: const Text('ورود'),
                                      style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all<Color>(
                                                Colors.green),
                                      ),
                                      onPressed: _login,
                                    ))),
                            const SizedBox(
                              height: 10.0,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.launch),
                                  label: const Text('ثبت نام'),
                                  onPressed: () {
                                    Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const SignUpForm()));
                                  },
                                ),
                                const SizedBox(
                                  width: 10.0,
                                ),
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.help),
                                  label: const Text('فراموشی گذرواژه'),
                                  onPressed: () async {
                                    var url =
                                        'https://museum.ganjoor.net/forgot-password';
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

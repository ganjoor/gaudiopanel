import 'package:after_layout/after_layout.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gaudiopanel/forms/login.dart';
import 'package:gaudiopanel/forms/main-form.dart';
import 'package:gaudiopanel/services/auth-service.dart';
import 'package:gaudiopanel/services/gservice-address.dart';
import 'package:loading_overlay/loading_overlay.dart';

class SignUpForm extends StatefulWidget {
  @override
  SignUpFormState createState() => SignUpFormState();
}

class SignUpFormState extends State<SignUpForm>
    with AfterLayoutMixin<SignUpForm> {
  bool _isLoading = true;
  String _captchaImageId = '';
  String get _captchaImageUrl {
    if (_captchaImageId.isEmpty) {
      return '';
    }
    return GServiceAddress.Url + '/api/rimages/' + _captchaImageId + '.jpg';
  }

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _captcha = TextEditingController();

  String _signupError = '';

  @override
  void dispose() {
    _email.dispose();
    _captcha.dispose();
    super.dispose();
  }

  void _signup() async {
    setState(() {
      _signupError = '';
    });
    if (_formKey.currentState.validate()) {
      setState(() {
        _isLoading = true;
      });
      String loginError = await AuthService().login(_email.text, _captcha.text);
      setState(() {
        _isLoading = false;
        _signupError = loginError;
      });

      if (_signupError.isNotEmpty) {
        _formKey.currentState.validate();
      } else {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => MainForm()));
      }
    }
  }

  Future _newCaptcha() async {
    setState(() {
      _isLoading = true;
    });
    var resCaptcha = await AuthService().getACaptchaImageId();
    if (resCaptcha.item2.isNotEmpty) {
      _signupError = resCaptcha.item2 + ' لطفا صفحه را رفرش کنید.';
    } else {
      setState(() {
        _captchaImageId = resCaptcha.item1;
      });
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void afterFirstLayout(BuildContext context) async {
    await _newCaptcha();
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
                  title: Text('پیشخان خوانشگران گنجور » ثبت نام'),
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
                                if (!RegExp(
                                        r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
                                    .hasMatch(value)) {
                                  return 'پست الکترونیکی وارد شده معتبر نیست.';
                                }
                                if (_signupError.isNotEmpty) {
                                  return _signupError;
                                }
                                return null;
                              },
                              onFieldSubmitted: (value) => _signup(),
                              decoration: InputDecoration(
                                  prefix: Icon(Icons.mail),
                                  hintText: 'پست الکترونیکی',
                                  labelText: 'پست الکترونیکی'),
                            ),
                            SizedBox(width: 10),
                            Visibility(
                              child: Image.network(_captchaImageUrl),
                              visible: _captchaImageId.isNotEmpty,
                            ),
                            SizedBox(width: 10),
                            TextFormField(
                              controller: _captcha,
                              autofillHints: [AutofillHints.password],
                              textDirection: TextDirection.ltr,
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'عدد تصویر امنیتی بالا را وارد کنید.';
                                }
                                return null;
                              },
                              onFieldSubmitted: (value) => _signup(),
                              decoration: InputDecoration(
                                  prefix: Icon(Icons.lock),
                                  hintText: 'عدد تصویر امنیتی',
                                  labelText: 'عدد تصویر امنیتی'),
                            ),
                            SizedBox(
                              height: 10.0,
                            ),
                            SizedBox(
                                width: double.maxFinite,
                                child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: RaisedButton.icon(
                                      icon: Icon(Icons.launch),
                                      label: Text('ادامه'),
                                      color: Colors.green,
                                      onPressed: _signup,
                                    ))),
                            RaisedButton.icon(
                              icon: Icon(Icons.exit_to_app),
                              label: Text('برگشت'),
                              onPressed: () {
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => LoginForm()));
                              },
                            )
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

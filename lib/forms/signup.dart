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
  bool _alreadyLoggedIn = false;
  bool _emailSent = false;
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
      String signupError = await AuthService()
          .signupUnverified(_email.text, _captchaImageId, _captcha.text);
      setState(() {
        _isLoading = false;
        _signupError = signupError;
      });

      if (_signupError.isNotEmpty) {
        _formKey.currentState.validate();
      } else {
        setState(() {
          _emailSent = true;
        });
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
    _alreadyLoggedIn = await AuthService().isLoggedOn;
    if (!_alreadyLoggedIn) {
      await _newCaptcha();
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
                            Visibility(
                                child: TextFormField(
                                  controller: _email,
                                  autofillHints: [AutofillHints.username],
                                  textDirection: TextDirection.ltr,
                                  validator: (value) {
                                    if (!_emailSent && value.isEmpty) {
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
                                visible: !_alreadyLoggedIn && !_emailSent),
                            Visibility(
                                child: Text(
                                    'لطفا پست الکترونیکی خود را بررسی کنید. در صورتی که نشانی پست الکترونیکی خود را درست وارد کرده باشید نامه‌ای از گنجور دریافت کرده‌اید که حاوی یک رمز است. '),
                                visible: !_alreadyLoggedIn && _emailSent),
                            Visibility(
                                child: Text(
                                    'یا روی نشانی ارسال شده به پست الکترونیکی خود کلیک کنید یا رمز دریافتی را در کادر زیر وارد کرده روی دکمهٔ «ادامه» کلیک کنید. '),
                                visible: !_alreadyLoggedIn && _emailSent),
                            SizedBox(width: 10),
                            Visibility(
                              child: Image.network(_captchaImageUrl),
                              visible: !_alreadyLoggedIn &&
                                  _captchaImageId.isNotEmpty &&
                                  !_emailSent,
                            ),
                            Visibility(
                                child: TextFormField(
                                  controller: _captcha,
                                  autofillHints: [AutofillHints.password],
                                  textDirection: TextDirection.ltr,
                                  validator: (value) {
                                    if (_emailSent && value.isEmpty) {
                                      return 'رمز دریافتی را وارد نمایید.';
                                    }
                                    return null;
                                  },
                                  onFieldSubmitted: (value) => _signup(),
                                  decoration: InputDecoration(
                                      prefix: Icon(Icons.lock),
                                      hintText: 'رمز دریافتی را وارد نمایید',
                                      labelText: 'رمز دریافتی'),
                                ),
                                visible: !_alreadyLoggedIn && _emailSent),
                            SizedBox(width: 10),
                            Visibility(
                                child: TextFormField(
                                  controller: _captcha,
                                  autofillHints: [AutofillHints.password],
                                  textDirection: TextDirection.ltr,
                                  validator: (value) {
                                    if (!_emailSent && value.isEmpty) {
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
                                visible: !_alreadyLoggedIn && !_emailSent),
                            SizedBox(
                              height: 10.0,
                            ),
                            Visibility(
                                child: SizedBox(
                                    width: double.maxFinite,
                                    child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: RaisedButton.icon(
                                          icon: Icon(Icons.launch),
                                          label: Text('ادامه'),
                                          color: Colors.green,
                                          onPressed: _signup,
                                        ))),
                                visible: !_alreadyLoggedIn && !_emailSent),
                            Visibility(
                              child: Text('شما پیش‌تر ثبت نام کرده‌اید!'),
                              visible: _alreadyLoggedIn,
                            ),
                            Visibility(
                                child: RaisedButton.icon(
                                  icon: Icon(Icons.exit_to_app),
                                  label: Text('برگشت'),
                                  onPressed: () {
                                    Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => LoginForm()));
                                  },
                                ),
                                visible: !_emailSent),
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

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
  bool _emailVerified = false;
  bool _finalized = false;
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
  final TextEditingController _secret = TextEditingController();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _family = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirm = TextEditingController();

  String _signupError = '';

  @override
  void dispose() {
    _email.dispose();
    _captcha.dispose();
    _secret.dispose();
    _name.dispose();
    _family.dispose();
    _password.dispose();
    _confirm.dispose();
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
      String signupResult = await AuthService()
          .signupUnverified(_email.text, _captchaImageId, _captcha.text);
      setState(() {
        _isLoading = false;
        _signupError = signupResult.replaceAll('"', '');
      });

      if (_signupError != 'verify' && _signupError != 'finalize') {
        _formKey.currentState.validate();
        await _newCaptcha();
      } else {
        var res = _signupError;
        setState(() {
          _emailSent = true;
          _emailVerified = res == "finalize";
          _signupError = '';
        });
      }
    }
  }

  void _verify() async {
    setState(() {
      _signupError = '';
    });
    if (_formKey.currentState.validate()) {
      setState(() {
        _isLoading = true;
      });
      var verifyRes = await AuthService().verifyEmail(true, _secret.text);
      setState(() {
        _isLoading = false;
      });

      if (verifyRes.item2.isNotEmpty) {
        setState(() {
          _signupError = verifyRes.item2;
        });
        _formKey.currentState.validate();
      } else {
        setState(() {
          _emailSent = true;
          _emailVerified = true;
          _email.text = verifyRes.item1;
        });
      }
    }
  }

  void _finalize() async {
    setState(() {
      _signupError = '';
    });
    if (_formKey.currentState.validate()) {
      setState(() {
        _isLoading = true;
      });
      var error = await AuthService().finalizeSignUp(
          _email.text, _secret.text, _password.text, _name.text, _family.text);
      setState(() {
        _isLoading = false;
      });

      if (error.isNotEmpty) {
        setState(() {
          _signupError = error;
        });
        _formKey.currentState.validate();
      } else {
        setState(() {
          _finalized = true;
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

  void _login() async {
    setState(() {
      _signupError = '';
    });
    if (_formKey.currentState.validate()) {
      setState(() {
        _isLoading = true;
      });
      String loginError =
          await AuthService().login(_email.text, _password.text);
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
                                visible: _emailSent && !_emailVerified),
                            Visibility(
                                child: Text(
                                    'رمز دریافتی را در کادر زیر وارد کرده، روی دکمهٔ «ادامه» کلیک کنید'),
                                visible: _emailSent && !_emailVerified),
                            Visibility(
                                child: Text(
                                  'تذکر: ممکن است نامه به پوشه اسپم منتقل شده باشد',
                                  style: TextStyle(color: Colors.red),
                                ),
                                visible: _emailSent && !_emailVerified),
                            Visibility(
                                child: Text(
                                    'لطفا نام و نام خانوادگی و رمز مد نظر خود برای ورود را وارد کنید.'),
                                visible: _emailVerified && !_finalized),
                            Visibility(
                                child: SizedBox(
                                    width: double.maxFinite,
                                    child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: ElevatedButton.icon(
                                          icon: Icon(Icons.login),
                                          label: Text(
                                              'تبریک! ثبت نام شما تکمیل شد. ورود به سیستم'),
                                          style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all<
                                                    Color>(Colors.green),
                                          ),
                                          onPressed: _login,
                                        ))),
                                visible: _finalized),
                            SizedBox(width: 10),
                            Visibility(
                              child: Image.network(_captchaImageUrl),
                              visible: !_alreadyLoggedIn &&
                                  _captchaImageId.isNotEmpty &&
                                  !_emailSent,
                            ),
                            Visibility(
                                child: TextFormField(
                                  controller: _secret,
                                  textDirection: TextDirection.ltr,
                                  validator: (value) {
                                    if (_emailSent && value.isEmpty) {
                                      return 'رمز دریافتی را وارد نمایید.';
                                    }
                                    if (_signupError.isNotEmpty) {
                                      return _signupError;
                                    }
                                    return null;
                                  },
                                  onFieldSubmitted: (value) => _verify(),
                                  decoration: InputDecoration(
                                      prefix: Icon(Icons.lock),
                                      hintText: 'رمز دریافتی را وارد نمایید',
                                      labelText: 'رمز دریافتی'),
                                ),
                                visible: !_alreadyLoggedIn &&
                                    _emailSent &&
                                    !_emailVerified),
                            Visibility(
                                child: TextFormField(
                                  controller: _name,
                                  validator: (value) {
                                    if (_emailVerified &&
                                        !_finalized &&
                                        value.isEmpty) {
                                      return 'لطفا نام خود را وارد نمایید.';
                                    }

                                    return null;
                                  },
                                  onFieldSubmitted: (value) => _finalize(),
                                  decoration: InputDecoration(
                                      prefix: Icon(Icons.person),
                                      hintText: 'نام',
                                      labelText: 'نام'),
                                ),
                                visible: _emailVerified && !_finalized),
                            Visibility(
                                child: TextFormField(
                                  controller: _family,
                                  validator: (value) {
                                    if (_emailVerified &&
                                        !_finalized &&
                                        value.isEmpty) {
                                      return 'لطفا نام خانوادگی خود را وارد نمایید.';
                                    }

                                    return null;
                                  },
                                  onFieldSubmitted: (value) => _finalize(),
                                  decoration: InputDecoration(
                                      prefix: Icon(Icons.person),
                                      hintText: 'نام خانوادگی',
                                      labelText: 'نام خانوادگی'),
                                ),
                                visible: _emailVerified && !_finalized),
                            Visibility(
                                child: Text(_signupError),
                                visible: _signupError.isNotEmpty && _finalized),
                            SizedBox(width: 10),
                            Visibility(
                                child: TextFormField(
                                  controller: _captcha,
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
                            Visibility(
                                child: SizedBox(
                                    width: double.maxFinite,
                                    child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: ElevatedButton.icon(
                                          icon: Icon(Icons.launch),
                                          label: Text('ادامه'),
                                          style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all<
                                                    Color>(Colors.green),
                                          ),
                                          onPressed: _verify,
                                        ))),
                                visible: _emailSent && !_emailVerified),
                            Visibility(
                                child: TextFormField(
                                  controller: _password,
                                  obscureText: true,
                                  autofillHints: [AutofillHints.password],
                                  textDirection: TextDirection.ltr,
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return 'گذرواژه وارد نشده است.';
                                    }
                                    if (_signupError.isNotEmpty) {
                                      return _signupError;
                                    }
                                    return null;
                                  },
                                  onFieldSubmitted: (value) => _finalize(),
                                  decoration: InputDecoration(
                                      icon: Icon(Icons.lock),
                                      hintText: 'گذرواژه',
                                      labelText: 'گذرواژه'),
                                ),
                                visible: _emailVerified && !_finalized),
                            Visibility(
                                child: TextFormField(
                                  controller: _confirm,
                                  obscureText: true,
                                  autofillHints: [AutofillHints.password],
                                  textDirection: TextDirection.ltr,
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return 'تکرار گذرواژه وارد نشده است.';
                                    }
                                    if (value != _password.text) {
                                      return 'تکرار گذرواژه همخوانی ندارد.';
                                    }
                                    return null;
                                  },
                                  onFieldSubmitted: (value) => _finalize(),
                                  decoration: InputDecoration(
                                      icon: Icon(Icons.lock),
                                      hintText: 'تکرار گذرواژه',
                                      labelText: 'تکرار گذرواژه'),
                                ),
                                visible: _emailVerified && !_finalized),
                            Visibility(
                                child: Text(
                                    'گذرواژه باید دست کم شامل ۶ حرف باشد و از ترکیبی از اعداد و حروف انگلیسی تشکیل شده باشد.'),
                                visible: _emailVerified && !_finalized),
                            Visibility(
                                child: Text(
                                    'حروف و اعداد نباید تکراری باشند و وجود حداقل یک عدد و یک حرف کوچک انگلیسی در گذرواژه الزامی است.'),
                                visible: _emailVerified && !_finalized),
                            SizedBox(
                              height: 10.0,
                            ),
                            Visibility(
                                child: SizedBox(
                                    width: double.maxFinite,
                                    child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: ElevatedButton.icon(
                                          icon: Icon(Icons.launch),
                                          label: Text('ادامه'),
                                          style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all<
                                                    Color>(Colors.green),
                                          ),
                                          onPressed: _signup,
                                        ))),
                                visible: !_alreadyLoggedIn && !_emailSent),
                            Visibility(
                                child: SizedBox(
                                    width: double.maxFinite,
                                    child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: ElevatedButton.icon(
                                          icon: Icon(Icons.launch),
                                          label: Text('ادامه'),
                                          style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all<
                                                    Color>(Colors.green),
                                          ),
                                          onPressed: _finalize,
                                        ))),
                                visible: _emailVerified && !_finalized),
                            Visibility(
                              child: Text('شما پیش‌تر ثبت نام کرده‌اید!'),
                              visible: _alreadyLoggedIn,
                            ),
                            Visibility(
                                child: ElevatedButton.icon(
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

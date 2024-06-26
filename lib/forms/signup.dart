import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:gaudiopanel/forms/login.dart';
import 'package:gaudiopanel/forms/main_form.dart';
import 'package:gaudiopanel/services/auth_service.dart';
import 'package:gaudiopanel/services/gservice_address.dart';
import 'package:loading_overlay/loading_overlay.dart';

class SignUpForm extends StatefulWidget {
  const SignUpForm({super.key});

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
    return '${GServiceAddress.url}/api/rimages/$_captchaImageId.jpg';
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
    if (_formKey.currentState != null && _formKey.currentState!.validate()) {
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
        _formKey.currentState!.validate();
        await _newCaptcha();
      } else {
        var res = _signupError;
        setState(() {
          _emailSent = true;
          _emailVerified = res == 'finalize';
          _signupError = '';
        });
      }
    }
  }

  void _verify() async {
    setState(() {
      _signupError = '';
    });
    if (_formKey.currentState != null && _formKey.currentState!.validate()) {
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
        _formKey.currentState!.validate();
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
    if (_formKey.currentState != null && _formKey.currentState!.validate()) {
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
        _formKey.currentState!.validate();
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
      _signupError = '${resCaptcha.item2} لطفا صفحه را رفرش کنید.';
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
    if (_formKey.currentState != null && _formKey.currentState!.validate()) {
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
        _formKey.currentState!.validate();
      } else {
        if (!mounted) return;
        await Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => const MainForm()));
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
                  title: const Text('پیشخان خوانشگران گنجور » ثبت نام'),
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
                                visible: !_alreadyLoggedIn && !_emailSent,
                                child: TextFormField(
                                  controller: _email,
                                  autofillHints: const [AutofillHints.username],
                                  textDirection: TextDirection.ltr,
                                  validator: (value) {
                                    if (!_emailSent &&
                                        (value == null || value.isEmpty)) {
                                      return 'پست الکترونیکی وارد نشده است.';
                                    }
                                    if (!RegExp(
                                            r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
                                        .hasMatch(value!)) {
                                      return 'پست الکترونیکی وارد شده معتبر نیست.';
                                    }
                                    if (_signupError.isNotEmpty) {
                                      return _signupError;
                                    }
                                    return null;
                                  },
                                  onFieldSubmitted: (value) => _signup(),
                                  decoration: const InputDecoration(
                                      prefix: Icon(Icons.mail),
                                      hintText: 'پست الکترونیکی',
                                      labelText: 'پست الکترونیکی'),
                                )),
                            Visibility(
                                visible: _emailSent && !_emailVerified,
                                child: const Text(
                                    'لطفا پست الکترونیکی خود را بررسی کنید. در صورتی که نشانی پست الکترونیکی خود را درست وارد کرده باشید نامه‌ای از گنجور دریافت کرده‌اید که حاوی یک رمز است. ')),
                            Visibility(
                                visible: _emailSent && !_emailVerified,
                                child: const Text(
                                    'رمز دریافتی را در کادر زیر وارد کرده، روی دکمهٔ «ادامه» کلیک کنید')),
                            Visibility(
                                visible: _emailSent && !_emailVerified,
                                child: const Text(
                                  'تذکر: ممکن است نامه به پوشه اسپم منتقل شده باشد',
                                  style: TextStyle(color: Colors.red),
                                )),
                            Visibility(
                                visible: _emailVerified && !_finalized,
                                child: const Text(
                                    'لطفا نام و نام خانوادگی و رمز مد نظر خود برای ورود را وارد کنید.')),
                            Visibility(
                                visible: _finalized,
                                child: SizedBox(
                                    width: double.maxFinite,
                                    child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: ElevatedButton.icon(
                                          icon: const Icon(Icons.login),
                                          label: const Text(
                                              'تبریک! ثبت نام شما تکمیل شد. ورود به سیستم'),
                                          style: ButtonStyle(
                                            backgroundColor:
                                                WidgetStateProperty.all<Color>(
                                                    Colors.green),
                                          ),
                                          onPressed: _login,
                                        )))),
                            const SizedBox(width: 10),
                            Visibility(
                              visible: !_alreadyLoggedIn &&
                                  _captchaImageId.isNotEmpty &&
                                  !_emailSent,
                              child: Image.network(_captchaImageUrl),
                            ),
                            Visibility(
                                visible: !_alreadyLoggedIn &&
                                    _emailSent &&
                                    !_emailVerified,
                                child: TextFormField(
                                  controller: _secret,
                                  textDirection: TextDirection.ltr,
                                  validator: (value) {
                                    if (_emailSent &&
                                        (value == null || value.isEmpty)) {
                                      return 'رمز دریافتی را وارد نمایید.';
                                    }
                                    if (_signupError.isNotEmpty) {
                                      return _signupError;
                                    }
                                    return null;
                                  },
                                  onFieldSubmitted: (value) => _verify(),
                                  decoration: const InputDecoration(
                                      prefix: Icon(Icons.lock),
                                      hintText: 'رمز دریافتی را وارد نمایید',
                                      labelText: 'رمز دریافتی'),
                                )),
                            Visibility(
                                visible: _emailVerified && !_finalized,
                                child: TextFormField(
                                  controller: _name,
                                  validator: (value) {
                                    if (_emailVerified &&
                                        !_finalized &&
                                        (value == null || value.isEmpty)) {
                                      return 'لطفا نام خود را وارد نمایید.';
                                    }

                                    return null;
                                  },
                                  onFieldSubmitted: (value) => _finalize(),
                                  decoration: const InputDecoration(
                                      prefix: Icon(Icons.person),
                                      hintText: 'نام',
                                      labelText: 'نام'),
                                )),
                            Visibility(
                                visible: _emailVerified && !_finalized,
                                child: TextFormField(
                                  controller: _family,
                                  validator: (value) {
                                    if (_emailVerified &&
                                        !_finalized &&
                                        (value == null || value.isEmpty)) {
                                      return 'لطفا نام خانوادگی خود را وارد نمایید.';
                                    }

                                    return null;
                                  },
                                  onFieldSubmitted: (value) => _finalize(),
                                  decoration: const InputDecoration(
                                      prefix: Icon(Icons.person),
                                      hintText: 'نام خانوادگی',
                                      labelText: 'نام خانوادگی'),
                                )),
                            Visibility(
                                visible: _signupError.isNotEmpty && _finalized,
                                child: Text(_signupError)),
                            const SizedBox(width: 10),
                            Visibility(
                                visible: !_alreadyLoggedIn && !_emailSent,
                                child: TextFormField(
                                  controller: _captcha,
                                  textDirection: TextDirection.ltr,
                                  validator: (value) {
                                    if (!_emailSent &&
                                        (value == null || value.isEmpty)) {
                                      return 'عدد تصویر امنیتی بالا را وارد کنید.';
                                    }
                                    return null;
                                  },
                                  onFieldSubmitted: (value) => _signup(),
                                  decoration: const InputDecoration(
                                      prefix: Icon(Icons.lock),
                                      hintText: 'عدد تصویر امنیتی',
                                      labelText: 'عدد تصویر امنیتی'),
                                )),
                            Visibility(
                                visible: _emailSent && !_emailVerified,
                                child: SizedBox(
                                    width: double.maxFinite,
                                    child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: ElevatedButton.icon(
                                          icon: const Icon(Icons.launch),
                                          label: const Text('ادامه'),
                                          style: ButtonStyle(
                                            backgroundColor:
                                                WidgetStateProperty.all<Color>(
                                                    Colors.green),
                                          ),
                                          onPressed: _verify,
                                        )))),
                            Visibility(
                                visible: _emailVerified && !_finalized,
                                child: TextFormField(
                                  controller: _password,
                                  obscureText: true,
                                  autofillHints: const [AutofillHints.password],
                                  textDirection: TextDirection.ltr,
                                  validator: (value) {
                                    if ((value == null || value.isEmpty)) {
                                      return 'گذرواژه وارد نشده است.';
                                    }
                                    if (_signupError.isNotEmpty) {
                                      return _signupError;
                                    }
                                    return null;
                                  },
                                  onFieldSubmitted: (value) => _finalize(),
                                  decoration: const InputDecoration(
                                      icon: Icon(Icons.lock),
                                      hintText: 'گذرواژه',
                                      labelText: 'گذرواژه'),
                                )),
                            Visibility(
                                visible: _emailVerified && !_finalized,
                                child: TextFormField(
                                  controller: _confirm,
                                  obscureText: true,
                                  autofillHints: const [AutofillHints.password],
                                  textDirection: TextDirection.ltr,
                                  validator: (value) {
                                    if ((value == null || value.isEmpty)) {
                                      return 'تکرار گذرواژه وارد نشده است.';
                                    }
                                    if (value != _password.text) {
                                      return 'تکرار گذرواژه همخوانی ندارد.';
                                    }
                                    return null;
                                  },
                                  onFieldSubmitted: (value) => _finalize(),
                                  decoration: const InputDecoration(
                                      icon: Icon(Icons.lock),
                                      hintText: 'تکرار گذرواژه',
                                      labelText: 'تکرار گذرواژه'),
                                )),
                            Visibility(
                                visible: _emailVerified && !_finalized,
                                child: const Text(
                                    'گذرواژه باید دست کم شامل ۶ حرف باشد و از ترکیبی از اعداد و حروف انگلیسی تشکیل شده باشد.')),
                            Visibility(
                                visible: _emailVerified && !_finalized,
                                child: const Text(
                                    'حروف و اعداد نباید تکراری باشند و وجود حداقل یک عدد و یک حرف کوچک انگلیسی در گذرواژه الزامی است.')),
                            const SizedBox(
                              height: 10.0,
                            ),
                            Visibility(
                                visible: !_alreadyLoggedIn && !_emailSent,
                                child: SizedBox(
                                    width: double.maxFinite,
                                    child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: ElevatedButton.icon(
                                          icon: const Icon(Icons.launch),
                                          label: const Text('ادامه'),
                                          style: ButtonStyle(
                                            backgroundColor:
                                                WidgetStateProperty.all<Color>(
                                                    Colors.green),
                                          ),
                                          onPressed: _signup,
                                        )))),
                            Visibility(
                                visible: _emailVerified && !_finalized,
                                child: SizedBox(
                                    width: double.maxFinite,
                                    child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: ElevatedButton.icon(
                                          icon: const Icon(Icons.launch),
                                          label: const Text('ادامه'),
                                          style: ButtonStyle(
                                            backgroundColor:
                                                WidgetStateProperty.all<Color>(
                                                    Colors.green),
                                          ),
                                          onPressed: _finalize,
                                        )))),
                            Visibility(
                              visible: _alreadyLoggedIn,
                              child: const Text('شما پیش‌تر ثبت نام کرده‌اید!'),
                            ),
                            Visibility(
                                visible: !_emailSent,
                                child: ElevatedButton.icon(
                                  icon: const Icon(Icons.exit_to_app),
                                  label: const Text('برگشت'),
                                  onPressed: () {
                                    Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const LoginForm()));
                                  },
                                )),
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

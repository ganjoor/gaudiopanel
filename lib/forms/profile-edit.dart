import 'package:flutter/material.dart';
import 'package:gaudiopanel/models/narration/user-narration-profile-viewmodel.dart';

class ProfileEdit extends StatefulWidget {
  final UserNarrationProfileViewModel profile;

  const ProfileEdit({Key key, this.profile}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ProfileEditState(this.profile);
}

class _ProfileEditState extends State<ProfileEdit> {
  final UserNarrationProfileViewModel profile;

  _ProfileEditState(this.profile);

  TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _nameController.text = this.profile.name;
    return FocusTraversalGroup(
        child: Form(
            autovalidateMode: AutovalidateMode.always,
            onChanged: () {
              setState(() {
                profile.name = _nameController.text;
                profile.modified = true;
              });
            },
            child: Wrap(children: [
              Visibility(
                  child: Text(
                      'ویرایش نمایه‌ها روی خوانش‌های موجود تأثیر نمی‌گذارد و لازم است در صورت نیاز آنها را روی خوانش‌های موجود اعمال کنید'),
                  visible: profile.id != null),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'نام نمایه',
                    hintText: 'نام نمایه',
                  ),
                ),
              ),
              Text(
                  'نام نمایه روی خوانش‌ها تأثیر نمی‌گذارد و فقط به انتخاب آسان نمایه در هنگام بارگذاری خوانش‌های جدید کمک می‌کند'),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  initialValue: profile.artistName,
                  decoration: InputDecoration(
                    labelText: 'نام خوانشگر',
                    hintText: 'نام خوانشگر را با حروف فارسی وارد کنید',
                  ),
                  onSaved: (String value) {
                    setState(() {
                      profile.artistName = value;
                    });
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Directionality(
                    textDirection: TextDirection.ltr,
                    child: TextFormField(
                      initialValue: profile.artistUrl,
                      decoration: InputDecoration(
                        labelText: 'نشانی وب',
                        hintText: 'نشانی وب',
                      ),
                      onSaved: (String value) {
                        setState(() {
                          profile.artistUrl = value;
                        });
                      },
                    )),
              ),
              Text(
                  'نشانی سایت یا کانال تلگرام یا صفحهٔ اینستاگرام، نشانی‌های نامرتبط تبلیغاتی قابل پذیرش نیستند'),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  initialValue: profile.audioSrc,
                  decoration: InputDecoration(
                    labelText: 'نام منبع',
                    hintText: 'نام منبع',
                  ),
                  onSaved: (String value) {
                    setState(() {
                      profile.audioSrc = value;
                    });
                  },
                ),
              ),
              Text(
                  'اختیاری، اگر خوانش را با کسب اجازه از جای دیگری دریافت و همگام کرده‌اید می‌توانید نام منبع را اینجا وارد کنید'),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Directionality(
                    textDirection: TextDirection.ltr,
                    child: TextFormField(
                      initialValue: profile.audioSrcUrl,
                      decoration: InputDecoration(
                        labelText: 'نشانی وب منبع',
                        hintText: 'نشانی وب منبع',
                      ),
                      onSaved: (String value) {
                        setState(() {
                          profile.audioSrcUrl = value;
                        });
                      },
                    )),
              ),
              Text(
                  'اختیاری، اگر خوانش را با کسب اجازه از جای دیگری دریافت و همگام کرده‌اید می‌توانید نشانی منبع را اینجا وارد کنید'),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Directionality(
                    textDirection: TextDirection.ltr,
                    child: TextFormField(
                      initialValue: profile.fileSuffixWithoutDash,
                      decoration: InputDecoration(
                        labelText: 'پسوند یکتاساز فایل',
                        hintText: 'پسوند یکتاساز فایل',
                      ),
                      onSaved: (String value) {
                        setState(() {
                          profile.fileSuffixWithoutDash = value;
                        });
                      },
                    )),
              ),
              Text(
                  'نام فایل خوانش شما روی سرور ترکیبی از یک عدد، یک خط میانه (دش) و این حروف خواهد بود. می‌توانید حروف ابتدایی نام و نام خانوادگیتان را به انگلیسی وارد کنید. اگر فایلی همنام فایل نهایی از پیش وجود داشته باشد اعدادی به نام فایل اضافه می‌شود. بهتر است تا حد ممکن این پسوند یکتا باشد'),
            ])));
  }
}

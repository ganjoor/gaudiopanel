import 'package:flutter/material.dart';
import 'package:gaudiopanel/models/recitation/user_recitation_profile_viewmodel.dart';

class ProfileEdit extends StatefulWidget {
  final UserRecitationProfileViewModel profile;

  const ProfileEdit({Key key, this.profile}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ProfileEditState();
}

class _ProfileEditState extends State<ProfileEdit> {
  bool _additionalFields = false;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _artistNameController = TextEditingController();
  final TextEditingController _artistUrlController = TextEditingController();
  final TextEditingController _audioSrcController = TextEditingController();
  final TextEditingController _audioSrcUrlController = TextEditingController();
  final TextEditingController _fileSuffixWithoutDashController =
      TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _artistNameController.dispose();
    _artistUrlController.dispose();
    _audioSrcController.dispose();
    _audioSrcUrlController.dispose();
    _fileSuffixWithoutDashController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _nameController.text = widget.profile.name;
    _artistNameController.text = widget.profile.artistName;
    _artistUrlController.text = widget.profile.artistUrl;
    _audioSrcController.text = widget.profile.audioSrc;
    _audioSrcUrlController.text = widget.profile.audioSrcUrl;
    _fileSuffixWithoutDashController.text =
        widget.profile.fileSuffixWithoutDash;
    return FocusTraversalGroup(
        child: Form(
            autovalidateMode: AutovalidateMode.always,
            child: Wrap(children: [
              Visibility(
                  visible: widget.profile.id != null,
                  child: Text(
                      'ویرایش نمایه‌ها روی خوانش‌های موجود تأثیر نمی‌گذارد و لازم است در صورت نیاز آنها را روی خوانش‌های موجود اعمال کنید.')),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'نام نمایه',
                    hintText: 'نام نمایه',
                  ),
                ),
              ),
              const Text(
                  'نام نمایه روی خوانش‌ها تأثیر نمی‌گذارد و فقط به انتخاب آسان نمایه در هنگام بارگذاری خوانش‌های جدید کمک می‌کند.'),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                    controller: _artistNameController,
                    decoration: const InputDecoration(
                      labelText: 'نام خوانشگر',
                      hintText: 'نام خوانشگر را با حروف فارسی وارد کنید',
                    )),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Directionality(
                    textDirection: TextDirection.ltr,
                    child: TextFormField(
                        controller: _artistUrlController,
                        decoration: const InputDecoration(
                          labelText: 'نشانی وب',
                          hintText: 'نشانی وب',
                        ))),
              ),
              const Text(
                  'نشانی سایت یا کانال تلگرام یا صفحهٔ اینستاگرام (نشانی‌های نامرتبط تبلیغاتی قابل پذیرش نیستند).'),
              Visibility(
                  visible: _additionalFields,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                        controller: _audioSrcController,
                        decoration: InputDecoration(
                          labelText: 'نام منبع',
                          hintText: 'نام منبع',
                        )),
                  )),
              Visibility(
                  visible: _additionalFields,
                  child: Text(
                      'اختیاری، اگر خوانش را با کسب اجازه از جای دیگری دریافت و همگام کرده‌اید می‌توانید نام منبع را اینجا وارد کنید.')),
              Visibility(
                  visible: _additionalFields,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Directionality(
                        textDirection: TextDirection.ltr,
                        child: TextFormField(
                            controller: _audioSrcUrlController,
                            decoration: InputDecoration(
                              labelText: 'نشانی وب منبع',
                              hintText: 'نشانی وب منبع',
                            ))),
                  )),
              Visibility(
                  visible: _additionalFields,
                  child: Text(
                      'اختیاری، اگر خوانش را با کسب اجازه از جای دیگری دریافت و همگام کرده‌اید می‌توانید نشانی منبع را اینجا وارد کنید.')),
              Visibility(
                  visible: _additionalFields,
                  child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Directionality(
                          textDirection: TextDirection.ltr,
                          child: TextFormField(
                              controller: _fileSuffixWithoutDashController,
                              decoration: InputDecoration(
                                labelText: 'پسوند یکتاساز فایل',
                                hintText: 'پسوند یکتاساز فایل',
                              ))))),
              Visibility(
                  visible: _additionalFields,
                  child: Text(
                      'اختیاری، نام فایل خوانش شما روی سرور ترکیبی از یک عدد، یک خط میانه (دش) و این حروف خواهد بود. می‌توانید حروف ابتدایی نام و نام خانوادگیتان را به انگلیسی وارد کنید. اگر فایلی همنام فایل نهایی از پیش وجود داشته باشد اعدادی به نام فایل اضافه می‌شود. بهتر است تا حد ممکن این پسوند یکتا باشد.')),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text('اطلاعات منبع'),
                      Switch(
                          value: _additionalFields,
                          onChanged: (value) {
                            setState(() {
                              _additionalFields = value;
                            });
                          }),
                      const Text('پیش‌فرض'),
                      Switch(
                          value: widget.profile.isDefault,
                          onChanged: (value) {
                            setState(() {
                              widget.profile.isDefault = value;
                            });
                          })
                    ]),
              ),
              Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ButtonBar(
                    alignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        child: Text(widget.profile.id ==
                                '00000000-0000-0000-0000-000000000000'
                            ? 'ایجاد'
                            : 'ذخیره'),
                        onPressed: () {
                          widget.profile.name = _nameController.text;
                          widget.profile.artistName =
                              _artistNameController.text;
                          widget.profile.artistUrl = _artistUrlController.text;
                          widget.profile.audioSrc = _audioSrcController.text;
                          widget.profile.audioSrcUrl =
                              _audioSrcUrlController.text;
                          widget.profile.fileSuffixWithoutDash =
                              _fileSuffixWithoutDashController.text;
                          Navigator.of(context).pop(widget.profile);
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

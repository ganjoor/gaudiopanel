import 'package:flutter/material.dart';
import 'package:gaudiopanel/models/recitation/user_recitation_profile_viewmodel.dart';

class ProfileEdit extends StatefulWidget {
  final UserRecitationProfileViewModel profile;

  const ProfileEdit({super.key, required this.profile});

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

  Widget _hint(String text) {
    return Padding(
      padding: const EdgeInsets.only(right: 4.0, bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 16, color: Colors.grey.shade600),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
            ),
          ),
        ],
      ),
    );
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
    bool isNew = widget.profile.id == null ||
        widget.profile.id == '00000000-0000-0000-0000-000000000000';
    return FocusTraversalGroup(
        child: Form(
            autovalidateMode: AutovalidateMode.always,
            child: Wrap(children: [
              Visibility(
                  visible: widget.profile.id != null,
                  child: _hint(
                      'ویرایش نمایه‌ها روی خوانش‌های موجود تأثیر نمی‌گذارد و لازم است در صورت نیاز آنها را روی خوانش‌های موجود اعمال کنید.')),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    icon: Icon(Icons.badge_outlined),
                    labelText: 'نام نمایه',
                    hintText: 'نام نمایه',
                  ),
                ),
              ),
              _hint(
                  'نام نمایه روی خوانش‌ها تأثیر نمی‌گذارد و فقط به انتخاب آسان نمایه در هنگام بارگذاری خوانش‌های جدید کمک می‌کند.'),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                    controller: _artistNameController,
                    decoration: const InputDecoration(
                      icon: Icon(Icons.person_outline),
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
                          icon: Icon(Icons.link),
                          labelText: 'نشانی وب',
                          hintText: 'نشانی وب',
                        ))),
              ),
              _hint(
                  'نشانی سایت یا کانال تلگرام یا صفحهٔ اینستاگرام (نشانی‌های نامرتبط تبلیغاتی قابل پذیرش نیستند).'),
              const Divider(),
              Visibility(
                  visible: _additionalFields,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                        controller: _audioSrcController,
                        decoration: const InputDecoration(
                          icon: Icon(Icons.source_outlined),
                          labelText: 'نام منبع',
                          hintText: 'نام منبع',
                        )),
                  )),
              Visibility(
                  visible: _additionalFields,
                  child: _hint(
                      'اختیاری، اگر خوانش را با کسب اجازه از جای دیگری دریافت و همگام کرده‌اید می‌توانید نام منبع را اینجا وارد کنید.')),
              Visibility(
                  visible: _additionalFields,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Directionality(
                        textDirection: TextDirection.ltr,
                        child: TextFormField(
                            controller: _audioSrcUrlController,
                            decoration: const InputDecoration(
                              icon: Icon(Icons.link),
                              labelText: 'نشانی وب منبع',
                              hintText: 'نشانی وب منبع',
                            ))),
                  )),
              Visibility(
                  visible: _additionalFields,
                  child: _hint(
                      'اختیاری، اگر خوانش را با کسب اجازه از جای دیگری دریافت و همگام کرده‌اید می‌توانید نشانی منبع را اینجا وارد کنید.')),
              Visibility(
                  visible: _additionalFields,
                  child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Directionality(
                          textDirection: TextDirection.ltr,
                          child: TextFormField(
                              controller: _fileSuffixWithoutDashController,
                              decoration: const InputDecoration(
                                icon: Icon(Icons.tag),
                                labelText: 'پسوند یکتاساز فایل',
                                hintText: 'پسوند یکتاساز فایل',
                              ))))),
              Visibility(
                  visible: _additionalFields,
                  child: _hint(
                      'اختیاری، نام فایل خوانش شما روی سرور ترکیبی از یک عدد، یک خط میانه (دش) و این حروف خواهد بود. می‌توانید حروف ابتدایی نام و نام خانوادگی‌تان را به انگلیسی وارد کنید. اگر فایلی همنام فایل نهایی از پیش وجود داشته باشد اعدادی به نام فایل اضافه می‌شود. بهتر است تا حد ممکن این پسوند یکتا باشد.')),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(Icons.tune, size: 20),
                      const SizedBox(width: 8),
                      const Text('اطلاعات منبع'),
                      Switch(
                          value: _additionalFields,
                          onChanged: (value) {
                            setState(() {
                              _additionalFields = value;
                            });
                          }),
                      const SizedBox(width: 16),
                      const Icon(Icons.star_outline, size: 20),
                      const SizedBox(width: 8),
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
                  child: OverflowBar(
                    alignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton.icon(
                        icon: Icon(isNew ? Icons.add : Icons.save_outlined),
                        label: Text(isNew ? 'ایجاد' : 'ذخیره'),
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
                      TextButton.icon(
                        icon: const Icon(Icons.close),
                        label: const Text('انصراف'),
                        onPressed: () {
                          Navigator.of(context).pop(null);
                        },
                      )
                    ],
                  )),
            ])));
  }
}

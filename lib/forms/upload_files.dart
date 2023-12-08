import 'package:flutter/material.dart';
import 'package:gaudiopanel/models/recitation/user_recitation_profile_viewmodel.dart';

class UploadFiles extends StatefulWidget {
  final UserRecitationProfileViewModel profile;

  const UploadFiles({Key? key, required this.profile}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _UploadFilesState();
}

class _UploadFilesState extends State<UploadFiles> {
  final TextEditingController _profileController = TextEditingController();

  bool _replace = true;

  @override
  void dispose() {
    _profileController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _profileController.text = widget.profile.name;
    return FocusTraversalGroup(
        child: Form(
            autovalidateMode: AutovalidateMode.always,
            child: Wrap(children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: _profileController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'نمایهٔ فعال',
                    hintText: 'نمایهٔ فعال',
                  ),
                ),
              ),
              const Text(
                  'نمایهٔ پیش‌فرض نام خوانشگر و نشانی وب خوانش‌های جدید را مشخص می‌کند. برای انتخاب نمایهٔ پیش‌فرض از قسمت نمایه‌های من اقدام کنید.'),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text('جایگزینی خوانش‌های موجود'),
                      Switch(
                          value: _replace,
                          onChanged: (value) {
                            setState(() {
                              _replace = value;
                            });
                          })
                    ]),
              ),
              const Text(
                  'اگر گزینهٔ جایگزینی خوانش‌های موجود فعال باشد و شما خوانشی برای یک شعر با نام خوانشگر یکسان با خوانش ارسالی داشته باشید این خوانش جایگزین آن خواهد شد. به این ترتیب موقعیت خوانش شما حفظ می‌شود.'),
              const Text('برای هر خوانش یک زوج فایل (mp3+xml) مورد نیاز است. '),
              const Text(
                  'فایل‌های xml را با همگام‌سازی خوانش با متن شعر در گنجور رومیزی تولید کنید.'),
              const Text(
                  'نام فایلها اهمیتی ندارد و نیاز نیست زوج فایل‌ها همنام باشند.'),
              Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ButtonBar(
                    alignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        child: const Text('انتخاب و ارسال فایل‌ها'),
                        onPressed: () {
                          Navigator.of(context).pop(_replace);
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

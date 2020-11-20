import 'package:flutter/material.dart';
import 'package:gaudiopanel/models/recitation/user-recitation-profile-viewmodel.dart';

class UploadFiles extends StatefulWidget {
  final UserRecitationProfileViewModel profile;

  const UploadFiles({Key key, this.profile}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _UploadFilesState(this.profile);
}

class _UploadFilesState extends State<UploadFiles> {
  final UserRecitationProfileViewModel profile;

  TextEditingController _profileController = TextEditingController();

  _UploadFilesState(this.profile);

  bool _replace = true;

  @override
  void dispose() {
    _profileController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _profileController.text = this.profile.name;
    return FocusTraversalGroup(
        child: Form(
            autovalidateMode: AutovalidateMode.always,
            child: Wrap(children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: _profileController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'نمایهٔ فعال',
                    hintText: 'نمایهٔ فعال',
                  ),
                ),
              ),
              Text(
                  'نمایهٔ پیش‌فرض نام خوانشگر و نشانی وب خوانش‌های جدید را مشخص می‌کند. برای انتخاب نمایهٔ پیش‌فرض از قسمت نمایه‌های من اقدام کنید.'),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('جایگزینی خوانش‌های موجود'),
                      Switch(
                          value: _replace,
                          onChanged: (value) {
                            setState(() {
                              _replace = value;
                            });
                          })
                    ]),
              ),
              Text(
                  'اگر گزینهٔ جایگزینی خوانش‌های موجود فعال باشد و شما خوانشی برای یک شعر با نام خوانشگر یکسان با خوانش ارسالی داشته باشید این خوانش جایگزین آن خواهد شد. به این ترتیب موقعیت خوانش شما حفظ می‌شود.'),
              Text('برای هر خوانش یک زوج فایل (mp3+xml) مورد نیاز است. '),
              Text(
                  'نام فایلها اهمیتی ندارد و نیاز نیست زوج فایل‌ها همنام باشند.'),
              Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ButtonBar(
                    alignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        child: Text('انتخاب و ارسال فایل‌ها'),
                        onPressed: () {
                          Navigator.of(context).pop(_replace);
                        },
                      ),
                      TextButton(
                        child: Text('انصراف'),
                        onPressed: () {
                          Navigator.of(context).pop(null);
                        },
                      )
                    ],
                  )),
            ])));
  }
}

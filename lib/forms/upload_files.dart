import 'package:flutter/material.dart';
import 'package:gaudiopanel/models/recitation/user_recitation_profile_viewmodel.dart';

class UploadFiles extends StatefulWidget {
  final UserRecitationProfileViewModel profile;

  const UploadFiles({super.key, required this.profile});
  @override
  State<StatefulWidget> createState() => _UploadFilesState();
}

class _UploadFilesState extends State<UploadFiles> {
  final TextEditingController _profileController = TextEditingController();

  bool _replace = true;
  bool _commentary = false;

  @override
  void dispose() {
    _profileController.dispose();
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
                    icon: Icon(Icons.badge_outlined),
                    labelText: 'نمایهٔ فعال',
                    hintText: 'نمایهٔ فعال',
                  ),
                ),
              ),
              _hint(
                  'نمایهٔ پیش‌فرض نام خوانشگر و نشانی وب خوانش‌های جدید را مشخص می‌کند. برای انتخاب نمایهٔ پیش‌فرض از قسمت نمایه‌های من اقدام کنید.'),
              const Divider(),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(Icons.published_with_changes, size: 20),
                      const SizedBox(width: 8),
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
              _hint(
                  'اگر گزینهٔ جایگزینی خوانش‌های موجود فعال باشد و شما خوانشی برای یک شعر با نام خوانشگر یکسان با خوانش ارسالی داشته باشید این خوانش جایگزین آن خواهد شد. به این ترتیب موقعیت خوانش شما حفظ می‌شود.'),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(Icons.record_voice_over, size: 20),
                      const SizedBox(width: 8),
                      const Text('شرح صوتی'),
                      Switch(
                          value: _commentary,
                          onChanged: (value) {
                            setState(() {
                              _commentary = value;
                            });
                          })
                    ]),
              ),
              _hint('شرح‌های صوتی در بخشی جدا از خوانش‌ها نمایش داده می‌شوند.'),
              const Divider(),
              _hint('برای هر خوانش یک زوج فایل (mp3+xml) مورد نیاز است.'),
              _hint(
                  'فایل‌های xml را با همگام‌سازی خوانش با متن شعر در گنجور رومیزی تولید کنید.'),
              _hint(
                  'نام فایل‌ها اهمیتی ندارد و نیاز نیست زوج فایل‌ها همنام باشند.'),
              Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: OverflowBar(
                    alignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.upload_file),
                        label: const Text('انتخاب و ارسال فایل‌ها'),
                        onPressed: () {
                          Navigator.of(context).pop((_replace, _commentary));
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

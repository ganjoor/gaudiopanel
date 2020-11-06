import 'package:flutter/material.dart';
import 'package:gaudiopanel/forms/profile-edit.dart';
import 'package:gaudiopanel/models/common/paginated-items-response-model.dart';
import 'package:gaudiopanel/models/narration/user-narration-profile-viewmodel.dart';

class ProfilesDataSection extends StatefulWidget {
  final PaginatedItemsResponseModel<UserNarrationProfileViewModel> profiles;

  const ProfilesDataSection({Key key, this.profiles}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ProfilesState(this.profiles);
}

class _ProfilesState extends State<ProfilesDataSection> {
  final PaginatedItemsResponseModel<UserNarrationProfileViewModel> profiles;
  _ProfilesState(this.profiles);

  Future<UserNarrationProfileViewModel> _edit(
      UserNarrationProfileViewModel profile) async {
    bool _isNew = profile == null;
    if (profile == null) {
      profile = UserNarrationProfileViewModel(
          name: '',
          artistName: '',
          artistUrl: '',
          audioSrc: '',
          audioSrcUrl: '',
          fileSuffixWithoutDash: '',
          isDefault: true);
    }

    return showDialog<UserNarrationProfileViewModel>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        ProfileEdit _profileEdit = ProfileEdit(profile: profile);
        return AlertDialog(
          title: Text(_isNew ? 'نمایهٔ جدید' : 'ویرایش نمایه'),
          content: SingleChildScrollView(
            child: _profileEdit,
          ),
          actions: <Widget>[
            ElevatedButton(
              child: Text(_isNew ? 'ایجاد' : 'ذخیره'),
              onPressed: () {
                Navigator.of(context).pop(_profileEdit.profile);
              },
            ),
            TextButton(
              child: Text('انصراف'),
              onPressed: () {
                Navigator.of(context).pop(null);
              },
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: profiles.items.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
              leading: IconButton(
                icon: Icon(Icons.edit),
                onPressed: () async {
                  final result = await _edit(profiles.items[index]);
                  if (result != null) {
                    setState(() {
                      profiles.items[index] = result;
                    });
                  }
                },
              ),
              title: Text(profiles.items[index].name),
              subtitle: Column(children: [
                Text(profiles.items[index].artistName),
                Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text(profiles.items[index].artistUrl))
              ]),
              trailing: IconButton(
                icon: profiles.items[index].isMarked
                    ? Icon(Icons.check_box)
                    : Icon(Icons.check_box_outline_blank),
                onPressed: () {
                  setState(() {
                    profiles.items[index].isMarked =
                        !profiles.items[index].isMarked;
                  });
                },
              ));
        });
  }
}

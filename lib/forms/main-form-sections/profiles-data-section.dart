import 'package:flutter/material.dart';
import 'package:gaudiopanel/callbacks/g-ui-callbacks.dart';
import 'package:gaudiopanel/forms/profile-edit.dart';
import 'package:gaudiopanel/models/common/paginated-items-response-model.dart';
import 'package:gaudiopanel/models/recitation/user-recitation-profile-viewmodel.dart';
import 'package:gaudiopanel/services/recitation-service.dart';

class ProfilesDataSection extends StatefulWidget {
  final PaginatedItemsResponseModel<UserRecitationProfileViewModel> profiles;
  final LoadingStateChanged loadingStateChanged;
  final SnackbarNeeded snackbarNeeded;

  const ProfilesDataSection(
      {Key key, this.profiles, this.loadingStateChanged, this.snackbarNeeded})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _ProfilesState(
      this.profiles, this.loadingStateChanged, this.snackbarNeeded);
}

class _ProfilesState extends State<ProfilesDataSection> {
  final PaginatedItemsResponseModel<UserRecitationProfileViewModel> profiles;
  final LoadingStateChanged loadingStateChanged;
  final SnackbarNeeded snackbarNeeded;
  _ProfilesState(this.profiles, this.loadingStateChanged, this.snackbarNeeded);

  Future<UserRecitationProfileViewModel> _edit(
      UserRecitationProfileViewModel profile) async {
    bool _isNew = profile == null;
    if (profile == null) {
      profile = UserRecitationProfileViewModel(
          name: '',
          artistName: '',
          artistUrl: '',
          audioSrc: '',
          audioSrcUrl: '',
          fileSuffixWithoutDash: '',
          isDefault: true);
    }

    var profileCopy = UserRecitationProfileViewModel.fromJson(profile.toJson());

    return showDialog<UserRecitationProfileViewModel>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        ProfileEdit _profileEdit = ProfileEdit(profile: profileCopy);
        return AlertDialog(
          title: Text(_isNew ? 'نمایهٔ جدید' : 'ویرایش نمایه'),
          content: SingleChildScrollView(
            child: _profileEdit,
          ),
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
              selected: profiles.items[index].isDefault,
              leading: IconButton(
                icon: Icon(Icons.edit),
                onPressed: () async {
                  final result = await _edit(profiles.items[index]);
                  if (result != null) {
                    if (this.loadingStateChanged != null) {
                      this.loadingStateChanged(true);
                    }
                    var serviceResult =
                        await RecitationService().updateProfile(result, false);
                    if (this.loadingStateChanged != null) {
                      this.loadingStateChanged(false);
                    }
                    if (serviceResult.item2 == '') {
                      setState(() {
                        profiles.items[index] = serviceResult.item1;
                        if (profiles.items[index].isDefault) {
                          for (var item in profiles.items) {
                            item.isDefault =
                                item.id == profiles.items[index].id;
                          }
                        }
                      });
                    } else {
                      if (this.snackbarNeeded != null) {
                        this.snackbarNeeded(
                            'خطا در ذخیرهٔ نمایه: ' + serviceResult.item2);
                      }
                    }
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

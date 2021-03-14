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
  State<StatefulWidget> createState() => _ProfilesState();
}

class _ProfilesState extends State<ProfilesDataSection> {
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
        itemCount: widget.profiles.items.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
              selected: widget.profiles.items[index].isDefault,
              leading: IconButton(
                icon: Icon(Icons.edit),
                onPressed: () async {
                  final result = await _edit(widget.profiles.items[index]);
                  if (result != null) {
                    if (widget.loadingStateChanged != null) {
                      widget.loadingStateChanged(true);
                    }
                    var serviceResult =
                        await RecitationService().updateProfile(result, false);
                    if (widget.loadingStateChanged != null) {
                      widget.loadingStateChanged(false);
                    }
                    if (serviceResult.item2 == '') {
                      setState(() {
                        widget.profiles.items[index] = serviceResult.item1;
                        if (widget.profiles.items[index].isDefault) {
                          for (var item in widget.profiles.items) {
                            item.isDefault =
                                item.id == widget.profiles.items[index].id;
                          }
                        }
                      });
                    } else {
                      if (widget.snackbarNeeded != null) {
                        widget.snackbarNeeded(
                            'خطا در ذخیرهٔ نمایه: ' + serviceResult.item2);
                      }
                    }
                  }
                },
              ),
              title: Text(widget.profiles.items[index].name),
              subtitle: Column(children: [
                Text(widget.profiles.items[index].artistName),
                Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text(widget.profiles.items[index].artistUrl))
              ]),
              trailing: IconButton(
                icon: widget.profiles.items[index].isMarked
                    ? Icon(Icons.check_box)
                    : Icon(Icons.check_box_outline_blank),
                onPressed: () {
                  setState(() {
                    widget.profiles.items[index].isMarked =
                        !widget.profiles.items[index].isMarked;
                  });
                },
              ));
        });
  }
}

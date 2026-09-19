import 'package:flutter/material.dart';
import 'package:gaudiopanel/callbacks/g_ui_callbacks.dart';
import 'package:gaudiopanel/forms/generic_lookups.dart';
import 'package:gaudiopanel/forms/profile_edit.dart';
import 'package:gaudiopanel/models/common/paginated_items_response_model.dart';
import 'package:gaudiopanel/models/recitation/user_recitation_profile_viewmodel.dart';
import 'package:gaudiopanel/services/recitation_service.dart';

class ProfilesDataSection extends StatefulWidget {
  final PaginatedItemsResponseModel<UserRecitationProfileViewModel> profiles;
  final LoadingStateChanged loadingStateChanged;
  final SnackbarNeeded snackbarNeeded;

  const ProfilesDataSection(
      {super.key,
      required this.profiles,
      required this.loadingStateChanged,
      required this.snackbarNeeded});

  @override
  State<StatefulWidget> createState() => _ProfilesState();
}

class _ProfilesState extends State<ProfilesDataSection> {
  Future<UserRecitationProfileViewModel?> _edit(
      UserRecitationProfileViewModel? profile) async {
    bool isNew = profile == null;
    profile ??= UserRecitationProfileViewModel(
        name: '',
        artistName: '',
        artistUrl: '',
        audioSrc: '',
        audioSrcUrl: '',
        fileSuffixWithoutDash: '',
        isDefault: true);

    var profileCopy = UserRecitationProfileViewModel.fromJson(profile.toJson());

    return showDialog<UserRecitationProfileViewModel>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        ProfileEdit profileEdit = ProfileEdit(profile: profileCopy);
        return AlertDialog(
          title: Text(isNew ? 'نمایهٔ جدید' : 'ویرایش نمایه'),
          content: SingleChildScrollView(
            child: profileEdit,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.profiles.items == null || widget.profiles.items!.isEmpty) {
      return const EmptyState(
        icon: Icons.badge_outlined,
        message: 'هنوز نمایه‌ای نساخته‌اید.\n'
            'برای ارسال خوانش، ابتدا از دکمهٔ + یک نمایه بسازید.',
      );
    }
    return ListView.builder(
        itemCount: widget.profiles.items!.length,
        itemBuilder: (BuildContext context, int index) {
          bool marked = widget.profiles.items![index].isMarked;
          return Card(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              elevation: marked ? 3 : 1,
              color: marked
                  ? Theme.of(context).colorScheme.primaryContainer
                  : null,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: marked
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey.shade300,
                  width: marked ? 1.5 : 1,
                ),
              ),
              child: ListTile(
              selected: widget.profiles.items![index].isDefault,
              leading: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () async {
                  final result = await _edit(widget.profiles.items![index]);
                  if (result == null) return;
                  widget.loadingStateChanged(true);
                  var serviceResult =
                      await RecitationService().updateProfile(result, false);
                  widget.loadingStateChanged(false);
                  if (serviceResult.item2 == '') {
                    setState(() {
                      widget.profiles.items![index] = serviceResult.item1!;
                      if (widget.profiles.items![index].isDefault) {
                        for (var item in widget.profiles.items!) {
                          item.isDefault =
                              item.id == widget.profiles.items![index].id;
                        }
                      }
                    });
                  } else {
                    widget.snackbarNeeded(
                        'خطا در ذخیرهٔ نمایه: ${serviceResult.item2}');
                  }
                },
              ),
              title: Text(widget.profiles.items![index].name),
              subtitle: Column(children: [
                Text(widget.profiles.items![index].artistName),
                Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text(widget.profiles.items![index].artistUrl,
                        style: const TextStyle(fontFamily: 'Roboto')))
              ]),
              trailing: IconButton(
                icon: widget.profiles.items![index].isMarked
                    ? const Icon(Icons.check_box)
                    : const Icon(Icons.check_box_outline_blank),
                onPressed: () {
                  setState(() {
                    widget.profiles.items![index].isMarked =
                        !widget.profiles.items![index].isMarked;
                  });
                },
              )));
        });
  }
}

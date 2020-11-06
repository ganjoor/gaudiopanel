import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    return ListView(children: [
      Padding(
          padding: EdgeInsets.all(10.0),
          child: ExpansionPanelList(
              expansionCallback: (int index, bool isExpanded) {
                setState(() {
                  profiles.items[index].isExpanded =
                      !profiles.items[index].isExpanded;
                });
              },
              children: profiles.items
                  .map((e) => ExpansionPanel(
                      headerBuilder: (BuildContext context, bool isExpanded) {
                        return ListTile(
                            leading: Icon(
                              Icons.people,
                              color: e.isDefault
                                  ? Colors.red
                                  : Theme.of(context).disabledColor,
                            ),
                            title: Text(e.name),
                            trailing: IconButton(
                              icon: e.modified
                                  ? Icon(Icons.save,
                                      color: Theme.of(context).primaryColor)
                                  : e.isMarked
                                      ? Icon(Icons.check_box)
                                      : Icon(Icons.check_box_outline_blank),
                              onPressed: () {
                                setState(() {
                                  e.isMarked = !e.isMarked;
                                });
                              },
                            ),
                            subtitle: Text(e.artistName));
                      },
                      isExpanded: e.isExpanded,
                      body: FocusTraversalGroup(
                          child: Form(
                              autovalidateMode: AutovalidateMode.always,
                              onChanged: () {
                                setState(() {
                                  e.modified = true;
                                });
                              },
                              child: Wrap(children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: TextFormField(
                                    initialValue: e.name,
                                    decoration: InputDecoration(
                                      labelText: 'نام نمایه',
                                      hintText: 'نامه نمایه',
                                    ),
                                    onSaved: (String value) {
                                      setState(() {
                                        e.name = value;
                                      });
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: TextFormField(
                                    initialValue: e.artistName,
                                    decoration: InputDecoration(
                                      labelText: 'نام خوانشگر',
                                      hintText: 'نام خوانشگر',
                                    ),
                                    onSaved: (String value) {
                                      setState(() {
                                        e.artistName = value;
                                      });
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Directionality(
                                      textDirection: TextDirection.ltr,
                                      child: TextFormField(
                                        initialValue: e.artistUrl,
                                        decoration: InputDecoration(
                                          labelText: 'نشانی وب',
                                          hintText: 'نشانی وب',
                                        ),
                                        onSaved: (String value) {
                                          setState(() {
                                            e.artistUrl = value;
                                          });
                                        },
                                      )),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: TextFormField(
                                    initialValue: e.audioSrc,
                                    decoration: InputDecoration(
                                      labelText: 'نام منبع',
                                      hintText: 'نام منبع',
                                    ),
                                    onSaved: (String value) {
                                      setState(() {
                                        e.audioSrc = value;
                                      });
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Directionality(
                                      textDirection: TextDirection.ltr,
                                      child: TextFormField(
                                        initialValue: e.audioSrcUrl,
                                        decoration: InputDecoration(
                                          labelText: 'نشانی وب منبع',
                                          hintText: 'نشانی وب منبع',
                                        ),
                                        onSaved: (String value) {
                                          setState(() {
                                            e.audioSrcUrl = value;
                                          });
                                        },
                                      )),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Directionality(
                                      textDirection: TextDirection.ltr,
                                      child: TextFormField(
                                        initialValue: e.fileSuffixWithoutDash,
                                        decoration: InputDecoration(
                                          labelText: 'پسوند یکتاساز فایل',
                                          hintText: 'پسوند یکتاساز فایل',
                                        ),
                                        onSaved: (String value) {
                                          setState(() {
                                            e.fileSuffixWithoutDash = value;
                                          });
                                        },
                                      )),
                                ),
                              ])))))
                  .toList()))
    ]);
  }
}

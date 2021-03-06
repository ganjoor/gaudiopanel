import 'package:flutter/material.dart';
import 'package:gaudiopanel/models/recitation/recitation-viewmodel.dart';

class RejectRecitation extends StatefulWidget {
  final RecitationViewModel recitation;

  const RejectRecitation({Key key, this.recitation}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _RejectRecitationState();
}

class _RejectRecitationState extends State<RejectRecitation> {
  TextEditingController _recitationController = TextEditingController();
  TextEditingController _causeController = TextEditingController();

  @override
  void dispose() {
    _recitationController.dispose();
    _causeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _recitationController.text = widget.recitation.audioTitle +
        ' به خوانش ' +
        widget.recitation.audioArtist;
    return FocusTraversalGroup(
        child: Form(
            autovalidateMode: AutovalidateMode.always,
            child: Wrap(children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: _recitationController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'خوانش',
                    hintText: 'خوانش',
                  ),
                ),
              ),
              Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    child: Text('مشکلات فنی از قبیل همگامسازی نادرست دارد'),
                    onPressed: () {
                      Navigator.of(context)
                          .pop('مشکلات فنی از قبیل همگامسازی نادرست دارد');
                    },
                  )),
              Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    child: Text('خوانش اشکالات ادبی و بیانی دارد'),
                    onPressed: () {
                      Navigator.of(context)
                          .pop('خوانش اشکالات ادبی و بیانی دارد');
                    },
                  )),
              Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    child: Text('خوانش متعلق به ارسال کننده نیست'),
                    onPressed: () {
                      Navigator.of(context)
                          .pop('خوانش متعلق به ارسال کننده نیست');
                    },
                  )),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: _causeController,
                  decoration: InputDecoration(
                    labelText: 'دلیل دیگر',
                    hintText: 'دلیل دیگر',
                  ),
                ),
              ),
              Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ButtonBar(
                    alignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        child: Text('رد خوانش'),
                        onPressed: () {
                          if (_causeController.text.isNotEmpty) {
                            Navigator.of(context).pop(_causeController.text);
                          }
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

import 'package:flutter/material.dart';
import 'package:gaudiopanel/models/recitation/recitation_viewmodel.dart';

class RejectRecitation extends StatefulWidget {
  final RecitationViewModel recitation;

  const RejectRecitation({super.key, required this.recitation});
  @override
  State<StatefulWidget> createState() => _RejectRecitationState();
}

class _RejectRecitationState extends State<RejectRecitation> {
  final TextEditingController _recitationController = TextEditingController();
  final TextEditingController _causeController = TextEditingController();

  @override
  void dispose() {
    _recitationController.dispose();
    _causeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _recitationController.text =
        '${widget.recitation.audioTitle} به خوانش ${widget.recitation.audioArtist}';
    return FocusTraversalGroup(
        child: Form(
            autovalidateMode: AutovalidateMode.always,
            child: Wrap(children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: _recitationController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'خوانش',
                    hintText: 'خوانش',
                  ),
                ),
              ),
              Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.sync_problem),
                    label:
                        const Text('مشکلات فنی از قبیل همگامسازی نادرست دارد'),
                    onPressed: () {
                      Navigator.of(context)
                          .pop('مشکلات فنی از قبیل همگامسازی نادرست دارد');
                    },
                  )),
              Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.menu_book_outlined),
                    label: const Text('خوانش اشکالات ادبی و بیانی دارد'),
                    onPressed: () {
                      Navigator.of(context)
                          .pop('خوانش اشکالات ادبی و بیانی دارد');
                    },
                  )),
              Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.person_off_outlined),
                    label: const Text('خوانش متعلق به ارسال کننده نیست'),
                    onPressed: () {
                      Navigator.of(context)
                          .pop('خوانش متعلق به ارسال کننده نیست');
                    },
                  )),
              Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.voice_over_off_outlined),
                    label: const Text('شرح صوتی نیست'),
                    onPressed: () {
                      Navigator.of(context).pop('شرح صوتی نیست');
                    },
                  )),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: _causeController,
                  decoration: const InputDecoration(
                    labelText: 'دلیل دیگر',
                    hintText: 'دلیل دیگر',
                  ),
                ),
              ),
              Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: OverflowBar(
                    alignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.block),
                        label: const Text('رد خوانش'),
                        onPressed: () {
                          if (_causeController.text.isNotEmpty) {
                            Navigator.of(context).pop(_causeController.text);
                          }
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

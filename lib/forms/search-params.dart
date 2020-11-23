import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

class SearchParams extends StatefulWidget {
  final Tuple2<int, String> sparams;

  const SearchParams({Key key, this.sparams}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _SearchParamsState(this.sparams);
}

class _SearchParamsState extends State<SearchParams> {
  final Tuple2<int, String> sparams;

  TextEditingController _searchController = TextEditingController();

  _SearchParamsState(this.sparams);

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _searchController.text = this.sparams.item2;
    return FocusTraversalGroup(
        child: Form(
            autovalidateMode: AutovalidateMode.always,
            child: Wrap(children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'متن جستجو',
                    hintText: 'متن جستجو',
                  ),
                ),
              ),
              Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ButtonBar(
                    alignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        child: Text('تأیید'),
                        onPressed: () {
                          Navigator.of(context).pop(
                              Tuple2<int, String>(20, _searchController.text));
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

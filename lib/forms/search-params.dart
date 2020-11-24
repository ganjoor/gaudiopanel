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
  int _pageSize;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _searchController.text = this.sparams.item2;
    _pageSize = this.sparams.item1;
  }

  @override
  Widget build(BuildContext context) {
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
                padding: EdgeInsets.all(20.0),
                child: DropdownButtonFormField(
                    value: this.sparams.item1,
                    decoration: InputDecoration(
                      labelText: 'تعداد در هر صفحه',
                    ),
                    items: [
                      DropdownMenuItem(
                        child: Text("20"),
                        value: 20,
                      ),
                      DropdownMenuItem(
                        child: Text("50"),
                        value: 50,
                      ),
                      DropdownMenuItem(child: Text("100"), value: 100),
                      DropdownMenuItem(child: Text("همه"), value: -1)
                    ],
                    onChanged: (value) {
                      setState(() {
                        _pageSize = value;
                      });
                    }),
              ),
              Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ButtonBar(
                    alignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        child: Text('تأیید'),
                        onPressed: () {
                          Navigator.of(context).pop(Tuple2<int, String>(
                              _pageSize, _searchController.text));
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

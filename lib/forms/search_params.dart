import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

class SearchParams extends StatefulWidget {
  final Tuple2<int, String> sparams;

  const SearchParams({super.key, required this.sparams});
  @override
  State<StatefulWidget> createState() => _SearchParamsState();
}

class _SearchParamsState extends State<SearchParams> {
  final TextEditingController _searchController = TextEditingController();

  int _pageSize = 100;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.sparams.item2;
    _pageSize = widget.sparams.item1;
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
                  decoration: const InputDecoration(
                    labelText: 'متن جستجو',
                    hintText: 'متن جستجو',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: DropdownButtonFormField(
                    value: widget.sparams.item1,
                    decoration: const InputDecoration(
                      labelText: 'تعداد در هر صفحه',
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 20,
                        child: Text('20'),
                      ),
                      DropdownMenuItem(
                        value: 50,
                        child: Text('50'),
                      ),
                      DropdownMenuItem(value: 100, child: Text('100')),
                      DropdownMenuItem(value: -1, child: Text('همه'))
                    ],
                    onChanged: (value) {
                      setState(() {
                        _pageSize = int.parse(value.toString());
                      });
                    }),
              ),
              Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ButtonBar(
                    alignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        child: const Text('تأیید'),
                        onPressed: () {
                          Navigator.of(context).pop(Tuple2<int, String>(
                              _pageSize, _searchController.text));
                        },
                      ),
                      TextButton(
                        child: const Text('انصراف'),
                        onPressed: () {
                          Navigator.of(context).pop(null);
                        },
                      )
                    ],
                  )),
            ])));
  }
}

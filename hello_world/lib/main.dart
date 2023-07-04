// import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:hello_world/favor.dart';
import 'package:hello_world/friend.dart';
import 'package:hello_world/mock.dart';
import 'package:flutter/services.dart';
// import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:datetime_picker_formfield_new/datetime_picker_formfield.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      home: FavorsPage(),
    );
  }
}

class FavorsPage extends StatefulWidget {
  const FavorsPage({
    Key? key,
  }) : super(key: key);

  @override
  State<FavorsPage> createState() => _FavorsPageState();
}

class _FavorsPageState extends State<FavorsPage> {
  List<Favor> pendingAnswerFavors = [];
  List<Favor> acceptedFavors = [];
  List<Favor> completedFavors = [];
  List<Favor> refusedFavors = [];

  @override
  void initState() {
    super.initState();
    loadFavors();
  }

  void loadFavors() {
    pendingAnswerFavors.addAll(mockPendingFavors);
    acceptedFavors.addAll(mockDoingFavors);
    completedFavors.addAll(mockCompletedFavors);
    refusedFavors.addAll(mockRefusedFavors);
  }

  void refuseToDo(Favor favor) {
    setState(() {
      pendingAnswerFavors.remove(favor);
      refusedFavors.add(
        favor.copyWith(accepted: false),
      );
    });
  }

  void acceptToDo(Favor favor) {
    setState(() {
      pendingAnswerFavors.remove(favor);
      acceptedFavors.add(favor.copyWith(accepted: true));
    });
  }

  static _FavorsPageState of(BuildContext context) {
    return context.findAncestorStateOfType<_FavorsPageState>()!;
  }

  @override
  Widget build(BuildContext context) {
    // You can use pendingFlavors and requestedFlavors here to build your widget
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Your Favors"),
          bottom: TabBar(tabs: [
            _buildCategoryTab("Requests"),
            _buildCategoryTab("Doing"),
            _buildCategoryTab("Completed"),
            _buildCategoryTab("Refused"),
          ]),
        ),
        body: TabBarView(
          children: [
            FavorsList(title: "Pending Requests", favors: pendingAnswerFavors),
            FavorsList(title: "Doing", favors: acceptedFavors),
            FavorsList(title: "Completed", favors: completedFavors),
            FavorsList(title: "Refused", favors: refusedFavors)
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) {
                  return RequestFavorPage(friends: mockFriends);
                },
              ),
            );
          },
          tooltip: 'Add a favor',
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

Widget _buildCategoryTab(String title) {
  return Tab(
    child: Text(title),
  );
}

class FavorsList extends StatelessWidget {
  final String title;
  final List<Favor> favors;

  const FavorsList({
    Key? key,
    required this.title,
    required this.favors,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: Text(title),
        ),
        Expanded(
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: favors.length,
            itemBuilder: (BuildContext context, int index) {
              final favor = favors[index];
              return FavorCardItem(favor: favor);
            },
          ),
        ),
      ],
    );
  }
}

class FavorCardItem extends StatelessWidget {
  final Favor favor;

  const FavorCardItem({
    Key? key,
    required this.favor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      key: ValueKey(favor.uuid),
      margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 25.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            _itemHeader(favor),
            Text(favor.description ?? ""),
            _itemFooter(favor, context)
          ],
        ),
      ),
    );
  }

  Widget _itemFooter(Favor favor, BuildContext context) {
    if (favor.isCompleted) {
      // final format = DateFormat();
      return Container(
        margin: const EdgeInsets.only(top: 8.0),
        alignment: Alignment.centerRight,
        child: Chip(
          label: Text("Completed at: ${favor.completed}"),
        ),
      );
    }
    if (favor.isRequested) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          ElevatedButton(
            onPressed: () {
              _FavorsPageState.of(context).refuseToDo(favor);
            },
            child: const Text("Refuse"),
          ),
          const SizedBox(
            width: 10,
          ),
          ElevatedButton(
            onPressed: () {
              _FavorsPageState.of(context).acceptToDo(favor);
            },
            child: const Text("Do"),
          )
        ],
      );
    }
    if (favor.isDoing) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          ElevatedButton(
            onPressed: () {},
            child: const Text("give up"),
          ),
          const SizedBox(
            width: 10,
          ),
          ElevatedButton(
            onPressed: () {},
            child: const Text("complete"),
          )
        ],
      );
    }

    return Container();
  }

  Widget _itemHeader(Favor favor) {
    return Row(
      children: <Widget>[
        CircleAvatar(
          backgroundImage: NetworkImage(
            favor.friend?.photoURL ?? "",
          ),
        ),
        Expanded(
          child: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text("${favor.friend?.name ?? ""} asked you to... ")),
        )
      ],
    );
  }
}

class RequestFavorPage extends StatefulWidget {
  final List<Friend>? friends;

  const RequestFavorPage({Key? key, this.friends}) : super(key: key);

  @override
  RequestFavorPageState createState() {
    return RequestFavorPageState();
  }
}

class RequestFavorPageState extends State<RequestFavorPage> {
  final _formKey = GlobalKey<FormState>();
  Friend? _selectedFriend;

  static RequestFavorPageState of(BuildContext context) {
    return context.findAncestorStateOfType<RequestFavorPageState>()!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Requesting a favor"),
        leading: const CloseButton(),
        actions: <Widget>[
          Builder(
            builder: (context) => ElevatedButton(
              child: const Text("SAVE"),
              onPressed: () {
                RequestFavorPageState.of(context).save();
              },
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              DropdownButtonFormField<Friend>(
                value: _selectedFriend,
                onChanged: (friend) {
                  setState(() {
                    _selectedFriend = friend;
                  });
                },
                items: widget.friends!
                    .map(
                      (f) => DropdownMenuItem<Friend>(
                        value: f,
                        child: Text(f.name ?? ""),
                      ),
                    )
                    .toList(),
                validator: (friend) {
                  if (friend == null) {
                    return "You must select a friend to ask the favor";
                  }
                  return null;
                },
              ),
              Container(
                height: 16.0,
              ),
              const Text("Favor description:"),
              TextFormField(
                maxLines: 5,
                inputFormatters: [LengthLimitingTextInputFormatter(200)],
                validator: (value) {
                  if (value?.isEmpty ?? false) {
                    return "You must detail the favor";
                  }
                  return null;
                },
              ),
              Container(
                height: 16.0,
              ),
              const Text("Due Date:"),
              // DateTimePickerFormField(
              //   inputType: InputType.both,
              //   format: DateFormat("EEEE, MMMM d, yyyy 'at' h:mma"),
              //   editable: false,
              //   decoration: InputDecoration(
              //       labelText: 'Date/Time', hasFloatingPlaceholder: false),
              //   validator: (dateTime) {
              //     if (dateTime == null) {
              //       return "You must select a due date time for the favor";
              //     }
              //     return null;
              //   },
              // ),
              DateTimeField(
                decoration: const InputDecoration(labelText: 'Date/Time'),
                format: DateFormat("yyyy-MM-dd HH:mm"),
                onShowPicker: (context, currentValue) async {
                  return await showDatePicker(
                    context: context,
                    firstDate: DateTime(1900),
                    initialDate: currentValue ?? DateTime.now(),
                    lastDate: DateTime(2100),
                  ).then(
                    (DateTime? date) async {
                      if (date != null) {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(
                              currentValue ?? DateTime.now()),
                        );
                        return DateTimeField.combine(date, time);
                      } else {
                        return currentValue;
                      }
                    },
                  );
                },
                validator: (dateTime) {
                  if (dateTime == null) {
                    return "You must select a due date time for the favor";
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void save() {
    if (_formKey.currentState?.validate() ?? false) {
      // store the favor request on firebase
      Navigator.pop(context);
    }
  }
}

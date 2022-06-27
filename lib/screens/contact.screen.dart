import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vimigo/services/json.services.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({Key? key}) : super(key: key);

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final ScrollController _scrollController = ScrollController();
  final List _displayList = [];
  List? _contactsList;
  int takeIndex = 10;
  SharedPreferences? prefs;

  @override
  void initState() {
    super.initState();

    //retrieve json
    setting();

    // scrolling listview to load more data
    _scrollController.addListener(() {
      if (_scrollController.offset ==
          _scrollController.position.maxScrollExtent) {
        if (_displayList.length < _contactsList!.length) {
          loadMoreData();
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/Header.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            title: Row(children: [
              Image.asset(
                'assets/vimigo_single.png',
                height: 70,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(50, 0, 0, 0),
                child: Image.asset(
                  'assets/ConTact_List.png',
                  height: 70,
                  width: 150,
                  fit: BoxFit.fitWidth,
                ),
              )
            ]),
            backgroundColor: Colors.black,
            elevation: 0,
            actions: [
              IconButton(
                  onPressed: (() => setState(() {
                        if (prefs!.getBool('normalTime') == null) {
                          prefs!.setBool('normalTime', true);
                        } else {
                          prefs!.setBool(
                              'normalTime', !prefs!.getBool('normalTime')!);
                        }
                      })),
                  icon: const Icon(
                    Icons.sort,
                    color: Colors.white,
                  ))
            ],
          ),
          body: _contactsList == null
              ? const Center(
                  child: CircularProgressIndicator(
                  color: Colors.black,
                ))
              : RefreshIndicator(
                  color: Colors.black,
                  onRefresh: loadRandomData,
                  child: Column(children: [
                    Expanded(
                      child: ListView.builder(
                          controller: _scrollController,
                          physics: const BouncingScrollPhysics(),
                          itemCount: _displayList.length + 1,
                          itemBuilder: (context, index) {
                            if (index < _displayList.length) {
                              return ListTile(
                                title: Row(
                                  children: [
                                    Expanded(
                                      flex: 9,
                                      child: Text(
                                        _displayList[index]['user'],
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      setTime(_displayList[index]['check-in']),
                                      style: const TextStyle(
                                          color: Colors.black38, fontSize: 14),
                                    ),
                                  ],
                                ),
                                subtitle: Text(_displayList[index]['phone']),
                                trailing: IconButton(
                                  onPressed: () {
                                    Share.share(_displayList[index].toString());
                                  },
                                  icon: const Icon(Icons.share_outlined),
                                ),
                              );
                            } else {
                              return Center(
                                child: Padding(
                                    padding: const EdgeInsets.only(
                                        top: 10, bottom: 50),
                                    child: index >= _contactsList!.length
                                        ? const Text(
                                            "You have reached end of the list")
                                        : const CircularProgressIndicator(
                                            color: Colors.black,
                                          )),
                              );
                            }
                          }),
                    ),
                  ]),
                )),
    );
  }

  setting() async {
    //declare sharedpreferences
    prefs = await SharedPreferences.getInstance();

    //load up json data
    _contactsList = await JsonServices.loadJsonData("assets/contacts.json");

    //sort contact up to recent
    _contactsList!.sort((b, a) {
      return (a['check-in']).compareTo(b['check-in']);
    });

    _displayList.addAll(_contactsList!.take(10));
    setState(() {});
  }

  loadMoreData() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _displayList.addAll(_contactsList!.getRange(takeIndex, takeIndex + 5));
      takeIndex += 5;
    });
  }

  setTime(String time) {
    DateTime dateTime = DateTime.parse(time);
    if (prefs!.getBool('normalTime') != null && prefs!.getBool('normalTime')!) {
      return DateFormat.yMd().format(dateTime);
    }
    return timeago.format(dateTime);
  }

  Future loadRandomData() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      int last = _contactsList!.length;
      for (var i = 0; i < 5; i++) {
        int index = Random().nextInt(last);
        _displayList.add(_contactsList![index]);
        _contactsList!.add(_contactsList![index]);
      }
    });
  }
}

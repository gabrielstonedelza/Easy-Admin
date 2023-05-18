import 'dart:convert';
import 'package:easy_admin/widget/loadingui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

import '../../constants.dart';


class Complains extends StatefulWidget {
  const Complains({Key? key}) : super(key: key);

  @override
  State<Complains> createState() => _ComplainsState();
}

class _ComplainsState extends State<Complains> {
  final storage = GetStorage();
  late String username = "";
  late String uToken = "";
  var items;
  bool isLoading = true;
  List complains = [];



  Future<void> getAllComplains() async {
    const url = "https://fnetagents.xyz/get_all_complains/";
    var myLink = Uri.parse(url);
    final response =
    await http.get(myLink, headers: {"Authorization": "Token $uToken"});
    if (response.statusCode == 200) {
      final codeUnits = response.body.codeUnits;
      var jsonData = const Utf8Decoder().convert(codeUnits);
      complains = json.decode(jsonData);
      setState(() {
        isLoading = false;
      });
    } else {
      if (kDebugMode) {
        // print(response.body);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    if (storage.read("token") != null) {
      setState(() {
        uToken = storage.read("token");
      });
    }
    getAllComplains();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Complains"),
        backgroundColor: secondaryColor,
      ),
      body: isLoading
          ? const LoadingUi()
          : ListView.builder(
        itemCount: complains != null ? complains.length : 0,
        itemBuilder: (context, index) {
          items = complains[index];
          return Card(
            elevation: 12,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
              child: ListTile(
                title: Row(
                  children: [
                    const Text("Agent : ",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        )),
                    Text(items['get_agent_username'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        )),
                  ],
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 18.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 18.0),
                        child: Row(
                          children: [
                            const Text("Title :",style: TextStyle(
                              fontWeight: FontWeight.bold,
                            )),
                            Text(items['title'],style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            )),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 18.0),
                        child: Row(
                          children: [
                            const Text("Complain : ",style: TextStyle(
                              fontWeight: FontWeight.bold,
                            )),
                            Text(items['complain'],style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            )),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 18.0),
                        child: Row(
                          children: [
                            const Text("Date : ",style:TextStyle(fontWeight: FontWeight.bold)),
                            Text(items['date_added'].toString().split("T").first),
                          ],
                        ),
                      ),

                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),

    );
  }
}

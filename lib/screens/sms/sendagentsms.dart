import 'dart:convert';

import 'package:easy_admin/constants.dart';
import 'package:flutter/material.dart' hide ModalBottomSheetRoute;
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import '../../sendsms.dart';
import '../../widget/loadingui.dart';


class SendAgentsSms extends StatefulWidget {
  const SendAgentsSms({Key? key}) : super(key: key);

  @override
  State<SendAgentsSms> createState() => _SendAgentsSmsState();
}

class _SendAgentsSmsState extends State<SendAgentsSms> {
  final storage = GetStorage();
  bool hasToken = false;
  late String uToken = "";
  bool isLoading = true;
  late List allAgents = [];
  late List selectedItems = [];
  late List selectedAll = [];
  var items;
  bool isSelectedAll = false;
  final SendSmsController sendSms = SendSmsController();
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController messageController = TextEditingController();

  fetchAgents() async {
    const url = "https://fnetagents.xyz/get_all_agents/";
    var myLink = Uri.parse(url);
    final response =
    await http.get(myLink, headers: {"Authorization": "Token $uToken"});

    if (response.statusCode == 200) {
      final codeUnits = response.body.codeUnits;
      var jsonData = const Utf8Decoder().convert(codeUnits);
      allAgents = json.decode(jsonData);
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    if (storage.read("token") != null) {
      setState(() {
        hasToken = true;
        uToken = storage.read("token");
      });
    }
    fetchAgents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Send sms"),
        backgroundColor: secondaryColor,
        actions: [
          TextButton(
            onPressed: () {
              for (var i in allAgents) {
                if (!selectedAll.contains(i['phone_number'])) {
                  setState(() {
                    selectedAll.add(i['phone_number']);
                    isSelectedAll = true;
                  });
                } else {
                  setState(() {
                    selectedAll.remove(i['phone_number']);
                    isSelectedAll = false;
                  });
                }
              }
            },
            child: isSelectedAll
                ? Text("Unselect All (${selectedAll.length})",
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.white))
                : Text("Select All (${allAgents.length})",
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.white)),
          )
        ],
      ),
      body: isLoading  ? const LoadingUi() : ListView.builder(
          itemCount: allAgents != null ? allAgents.length : 0,
          itemBuilder: (context, index) {
            items = allAgents[index];
            return Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8),
              child: Card(
                  elevation: 12,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    onTap: () {
                      if (!selectedAll.contains(allAgents[index]['phone_number'])) {
                        setState(() {
                          selectedAll.add(allAgents[index]['phone_number']);
                        });
                      } else {
                        setState(() {
                          selectedAll.remove(allAgents[index]['phone_number']);
                        });
                      }
                    },
                    leading: const CircleAvatar(
                      backgroundColor: secondaryColor,
                      radius: 30,
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                    title: Text(items['username'],
                        style:
                        const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(items['phone_number']),
                    trailing: selectedAll.contains(allAgents[index]['phone_number'])
                        ? const Icon(Icons.check_box)
                        : const Icon(Icons.check_box_outline_blank),
                  )),
            );
          }),
      floatingActionButton: selectedAll.isNotEmpty
          ? FloatingActionButton(
          backgroundColor: secondaryColor,
          onPressed: () {
            showMaterialModalBottomSheet(
              context: context,
              isDismissible: true,
              enableDrag: false,
              shape: const RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.vertical(top: Radius.circular(25.0))),
              builder: (context) => Padding(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom),
                child: SingleChildScrollView(
                  controller: ModalScrollController.of(context),
                  child: SizedBox(
                    height: 350,
                    child: ListView(
                      children: [
                        const Center(
                            child: Text("Enter message and hit send",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ))),
                        Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                    bottom: 10.0,
                                    left: 10,
                                    right: 10,
                                    top: 10),
                                child: TextFormField(
                                  autofocus: true,
                                  controller: messageController,
                                  cursorColor: Colors.black,
                                  cursorRadius:
                                  const Radius.elliptical(5, 5),
                                  cursorWidth: 5,
                                  maxLines: 10,
                                  keyboardType: TextInputType.multiline,
                                  decoration: InputDecoration(
                                    focusColor: primaryColor,
                                    // fillColor: Colors.white,
                                    focusedBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                            color: Colors.black, width: 2),
                                        borderRadius:
                                        BorderRadius.circular(12)),
                                    // border: OutlineInputBorder(
                                    //     borderRadius: BorderRadius.circular(12))
                                  ),
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return "Please enter message";
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              Padding(
                                  padding: const EdgeInsets.only(
                                      left: 18.0, right: 18),
                                  child: RawMaterialButton(
                                    onPressed: () {
                                      if (!_formKey.currentState!
                                          .validate()) {
                                        Get.snackbar(
                                            "Error", "Something went wrong",
                                            colorText: defaultWhite,
                                            snackPosition:
                                            SnackPosition.BOTTOM,
                                            backgroundColor: warning);
                                        return;
                                      } else {
                                        for(var i in selectedAll){
                                          String telnum = i;
                                          telnum = telnum.replaceFirst("0", '+233');
                                          sendSms.sendMySms(telnum, "EasyAgent",messageController.text.trim());
                                          Get.snackbar(
                                              "Success", "message sent",
                                              colorText: defaultWhite,
                                              snackPosition:
                                              SnackPosition.BOTTOM,
                                              duration:const Duration(seconds:5),
                                              backgroundColor: secondaryColor);
                                          setState(() {
                                            messageController.text = "";
                                            selectedAll.clear();
                                          });
                                          Navigator.pop(context);
                                        }
                                      }
                                    },
                                    // child: const Text("Send"),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(8)),
                                    elevation: 8,
                                    fillColor: secondaryColor,
                                    splashColor: defaultWhite,
                                    child: const Text(
                                      "Send",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                          color: defaultWhite),
                                    ),
                                  ))
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
          child: const Icon(Icons.upload))
          : Container(),
    );
  }
}
